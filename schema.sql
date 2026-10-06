begin;
create table if not exists public.records (
 owner uuid not null references auth.users(id) on delete cascade,
 id text not null,
 kind text not null check (kind in ('class','student','lesson','activity','assessment','grade','schedule','event','weekly')),
 data jsonb not null,
 primary key(owner,id),
 check (jsonb_typeof(data)='object' and octet_length(data::text)<100000),
 check (id=data->>'id' and kind=data->>'kind')
);
alter table public.records enable row level security;
revoke all on public.records from anon;
grant select,insert,update,delete on public.records to authenticated;
drop policy if exists own_records on public.records;
create policy own_records on public.records for all to authenticated using ((select auth.uid())=owner) with check ((select auth.uid())=owner);
create or replace function public.validate_caderno_record() returns trigger language plpgsql set search_path=public as $$
declare cid text; ids jsonb; a jsonb; s jsonb; requested date; due date;
begin
 if new.kind <> 'grade' and coalesce(trim(new.data->>'title'),'')='' then raise exception 'Preencha o título ou nome.'; end if;
 if new.kind in ('lesson','activity') then
 ids := coalesce(new.data->'classIds',jsonb_build_array(new.data->>'classId'));
 if jsonb_typeof(ids)<>'array' or jsonb_array_length(ids)=0 then raise exception 'Selecione uma ou mais turmas.'; end if;
 for cid in select jsonb_array_elements_text(ids) loop
 if not exists(select 1 from public.records where owner=new.owner and id=cid and kind='class') then raise exception 'Turma inválida.'; end if;
 end loop;
 new.data := jsonb_set(jsonb_set(new.data,'{classIds}',ids),'{classId}',ids->0);
 elsif new.kind<>'class' and not(new.kind='event' and coalesce(new.data->>'classId','')='') then
 if not exists(select 1 from public.records where owner=new.owner and id=new.data->>'classId' and kind='class') then raise exception 'Turma inválida.'; end if;
 end if;
 if new.kind='activity' then
 requested := coalesce(new.data->>'requestedDate',new.data->>'date')::date;
 if requested is null then raise exception 'Informe a data de solicitação.'; end if;
 if new.data ? 'dueDate' then due := (new.data->>'dueDate')::date; if due is null or due<requested then raise exception 'A entrega deve ocorrer após a solicitação ou no mesmo dia.'; end if; end if;
 new.data := jsonb_set(jsonb_set(new.data,'{requestedDate}',to_jsonb(requested::text)),'{date}',to_jsonb(requested::text));
 end if;
 if new.kind='assessment' then
 if coalesce((new.data->>'max')::numeric,0)<=0 or coalesce((new.data->>'weight')::numeric,0)<=0 then raise exception 'Valor e peso devem ser positivos.'; end if;
 if exists(select 1 from public.records where owner=new.owner and kind='grade' and data->>'assessmentId'=new.id and ((data->>'value')::numeric>(new.data->>'max')::numeric or data->>'classId'<>new.data->>'classId')) then raise exception 'Alteração incompatível com notas já lançadas.'; end if;
 end if;
 if new.kind='grade' then
 select data into a from public.records where owner=new.owner and kind='assessment' and id=new.data->>'assessmentId';
 select data into s from public.records where owner=new.owner and kind='student' and id=new.data->>'studentId';
 if a is null or s is null or a->>'classId'<>new.data->>'classId' or s->>'classId'<>new.data->>'classId' or new.id<>concat(new.data->>'assessmentId',':',new.data->>'studentId') or coalesce(new.data->>'value','')='' or (new.data->>'value')::numeric<0 or (new.data->>'value')::numeric>(a->>'max')::numeric then raise exception 'Nota inválida para esta turma e avaliação.'; end if;
 end if;
 if new.kind='student' and tg_op='UPDATE' and old.data->>'classId'<>new.data->>'classId' and exists(select 1 from public.records where owner=new.owner and kind='grade' and data->>'studentId'=new.id) then raise exception 'Mantenha a turma do aluno com notas lançadas.'; end if;
 if new.kind='weekly' then
 if extract(isodow from (new.data->>'week')::date)<>1 or new.id<>concat('weekly:',new.data->>'week',':',new.data->>'classId') or coalesce(trim(new.data->>'content'),'')='' then raise exception 'Semana ou resumo inválidos.'; end if;
 end if;
 if new.kind='event' then
 if (new.data->>'date')::date is null then raise exception 'Informe a data.'; end if;
 end if;
 if new.kind='schedule' then
 if (new.data->>'day')::integer not between 0 and 6 or (new.data->>'start')::time >= (new.data->>'end')::time then raise exception 'Horário inválido.'; end if;
 end if;
 return new;
end;
$$;
drop trigger if exists validate_caderno on public.records;
create trigger validate_caderno before insert or update on public.records for each row execute function public.validate_caderno_record();
commit;

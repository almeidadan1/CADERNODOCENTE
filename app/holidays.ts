export type Holiday={id:string;kind:'holiday';title:string;date:string;scope:string};
export function holidaysForYear(year:number):Holiday[]{
 const key=(m:number,d:number)=>`${year}-${String(m).padStart(2,'0')}-${String(d).padStart(2,'0')}`;
 const fixed:[number,number,string,string][]=[[1,1,'Confraternização Universal','Nacional'],[1,25,'Aniversário de São Paulo','Municipal · São Paulo'],[4,21,'Tiradentes','Nacional'],[5,1,'Dia do Trabalho','Nacional'],[7,9,'Revolução Constitucionalista','Estadual · São Paulo'],[9,7,'Independência do Brasil','Nacional'],[10,12,'Nossa Senhora Aparecida','Nacional'],[11,2,'Finados','Nacional'],[11,15,'Proclamação da República','Nacional'],[11,20,'Dia de Zumbi e da Consciência Negra','Nacional'],[12,25,'Natal','Nacional']];
 const a=year%19,b=Math.floor(year/100),c=year%100,d=Math.floor(b/4),e=b%4,f=Math.floor((b+8)/25),g=Math.floor((b-f+1)/3),h=(19*a+b-d-g+15)%30,i=Math.floor(c/4),k=c%4,l=(32+2*e+2*i-h-k)%7,m=Math.floor((a+11*h+22*l)/451),month=Math.floor((h+l-7*m+114)/31),day=(h+l-7*m+114)%31+1;
 const easter=new Date(Date.UTC(year,month-1,day,12));
 const moving=(offset:number,title:string)=>{const date=new Date(easter);date.setUTCDate(date.getUTCDate()+offset);return {id:'holiday:'+date.toISOString().slice(0,10),kind:'holiday' as const,title,date:date.toISOString().slice(0,10),scope:'Municipal · São Paulo'};};
 return [...fixed.map(([month,day,title,scope])=>({id:'holiday:'+key(month,day),kind:'holiday' as const,title,date:key(month,day),scope})),moving(-2,'Paixão de Cristo'),moving(60,'Corpus Christi')].sort((a,b)=>a.date.localeCompare(b.date));
}

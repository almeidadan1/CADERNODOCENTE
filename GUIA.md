# Caderno Docente — Vercel + Supabase

Esta versão usa login próprio por e-mail e senha. A sessão fica guardada no navegador; entrar com a mesma conta em outro dispositivo permite acessar seus dados salvos online.

O pacote já foi compilado. A conexão real e as regras SQL ainda precisam ser verificadas no seu projeto Supabase antes de usar com dados reais.

## 1. Criar o Supabase

1. Abra https://supabase.com/dashboard e crie sua conta (pode usar GitHub).
2. Crie um projeto. Guarde a senha do banco no seu gerenciador de senhas; ela não é necessária no aplicativo.
3. Abra SQL Editor, crie uma consulta, copie todo o conteúdo de `supabase/schema.sql` e execute.
4. Abra Authentication > Users e crie seu usuário com e-mail e senha. Confirme o e-mail conforme as opções do painel. Para este caderno pessoal, desative novos cadastros públicos nas configurações de Authentication.
5. Copie a URL do projeto e a chave **publishable** (ou a chave pública **anon** legada), disponíveis nas configurações/API do projeto. Não use `service_role`, secret key ou senha do banco no aplicativo.

## 2. Publicar no Vercel

1. Extraia este ZIP.
2. Crie um novo repositório no GitHub e envie os arquivos da pasta extraída. `package.json`, `index.html` e `vite.config.ts` devem estar na raiz. Não envie `node_modules`, `.env` nem dados pessoais.
3. No Vercel, importe esse repositório como projeto novo. Framework: Vite. Comando de build: `npm run build`. Pasta de saída: `dist`.
4. Antes de publicar, cadastre as variáveis de ambiente:
   - `VITE_SUPABASE_URL`: URL do projeto Supabase.
   - `VITE_SUPABASE_PUBLISHABLE_KEY`: chave pública publishable (ou anon).
5. Publique. Ao mudar variáveis, publique novamente.
6. Abra o endereço do Vercel e entre com o e-mail e a senha criados em Authentication.

## 3. Transferir seus registros

1. No caderno antigo, ainda conectado ao ChatGPT, clique em **Baixar backup**.
2. No caderno novo, entre com sua conta própria e clique em **Importar backup**.
3. Selecione o JSON baixado. A importação mantém os identificadores e pode ser repetida sem duplicar registros. Se ocorrer um erro, os registros anteriores ao erro podem já estar salvos; a mensagem informa quantos.
4. Confira turmas, alunos, planos, atividades, notas, horários, calendário e semanário.
5. Teste no celular e no computador com a mesma conta antes de passar a usar exclusivamente o caderno novo.

O caderno antigo continua disponível. A importação é uma transferência pontual: alterações futuras em um não atualizam o outro.

## Verificação inicial

- Crie duas turmas de teste, um aluno e um plano para ambas.
- Crie uma atividade com solicitação e entrega e confira as duas datas no calendário.
- Crie avaliação de valor 10, lance nota 8 e confira a média.
- Escreva um resumo no semanário, salve e recarregue.
- Saia e confirme que é preciso entrar para acessar os dados.
- Abra no outro dispositivo e confira os mesmos registros.

## Desenvolvimento local

Node.js 24 é recomendado. Rode `npm install`, copie `.env.example` como `.env.local`, preencha somente a URL e a chave pública, e rode `npm run dev`.

## Fontes oficiais

- Vite no Vercel: https://vercel.com/docs/frameworks/frontend/vite
- Variáveis: https://vercel.com/docs/environment-variables/managing-environment-variables
- Chaves Supabase: https://supabase.com/docs/guides/getting-started/api-keys
- Segurança por usuário: https://supabase.com/docs/guides/database/postgres/row-level-security
- Login por senha: https://supabase.com/docs/guides/auth/passwords

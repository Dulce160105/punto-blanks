-- =====================================================================
-- PUNTO BLANKS · Esquema de Supabase
-- Cómo usarlo: Supabase → SQL Editor → New query → pegar TODO → Run.
-- Es seguro ejecutarlo más de una vez.
-- =====================================================================

-- 1) Tabla principal: un documento por usuario con todos los datos del sistema
create table if not exists public.app_state (
  user_id    uuid primary key references auth.users (id) on delete cascade,
  data       jsonb not null,
  updated_at timestamptz not null default now(),
  constraint app_state_es_objeto check (jsonb_typeof(data) = 'object'),
  constraint app_state_tamano    check (pg_column_size(data) < 5000000)
);

-- 2) Historial de respaldos automáticos (una copia por sesión de trabajo, 60 días)
create table if not exists public.app_state_history (
  id       bigint generated always as identity primary key,
  user_id  uuid not null references auth.users (id) on delete cascade,
  data     jsonb not null,
  saved_at timestamptz not null default now()
);
create index if not exists app_state_history_user_idx
  on public.app_state_history (user_id, saved_at desc);

-- 3) Trigger: fecha de modificación fiable (la pone el servidor) + respaldo
create or replace function public.app_state_before_write()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE' and old.updated_at < now() - interval '1 hour' then
    insert into public.app_state_history (user_id, data, saved_at)
    values (old.user_id, old.data, old.updated_at);
    delete from public.app_state_history
     where user_id = old.user_id and saved_at < now() - interval '60 days';
  end if;
  new.updated_at := now();
  return new;
end;
$$;
revoke all on function public.app_state_before_write() from public, anon, authenticated;

drop trigger if exists app_state_write on public.app_state;
create trigger app_state_write
  before insert or update on public.app_state
  for each row execute function public.app_state_before_write();

-- 4) Seguridad por filas (RLS): cada usuario SOLO ve y modifica lo suyo
alter table public.app_state         enable row level security;
alter table public.app_state_history enable row level security;

revoke all on public.app_state         from anon;
revoke all on public.app_state_history from anon;
grant select, insert, update, delete on public.app_state to authenticated;
grant select                         on public.app_state_history to authenticated;

drop policy if exists "estado: leer lo propio"       on public.app_state;
drop policy if exists "estado: crear lo propio"      on public.app_state;
drop policy if exists "estado: actualizar lo propio" on public.app_state;
drop policy if exists "estado: borrar lo propio"     on public.app_state;
drop policy if exists "historial: leer lo propio"    on public.app_state_history;

create policy "estado: leer lo propio" on public.app_state
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "estado: crear lo propio" on public.app_state
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "estado: actualizar lo propio" on public.app_state
  for update to authenticated
  using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "estado: borrar lo propio" on public.app_state
  for delete to authenticated using ((select auth.uid()) = user_id);
create policy "historial: leer lo propio" on public.app_state_history
  for select to authenticated using ((select auth.uid()) = user_id);

-- 5) Restaurar un respaldo (SOLO si lo necesita; ejecútelo a mano en el SQL Editor):
--   a) Ver respaldos disponibles:
--      select id, saved_at, pg_column_size(data) as bytes
--        from public.app_state_history order by saved_at desc limit 20;
--   b) Restaurar el respaldo con id = 123 (cambie el número):
--      update public.app_state s set data = h.data
--        from public.app_state_history h
--       where h.id = 123 and h.user_id = s.user_id;

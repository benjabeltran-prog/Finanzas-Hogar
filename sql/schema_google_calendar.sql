-- ============================================================
-- INTEGRACIÓN CON GOOGLE CALENDAR (calendario compartido del hogar)
-- Guarda el token de la cuenta de Google que conectó el hogar, y
-- el id del calendario secundario que se crea para las actividades.
-- Esta tabla NUNCA es legible por los clientes (ni siquiera los
-- miembros del hogar) — solo la tocan las Edge Functions con la
-- service_role key. Por eso no tiene ninguna policy de RLS.
-- ============================================================

create table if not exists household_google_calendar (
  household_id uuid primary key references households(id) on delete cascade,
  google_calendar_id text not null,
  refresh_token text not null,
  access_token text,
  token_expires_at timestamptz,
  connected_by_email text,
  created_at timestamptz default now()
);

alter table household_google_calendar enable row level security;
-- Sin policies = ningún cliente (anon/authenticated) puede leer ni escribir esto.
-- Solo las Edge Functions (que usan la service_role key) pueden acceder.

-- El id del evento correspondiente en Google Calendar, para poder
-- actualizarlo/borrarlo después sin crear uno duplicado.
alter table household_events add column if not exists google_event_id text;

-- Función segura para que la app pregunte "¿este hogar ya conectó
-- Google Calendar?" sin poder leer los tokens (la tabla de arriba
-- sigue sin ninguna policy, así que esto es lo único expuesto).
create or replace function is_google_calendar_connected(hh_id uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists(select 1 from household_google_calendar where household_id = hh_id);
$$;

grant execute on function is_google_calendar_connected(uuid) to authenticated;

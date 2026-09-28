-- ============================================================
-- FIX: permitir "unirse a un hogar" buscando por código
-- Antes, RLS bloqueaba ver un hogar si aún no eras miembro,
-- incluso sabiendo el código exacto. Esta función expone solo
-- lo mínimo (id, nombre) para poder unirse.
-- ============================================================
create or replace function find_household_by_code(code text)
returns table(id uuid, name text)
language sql
security definer
set search_path = public
as $$
  select h.id, h.name from households h where h.join_code = code;
$$;

grant execute on function find_household_by_code(text) to authenticated;

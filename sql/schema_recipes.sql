-- ============================================================
-- PLANIFICADOR DE COMIDAS
-- Recetas guardadas que se pueden agregar de un clic a la
-- lista de compras (un ingrediente por línea).
-- ============================================================

create table if not exists recipes (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  name text not null,
  ingredients text not null,
  created_at timestamptz default now()
);

alter table recipes enable row level security;
create policy "recipes_all" on recipes for all
  using (is_member_of(household_id)) with check (is_member_of(household_id));

-- ============================================================
-- INVENTARIO DEL HOGAR
-- Lleva el stock de productos recurrentes (ok / bajo / agotado).
-- Al quedar "agotado", se agrega solo a la lista de compras.
-- Al comprarlo y marcarlo, el inventario vuelve a "ok" solo.
-- ============================================================

create table if not exists household_inventory (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  name text not null,
  status text not null default 'ok' check (status in ('ok', 'low', 'out')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

alter table household_inventory enable row level security;
create policy "household_inventory_all" on household_inventory for all
  using (is_member_of(household_id)) with check (is_member_of(household_id));

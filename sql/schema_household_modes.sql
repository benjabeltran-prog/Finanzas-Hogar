-- ============================================================
-- MODOS DE HOGAR: "conjunto" (todo compartido) vs "separado"
-- (ingresos privados/compartidos caso a caso, gastos con
-- responsable asignado). Ejecutar una sola vez.
-- ============================================================

-- 1) Modo del hogar (se define al crearlo, queda fijo)
alter table households add column if not exists mode text not null default 'joint' check (mode in ('joint','separate'));

-- 2) Ingresos: quién lo ingresó + si se comparte con el resto del hogar
alter table incomes add column if not exists owner_user_id uuid references auth.users(id);
alter table incomes add column if not exists is_shared boolean not null default true;

-- 3) Gastos: quién se hace cargo (solo se usa/pide en hogares separados)
alter table fixed_expenses add column if not exists responsible_user_id uuid references auth.users(id);
alter table extra_expenses add column if not exists responsible_user_id uuid references auth.users(id);

-- 4) RLS de incomes: reemplazamos la política única por 4,
--    para poder aplicar privacidad en el SELECT.
drop policy if exists "incomes_all" on incomes;

create policy "incomes_select" on incomes for select
  using (
    is_member_of(household_id)
    and (
      (select mode from households where id = incomes.household_id) = 'joint'
      or owner_user_id = auth.uid()
      or is_shared = true
      or owner_user_id is null  -- filas creadas antes de este cambio, sin dueño asignado
    )
  );

create policy "incomes_insert" on incomes for insert
  with check (is_member_of(household_id));

create policy "incomes_update" on incomes for update
  using (
    is_member_of(household_id)
    and (
      (select mode from households where id = incomes.household_id) = 'joint'
      or owner_user_id = auth.uid()
      or owner_user_id is null
    )
  )
  with check (is_member_of(household_id));

create policy "incomes_delete" on incomes for delete
  using (
    is_member_of(household_id)
    and (
      (select mode from households where id = incomes.household_id) = 'joint'
      or owner_user_id = auth.uid()
      or owner_user_id is null
    )
  );

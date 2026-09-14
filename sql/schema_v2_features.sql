-- ============================================================
-- PAQUETE DE MEJORAS: presupuestos, recurrencia en actividades,
-- registro de actividad del hogar.
-- (Recuperar contraseña no necesita SQL, ya lo trae Supabase Auth)
-- ============================================================

-- 1) PRESUPUESTOS POR CATEGORÍA (tarjeta de crédito)
create table if not exists category_budgets (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  category text not null,
  monthly_limit numeric not null,
  created_at timestamptz default now(),
  unique(household_id, category)
);
alter table category_budgets enable row level security;
create policy "category_budgets_all" on category_budgets for all
  using (is_member_of(household_id)) with check (is_member_of(household_id));

-- 2) ACTIVIDADES RECURRENTES (Planificación)
alter table household_events add column if not exists recurrence text not null default 'none' check (recurrence in ('none', 'daily', 'weekly', 'monthly'));

-- 3) REGISTRO DE ACTIVIDAD DEL HOGAR
create table if not exists activity_log (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  user_email text,
  action text not null,
  created_at timestamptz default now()
);
alter table activity_log enable row level security;
create policy "activity_log_all" on activity_log for all
  using (is_member_of(household_id)) with check (is_member_of(household_id));

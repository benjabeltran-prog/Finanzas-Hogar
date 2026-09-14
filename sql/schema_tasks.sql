-- ============================================================
-- TAREAS DEL HOGAR
-- Tareas asignables a integrantes, con prioridad, fecha límite
-- y repetición (diaria/semanal/mensual).
-- ============================================================

create table if not exists household_tasks (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  title text not null,
  description text,
  assigned_to uuid references auth.users(id),
  due_date date,
  priority text not null default 'media' check (priority in ('baja', 'media', 'alta')),
  is_completed boolean not null default false,
  completed_at timestamptz,
  recurrence text not null default 'none' check (recurrence in ('none', 'daily', 'weekly', 'monthly')),
  created_by uuid references auth.users(id),
  created_at timestamptz default now()
);

alter table household_tasks enable row level security;
create policy "household_tasks_all" on household_tasks for all
  using (is_member_of(household_id)) with check (is_member_of(household_id));

-- ============================================================
-- COLUMNAS PERSONALIZABLES DEL TABLERO DE TAREAS
-- Reemplaza el status fijo (todo/in_progress/done) por columnas
-- que cada hogar puede nombrar y agregar libremente.
-- ============================================================

create table if not exists task_columns (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references households(id) on delete cascade,
  name text not null,
  position integer not null default 0,
  created_at timestamptz default now()
);

alter table task_columns enable row level security;
create policy "task_columns_all" on task_columns for all
  using (is_member_of(household_id)) with check (is_member_of(household_id));

alter table household_tasks add column if not exists column_id uuid references task_columns(id);

-- Para cada hogar que ya tiene tareas (creadas antes de este cambio),
-- se crean sus 3 columnas por defecto y se migran las tareas existentes
-- según su status anterior.
do $$
declare
  h record;
  col_todo uuid;
  col_progress uuid;
  col_done uuid;
begin
  for h in select distinct household_id from household_tasks loop
    if exists (select 1 from task_columns where household_id = h.household_id) then
      continue;
    end if;

    insert into task_columns (household_id, name, position) values (h.household_id, 'To Do', 0) returning id into col_todo;
    insert into task_columns (household_id, name, position) values (h.household_id, 'En Progreso', 1) returning id into col_progress;
    insert into task_columns (household_id, name, position) values (h.household_id, 'Lista', 2) returning id into col_done;

    update household_tasks set column_id = col_todo where household_id = h.household_id and status = 'todo';
    update household_tasks set column_id = col_progress where household_id = h.household_id and status = 'in_progress';
    update household_tasks set column_id = col_done where household_id = h.household_id and status = 'done';
  end loop;
end $$;

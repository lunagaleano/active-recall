-- Active Recall · esquema para Supabase (PostgreSQL)
-- Pegalo completo en Supabase > SQL Editor > Run

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  nombre text not null,
  apellido text not null,
  email text not null,
  created_at timestamptz not null default now()
);

create table public.materias (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nombre text not null,
  descripcion text,
  color text not null default '#4f46e5',
  created_at timestamptz not null default now()
);

create table public.tareas (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  materia_id uuid not null references public.materias(id) on delete cascade,
  titulo text not null,
  descripcion text,
  prioridad text not null default 'media' check (prioridad in ('baja','media','alta')),
  estado text not null default 'pendiente' check (estado in ('pendiente','en_proceso','completada')),
  fecha_limite date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.actividades (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  materia_id uuid not null references public.materias(id) on delete cascade,
  titulo text not null,
  descripcion text,
  tipo text not null check (tipo in ('examen','entrega')),
  fecha date not null,
  hora time,
  created_at timestamptz not null default now()
);

-- Un recordatorio apunta a una tarea O a una actividad (examen/entrega)
create table public.recordatorios (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users(id) on delete cascade,
  tarea_id uuid references public.tareas(id) on delete cascade,
  actividad_id uuid references public.actividades(id) on delete cascade,
  dias_antes int not null check (dias_antes in (1,2,7)),
  fecha_hora timestamptz not null,
  estado text not null default 'pendiente' check (estado in ('pendiente','vista')),
  created_at timestamptz not null default now(),
  check (num_nonnulls(tarea_id, actividad_id) = 1)
);

create index on public.materias(user_id);
create index on public.tareas(user_id, fecha_limite);
create index on public.actividades(user_id, fecha);
create index on public.recordatorios(user_id, fecha_hora);

-- Crea el perfil automáticamente al registrarse
create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id, nombre, apellido, email)
  values (new.id,
          coalesce(new.raw_user_meta_data->>'nombre',''),
          coalesce(new.raw_user_meta_data->>'apellido',''),
          new.email);
  return new;
end $$;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- Row Level Security: cada usuario solo ve y modifica lo suyo
alter table public.profiles enable row level security;
alter table public.materias enable row level security;
alter table public.tareas enable row level security;
alter table public.actividades enable row level security;
alter table public.recordatorios enable row level security;

create policy "perfil propio" on public.profiles for all
  using (id = auth.uid()) with check (id = auth.uid());

create policy "materias propias" on public.materias for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

-- tareas/actividades: además, la materia debe ser del mismo usuario
create policy "tareas propias" on public.tareas for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid() and exists (
    select 1 from public.materias m where m.id = materia_id and m.user_id = auth.uid()));

create policy "actividades propias" on public.actividades for all
  using (user_id = auth.uid())
  with check (user_id = auth.uid() and exists (
    select 1 from public.materias m where m.id = materia_id and m.user_id = auth.uid()));

create policy "recordatorios propios" on public.recordatorios for all
  using (user_id = auth.uid()) with check (user_id = auth.uid());

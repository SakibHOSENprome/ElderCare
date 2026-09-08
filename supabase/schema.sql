-- ============================================================
-- ElderCare — Complete Supabase Schema (single file)
--
-- This is the ONLY SQL file you need. It replaces every previous
-- schema.sql / add_*.sql / fix_*.sql file.
--
-- Safe to run on:
--   - a brand new Supabase project, OR
--   - a project that already ran any earlier version of this schema
--     (every table, column, function, trigger and policy is created
--     with "if not exists" / "or replace" / "drop ... if exists",
--     so re-running this file never errors out).
--
-- Run in: Supabase Dashboard -> SQL Editor -> New query -> paste this
-- whole file -> Run.
-- ============================================================

create extension if not exists "uuid-ossp";

-- ------------------------------------------------------------
-- PROFILES  (extends auth.users)
-- ------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  email text not null,
  phone text,
  role text not null default 'elder' check (role in ('elder','caregiver')),
  created_at timestamptz not null default now()
);

-- Columns added by later iterations of the app — safe no-ops if a
-- fresh install already created them above.
alter table public.profiles
  add column if not exists age int,
  add column if not exists gender text,
  add column if not exists blood_group text,
  add column if not exists medical_condition text,
  add column if not exists avatar_url text,
  add column if not exists linked_elder_id uuid references public.profiles(id),
  add column if not exists experience text,
  add column if not exists caregiver_relation text,
  add column if not exists remuneration text;

alter table public.profiles enable row level security;

-- SECURITY DEFINER function: bypasses RLS internally, so any policy that
-- needs to know "which elder is this caregiver linked to" can call this
-- instead of subquerying public.profiles directly (which would re-trigger
-- the very policy being evaluated -> infinite recursion, error 42P17).
create or replace function public.linked_elder_id_of(caregiver_id uuid)
returns uuid
language sql
stable
security definer
set search_path = public
as $$
  select linked_elder_id from public.profiles where id = caregiver_id;
$$;

-- ------------------------------------------------------------
-- CAREGIVER ASSIGNMENTS  (many-to-many: an elder can assign several
-- caregivers, and a caregiver can be assigned to several elders)
-- ------------------------------------------------------------
create table if not exists public.caregiver_assignments (
  id uuid primary key default uuid_generate_v4(),
  elder_id uuid not null references public.profiles(id) on delete cascade,
  caregiver_id uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (elder_id, caregiver_id)
);

alter table public.caregiver_assignments enable row level security;

-- SECURITY DEFINER: lets other tables' RLS policies check "is the
-- current user an assigned caregiver of this elder?" without
-- re-triggering caregiver_assignments' own RLS (which would recurse).
create or replace function public.is_caregiver_of(target_elder_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.caregiver_assignments
    where elder_id = target_elder_id and caregiver_id = auth.uid()
  );
$$;

drop policy if exists "Elder or assigned caregiver can view an assignment" on public.caregiver_assignments;
create policy "Elder or assigned caregiver can view an assignment"
  on public.caregiver_assignments for select
  using (auth.uid() = elder_id or auth.uid() = caregiver_id);

drop policy if exists "Elder can assign a caregiver to themself" on public.caregiver_assignments;
create policy "Elder can assign a caregiver to themself"
  on public.caregiver_assignments for insert
  with check (auth.uid() = elder_id);

drop policy if exists "Elder can remove their own assignment" on public.caregiver_assignments;
create policy "Elder can remove their own assignment"
  on public.caregiver_assignments for delete
  using (auth.uid() = elder_id);

-- ---- PROFILES policies (defined here, after is_caregiver_of exists) ----

drop policy if exists "Profiles are viewable by owner or linked caregiver" on public.profiles;
create policy "Profiles are viewable by owner or linked caregiver"
  on public.profiles for select
  using (
    auth.uid() = id
    or id = public.linked_elder_id_of(auth.uid())
    or public.is_caregiver_of(id)
  );

-- Lets any signed-in user browse the caregiver directory (name, experience,
-- relation, remuneration) on the "Assign Caregiver" screen.
drop policy if exists "Caregiver profiles are browsable by any signed-in user" on public.profiles;
create policy "Caregiver profiles are browsable by any signed-in user"
  on public.profiles for select
  using (role = 'caregiver');

drop policy if exists "Users can insert their own profile" on public.profiles;
create policy "Users can insert their own profile"
  on public.profiles for insert
  with check (auth.uid() = id);

drop policy if exists "Users can update their own profile" on public.profiles;
create policy "Users can update their own profile"
  on public.profiles for update
  using (auth.uid() = id);

-- Auto-create a profiles row whenever a new auth user signs up.
-- Runs as SECURITY DEFINER so it works even if there's no active session
-- yet (e.g. when "Confirm email" is enabled and the client has no JWT).
-- full_name / phone / role are read from the signUp() call's `data` payload.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, full_name, email, phone, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1)),
    new.email,
    new.raw_user_meta_data->>'phone',
    coalesce(new.raw_user_meta_data->>'role', 'elder')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Backfill: create a profiles row for any EXISTING auth user that is
-- missing one (e.g. an account created before the trigger above existed).
insert into public.profiles (id, full_name, email, phone, role)
select
  u.id,
  coalesce(u.raw_user_meta_data->>'full_name', split_part(u.email, '@', 1)),
  u.email,
  u.raw_user_meta_data->>'phone',
  coalesce(u.raw_user_meta_data->>'role', 'elder')
from auth.users u
left join public.profiles p on p.id = u.id
where p.id is null;

-- ------------------------------------------------------------
-- MEDICINES
-- ------------------------------------------------------------
create table if not exists public.medicines (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  dosage text not null,
  frequency text not null default 'Daily',
  time text not null default '08:00',
  reminder boolean not null default true,
  status text not null default 'upcoming' check (status in ('taken','pending','upcoming')),
  created_at timestamptz not null default now()
);

alter table public.medicines enable row level security;

drop policy if exists "Owner or caregiver can view medicines" on public.medicines;
create policy "Owner or caregiver can view medicines"
  on public.medicines for select
  using (
    auth.uid() = user_id
    or user_id = public.linked_elder_id_of(auth.uid())
    or public.is_caregiver_of(user_id)
  );

drop policy if exists "Owner can manage own medicines" on public.medicines;
drop policy if exists "Owner or assigned caregiver can manage medicines" on public.medicines;
create policy "Owner or assigned caregiver can manage medicines"
  on public.medicines for all
  using (auth.uid() = user_id or public.is_caregiver_of(user_id))
  with check (auth.uid() = user_id or public.is_caregiver_of(user_id));

-- ------------------------------------------------------------
-- APPOINTMENTS
-- ------------------------------------------------------------
create table if not exists public.appointments (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  doctor_name text not null,
  specialty text,
  date_time timestamptz not null,
  location text,
  is_upcoming boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.appointments
  add column if not exists prescription_link text;

alter table public.appointments enable row level security;

drop policy if exists "Owner or caregiver can view appointments" on public.appointments;
create policy "Owner or caregiver can view appointments"
  on public.appointments for select
  using (
    auth.uid() = user_id
    or user_id = public.linked_elder_id_of(auth.uid())
    or public.is_caregiver_of(user_id)
  );

drop policy if exists "Owner can manage own appointments" on public.appointments;
drop policy if exists "Owner or assigned caregiver can manage appointments" on public.appointments;
create policy "Owner or assigned caregiver can manage appointments"
  on public.appointments for all
  using (auth.uid() = user_id or public.is_caregiver_of(user_id))
  with check (auth.uid() = user_id or public.is_caregiver_of(user_id));

-- ------------------------------------------------------------
-- HEALTH RECORDS
-- ------------------------------------------------------------
create table if not exists public.health_records (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  recorded_at timestamptz not null default now(),
  bp_systolic int,
  bp_diastolic int,
  sugar int,
  weight numeric(5,2),
  pulse int
);

alter table public.health_records enable row level security;

drop policy if exists "Owner or caregiver can view health records" on public.health_records;
create policy "Owner or caregiver can view health records"
  on public.health_records for select
  using (
    auth.uid() = user_id
    or user_id = public.linked_elder_id_of(auth.uid())
    or public.is_caregiver_of(user_id)
  );

drop policy if exists "Owner can manage own health records" on public.health_records;
drop policy if exists "Owner or assigned caregiver can manage health records" on public.health_records;
create policy "Owner or assigned caregiver can manage health records"
  on public.health_records for all
  using (auth.uid() = user_id or public.is_caregiver_of(user_id))
  with check (auth.uid() = user_id or public.is_caregiver_of(user_id));

-- ------------------------------------------------------------
-- EMERGENCY CONTACTS
-- ------------------------------------------------------------
create table if not exists public.emergency_contacts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  relation text,
  phone text not null,
  created_at timestamptz not null default now()
);

alter table public.emergency_contacts
  add column if not exists email text,
  add column if not exists address text;

alter table public.emergency_contacts enable row level security;

drop policy if exists "Owner or caregiver can view emergency contacts" on public.emergency_contacts;
create policy "Owner or caregiver can view emergency contacts"
  on public.emergency_contacts for select
  using (
    auth.uid() = user_id
    or user_id = public.linked_elder_id_of(auth.uid())
    or public.is_caregiver_of(user_id)
  );

drop policy if exists "Owner can manage own emergency contacts" on public.emergency_contacts;
drop policy if exists "Owner or assigned caregiver can manage emergency contacts" on public.emergency_contacts;
create policy "Owner or assigned caregiver can manage emergency contacts"
  on public.emergency_contacts for all
  using (auth.uid() = user_id or public.is_caregiver_of(user_id))
  with check (auth.uid() = user_id or public.is_caregiver_of(user_id));

-- ------------------------------------------------------------
-- SOS ALERTS
-- ------------------------------------------------------------
create table if not exists public.sos_alerts (
  id uuid primary key default uuid_generate_v4(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  latitude double precision,
  longitude double precision,
  status text not null default 'active' check (status in ('active','cancelled','resolved')),
  created_at timestamptz not null default now()
);

alter table public.sos_alerts enable row level security;

drop policy if exists "Owner or caregiver can view sos alerts" on public.sos_alerts;
create policy "Owner or caregiver can view sos alerts"
  on public.sos_alerts for select
  using (
    auth.uid() = user_id
    or user_id = public.linked_elder_id_of(auth.uid())
    or public.is_caregiver_of(user_id)
  );

drop policy if exists "Owner can manage own sos alerts" on public.sos_alerts;
drop policy if exists "Owner or assigned caregiver can manage sos alerts" on public.sos_alerts;
create policy "Owner or assigned caregiver can manage sos alerts"
  on public.sos_alerts for all
  using (auth.uid() = user_id or public.is_caregiver_of(user_id))
  with check (auth.uid() = user_id or public.is_caregiver_of(user_id));

-- ------------------------------------------------------------
-- Realtime (optional): enable replication for live updates.
-- Guarded so re-running this file never errors with "table is
-- already a member of publication".
-- ------------------------------------------------------------
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'medicines'
  ) then
    alter publication supabase_realtime add table public.medicines;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'sos_alerts'
  ) then
    alter publication supabase_realtime add table public.sos_alerts;
  end if;
end $$;

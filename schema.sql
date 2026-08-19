-- Project Queue — Supabase schema
-- Run this once in the Supabase SQL editor (Project → SQL Editor → New query).
-- Single-user app: RLS policies below allow any authenticated request full access
-- to every table, since only you will ever be signed in (auth is a login gate,
-- not a multi-tenant boundary).

create table if not exists projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  notes text default '',
  deadline text default '',
  status text not null check (status in ('queued','backlog')),
  order_index int not null default 0,
  created_at timestamptz default now()
);

create table if not exists project_links (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  label text not null,
  url text not null,
  order_index int default 0
);

create table if not exists todos (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  due text default '',
  today boolean default false,
  done boolean default false,
  order_index int default 0,
  created_at timestamptz default now()
);

create table if not exists parking_lot (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  created_at timestamptz default now()
);

alter table projects enable row level security;
alter table project_links enable row level security;
alter table todos enable row level security;
alter table parking_lot enable row level security;

-- Authenticated-only access (any signed-in user — there will only ever be you).
create policy "authenticated full access" on projects
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "authenticated full access" on project_links
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "authenticated full access" on todos
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

create policy "authenticated full access" on parking_lot
  for all using (auth.role() = 'authenticated') with check (auth.role() = 'authenticated');

-- Seed data — carried over from the original artifact's default board.
insert into projects (title, notes, deadline, status, order_index) values
  ('Fantasy football draft', 'Draft ranking tool in progress. Draft is in ~2 weeks.', 'in 2 weeks', 'queued', 0),
  ('Lawn repair prep', 'Soil test, buy seed/product, plan aeration before the fall window closes.', 'early-mid Sept', 'queued', 1),
  ('Home server build', 'TrueNAS Scale + RAID1 for Immich photo library.', '', 'queued', 2),
  ('Meal planning app revisit', 'Improve usability of the existing app.', '', 'backlog', 0),
  ('Financial planning and budget', 'Mostly maintenance at this point.', '', 'backlog', 1),
  ('Inventory collectible items', '', '', 'backlog', 2);

insert into parking_lot (title) values
  ('Cooking fundamentals reference + AI chef agent (Kenji-style)'),
  ('Gardening fundamentals reference (soil science, plant care, pest/disease diagnosis)');

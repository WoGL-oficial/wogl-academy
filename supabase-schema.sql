/* ═══════════════════════════════════════
   WoGL — World of GL
   wogl.io | worldofgl.com | mundogl.com
   hello@wogl.io | hola@mundogl.com

   Proprietary. All rights reserved.
   ═══════════════════════════════════════ */

-- Enable UUID extension
create extension if not exists "uuid-ossp";

-- ─────────────────────────────────────────
-- profiles table
-- ─────────────────────────────────────────

create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  traveler_num integer unique not null,
  display_name text unique not null,
  level integer default 1 not null,
  xp integer default 0 not null,
  backpack text default 'generic' not null,
  theme text default 'default' not null,
  created_at timestamptz default now() not null
);

-- Enable RLS on profiles
alter table public.profiles enable row level security;

-- RLS Policy: Users can only access their own profile
create policy "Users can view own profile"
  on public.profiles
  for select
  using (auth.uid() = id);

-- RLS Policy: Users can only insert their own profile
create policy "Users can insert own profile"
  on public.profiles
  for insert
  with check (auth.uid() = id);

-- RLS Policy: Users can only update their own profile
create policy "Users can update own profile"
  on public.profiles
  for update
  using (auth.uid() = id)
  with check (auth.uid() = id);

-- RLS Policy: Public read access for display names (name availability checking)
create policy "Public can view profile display names"
  on public.profiles
  for select
  using (true);

-- ─────────────────────────────────────────
-- lesson_progress table
-- ─────────────────────────────────────────

create table if not exists public.lesson_progress (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles on delete cascade,
  section text not null,
  lesson_idx integer not null,
  completed_at timestamptz default now() not null,
  unique (user_id, section, lesson_idx)
);

-- Enable RLS on lesson_progress
alter table public.lesson_progress enable row level security;

-- RLS Policy: Users can only view their own lesson progress
create policy "Users can view own lesson progress"
  on public.lesson_progress
  for select
  using (auth.uid() = user_id);

-- RLS Policy: Users can only insert their own lesson progress
create policy "Users can insert own lesson progress"
  on public.lesson_progress
  for insert
  with check (auth.uid() = user_id);

-- RLS Policy: Users can only update their own lesson progress
create policy "Users can update own lesson progress"
  on public.lesson_progress
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─────────────────────────────────────────
-- badges table
-- ─────────────────────────────────────────

create table if not exists public.badges (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles on delete cascade,
  badge_key text not null,
  unlocked_at timestamptz default now() not null,
  unique (user_id, badge_key)
);

-- Enable RLS on badges
alter table public.badges enable row level security;

-- RLS Policy: Users can only view their own badges
create policy "Users can view own badges"
  on public.badges
  for select
  using (auth.uid() = user_id);

-- RLS Policy: Users can only insert their own badges
create policy "Users can insert own badges"
  on public.badges
  for insert
  with check (auth.uid() = user_id);

-- RLS Policy: Users can only update their own badges
create policy "Users can update own badges"
  on public.badges
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─────────────────────────────────────────
-- inventory table
-- ─────────────────────────────────────────

create table if not exists public.inventory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles on delete cascade,
  item_key text not null,
  equipped boolean default false not null,
  unlocked_at timestamptz default now() not null,
  unique (user_id, item_key)
);

-- Enable RLS on inventory
alter table public.inventory enable row level security;

-- RLS Policy: Users can only view their own inventory
create policy "Users can view own inventory"
  on public.inventory
  for select
  using (auth.uid() = user_id);

-- RLS Policy: Users can only insert their own inventory items
create policy "Users can insert own inventory items"
  on public.inventory
  for insert
  with check (auth.uid() = user_id);

-- RLS Policy: Users can only update their own inventory items
create policy "Users can update own inventory items"
  on public.inventory
  for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─────────────────────────────────────────
-- Helper function: next_traveler_num
-- ─────────────────────────────────────────

create or replace function public.next_traveler_num()
returns integer
language sql
security definer
as $$
  select coalesce(max(traveler_num), 0) + 1 from public.profiles;
$$;

-- ─────────────────────────────────────────
-- Indexes for performance
-- ─────────────────────────────────────────

create index idx_lesson_progress_user_id on public.lesson_progress (user_id);
create index idx_badges_user_id on public.badges (user_id);
create index idx_inventory_user_id on public.inventory (user_id);

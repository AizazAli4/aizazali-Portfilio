-- =========================================
-- PROFILE TABLE MIGRATION
-- Run this in Supabase SQL Editor (adds a new table
-- for your name/tagline/bio/photo/resume — safe to run
-- even though your other tables already exist)
-- =========================================

create table profile (
  id uuid primary key default gen_random_uuid(),
  full_name text,
  tagline text,
  bio text,
  photo_url text,
  resume_url text,
  updated_at timestamptz default now()
);

alter table profile enable row level security;

create policy "Public can read profile" on profile for select using (true);
create policy "Admin can insert profile" on profile for insert with check (auth.role() = 'authenticated');
create policy "Admin can update profile" on profile for update using (auth.role() = 'authenticated');

-- Seed one starter row so the admin panel has something to edit
insert into profile (full_name, tagline, bio)
values (
  'Aitzaz Ali',
  'QA Engineer × AI Automation Builder',
  'I test systems, break them on purpose, and build the automation that stops them from breaking again — spanning QA, AI workflows, and full-stack development.'
);

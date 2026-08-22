-- =========================================
-- UPGRADE MIGRATION
-- Run this in Supabase SQL Editor (after your original schema is already set up)
-- =========================================

-- 1. PROFILE TABLE (single row — controls all editable site text + photos)
create table profile (
  id uuid primary key default gen_random_uuid(),
  full_name text,
  professional_title text,
  tagline text,
  hero_heading text,
  hero_subheading text,
  hero_photo_url text,
  about_heading text,
  about_paragraphs text,      -- one paragraph per line
  about_photo_url text,
  resume_url text,
  updated_at timestamptz default now()
);

alter table profile enable row level security;

create policy "Public can read profile" on profile for select using (true);
create policy "Admin can insert profile" on profile for insert with check (auth.role() = 'authenticated');
create policy "Admin can update profile" on profile for update using (auth.role() = 'authenticated');

-- insert one starter row so the admin panel has something to edit
insert into profile (full_name, professional_title, tagline, hero_heading, hero_subheading, about_heading, about_paragraphs)
values (
  'Aitzaz Ali',
  'QA Engineer | AI Automation Builder',
  'I test systems, break them on purpose, and build the automation that stops them from breaking again.',
  'Hi, I''m Aitzaz Ali',
  'QA Engineer x AI Automation Builder building intelligent, well-tested systems.',
  'QA + AI Automation + Full-Stack',
  'I am a Computer Science / IT professional with hands-on QA testing experience and a growing focus on AI automation and full-stack development.
I enjoy building practical projects that solve real-world problems, from AI-powered recruitment tools to hardware automation systems.
My goal is to combine QA rigor with AI engineering to build systems that are both intelligent and reliable.'
);


-- 2. SKILL CATEGORIES TABLE (replaces the old per-skill "skills" table)
-- Drop the old one first (safe — it's currently empty in most setups; back up first if you already added skills)
drop table if exists skills cascade;

create table skill_categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,             -- e.g. 'Programming Languages'
  proficiency int check (proficiency between 1 and 100),
  skills_list text,               -- comma-separated, e.g. 'Python, JavaScript, HTML5'
  sort_order int default 0,
  created_at timestamptz default now()
);

alter table skill_categories enable row level security;

create policy "Public can read skill_categories" on skill_categories for select using (true);
create policy "Admin can insert skill_categories" on skill_categories for insert with check (auth.role() = 'authenticated');
create policy "Admin can update skill_categories" on skill_categories for update using (auth.role() = 'authenticated');
create policy "Admin can delete skill_categories" on skill_categories for delete using (auth.role() = 'authenticated');

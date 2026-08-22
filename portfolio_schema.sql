-- =========================================
-- PORTFOLIO WEBSITE - SUPABASE SQL SCHEMA
-- Run this whole file in Supabase SQL Editor
-- =========================================

-- 1. PROJECTS TABLE
create table projects (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  description text,
  tech_stack text[],           -- e.g. {'React','Node.js','Supabase'}
  image_url text,
  project_link text,
  github_link text,
  featured boolean default false,
  created_at timestamptz default now()
);

-- 2. SKILLS TABLE
create table skills (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text,                -- e.g. 'Frontend', 'Backend', 'Tools'
  proficiency int check (proficiency between 1 and 100),
  icon_url text,
  created_at timestamptz default now()
);

-- 3. EDUCATION TABLE
create table education (
  id uuid primary key default gen_random_uuid(),
  institution text not null,
  degree text,
  field_of_study text,
  start_date date,
  end_date date,
  description text,
  created_at timestamptz default now()
);

-- 4. EXPERIENCE TABLE
create table experience (
  id uuid primary key default gen_random_uuid(),
  company text not null,
  role text,
  start_date date,
  end_date date,
  is_current boolean default false,
  description text,
  created_at timestamptz default now()
);

-- 5. CERTIFICATIONS TABLE
create table certifications (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  issued_by text,
  issue_date date,
  credential_url text,
  image_url text,
  created_at timestamptz default now()
);

-- 6. TESTIMONIALS TABLE
create table testimonials (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  designation text,
  message text,
  image_url text,
  created_at timestamptz default now()
);

-- 7. SOCIAL LINKS TABLE
create table social_links (
  id uuid primary key default gen_random_uuid(),
  platform text not null,       -- e.g. 'GitHub', 'LinkedIn'
  url text not null,
  icon_url text,
  created_at timestamptz default now()
);

-- 8. CONTACT MESSAGES TABLE
create table contact_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  message text not null,
  is_read boolean default false,
  created_at timestamptz default now()
);


-- =========================================
-- ROW LEVEL SECURITY (RLS)
-- =========================================

alter table projects enable row level security;
alter table skills enable row level security;
alter table education enable row level security;
alter table experience enable row level security;
alter table certifications enable row level security;
alter table testimonials enable row level security;
alter table social_links enable row level security;
alter table contact_messages enable row level security;

-- ---- PUBLIC READ POLICIES (everyone can view portfolio data) ----
create policy "Public can read projects" on projects for select using (true);
create policy "Public can read skills" on skills for select using (true);
create policy "Public can read education" on education for select using (true);
create policy "Public can read experience" on experience for select using (true);
create policy "Public can read certifications" on certifications for select using (true);
create policy "Public can read testimonials" on testimonials for select using (true);
create policy "Public can read social_links" on social_links for select using (true);

-- ---- ADMIN-ONLY WRITE POLICIES (only logged-in user = you) ----
create policy "Admin can insert projects" on projects for insert with check (auth.role() = 'authenticated');
create policy "Admin can update projects" on projects for update using (auth.role() = 'authenticated');
create policy "Admin can delete projects" on projects for delete using (auth.role() = 'authenticated');

create policy "Admin can insert skills" on skills for insert with check (auth.role() = 'authenticated');
create policy "Admin can update skills" on skills for update using (auth.role() = 'authenticated');
create policy "Admin can delete skills" on skills for delete using (auth.role() = 'authenticated');

create policy "Admin can insert education" on education for insert with check (auth.role() = 'authenticated');
create policy "Admin can update education" on education for update using (auth.role() = 'authenticated');
create policy "Admin can delete education" on education for delete using (auth.role() = 'authenticated');

create policy "Admin can insert experience" on experience for insert with check (auth.role() = 'authenticated');
create policy "Admin can update experience" on experience for update using (auth.role() = 'authenticated');
create policy "Admin can delete experience" on experience for delete using (auth.role() = 'authenticated');

create policy "Admin can insert certifications" on certifications for insert with check (auth.role() = 'authenticated');
create policy "Admin can update certifications" on certifications for update using (auth.role() = 'authenticated');
create policy "Admin can delete certifications" on certifications for delete using (auth.role() = 'authenticated');

create policy "Admin can insert testimonials" on testimonials for insert with check (auth.role() = 'authenticated');
create policy "Admin can update testimonials" on testimonials for update using (auth.role() = 'authenticated');
create policy "Admin can delete testimonials" on testimonials for delete using (auth.role() = 'authenticated');

create policy "Admin can insert social_links" on social_links for insert with check (auth.role() = 'authenticated');
create policy "Admin can update social_links" on social_links for update using (auth.role() = 'authenticated');
create policy "Admin can delete social_links" on social_links for delete using (auth.role() = 'authenticated');

-- ---- CONTACT MESSAGES POLICIES ----
-- Anyone (even not logged in) can submit a message
create policy "Public can insert contact_messages" on contact_messages for insert with check (true);
-- Only admin (you) can read/delete messages
create policy "Admin can read contact_messages" on contact_messages for select using (auth.role() = 'authenticated');
create policy "Admin can delete contact_messages" on contact_messages for delete using (auth.role() = 'authenticated');

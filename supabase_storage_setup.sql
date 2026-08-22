-- =========================================
-- STORAGE BUCKET SETUP
-- Run this AFTER the main schema.sql
-- =========================================

-- 1. Create a public bucket for portfolio images
insert into storage.buckets (id, name, public)
values ('portfolio-images', 'portfolio-images', true);

-- 2. Anyone can VIEW images (public bucket)
create policy "Public can view portfolio images"
on storage.objects for select
using ( bucket_id = 'portfolio-images' );

-- 3. Only logged-in (authenticated) users can UPLOAD images
create policy "Admin can upload portfolio images"
on storage.objects for insert
with check ( bucket_id = 'portfolio-images' and auth.role() = 'authenticated' );

-- 4. Only logged-in users can DELETE/UPDATE images
create policy "Admin can update portfolio images"
on storage.objects for update
using ( bucket_id = 'portfolio-images' and auth.role() = 'authenticated' );

create policy "Admin can delete portfolio images"
on storage.objects for delete
using ( bucket_id = 'portfolio-images' and auth.role() = 'authenticated' );

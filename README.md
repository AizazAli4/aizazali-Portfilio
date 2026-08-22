# Aitzaz Ali — Dynamic Portfolio

Frontend: HTML/CSS/JS (no framework). Backend: Supabase (Postgres + Auth + Storage).

## Folder structure
```
portfolio/
  index.html                 -> public website
  css/style.css
  js/supabaseClient.js       -> your Supabase URL + anon key go here
  js/app.js                  -> fetches & renders all sections dynamically
  admin/
    index.html                -> admin login + dashboard
    css/admin.css
    js/admin.js                -> full CRUD logic for every table
  portfolio_schema.sql        -> run first in Supabase SQL editor
  supabase_storage_setup.sql  -> run second, sets up image bucket
```

## Setup steps

1. **Create Supabase project** at supabase.com.

2. **Run the SQL files** (SQL Editor, in this order):
   - `portfolio_schema.sql` — creates all 8 tables + RLS policies
   - `supabase_storage_setup.sql` — creates the `portfolio-images` bucket + policies

3. **Create your admin login**: Supabase Dashboard → Authentication → Users → Add User (this is the ONLY account — it's you, the site owner).

4. **Add your API keys**: open `js/supabaseClient.js` and replace:
   ```js
   const SUPABASE_URL = "https://YOUR-PROJECT-ID.supabase.co";
   const SUPABASE_ANON_KEY = "YOUR-ANON-PUBLIC-KEY";
   ```
   Both values are in Supabase → Project Settings → API. The `anon` key is safe to expose in frontend code — it only allows what your RLS policies permit.

5. **Test locally**: open `index.html` in a browser (or use VS Code's Live Server extension). Sections will show "No data yet" until you add content via the admin panel.

6. **Log in to admin**: open `admin/index.html`, log in with the account from step 3. Add your projects, skills, experience, education, certifications, testimonials, and social links. Images upload directly to Supabase Storage.

7. **Deploy**:
   - **Netlify**: drag-and-drop the whole `portfolio` folder onto app.netlify.com/drop, or connect your GitHub repo.
   - **Vercel**: `vercel` CLI or import the GitHub repo at vercel.com/new. No build step needed — it's static HTML/CSS/JS.

## Notes
- The admin panel (`/admin`) is not linked from the public nav — access it directly via URL. Since RLS blocks writes without login anyway, this is just to keep it out of casual visitors' way, not a substitute for the login.
- Contact form messages land in the `contact_messages` table — view/manage them from the admin "Messages" tab.
- To change the color theme, edit the `:root` variables at the top of `css/style.css`.

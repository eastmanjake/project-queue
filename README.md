# Project Queue

A personal project/task tracker — Today / Projects / To-Dos / Parking lot. Static HTML/JS, no build step, backed by Supabase (Postgres + Auth), deployed via GitHub Pages.

## One-time setup

### 1. Create a Supabase project
Go to [supabase.com](https://supabase.com), sign in, and create a new project. Note the region closest to you; anything else can stay default.

### 2. Run the schema
In the Supabase dashboard: **SQL Editor → New query**, paste the contents of [`schema.sql`](./schema.sql), and run it. This creates the four tables (`projects`, `project_links`, `todos`, `parking_lot`), turns on row-level security, adds an authenticated-only access policy to each table, and seeds your existing board data (the projects/parking items already in the app).

### 3. Enable magic-link auth
**Authentication → Providers**: confirm Email is enabled (it is by default). **Authentication → URL Configuration**: set the Site URL to your future GitHub Pages URL (e.g. `https://eastmanjake.github.io/project-queue`) once you know it from step 5 — you can come back and update this after.

This app has no signup flow — anyone who knows a valid email can request a magic link, but only requests to *your* inbox let anyone in. If you want to hard-restrict sign-in to just your address, add a Postgres trigger on `auth.users` that rejects other emails, or simply don't share the link.

### 4. Get your API keys
**Settings → API**. Copy the **Project URL** and the **anon public key**.

Open `index.html` and fill in:
```js
const SUPABASE_URL = 'YOUR_SUPABASE_PROJECT_URL';
const SUPABASE_ANON_KEY = 'YOUR_SUPABASE_ANON_KEY';
```
Commit and push that change (the anon key is safe to embed client-side by design — it only grants what your RLS policies allow, which is authenticated-only access).

### 5. Enable GitHub Pages
**Repo Settings → Pages → Build and deployment → Source**: Deploy from a branch. Pick `main` (or whichever branch has `index.html`) and `/ (root)`. Save. GitHub will give you a URL like `https://eastmanjake.github.io/project-queue`.

### 6. Sign in
Visit the Pages URL, enter your email, and check your inbox for the magic link. First sign-in on each device works the same way.

## Local development
No build step — just open `index.html` in a browser, or serve the folder with any static file server (`python3 -m http.server`, `npx serve`, etc.).

## Notes
- `deadline` (projects) and `due` (todos) are free text, not real dates — kept that way to allow phrases like "early-mid Sept".
- No realtime sync — each device fetches fresh on load/sign-in. A change on one device won't appear on another until you reload.
- Every write (add/edit/delete/reorder) round-trips to Supabase before the UI updates, so a failed sync shows an error instead of silently losing the change.

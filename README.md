# The Sacred Archive

A private, installable document library with email/password accounts, owner approval, protected uploads, in-app reading, and search.

## One-time setup

1. Create a Supabase project at https://supabase.com.
2. Open **SQL Editor**, paste everything from `supabase/schema.sql`, and select **Run**.
3. Open **Project Settings → API** and copy the Project URL and public anon key.
4. In this GitHub repository, open **Settings → Secrets and variables → Actions**.
5. Add secrets named `VITE_SUPABASE_URL` and `VITE_SUPABASE_ANON_KEY`.
6. Open **Settings → Pages** and set **Source** to **GitHub Actions**.
7. Run the **Deploy Sacred Archive** workflow.
8. Create Samuel's account before sharing the link. The first account becomes the approved owner; every later account waits for approval.

The public anon key is intended for browser apps. Security is enforced by Row Level Security. Never add the service-role key to GitHub or browser code.

## Features

- Email/password accounts
- Owner approval and denial
- Private PDF and document storage
- Searchable pasted/text content
- In-app reader without download controls
- Owner-only upload and removal
- Installable iPhone/desktop PWA

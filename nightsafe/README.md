# NightSafe — real version
This branch turns the uploaded prototype into a real GPS journey-sharing web app.

## Stack
- HTML/CSS/JavaScript
- Leaflet + OpenStreetMap
- Supabase Postgres + RPC functions
- GitHub Pages + GitHub Actions

## Setup
1. Create a Supabase project and run `supabase/schema.sql`.
2. Add repository secrets `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
3. Copy `config.example.js` to `config.js` only for local development.
4. Deploy the `nightsafe` directory with GitHub Pages/Actions.

The browser requests GPS permission only after the traveller starts live location. Viewer links use random tokens. For a full production launch, add authentication, token expiry/rotation, rate limiting, audit logs, and a server-side missed-check-in notification worker.
# GGSS.cl — Environment Notes

## PostgreSQL

**Not required locally.**

All database operations in GGSS.cl use one of:
- The Supabase hosted PostgreSQL instance (via Flutter Supabase client)
- Supabase CLI for migrations and schema management

No local PostgreSQL installation (`psql`, `pg_ctl`, etc.) is needed to
build, run, or test the app. Do not install a local PostgreSQL server
unless a specific local migration workflow requires it.

## Node.js

**Not required.**

Edge Functions in this project (`supabase/functions/`) run on the
**Deno** runtime hosted on Supabase servers. They are deployed via
Supabase CLI (`supabase functions deploy`), not via Node.js tooling.

The Flutter project has zero Node.js dependencies. There is no
`package.json`, no `node_modules`, and no npm/yarn/pnpm scripts.

If a future tool or workflow requires Node.js, install the LTS version
from https://nodejs.org — do not use nightly or legacy versions.

## Summary Table

| Tool        | Required? | Used for                                  |
|-------------|-----------|-------------------------------------------|
| Flutter SDK | YES       | App development (stable channel ≥ 3.41)  |
| Dart SDK    | YES       | Bundled with Flutter                      |
| Supabase CLI| optional  | Deploying Edge Functions / migrations     |
| PostgreSQL  | NO        | Handled by Supabase hosted instance       |
| Node.js     | NO        | Edge Functions use Deno, not Node         |
| Android SDK | YES       | Building Android APK / AAB                |
| Xcode       | macOS only| Building iOS app                          |

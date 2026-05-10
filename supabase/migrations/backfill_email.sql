-- ============================================================
-- backfill_email.sql
-- Rellena la columna email en profiles para usuarios registrados
-- antes de que se añadiera la columna.
--
-- EJECUTAR MANUALMENTE en Supabase Dashboard → SQL Editor.
-- Requiere acceso a auth.users (solo disponible con rol service_role).
-- ============================================================

UPDATE profiles p
SET email = u.email
FROM auth.users u
WHERE p.id = u.id
  AND p.email IS NULL;

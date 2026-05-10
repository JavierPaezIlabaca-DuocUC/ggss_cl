-- ============================================================
-- Migración: campos de nombre separados en la tabla profiles
-- Prompt II: deprecar alias, agregar primer nombre y apellidos
-- ============================================================

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS first_name TEXT,
  ADD COLUMN IF NOT EXISTS last_name_paternal TEXT,
  ADD COLUMN IF NOT EXISTS last_name_maternal TEXT;

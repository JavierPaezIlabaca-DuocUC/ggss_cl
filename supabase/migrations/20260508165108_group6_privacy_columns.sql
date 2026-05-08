-- ============================================================
-- Migración: columnas de privacidad en la tabla profiles
-- Grupo 6: mejoras de perfil y privacidad
-- ============================================================

ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS show_email BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS show_phone BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS show_posts BOOLEAN DEFAULT true;

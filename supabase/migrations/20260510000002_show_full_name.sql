-- Agrega columna show_full_name a la tabla profiles.
-- Controla si el nombre completo (apellidos) se muestra en el perfil público.
-- Por defecto: false (solo se muestra el primer nombre).
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS show_full_name BOOLEAN DEFAULT false;

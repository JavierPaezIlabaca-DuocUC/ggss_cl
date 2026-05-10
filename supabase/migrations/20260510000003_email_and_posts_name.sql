-- Agrega columna email a profiles para mostrar en perfil público.
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS email TEXT;

-- Agrega columna show_full_name_in_posts para controlar nombre en publicaciones.
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS show_full_name_in_posts BOOLEAN DEFAULT false;

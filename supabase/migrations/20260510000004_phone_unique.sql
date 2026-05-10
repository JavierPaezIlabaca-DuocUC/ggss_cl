-- Eliminar teléfonos duplicados antes de agregar la restricción UNIQUE.
-- En caso de duplicados, se conserva el registro con created_at más antiguo
-- (primera cuenta registrada) y se anula el teléfono de los demás.
UPDATE profiles
SET phone = NULL
WHERE id NOT IN (
  SELECT DISTINCT ON (phone) id
  FROM profiles
  WHERE phone IS NOT NULL
  ORDER BY phone, created_at
);

-- Restricción UNIQUE en la columna phone.
-- PostgreSQL permite múltiples NULL bajo UNIQUE (NULL != NULL en SQL),
-- por lo que cuentas sin teléfono registrado no entran en conflicto.
ALTER TABLE profiles
  ADD CONSTRAINT profiles_phone_unique UNIQUE (phone);

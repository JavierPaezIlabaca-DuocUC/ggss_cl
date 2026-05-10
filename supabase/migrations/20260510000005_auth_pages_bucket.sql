-- Bucket público para páginas estáticas de autenticación.
-- Sirve auth-success.html y auth-error.html con Content-Type correcto,
-- evitando la limitación del Gateway v1 de Edge Functions que fuerza text/plain.
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'auth-pages',
  'auth-pages',
  true,
  102400,
  ARRAY['text/html']
)
ON CONFLICT (id) DO NOTHING;

-- Política: cualquier usuario puede leer objetos del bucket (es público)
CREATE POLICY "auth-pages public read"
  ON storage.objects FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'auth-pages');

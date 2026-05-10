// ============================================================
// auth-confirm/index.ts
// Edge Function: verificación de correo electrónico para GGSS.cl.
//
// Flujo:
//   1. Supabase envía el correo con esta URL como destino
//   2. El usuario hace clic desde cualquier dispositivo/navegador
//   3. Esta función verifica el token y redirige (HTTP 302):
//      - Móvil (Android/iOS): redirige a ggss://app (deep link)
//      - Escritorio: redirige a la página HTML en jsDelivr CDN
//
// IMPORTANTE — Limitación del Gateway v1 de Supabase:
//   El Gateway v1 sobreescribe Content-Type a 'text/plain' e inyecta
//   'Content-Security-Policy: default-src none; sandbox' en TODAS las
//   respuestas de Edge Functions Y de Supabase Storage, sin excepción.
//   Por esto, NO se puede servir HTML renderizable desde *.supabase.co.
//   Solución: las páginas HTML se sirven desde jsDelivr CDN, que usa el
//   repositorio público de GitHub y sí envía Content-Type: text/html.
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!

// Deep link de la app móvil
const APP_DEEP_LINK = 'ggss://app'

// Páginas HTML estáticas servidas via jsDelivr CDN desde el repo de GitHub.
// jsDelivr envía Content-Type: text/html correcto, a diferencia de Supabase.
// Después de cada git push, jsDelivr actualiza las páginas automáticamente.
const GITHUB_REPO = 'JavierPaezIlabaca-DuocUC/ggss_cl'
const CDN_BASE = `https://cdn.jsdelivr.net/gh/${GITHUB_REPO}@main/docs`
const CDN_SUCCESS = `${CDN_BASE}/auth-success.html`
const CDN_ERROR   = `${CDN_BASE}/auth-error.html`

// ──────────────────────────────────────────
// Cabeceras CORS mínimas para respuestas de redirección
// ──────────────────────────────────────────
const REDIRECT_HEADERS = {
  'Access-Control-Allow-Origin': '*',
}

// ──────────────────────────────────────────
// Handler principal
// ──────────────────────────────────────────
Deno.serve(async (req: Request) => {
  // Responder a preflight CORS
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, OPTIONS',
        'Access-Control-Allow-Headers': '*',
      },
    })
  }

  const url = new URL(req.url)
  const tokenHash = url.searchParams.get('token_hash')
  const type = url.searchParams.get('type') as 'signup' | 'recovery' | null
  const userAgent = req.headers.get('user-agent') ?? ''
  const isMobile = /Android|iPhone|iPad|iPod/i.test(userAgent)

  // Sin parámetros: acceso directo desde navegador (test manual).
  // Redirigir a la página de error informativa en el CDN.
  if (!tokenHash || !type) {
    if (isMobile) {
      return new Response(null, {
        status: 302,
        headers: { ...REDIRECT_HEADERS, 'Location': APP_DEEP_LINK },
      })
    }
    return new Response(null, {
      status: 302,
      headers: { ...REDIRECT_HEADERS, 'Location': CDN_ERROR },
    })
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  // Verificar el token con Supabase Auth (service role)
  const { data, error } = await supabase.auth.verifyOtp({
    token_hash: tokenHash,
    type,
  })

  if (error || !data.user) {
    console.error('Token verification failed:', error?.message)
    if (isMobile) {
      return new Response(null, {
        status: 302,
        headers: { ...REDIRECT_HEADERS, 'Location': APP_DEEP_LINK },
      })
    }
    return new Response(null, {
      status: 302,
      headers: { ...REDIRECT_HEADERS, 'Location': CDN_ERROR },
    })
  }

  // Verificación exitosa
  const email = encodeURIComponent(data.user.email ?? '')

  if (isMobile) {
    // En móvil: abrir la app directamente via deep link
    return new Response(null, {
      status: 302,
      headers: { ...REDIRECT_HEADERS, 'Location': APP_DEEP_LINK },
    })
  }

  // En escritorio: redirigir a la página de éxito en el CDN
  // Se pasa el email como query param para personalizar la página
  return new Response(null, {
    status: 302,
    headers: {
      ...REDIRECT_HEADERS,
      'Location': `${CDN_SUCCESS}?email=${email}`,
    },
  })
})

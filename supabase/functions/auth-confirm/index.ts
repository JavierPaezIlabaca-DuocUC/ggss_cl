// ============================================================
// auth-confirm/index.ts
// Edge Function: página de redirección para confirmación de cuenta.
//
// Flujo:
//   1. Supabase envía el correo con esta URL como destino
//   2. El usuario hace clic desde cualquier dispositivo/navegador
//   3. Esta función verifica el token y devuelve HTML que:
//      - En móvil: intenta abrir ggss://app automáticamente
//      - En escritorio: muestra mensaje de éxito con instrucciones
// ============================================================

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
const APP_DEEP_LINK = 'ggss://app'

// ──────────────────────────────────────────
// HTML de éxito (con intento automático de abrir la app)
// ──────────────────────────────────────────
function successHtml(email: string): string {
  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Cuenta verificada — GGSS.cl</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f5f7fa;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: 24px;
    }
    .card {
      background: white;
      border-radius: 16px;
      padding: 40px 32px;
      max-width: 420px;
      width: 100%;
      text-align: center;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    }
    .icon { font-size: 56px; margin-bottom: 16px; }
    h1 { color: #1565C0; font-size: 22px; font-weight: 700; margin-bottom: 12px; }
    .subtitle { color: #555; font-size: 15px; line-height: 1.6; margin-bottom: 8px; }
    .email { color: #1565C0; font-weight: 600; font-size: 14px; margin-bottom: 24px; }
    .desktop-note {
      background: #e3f0ff;
      border-radius: 10px;
      padding: 14px 16px;
      color: #1565C0;
      font-size: 13px;
      line-height: 1.5;
      margin-bottom: 24px;
      display: none;
    }
    .btn {
      display: inline-block;
      background: #1565C0;
      color: white;
      text-decoration: none;
      padding: 14px 32px;
      border-radius: 10px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      border: none;
      width: 100%;
      margin-bottom: 12px;
    }
    .btn:hover { background: #0d47a1; }
    .footer { color: #aaa; font-size: 12px; margin-top: 24px; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">✅</div>
    <h1>Cuenta verificada correctamente</h1>
    <p class="subtitle">Tu cuenta de GGSS.cl ha sido activada.</p>
    <p class="email">${email}</p>
    <div class="desktop-note" id="desktopNote">
      Tu cuenta ha sido verificada.<br/>
      <strong>Abre la app en tu teléfono para continuar.</strong>
    </div>
    <a href="${APP_DEEP_LINK}" class="btn" id="openBtn">Abrir GGSS.cl</a>
    <p class="subtitle" id="autoMsg">Si la app no se abre automáticamente, toca el botón de arriba.</p>
    <div class="footer">GGSS.cl — Plataforma de Seguridad Privada en Chile</div>
  </div>
  <script>
    // Detectar si es móvil
    const isMobile = /Android|iPhone|iPad|iPod/i.test(navigator.userAgent);
    if (!isMobile) {
      document.getElementById('desktopNote').style.display = 'block';
      document.getElementById('autoMsg').style.display = 'none';
      document.getElementById('openBtn').style.display = 'none';
    } else {
      // Intentar abrir la app automáticamente en móvil
      setTimeout(() => { window.location.href = '${APP_DEEP_LINK}'; }, 500);
    }
  </script>
</body>
</html>`
}

// ──────────────────────────────────────────
// HTML de error
// ──────────────────────────────────────────
function errorHtml(reason: string): string {
  return `<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Error de verificación — GGSS.cl</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
      background: #f5f7fa;
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      padding: 24px;
    }
    .card {
      background: white;
      border-radius: 16px;
      padding: 40px 32px;
      max-width: 420px;
      width: 100%;
      text-align: center;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08);
    }
    .icon { font-size: 56px; margin-bottom: 16px; }
    h1 { color: #c62828; font-size: 22px; font-weight: 700; margin-bottom: 12px; }
    .subtitle { color: #555; font-size: 15px; line-height: 1.6; margin-bottom: 24px; }
    .note {
      background: #fff3f3;
      border-radius: 10px;
      padding: 14px 16px;
      color: #c62828;
      font-size: 13px;
      line-height: 1.5;
      margin-bottom: 24px;
    }
    .footer { color: #aaa; font-size: 12px; margin-top: 24px; }
  </style>
</head>
<body>
  <div class="card">
    <div class="icon">❌</div>
    <h1>El enlace de verificación ha expirado o ya fue utilizado.</h1>
    <p class="subtitle">No fue posible verificar tu cuenta con este enlace.</p>
    <div class="note">
      Abre la app GGSS.cl y solicita un nuevo correo de verificación.
    </div>
    <div class="footer">GGSS.cl — Plataforma de Seguridad Privada en Chile</div>
  </div>
</body>
</html>`
}

// ──────────────────────────────────────────
// Cabeceras comunes para todas las respuestas
// Access-Control-Allow-Origin: * es obligatorio para que navegadores
// puedan acceder a la función sin autenticación (función pública).
// ──────────────────────────────────────────
const HTML_HEADERS = {
  'Content-Type': 'text/html; charset=utf-8',
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

  // Sin parámetros: acceso directo desde navegador (ej. test manual).
  // Devolver HTML informativo en lugar de error técnico.
  if (!tokenHash || !type) {
    return new Response(
      errorHtml('No se encontró token de verificación en la URL. Abre la app y solicita un nuevo correo de verificación.'),
      { status: 200, headers: HTML_HEADERS },
    )
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY, {
    auth: { autoRefreshToken: false, persistSession: false },
  })

  // Verificar el token con Supabase Auth (service role, sin JWT de usuario)
  const { data, error } = await supabase.auth.verifyOtp({
    token_hash: tokenHash,
    type,
  })

  if (error || !data.user) {
    console.error('Token verification failed:', error?.message)
    return new Response(errorHtml(error?.message ?? 'unknown'), {
      status: 200,
      headers: HTML_HEADERS,
    })
  }

  const email = data.user.email ?? ''

  // ──────────────────────────────────────────
  // El Supabase Gateway v1 sobreescribe el header Content-Type a 'text/plain'
  // e inyecta 'Content-Security-Policy: default-src none; sandbox' en TODAS
  // las respuestas de Edge Functions, sin importar lo que la función devuelva.
  // Esto impide que el navegador renderice HTML y que se ejecute JavaScript.
  //
  // Solución para móvil (caso principal):
  //   HTTP 302 → ggss://app
  //   El navegador sigue el redirect sin importar Content-Type.
  //   Android intercepta el esquema ggss:// y abre la app.
  //
  // Solución para escritorio:
  //   Se devuelve el HTML informativo (visible como texto plano).
  //   El contenido es legible aunque no esté estilizado.
  // ──────────────────────────────────────────
  const userAgent = req.headers.get('user-agent') ?? ''
  const isMobile = /Android|iPhone|iPad|iPod/i.test(userAgent)

  if (isMobile) {
    return new Response(null, {
      status: 302,
      headers: {
        'Location': APP_DEEP_LINK,
        'Access-Control-Allow-Origin': '*',
      },
    })
  }

  return new Response(successHtml(email), {
    status: 200,
    headers: HTML_HEADERS,
  })
})

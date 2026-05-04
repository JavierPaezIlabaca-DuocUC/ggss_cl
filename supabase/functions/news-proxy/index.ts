// ============================================================
// news-proxy/index.ts
// Edge Function de Supabase que actúa como proxy para la API
// de Google Custom Search, resolviendo el error CORS que ocurre
// cuando Flutter Web intenta llamar a Google directamente.
//
// Endpoint: GET /functions/v1/news-proxy?q=<query>
// Responde con el JSON de Google Custom Search.
// ============================================================

// Credenciales de Google Custom Search (almacenadas server-side)
const GOOGLE_API_KEY = "AIzaSyDA0VkjJbHIdMeE6i3CXajfhJPb3-LkzKc";
const GOOGLE_CSE_ID = "00e582294d1a54e57";
const DEFAULT_QUERY = "seguridad privada Chile guardias";
const GOOGLE_CSE_BASE_URL = "https://www.googleapis.com/customsearch/v1";

// Cabeceras CORS necesarias para permitir peticiones desde el navegador
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

Deno.serve(async (req: Request): Promise<Response> => {
  // ----------------------------------------------------------
  // Preflight CORS (petición OPTIONS del navegador)
  // ----------------------------------------------------------
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  try {
    // ----------------------------------------------------------
    // Leer el parámetro de búsqueda desde la URL
    // ----------------------------------------------------------
    const url = new URL(req.url);
    const query = url.searchParams.get("q")?.trim() || DEFAULT_QUERY;

    // ----------------------------------------------------------
    // Construir URL de Google Custom Search con parámetros
    // ----------------------------------------------------------
    const googleUrl = new URL(GOOGLE_CSE_BASE_URL);
    googleUrl.searchParams.set("key", GOOGLE_API_KEY);
    googleUrl.searchParams.set("cx", GOOGLE_CSE_ID);
    googleUrl.searchParams.set("q", query);
    googleUrl.searchParams.set("num", "10");
    googleUrl.searchParams.set("sort", "date");
    googleUrl.searchParams.set("lr", "lang_es");
    googleUrl.searchParams.set("gl", "cl");

    // ----------------------------------------------------------
    // Llamar a Google Custom Search desde el servidor
    // ----------------------------------------------------------
    const googleResponse = await fetch(googleUrl.toString());

    if (!googleResponse.ok) {
      const errorText = await googleResponse.text();
      return new Response(
        JSON.stringify({
          error: `Error de Google API: ${googleResponse.status}`,
          detail: errorText,
        }),
        {
          status: googleResponse.status,
          headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
        },
      );
    }

    const data = await googleResponse.json();

    // ----------------------------------------------------------
    // Devolver la respuesta al cliente Flutter con cabeceras CORS
    // ----------------------------------------------------------
    return new Response(JSON.stringify(data), {
      status: 200,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (error) {
    // ----------------------------------------------------------
    // Error inesperado del servidor
    // ----------------------------------------------------------
    return new Response(
      JSON.stringify({
        error: "Error interno del servidor",
        detail: String(error),
      }),
      {
        status: 500,
        headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
      },
    );
  }
});

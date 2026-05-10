// ============================================================
// news-proxy/index.ts
// Edge Function que obtiene noticias desde Google News RSS.
//
// Flujo:
//   1. Fetch del RSS de Google News (server-side, sin restricciones CORS)
//   2. Parseo del XML y extracción de campos relevantes
//   3. Respuesta JSON normalizada al cliente Flutter
//
// Endpoint: GET /functions/v1/news-proxy
// Retorna: JSON array de { title, description, url, publishedAt, source }
// ============================================================

// URL del feed RSS de Google News — seguridad privada Chile
const RSS_URL =
  "https://news.google.com/rss/search?q=seguridad+privada+Chile+guardias&hl=es-419&gl=CL&ceid=CL:es-419";

// Número máximo de artículos a retornar
const MAX_ITEMS = 20;

// Cabeceras CORS necesarias para peticiones desde el navegador / Flutter Web
const CORS_HEADERS = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

// ============================================================
// Utilidades de parseo RSS/XML
// ============================================================

/**
 * Extrae el contenido de texto de un tag XML específico.
 * Maneja secciones CDATA: <![CDATA[...]]>
 */
function getTagContent(xml: string, tag: string): string {
  const regex = new RegExp(
    `<${tag}(?:[^>]*)?>([\\s\\S]*?)<\\/${tag}>`,
    "i",
  );
  const match = xml.match(regex);
  if (!match) return "";

  const raw = match[1].trim();

  // Eliminar envoltura CDATA si existe
  const cdataMatch = raw.match(/^<!\[CDATA\[([\s\S]*?)\]\]>$/);
  return cdataMatch ? cdataMatch[1].trim() : raw;
}

/**
 * Elimina etiquetas HTML y decodifica entidades HTML comunes.
 * Usado para limpiar el campo <description> que suele tener HTML.
 *
 * IMPORTANTE: decodificar entidades PRIMERO para que &lt;a&gt; → <a>
 * quede visible antes de que el regex de strip lo elimine.
 */
function stripHtml(html: string): string {
  // Paso 1: decodificar entidades HTML para que los tags codificados
  // como &lt;a href=...&gt; se conviertan en tags reales <a href=...>
  const decoded = html
    .replace(/&amp;/g, "&")
    .replace(/&lt;/g, "<")
    .replace(/&gt;/g, ">")
    .replace(/&quot;/g, '"')
    .replace(/&#39;/g, "'")
    .replace(/&nbsp;/g, " ");

  // Paso 2: eliminar todas las etiquetas HTML y colapsar espacios
  return decoded
    .replace(/<[^>]*>/g, " ")   // Eliminar todas las etiquetas HTML
    .replace(/\s+/g, " ")       // Colapsar espacios múltiples
    .trim();
}

/**
 * Extrae el nombre de la fuente desde el tag <source url="...">Name</source>.
 * Si el tag no existe, retorna cadena vacía.
 */
function extractSourceName(itemXml: string): string {
  const match = itemXml.match(/<source(?:[^>]*)>([^<]*)<\/source>/i);
  return match ? match[1].trim() : "";
}

/**
 * Convierte una fecha RSS (RFC 822) a cadena ISO 8601.
 * Retorna null si la fecha no puede parsearse.
 */
function normalizePubDate(pubDate: string): string | null {
  if (!pubDate.trim()) return null;
  try {
    const date = new Date(pubDate.trim());
    return isNaN(date.getTime()) ? null : date.toISOString();
  } catch {
    return null;
  }
}

// ============================================================
// Tipo de artículo normalizado
// ============================================================

interface NewsItem {
  title: string;
  description: string;
  url: string;
  publishedAt: string | null;
  source: string;
}

/**
 * Parsea el texto XML del RSS y extrae los artículos de cada <item>.
 * Retorna hasta MAX_ITEMS artículos con título no vacío.
 */
function parseRss(rssText: string): NewsItem[] {
  const items: NewsItem[] = [];
  const itemRegex = /<item>([\s\S]*?)<\/item>/gi;

  let match: RegExpExecArray | null;

  while (
    (match = itemRegex.exec(rssText)) !== null &&
    items.length < MAX_ITEMS
  ) {
    const itemXml = match[1];

    const title = stripHtml(getTagContent(itemXml, "title"));

    // Ignorar artículos sin título
    if (!title) continue;

    const rawDescription = getTagContent(itemXml, "description");
    const description = stripHtml(rawDescription) || title;
    const url = getTagContent(itemXml, "link");
    const pubDate = getTagContent(itemXml, "pubDate");
    const source = extractSourceName(itemXml);

    items.push({
      title,
      description,
      url,
      publishedAt: normalizePubDate(pubDate),
      source,
    });
  }

  return items;
}

// ============================================================
// Handler principal de la Edge Function
// ============================================================

Deno.serve(async (req: Request): Promise<Response> => {
  // ----------------------------------------------------------
  // Preflight CORS (petición OPTIONS del navegador)
  // ----------------------------------------------------------
  if (req.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: CORS_HEADERS });
  }

  try {
    // ----------------------------------------------------------
    // Fetch del RSS de Google News desde el servidor
    // ----------------------------------------------------------
    const rssResponse = await fetch(RSS_URL, {
      headers: {
        // User-Agent de navegador para evitar bloqueos
        "User-Agent":
          "Mozilla/5.0 (compatible; GGSS.cl/1.0; +https://ggss.cl)",
        "Accept": "application/rss+xml, application/xml, text/xml, */*",
      },
    });

    if (!rssResponse.ok) {
      return new Response(
        JSON.stringify({
          error: `Error al obtener RSS: ${rssResponse.status}`,
        }),
        {
          status: rssResponse.status,
          headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
        },
      );
    }

    const rssText = await rssResponse.text();

    // ----------------------------------------------------------
    // Parseo del XML y normalización de los artículos
    // ----------------------------------------------------------
    const items = parseRss(rssText);

    // ----------------------------------------------------------
    // Respuesta JSON al cliente
    // ----------------------------------------------------------
    return new Response(JSON.stringify(items), {
      status: 200,
      headers: { ...CORS_HEADERS, "Content-Type": "application/json" },
    });
  } catch (error) {
    // ----------------------------------------------------------
    // Error inesperado — respuesta de error con detalle
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

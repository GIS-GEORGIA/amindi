// CORS proxy for meteo.gov.ge, used by the web build of the amindi app.
//
// meteo.gov.ge sends no Access-Control-Allow-Origin header, so the browser
// blocks direct requests from meteo.qgis.ge. This Worker fetches the page
// server-side (no CORS in a Worker) and re-serves it with permissive CORS.
//
// It is NOT an open proxy: the upstream host is hard-coded to meteo.gov.ge,
// so the incoming path/query is the only thing a caller controls.

const UPSTREAM = 'https://meteo.gov.ge';
const ALLOWED_METHODS = new Set(['GET', 'HEAD', 'OPTIONS']);

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, HEAD, OPTIONS',
    'Access-Control-Allow-Headers': '*',
    'Cache-Control': 'public, max-age=300',
  };
}

export default {
  async fetch(request) {
    if (request.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders() });
    }
    if (!ALLOWED_METHODS.has(request.method)) {
      return new Response('Method not allowed', {
        status: 405,
        headers: corsHeaders(),
      });
    }

    const incoming = new URL(request.url);
    const target = UPSTREAM + incoming.pathname + incoming.search;

    let upstream;
    try {
      upstream = await fetch(target, {
        method: request.method,
        headers: {
          'User-Agent': 'meteo.qgis.ge-proxy/1.0 (weather app)',
          Accept: request.headers.get('accept') || 'text/html',
          'Accept-Language': 'ka,en;q=0.8',
        },
        redirect: 'follow',
      });
    } catch (e) {
      return new Response('Upstream fetch failed: ' + e, {
        status: 502,
        headers: corsHeaders(),
      });
    }

    const headers = new Headers(upstream.headers);
    for (const [key, value] of Object.entries(corsHeaders())) {
      headers.set(key, value);
    }
    // Drop headers that would stop the app from embedding/reading the body.
    headers.delete('content-security-policy');
    headers.delete('x-frame-options');
    headers.delete('content-encoding');
    headers.delete('content-length');

    return new Response(upstream.body, {
      status: upstream.status,
      statusText: upstream.statusText,
      headers,
    });
  },
};

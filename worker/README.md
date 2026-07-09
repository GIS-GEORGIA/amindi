# meteo.gov.ge CORS proxy (Cloudflare Worker)

The web build of amindi (`meteo.qgis.ge`) can't call `meteo.gov.ge` directly:
that host sends no CORS headers, so the browser blocks the request. This Worker
fetches the page server-side and re-serves it with permissive CORS.

- **Upstream is hard-coded** to `https://meteo.gov.ge` — the caller only controls
  the path, so this is not an open proxy.
- Deployed at **`https://meteo-proxy.qgis.ge`**; `…/natural-disaster` maps to
  `https://meteo.gov.ge/natural-disaster`, etc.
- The Flutter app uses this base **only on web** (`kIsWeb`); native builds call
  meteo.gov.ge directly (see `lib/features/nea/data/nea_endpoints.dart`).

## Deploy

```bash
cd worker
npx wrangler login       # one-time, opens the browser
npx wrangler deploy
```

`custom_domain = true` in `wrangler.toml` makes wrangler create the
`meteo-proxy.qgis.ge` DNS record on the qgis.ge zone automatically.

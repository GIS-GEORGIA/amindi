import 'package:flutter/foundation.dart';

/// Base URL for meteo.gov.ge requests.
///
/// Native builds hit meteo.gov.ge directly. The web build must go through the
/// Cloudflare Worker proxy (`worker/`) because meteo.gov.ge sends no CORS
/// headers and the browser would block a direct call. The proxy passes the
/// path straight through, so only the host changes.
const String _directBase = 'https://meteo.gov.ge';
const String _proxyBase = 'https://meteo-proxy.qgis.ge';

String get neaBaseUrl => kIsWeb ? _proxyBase : _directBase;

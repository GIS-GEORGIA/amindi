import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'models/forecasts.dart';

/// meteo.gov.ge-ს პროგნოზების წამკითხავი სერვისი.
///
/// სამი წყარო:
///   • /Ge/Regions       — რეგიონული პროგნოზი (⚠️ JS-რენდერი — raw HTTP-ზე
///                         კონტენტი არ ჩანს, ამიტომ ამ სახით `null`-ს აბრუნებს;
///                         მოითხოვს proxy-ს ან სააგენტოს JSON endpoint-ს)
///   • /Ge/Months        — თვეების სია → /Ge/Month/{id} detail გვერდები
///   • /Ge/Seasons       — სეზონების სია → /Ge/Season/{id} detail გვერდები
///
/// სია-გვერდებიდან ვიღებთ პირველ (უახლეს) ჩანაწერს და მის detail გვერდს.
///
/// შენიშვნა: საიტი "სატესტო რეჟიმშია"; parsing მოქნილია, გატეხვაზე null.
/// Web-ზე CORS-ის გამო მოთხოვნები ჩავარდება (იხ. [WarningService]).
class ForecastService {
  ForecastService({http.Client? client, this.baseUrl = _base})
      : _client = client ?? http.Client();

  static const _base = 'https://meteo.gov.ge';

  final http.Client _client;
  final String baseUrl;

  Future<String?> _get(String url) async {
    try {
      final resp = await _client.get(
        Uri.parse(url),
        headers: {
          if (!kIsWeb) 'User-Agent': 'meteo.qgis.ge-app/1.0',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 20));
      return resp.statusCode == 200 ? resp.body : null;
    } catch (e) {
      debugPrint('ForecastService._get error ($url): $e');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // რეგიონები
  // ---------------------------------------------------------------------------

  Future<RegionForecast?> fetchRegions() async {
    final html = await _get('$baseUrl/Ge/Regions');
    if (html == null) return null;
    return parseRegions(html);
  }

  /// public — ტესტისთვის. აჯგუფებს კონტენტს დღეებად.
  RegionForecast? parseRegions(String html) {
    final doc = html_parser.parse(html);

    // ვიპოვოთ "პროგნოზი რეგიონებისთვის" heading-ის კონტეინერი.
    final anchor = doc
        .querySelectorAll('h1, h2, h3, h4')
        .cast<dom.Element?>()
        .firstWhere(
          (e) => e != null && e.text.contains('პროგნოზი რეგიონებისთვის'),
          orElse: () => null,
        );

    // კონტეინერი: heading-ის მშობელი, ან მთელი body fallback-ად.
    final dom.Element scope =
        anchor?.parent ?? doc.body ?? doc.documentElement!;

    // ტექსტურ ბლოკებად დაშლა. საიტი bold-ს იყენებს თარიღებისა და
    // "დასავლეთ/აღმოსავლეთ საქართველოში" ლეიბლებისთვის, მაგრამ საიმედოობის
    // მიზნით ტექსტს ხაზებად ვშლით და regex-ით ვცნობთ თარიღებს.
    final rawLines = scope.text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final dateRe = RegExp(r'^\d{1,2}\s+\S+ს\s*-'); // "9 ივლისს -"
    final days = <RegionDayForecast>[];
    String? curDate;
    String? west;
    String? east;

    void flush() {
      if (curDate != null && (west != null || east != null)) {
        days.add(RegionDayForecast(date: curDate, west: west, east: east));
      }
    }

    for (final line in rawLines) {
      if (dateRe.hasMatch(line)) {
        flush();
        curDate = line;
        west = null;
        east = null;
      } else if (line.startsWith('დასავლეთ') && curDate != null) {
        west = _afterDash(line);
      } else if (line.startsWith('აღმოსავლეთ') && curDate != null) {
        east = _afterDash(line);
      } else if (curDate != null) {
        // გაგრძელების ხაზი — მივაბათ ბოლო შევსებულ ველს.
        if (east != null) {
          east = '$east $line';
        } else if (west != null) {
          west = '$west $line';
        }
      }
    }
    flush();

    if (days.isEmpty) return null;
    return RegionForecast(days: days, fetchedAt: DateTime.now());
  }

  String _afterDash(String line) {
    final idx = line.indexOf('-');
    return idx >= 0 ? line.substring(idx + 1).trim() : line.trim();
  }

  // ---------------------------------------------------------------------------
  // თვის პროგნოზი
  // ---------------------------------------------------------------------------

  Future<LongRangeForecast?> fetchLatestMonth() async {
    final listHtml = await _get('$baseUrl/Ge/Months');
    if (listHtml == null) return null;
    final detailUrl = _firstDetailLink(listHtml, '/Ge/Month/');
    if (detailUrl == null) return null;
    final detailHtml = await _get(detailUrl);
    if (detailHtml == null) return null;
    return parseDetail(detailHtml, detailUrl);
  }

  // ---------------------------------------------------------------------------
  // სეზონის პროგნოზი
  // ---------------------------------------------------------------------------

  Future<LongRangeForecast?> fetchLatestSeason() async {
    final listHtml = await _get('$baseUrl/Ge/Seasons');
    if (listHtml == null) return null;
    final detailUrl = _firstDetailLink(listHtml, '/Ge/Season/');
    if (detailUrl == null) return null;
    final detailHtml = await _get(detailUrl);
    if (detailHtml == null) return null;
    return parseDetail(detailHtml, detailUrl);
  }

  /// სია-გვერდიდან პირველი detail ლინკის ამოღება (უახლესი ჩანაწერი).
  /// public — ტესტისთვის.
  String? firstDetailLink(String listHtml, String pathPrefix) =>
      _firstDetailLink(listHtml, pathPrefix);

  String? _firstDetailLink(String listHtml, String pathPrefix) {
    final doc = html_parser.parse(listHtml);
    for (final a in doc.querySelectorAll('a')) {
      final href = a.attributes['href'] ?? '';
      // ვცნობთ როგორც სრულ, ისე ფარდობით URL-ს, და ვრიცხავთ pageSize/page-ს.
      final matches = href.contains(pathPrefix) &&
          RegExp(RegExp.escape(pathPrefix) + r'\d+$').hasMatch(href);
      if (matches) {
        return href.startsWith('http') ? href : '$baseUrl$href';
      }
    }
    return null;
  }

  /// detail გვერდის (თვე ან სეზონი) parsing.
  /// public — ტესტისთვის.
  LongRangeForecast? parseDetail(String html, String detailUrl) {
    final doc = html_parser.parse(html);

    // სათაური: პირველი მნიშვნელოვანი heading, რომელიც "პროგნოზ"-ს შეიცავს.
    String title = '';
    for (final h in doc.querySelectorAll('h1, h2, h3')) {
      final t = h.text.trim();
      if (t.contains('პროგნოზ') && t.length > title.length) title = t;
    }

    // ტექსტი: ვცდილობთ ვიპოვოთ ძირითადი კონტენტის კონტეინერი. საიტს არა აქვს
    // სუფთა semantic markup, ამიტომ ვკრებთ <p> ელემენტებს, რომლებიც შინაარსობრივ
    // ტექსტს შეიცავს (ტემპერატურა/ნალექი/რაიონი) და ვფილტრავთ ნავიგაციას.
    final paras = <String>[];
    final seen = <String>{};
    for (final p in doc.querySelectorAll('p')) {
      final t = p.text.trim();
      if (t.length < 20) continue; // მოკლე = სავარაუდოდ ნავიგაცია/ლეიბლი
      if (_isNav(t)) continue;
      if (seen.add(t)) paras.add(t);
    }

    // fallback: თუ <p>-ებით ვერაფერი მოვიპოვეთ, ავიღოთ ყველაზე დიდი
    // ტექსტიანი <div> და მისი ტექსტი.
    String body;
    if (paras.length >= 2) {
      body = paras.join('\n\n');
    } else {
      dom.Element? biggest;
      int max = 0;
      for (final div in doc.querySelectorAll('div')) {
        final len = div.text.trim().length;
        if (len > max && div.querySelectorAll('div').length < 3) {
          max = len;
          biggest = div;
        }
      }
      body = biggest?.text.trim() ?? '';
    }

    if (body.trim().isEmpty) return null;

    return LongRangeForecast(
      title: title.isEmpty ? 'პროგნოზი' : title,
      body: body,
      detailUrl: detailUrl,
      fetchedAt: DateTime.now(),
    );
  }

  bool _isNav(String t) {
    const navMarkers = [
      'ცხელი ხაზი',
      'ონლაინ დახმარება',
      'მენიუ',
      'ჩვენ შესახებ',
      'ყველა უფლება დაცულია',
      'გამოიწერეთ ამინდი',
      'პროგნოზი ქალაქებისთვის',
      'search form',
    ];
    return navMarkers.any((m) => t.contains(m));
  }

  void dispose() => _client.close();
}

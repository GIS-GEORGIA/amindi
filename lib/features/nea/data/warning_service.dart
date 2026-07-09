import 'package:flutter/foundation.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

import 'models/weather_warning.dart';

/// meteo.gov.ge-დან გაფრთხილებების წამკითხავი სერვისი.
///
/// წყარო: მთავარი გვერდი `/natural-disaster`, სადაც warning ბლოკი
/// (`#გაფრთხილება!` სათაურით და "საფრთხის დონე ..." სტრიქონებით)
/// სერვერზე რენდერდება (curl-ითაც ჩანს). `/Warnings` ცალკე გვერდი ტექსტს
/// სტაბილურად არ აბრუნებდა, ამიტომ მთავარ გვერდზე ვჩერდებით.
///
/// მნიშვნელოვანი: საიტი "სატესტო რეჟიმშია" (თავად წერს header-ში),
/// ამიტომ markup შეიძლება შეიცვალოს. parsing განზრახ მოქნილია და
/// გატეხვის შემთხვევაში `null`-ს აბრუნებს (crash-ის ნაცვლად).
///
/// Web: ბრაუზერი `User-Agent`-ს ვერ დააყენებს და meteo.gov.ge CORS-ს არ
/// უშვებს, ამიტომ web-ზე მოთხოვნა ჩავარდება და `null` დაბრუნდება (banner
/// უბრალოდ არ გამოჩნდება). სრული ფუნქციონალი მობილურზეა.
class WarningService {
  WarningService({http.Client? client, this.sourceUrl = _defaultUrl})
      : _client = client ?? http.Client();

  static const _defaultUrl = 'https://meteo.gov.ge/natural-disaster';

  final http.Client _client;
  final String sourceUrl;

  /// გაფრთხილების წამოღება. აბრუნებს `null`-ს ქსელის ან parsing შეცდომაზე.
  Future<WeatherWarning?> fetchWarning() async {
    try {
      final resp = await _client.get(
        Uri.parse(sourceUrl),
        headers: {
          // ბრაუზერი User-Agent-ის ხელით დაყენებას კრძალავს.
          if (!kIsWeb) 'User-Agent': 'meteo.qgis.ge-app/1.0 (weather warnings)',
          'Accept': 'text/html',
        },
      ).timeout(const Duration(seconds: 20));

      if (resp.statusCode != 200) return null;

      return parseHtml(resp.body);
    } catch (e) {
      debugPrint('WarningService.fetchWarning error: $e');
      return null;
    }
  }

  /// HTML-ის დაპარსვა WeatherWarning-ად. public — რომ ტესტში მოვახდინოთ
  /// mock HTML-ზე გაშვება ქსელის გარეშე.
  ///
  /// სტრატეგია (მრავალდონიანი fallback, რომ markup-ის ცვლილებას გაუძლოს):
  ///   1. ვეძებთ ელემენტს, რომელიც შეიცავს "გაფრთხილება"-ს.
  ///   2. მისი კონტეინერიდან ვკრებთ ტექსტურ სტრიქონებს.
  ///   3. ვფილტრავთ "საფრთხის დონე"-ს და შინაარსობრივ სტრიქონებს.
  WeatherWarning? parseHtml(String htmlBody) {
    final doc = html_parser.parse(htmlBody);

    // 1. ვიპოვოთ warning-ის კონტეინერი "გაფრთხილება" საკვანძო სიტყვით.
    final anchor = _findWarningAnchor(doc);
    if (anchor == null) return null;

    // 2. კონტეინერის (ან უახლოესი მნიშვნელოვანი მშობლის) ტექსტი.
    final container = _bestContainer(anchor);
    final rawText = container.text.trim();

    if (rawText.isEmpty || !rawText.contains('გაფრთხილება')) return null;

    // 3. სტრიქონებად დაშლა და გაწმენდა.
    final messages = _extractMessages(container);

    return WeatherWarning(
      messages: messages,
      rawText: rawText,
      level: WarningLevel.fromText(rawText),
      fetchedAt: DateTime.now(),
    );
  }

  /// ვეძებთ პირველ ელემენტს, რომლის ტექსტში "გაფრთხილება" გვხვდება.
  dom.Element? _findWarningAnchor(dom.Document doc) {
    // ჯერ სათაურები (h1-h6), სადაც "#გაფრთხილება!" გამოჩნდა.
    for (final tag in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']) {
      for (final el in doc.querySelectorAll(tag)) {
        if (el.text.contains('გაფრთხილება')) return el;
      }
    }
    // fallback: ნებისმიერი ელემენტი.
    for (final el in doc.querySelectorAll('*')) {
      // მხოლოდ leaf-თან ახლოს, რომ მთელი body არ დავიჭიროთ.
      if (el.text.contains('გაფრთხილება') && el.children.length <= 3) {
        return el;
      }
    }
    return null;
  }

  /// warning anchor-იდან ავდივართ მშობლებში, სანამ საზრიან კონტეინერს
  /// ვიპოვით (რომელიც "საფრთხის დონე"-საც შეიცავს), მაგრამ არა მთელ body-ს.
  dom.Element _bestContainer(dom.Element anchor) {
    dom.Element current = anchor;
    for (int i = 0; i < 5; i++) {
      final parent = current.parent;
      if (parent == null) break;
      // თუ მშობელი უკვე შეიცავს "საფრთხის დონე"-ს, ის კარგი კონტეინერია.
      if (parent.text.contains('საფრთხის დონე')) return parent;
      // body-მდე არ ავიდეთ.
      if (parent.localName == 'body') break;
      current = parent;
    }
    return current;
  }

  /// კონტეინერიდან ცალკეული გაფრთხილების სტრიქონების ამოღება.
  List<String> _extractMessages(dom.Element container) {
    final seen = <String>{};
    final out = <String>[];

    // li და p ელემენტები ყველაზე ხშირად შეიცავს ცალკეულ გაფრთხილებებს.
    final candidates = <dom.Element>[
      ...container.querySelectorAll('li'),
      ...container.querySelectorAll('p'),
    ];

    for (final el in candidates) {
      final t = el.text.trim();
      if (t.isEmpty) continue;
      if (_isNoise(t)) continue;
      if (seen.add(t)) out.add(t);
    }

    // fallback: თუ li/p ვერაფერი მოვძებნეთ, დავშალოთ ტექსტი ხაზებად.
    if (out.isEmpty) {
      for (final line in container.text.split('\n')) {
        final t = line.trim();
        if (!_isNoise(t) && seen.add(t)) out.add(t);
      }
    }

    return out;
  }

  /// სათაურები, დონის ლეიბლები და ახსნები — ეს ცალკეული გაფრთხილება არაა.
  /// დონე ისედაც [WarningLevel]-შია, ბანერზე ჩიპად ჩანს.
  bool _isNoise(String t) {
    if (t.length < 4) return true;
    if (t == 'გაფრთხილება' || t == '#გაფრთხილება!') return true;
    if (t.startsWith('საფრთხის დონე')) return true;
    if (t.contains('მაფრთხილებელი ნიშნების')) return true;
    return false;
  }

  void dispose() => _client.close();
}

import 'package:amindi/features/nea/data/models/weather_warning.dart';
import 'package:amindi/features/nea/data/warning_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = WarningService();

  group('WarningLevel.fromText', () {
    test('picks the highest level when several appear', () {
      expect(WarningLevel.fromText('საფრთხის დონე დაბალი და მაღალი'),
          WarningLevel.high);
      expect(WarningLevel.fromText('საფრთხის დონე საშუალო'),
          WarningLevel.medium);
      expect(WarningLevel.fromText('საფრთხის დონე დაბალი'), WarningLevel.low);
      expect(WarningLevel.fromText('ტექსტი დონის გარეშე'),
          WarningLevel.unknown);
    });
  });

  group('parseHtml', () {
    const warningHtml = '''
    <html><body>
      <div class="header">meteo.gov.ge სატესტო რეჟიმი</div>
      <section>
        <h3>#გაფრთხილება!</h3>
        <div>
          <p>საფრთხის დონე მაღალი</p>
          <ul>
            <li>სანაპირო ზოლში ძლიერი ქარი, ბათუმში შტორმი</li>
            <li>აღმოსავლეთ საქართველოში ძლიერი წვიმა და სეტყვა</li>
          </ul>
        </div>
      </section>
    </body></html>
    ''';

    test('extracts messages and the highest hazard level', () {
      final w = service.parseHtml(warningHtml);
      expect(w, isNotNull);
      expect(w!.level, WarningLevel.high);
      expect(w.messages, contains('სანაპირო ზოლში ძლიერი ქარი, ბათუმში შტორმი'));
      expect(w.messages.any((m) => m.contains('სეტყვა')), isTrue);
      expect(w.isEmpty, isFalse);
    });

    test('returns null when the page has no warning block', () {
      expect(service.parseHtml('<html><body>დღის ამინდი</body></html>'),
          isNull);
    });
  });

  group('WeatherWarning JSON + equality', () {
    test('round-trips through JSON', () {
      final w = WeatherWarning(
        messages: const ['ძლიერი ქარი'],
        rawText: 'საფრთხის დონე მაღალი ძლიერი ქარი',
        level: WarningLevel.high,
        fetchedAt: DateTime(2026, 7, 9, 12),
      );
      final restored = WeatherWarning.fromJson(w.toJson());
      expect(restored.level, WarningLevel.high);
      expect(restored.messages, ['ძლიერი ქარი']);
      expect(restored, equals(w)); // equality by signature
    });
  });
}

import 'package:amindi/features/nea/data/forecast_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = ForecastService();

  group('parseRegions', () {
    const regionsHtml = '''
    <html><body>
      <div class="menu">გაფრთხილებები პროგნოზი ქალაქებისთვის</div>
      <div class="content">
        <h2>პროგნოზი რეგიონებისთვის</h2>
        <p><b>9 ივლისს - ხუთშაბათს</b></p>
        <p><b>დასავლეთ საქართველოში</b> - ღრუბლიანობის მომატება, ხანმოკლე წვიმა.</p>
        <p><b>აღმოსავლეთ საქართველოში</b> - ხანმოკლე წვიმა და ელჭექი, ზოგან ძლიერი.</p>
        <p><b>10 ივლისს - პარასკევს</b></p>
        <p><b>დასავლეთ საქართველოში</b> - ზოგან ხანმოკლე წვიმა.</p>
        <p><b>აღმოსავლეთ საქართველოში</b> - ღამით ძლიერი და სეტყვა.</p>
      </div>
    </body></html>
    ''';

    test('groups content into days with west and east', () {
      final f = service.parseRegions(regionsHtml);
      expect(f, isNotNull);
      expect(f!.days.length, 2);
      expect(f.days.first.date, contains('9 ივლისს'));
      expect(f.days.first.west, contains('ღრუბლიანობის'));
      expect(f.days.first.east, contains('ელჭექი'));
      expect(f.days[1].date, contains('10 ივლისს'));
    });

    test('returns null when no region content', () {
      expect(service.parseRegions('<html><body>დღის ამინდი</body></html>'),
          isNull);
    });
  });

  group('firstDetailLink', () {
    const monthsHtml = '''
    <html><body>
      <a href="https://meteo.gov.ge/Ge/Month/54">ივლისი 2026</a>
      <a href="https://meteo.gov.ge/Ge/Month/53">ივნისი 2026</a>
      <a href="https://meteo.gov.ge/Ge/Months?page=2&pageSize=9">2</a>
    </body></html>
    ''';

    test('picks first (latest) detail link, excludes pagination', () {
      final link = service.firstDetailLink(monthsHtml, '/Ge/Month/');
      expect(link, 'https://meteo.gov.ge/Ge/Month/54');
    });

    test('handles relative hrefs', () {
      const rel =
          '<html><body><a href="/Ge/Season/22">ზაფხული</a></body></html>';
      final link = service.firstDetailLink(rel, '/Ge/Season/');
      expect(link, 'https://meteo.gov.ge/Ge/Season/22');
    });
  });

  group('parseDetail', () {
    const detailHtml = '''
    <html><body>
      <div class="menu">ცხელი ხაზი 1501 მენიუ ჩვენ შესახებ</div>
      <h2>2026 წლის ივლისის თვის პროგნოზი</h2>
      <p>კლიმატური მონაცემებით ივლისის საშუალო ტემპერატურა ივნისთან შედარებით 2-3°C-ით მაღალია.</p>
      <p>ივლისი საქართველოს დიდ ნაწილში წლის ყველაზე ცხელი თვეა, ტემპერატურა +42°C-ს აღწევს.</p>
      <p>გამოიწერეთ ამინდი</p>
    </body></html>
    ''';

    test('extracts title and body, filters nav', () {
      final f =
          service.parseDetail(detailHtml, 'https://meteo.gov.ge/Ge/Month/54');
      expect(f, isNotNull);
      expect(f!.title, contains('ივლისის თვის პროგნოზი'));
      expect(f.body, contains('კლიმატური მონაცემებით'));
      expect(f.body, contains('ცხელი თვეა'));
      expect(f.body.contains('გამოიწერეთ ამინდი'), isFalse); // nav filtered
      expect(f.body.contains('ცხელი ხაზი'), isFalse);
      expect(f.detailUrl, endsWith('/54'));
    });
  });
}

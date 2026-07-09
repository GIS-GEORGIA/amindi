import 'package:amindi/core/constants/map_constants.dart';
import 'package:amindi/features/cities/data/georgian_cities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every bundled city sits inside the Georgia bounds', () {
    for (final city in georgianCities) {
      expect(
        MapConstants.georgiaBounds.contains(city.location),
        isTrue,
        reason: '${city.nameEn} (${city.lat}, ${city.lon}) is out of bounds',
      );
    }
  });

  test('no duplicate city names', () {
    final names = georgianCities.map((c) => c.name).toList();
    expect(names.toSet().length, names.length);
  });

  test('English names are unique and non-empty', () {
    final en = georgianCities.map((c) => c.nameEn).toList();
    expect(en.toSet().length, en.length);
    expect(en.every((n) => n.isNotEmpty), isTrue);
  });
}

import 'package:amindi/core/constants/map_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Georgia bounds contain the initial map center', () {
    expect(MapConstants.georgiaBounds.contains(MapConstants.georgiaCenter),
        isTrue);
  });

  test('zoom range is coherent', () {
    expect(MapConstants.minZoom, lessThan(MapConstants.initialZoom));
    expect(MapConstants.initialZoom, lessThan(MapConstants.maxZoom));
  });
}

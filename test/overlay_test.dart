import 'package:amindi/features/overlay/domain/overlay_grid.dart';
import 'package:amindi/features/overlay/domain/overlay_type.dart';
import 'package:amindi/features/overlay/presentation/overlay_renderer.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ColorScale', () {
    test('clamps below and above the stops', () {
      expect(temperatureScale.colorFor(-100),
          temperatureScale.stops.first.$2);
      expect(temperatureScale.colorFor(100), temperatureScale.stops.last.$2);
    });

    test('interpolates between stops', () {
      final mid = temperatureScale.colorFor(5);
      final at0 = temperatureScale.colorFor(0);
      final at10 = temperatureScale.colorFor(10);
      expect(mid, Color.lerp(at0, at10, 0.5));
    });

    test('dry precipitation is fully transparent', () {
      expect(precipitationScale.colorFor(0).a, 0);
      expect(precipitationScale.colorFor(1).a, greaterThan(0));
    });
  });

  group('renderOverlayPng', () {
    OverlayGrid grid({double? holeValue = 15}) => OverlayGrid(
          lats: const [43.6, 42.3, 41.0],
          lons: const [40.0, 43.4, 46.8],
          times: [DateTime(2026, 7, 7, 12)],
          temperature: [
            [10, 20, 30, 15, holeValue, 25, 5, 10, 20]
          ],
          precipitation: [List.filled(9, 0.0)],
        );

    test('produces a PNG for a full grid', () async {
      final png = await renderOverlayPng(
        grid: grid(),
        type: OverlayType.temperature,
        timeIndex: 0,
      );
      // PNG magic bytes
      expect(png.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    });

    test('tolerates null cells (renders them transparent)', () async {
      final png = await renderOverlayPng(
        grid: grid(holeValue: null),
        type: OverlayType.temperature,
        timeIndex: 0,
      );
      expect(png, isNotEmpty);
    });

    test('clamps out-of-range time index', () async {
      final png = await renderOverlayPng(
        grid: grid(),
        type: OverlayType.precipitation,
        timeIndex: 99,
      );
      expect(png, isNotEmpty);
    });
  });
}

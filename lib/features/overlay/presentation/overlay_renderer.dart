import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../domain/overlay_grid.dart';
import '../domain/overlay_type.dart';

/// Piecewise-linear color scale: (value, ARGB color) stops, sorted by value.
class ColorScale {
  const ColorScale(this.stops);

  final List<(double, Color)> stops;

  Color colorFor(double value) {
    if (value <= stops.first.$1) return stops.first.$2;
    if (value >= stops.last.$1) return stops.last.$2;
    for (var i = 1; i < stops.length; i++) {
      if (value <= stops[i].$1) {
        final t = (value - stops[i - 1].$1) / (stops[i].$1 - stops[i - 1].$1);
        return Color.lerp(stops[i - 1].$2, stops[i].$2, t)!;
      }
    }
    return stops.last.$2;
  }
}

/// Temperature °C — alpha baked in so the base map stays readable.
const temperatureScale = ColorScale([
  (-25, Color(0x967B2ABF)),
  (-10, Color(0x963557D6)),
  (0, Color(0x962E9BD6)),
  (10, Color(0x963DB56F)),
  (20, Color(0x96EFC845)),
  (30, Color(0x96EF8C2A)),
  (40, Color(0x96D93025)),
]);

/// Precipitation mm/h — transparent when dry, ramping up in opacity.
const precipitationScale = ColorScale([
  (0.0, Color(0x007FC8F0)),
  (0.1, Color(0x507FC8F0)),
  (1.0, Color(0x8C4AA8E8)),
  (3.0, Color(0xB42563D9)),
  (8.0, Color(0xC87A3FD1)),
  (15.0, Color(0xDCD12FA8)),
]);

/// Renders one overlay frame as PNG bytes. The grid is upsampled with
/// bilinear interpolation; final smoothing is left to GPU image scaling.
Future<Uint8List> renderOverlayPng({
  required OverlayGrid grid,
  required OverlayType type,
  required int timeIndex,
  int scale = 8,
}) async {
  assert(type != OverlayType.none);
  final frame = timeIndex.clamp(0, grid.times.length - 1);
  final values = type == OverlayType.temperature
      ? grid.temperature[frame]
      : grid.precipitation[frame];
  final colorScale = type == OverlayType.temperature
      ? temperatureScale
      : precipitationScale;

  final rows = grid.rows;
  final cols = grid.cols;
  final width = (cols - 1) * scale + 1;
  final height = (rows - 1) * scale + 1;
  final pixels = Uint8List(width * height * 4);

  for (var y = 0; y < height; y++) {
    final gy = y / scale;
    final r0 = gy.floor().clamp(0, rows - 2);
    final fy = gy - r0;
    for (var x = 0; x < width; x++) {
      final gx = x / scale;
      final c0 = gx.floor().clamp(0, cols - 2);
      final fx = gx - c0;

      final v00 = values[r0 * cols + c0];
      final v01 = values[r0 * cols + c0 + 1];
      final v10 = values[(r0 + 1) * cols + c0];
      final v11 = values[(r0 + 1) * cols + c0 + 1];
      if (v00 == null || v01 == null || v10 == null || v11 == null) {
        continue; // leave transparent
      }

      final value = v00 * (1 - fx) * (1 - fy) +
          v01 * fx * (1 - fy) +
          v10 * (1 - fx) * fy +
          v11 * fx * fy;
      final color = colorScale.colorFor(value);

      final offset = (y * width + x) * 4;
      pixels[offset] = (color.r * 255).round();
      pixels[offset + 1] = (color.g * 255).round();
      pixels[offset + 2] = (color.b * 255).round();
      pixels[offset + 3] = (color.a * 255).round();
    }
  }

  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
      pixels, width, height, ui.PixelFormat.rgba8888, completer.complete);
  final image = await completer.future;
  final png = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();
  return png!.buffer.asUint8List();
}

import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/api_client.dart';
import '../../data/overlay_grid_api.dart';
import '../../domain/overlay_grid.dart';
import '../../domain/overlay_type.dart';
import '../overlay_renderer.dart';

final overlayTypeProvider =
    NotifierProvider<OverlayTypeNotifier, OverlayType>(OverlayTypeNotifier.new);

class OverlayTypeNotifier extends Notifier<OverlayType> {
  @override
  OverlayType build() => OverlayType.none;

  void set(OverlayType type) => state = type;
}

final overlayTimeIndexProvider =
    NotifierProvider<OverlayTimeIndexNotifier, int>(OverlayTimeIndexNotifier.new);

class OverlayTimeIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int index) => state = index;
}

/// One grid fetch covers both layer types and all slider frames; cached for
/// the app session (not autoDispose) so toggling layers doesn't refetch.
final overlayGridProvider = FutureProvider<OverlayGrid>(
  (ref) => OverlayGridApi(ref.watch(dioProvider)).fetch(),
);

typedef OverlayFrame = ({OverlayType type, int timeIndex});

final overlayImageProvider =
    FutureProvider.autoDispose.family<Uint8List, OverlayFrame>(
  (ref, frame) async {
    final grid = await ref.watch(overlayGridProvider.future);
    return renderOverlayPng(
      grid: grid,
      type: frame.type,
      timeIndex: frame.timeIndex,
    );
  },
);

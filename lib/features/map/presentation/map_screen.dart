import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/map_constants.dart';
import '../../forecast/presentation/widgets/comparison_panel.dart';
import '../../model_info/presentation/model_info_screen.dart';
import '../../nea/presentation/providers/nea_providers.dart';
import '../../nea/presentation/widgets/warning_banner.dart';
import '../../overlay/domain/overlay_type.dart';
import '../../overlay/presentation/providers/overlay_providers.dart';
import '../../overlay/presentation/widgets/overlay_controls.dart';
import '../../settings/presentation/settings_screen.dart';
import 'providers/base_map_opacity_provider.dart';

enum BaseLayer { standard, terrain }

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  BaseLayer _baseLayer = BaseLayer.standard;

  @override
  Widget build(BuildContext context) {
    final overlayType = ref.watch(overlayTypeProvider);
    final overlayTimeIndex = ref.watch(overlayTimeIndexProvider);

    // When an official warning banner is shown, push the top controls below it.
    final warning = ref.watch(warningProvider).value;
    final topInset = (warning != null && !warning.isEmpty) ? 44.0 : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: MapConstants.georgiaCenter,
              initialZoom: MapConstants.initialZoom,
              minZoom: MapConstants.minZoom,
              maxZoom: MapConstants.maxZoom,
              // containCenter instead of contain: Georgia's bounds are smaller
              // than a phone viewport at low zoom, which makes contain jitter.
              cameraConstraint: CameraConstraint.containCenter(
                bounds: MapConstants.georgiaBounds,
              ),
              onTap: (_, point) => _showPointSheet(context, point),
            ),
            children: [
              Opacity(
                opacity: ref.watch(baseMapOpacityProvider),
                child: TileLayer(
                  urlTemplate: _baseLayer == BaseLayer.standard
                      ? MapConstants.osmTileUrl
                      : MapConstants.openTopoTileUrl,
                  userAgentPackageName: MapConstants.userAgentPackageName,
                ),
              ),
              if (overlayType != OverlayType.none)
                ref
                    .watch(overlayImageProvider(
                        (type: overlayType, timeIndex: overlayTimeIndex)))
                    .maybeWhen(
                      data: (png) => OverlayImageLayer(
                        overlayImages: [
                          OverlayImage(
                            bounds: MapConstants.georgiaBounds,
                            imageProvider: MemoryImage(png),
                            gaplessPlayback: true,
                          ),
                        ],
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
              RichAttributionWidget(
                alignment: AttributionAlignment.bottomLeft,
                attributions: [
                  TextSourceAttribution(
                    _baseLayer == BaseLayer.standard
                        ? '© OpenStreetMap contributors'
                        : '© OpenTopoMap (CC-BY-SA) · © OpenStreetMap contributors',
                  ),
                  if (overlayType != OverlayType.none)
                    const TextSourceAttribution(
                        'Weather: Open-Meteo · ICON-EU'),
                ],
              ),
            ],
          ),
          const SafeArea(
            child: Align(
              alignment: Alignment.bottomRight,
              child: OverlayControls(),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: 8 + topInset, right: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton.filledTonal(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'settings.title'.tr(),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    IconButton.filledTonal(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'model_info.title'.tr(),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => const ModelInfoScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 8 + topInset),
                child: SegmentedButton<BaseLayer>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                    // On web the Georgian font loads after first layout and
                    // the segments get measured too narrow; a minimum size
                    // keeps them full-width from the first frame.
                    minimumSize: const Size(96, 40),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  segments: [
                    ButtonSegment(
                      value: BaseLayer.standard,
                      label: _segmentLabel('map.layer_standard'.tr()),
                    ),
                    ButtonSegment(
                      value: BaseLayer.terrain,
                      label: _segmentLabel('map.layer_terrain'.tr()),
                    ),
                  ],
                  selected: {_baseLayer},
                  onSelectionChanged: (selection) =>
                      setState(() => _baseLayer = selection.first),
                ),
              ),
            ),
          ),
          // Official NEA hazard warning, pinned to the very top (topmost so it
          // spans full width above the controls). Renders nothing when none.
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(bottom: false, child: WarningBanner()),
          ),
        ],
      ),
    );
  }

  /// Fixed-width, non-wrapping label: on web the Georgian font loads after
  /// first layout and mis-measured text otherwise renders squeezed/wrapped.
  Widget _segmentLabel(String text) => SizedBox(
        width: 64,
        child: Text(
          text,
          textAlign: TextAlign.center,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
        ),
      );

  void _showPointSheet(BuildContext context, LatLng point) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.7,
        child: ComparisonPanel(
          lat: point.latitude,
          lon: point.longitude,
        ),
      ),
    );
  }
}

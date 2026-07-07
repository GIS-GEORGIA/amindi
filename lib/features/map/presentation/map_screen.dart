import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/map_constants.dart';
import '../../forecast/presentation/widgets/comparison_panel.dart';
import '../../model_info/presentation/model_info_screen.dart';
import '../../overlay/domain/overlay_type.dart';
import '../../overlay/presentation/providers/overlay_providers.dart';
import '../../overlay/presentation/widgets/overlay_controls.dart';
import '../../settings/presentation/settings_screen.dart';

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
              TileLayer(
                urlTemplate: _baseLayer == BaseLayer.standard
                    ? MapConstants.osmTileUrl
                    : MapConstants.openTopoTileUrl,
                userAgentPackageName: MapConstants.userAgentPackageName,
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
                padding: const EdgeInsets.only(top: 8, right: 8),
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
                padding: const EdgeInsets.only(top: 8),
                child: SegmentedButton<BaseLayer>(
                  showSelectedIcon: false,
                  style: SegmentedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
                  ),
                  segments: [
                    ButtonSegment(
                      value: BaseLayer.standard,
                      label: Text('map.layer_standard'.tr()),
                    ),
                    ButtonSegment(
                      value: BaseLayer.terrain,
                      label: Text('map.layer_terrain'.tr()),
                    ),
                  ],
                  selected: {_baseLayer},
                  onSelectionChanged: (selection) =>
                      setState(() => _baseLayer = selection.first),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPointSheet(BuildContext context, LatLng point) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.95,
        snap: true,
        snapSizes: const [0.6, 0.95],
        builder: (context, scrollController) => ComparisonPanel(
          lat: point.latitude,
          lon: point.longitude,
          scrollController: scrollController,
        ),
      ),
    );
  }
}

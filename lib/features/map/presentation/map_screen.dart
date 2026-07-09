import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/map_constants.dart';
import '../../cities/presentation/city_search_delegate.dart';
import '../../cities/domain/georgian_city.dart';
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
  final MapController _mapController = MapController();
  GeorgianCity? _selectedCity;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _openCitySearch() async {
    final city = await showSearch<GeorgianCity?>(
      context: context,
      delegate: CitySearchDelegate(context.locale.languageCode),
    );
    if (city == null || !mounted) return;
    setState(() => _selectedCity = city);
    _mapController.move(city.location, 10);
    _showPointSheet(context, city.location);
  }

  @override
  Widget build(BuildContext context) {
    final overlayType = ref.watch(overlayTypeProvider);
    final overlayTimeIndex = ref.watch(overlayTimeIndexProvider);

    // The official warning banner sits in normal layout above the map (see
    // below), so it grows to fit its text and never overlaps the controls.
    final warning = ref.watch(warningProvider).value;
    final hasWarning = warning != null && !warning.isEmpty;

    final mapStack = Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
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
              if (_selectedCity != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedCity!.location,
                      width: 160,
                      height: 58,
                      alignment: Alignment.topCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on,
                              color: Theme.of(context).colorScheme.error,
                              size: 34),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              context.locale.languageCode == 'en'
                                  ? _selectedCity!.nameEn
                                  : _selectedCity!.name,
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: FloatingActionButton.small(
                  heroTag: 'citySearch',
                  tooltip: 'cities.search'.tr(),
                  onPressed: _openCitySearch,
                  child: const Icon(Icons.search),
                ),
              ),
            ),
          ),
        ],
      );

    return Scaffold(
      body: Column(
        children: [
          // Banner in normal layout so it grows to fit (up to 3 lines) and
          // pushes the map down instead of overlapping the controls. When it
          // consumes the top safe area, remove it for the map below so the
          // controls' own SafeArea doesn't double-count it.
          if (hasWarning)
            const SafeArea(bottom: false, child: WarningBanner()),
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeTop: hasWarning,
              child: mapStack,
            ),
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

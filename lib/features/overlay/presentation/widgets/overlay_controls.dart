import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../map/presentation/providers/base_map_opacity_provider.dart';
import '../../domain/overlay_type.dart';
import '../overlay_renderer.dart';
import '../providers/overlay_providers.dart';

/// Bottom map controls: layer picker button and, when a layer is active,
/// a card with the time slider and color legend.
class OverlayControls extends ConsumerWidget {
  const OverlayControls({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final type = ref.watch(overlayTypeProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          PopupMenuButton<OverlayType>(
            tooltip: 'overlay.layers'.tr(),
            initialValue: type,
            // Open upward so the menu never covers the slider card below
            // or clips at the bottom screen edge.
            position: PopupMenuPosition.over,
            offset: const Offset(0, -170),
            onSelected: (t) => ref.read(overlayTypeProvider.notifier).set(t),
            itemBuilder: (context) => [
              for (final t in OverlayType.values)
                PopupMenuItem(
                  value: t,
                  child: Text('overlay.${t.name}'.tr()),
                ),
            ],
            child: CircleAvatar(
              radius: 22,
              backgroundColor: type == OverlayType.none
                  ? theme.colorScheme.surface.withValues(alpha: 0.9)
                  : theme.colorScheme.primaryContainer,
              child: Icon(
                Icons.layers_outlined,
                color: type == OverlayType.none
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          if (type != OverlayType.none) ...[
            const SizedBox(height: 8),
            _SliderCard(type: type),
          ],
        ],
      ),
    );
  }
}

class _SliderCard extends ConsumerWidget {
  const _SliderCard({required this.type});

  final OverlayType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grid = ref.watch(overlayGridProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.opacity,
                    size: 18, color: theme.colorScheme.onSurfaceVariant),
                Expanded(
                  child: SizedBox(
                    height: 28,
                    child: Slider(
                      min: 0.2,
                      max: 1,
                      value: ref.watch(baseMapOpacityProvider),
                      onChanged: (v) => ref
                          .read(baseMapOpacityProvider.notifier)
                          .set(v),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 8),
            grid.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(8),
            child: LinearProgressIndicator(),
          ),
          error: (error, _) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('forecast.failed'.tr()),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => ref.invalidate(overlayGridProvider),
              ),
            ],
          ),
          data: (data) {
            final index = ref
                .watch(overlayTimeIndexProvider)
                .clamp(0, data.times.length - 1);
            final format =
                DateFormat('EEE HH:00', context.locale.languageCode);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      format.format(data.times[index]),
                      style: theme.textTheme.titleSmall,
                    ),
                    const Spacer(),
                    Text(
                      'ICON-EU',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
                SizedBox(
                  height: 28,
                  child: Slider(
                    value: index.toDouble(),
                    max: (data.times.length - 1).toDouble(),
                    divisions:
                        data.times.length > 1 ? data.times.length - 1 : null,
                    onChanged: (v) => ref
                        .read(overlayTimeIndexProvider.notifier)
                        .set(v.round()),
                  ),
                ),
                const SizedBox(height: 4),
                _Legend(type: type),
              ],
            );
          },
        ),
          ],
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.type});

  final OverlayType type;

  @override
  Widget build(BuildContext context) {
    final scale =
        type == OverlayType.temperature ? temperatureScale : precipitationScale;
    final labels = type == OverlayType.temperature
        ? const ['-10°', '0°', '10°', '20°', '30°']
        : const ['0.1', '1', '3', '8', '15 mm'];
    final style = Theme.of(context).textTheme.labelSmall;

    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              colors: [for (final stop in scale.stops) stop.$2.withValues(alpha: 1)],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [for (final label in labels) Text(label, style: style)],
        ),
      ],
    );
  }
}

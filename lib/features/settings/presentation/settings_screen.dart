import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../map/presentation/providers/base_map_opacity_provider.dart';
import 'providers/theme_mode_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: Text('settings.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'settings.language'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<Locale>(
            segments: const [
              ButtonSegment(value: Locale('ka'), label: Text('ქართული')),
              ButtonSegment(value: Locale('en'), label: Text('English')),
            ],
            selected: {context.locale},
            onSelectionChanged: (selection) =>
                context.setLocale(selection.first),
          ),
          const SizedBox(height: 24),
          Text(
            'settings.theme'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SegmentedButton<ThemeMode>(
            segments: [
              ButtonSegment(
                value: ThemeMode.light,
                icon: const Icon(Icons.light_mode_outlined),
                label: Text('settings.theme_light'.tr()),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                icon: const Icon(Icons.dark_mode_outlined),
                label: Text('settings.theme_dark'.tr()),
              ),
              ButtonSegment(
                value: ThemeMode.system,
                icon: const Icon(Icons.brightness_auto_outlined),
                label: Text('settings.theme_system'.tr()),
              ),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) =>
                ref.read(themeModeProvider.notifier).set(selection.first),
          ),
          const SizedBox(height: 24),
          Text(
            'settings.map_opacity'.tr(),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.opacity,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              Expanded(
                child: Slider(
                  min: 0.2,
                  max: 1,
                  value: ref.watch(baseMapOpacityProvider),
                  onChanged: (v) =>
                      ref.read(baseMapOpacityProvider.notifier).set(v),
                ),
              ),
              Text(
                '${(ref.watch(baseMapOpacityProvider) * 100).round()}%',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

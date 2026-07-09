import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/nea_providers.dart';

/// Latest monthly outlook text scraped from meteo.gov.ge (National
/// Environmental Agency). Shown on the model-info screen as an official,
/// human-written complement to the numeric models. Hidden on failure/empty
/// (e.g. web without the proxy reachable).
class OfficialForecastSection extends ConsumerWidget {
  const OfficialForecastSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthForecastProvider);
    final theme = Theme.of(context);

    return month.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (forecast) {
        if (forecast == null || forecast.isEmpty) return const SizedBox.shrink();
        return Card(
          color: theme.colorScheme.surfaceContainerHigh,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.public, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'model_info.official_title'.tr(),
                        style: theme.textTheme.labelLarge
                            ?.copyWith(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(forecast.title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(forecast.body, style: theme.textTheme.bodyMedium),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(forecast.detailUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new, size: 16),
                    label: Text('warning.source'.tr()),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

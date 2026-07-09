import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/weather_warning.dart';
import '../providers/nea_providers.dart';

const _sourceUrl = 'https://meteo.gov.ge/natural-disaster';

/// Slim tappable strip shown at the top of the map when the National
/// Environmental Agency has an active hazard warning. Renders nothing when
/// there is no warning (also the case on web, where CORS blocks the source).
class WarningBanner extends ConsumerWidget {
  const WarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warning = ref.watch(warningProvider).value;
    if (warning == null ||
        warning.isEmpty ||
        warning.level == WarningLevel.unknown) {
      return const SizedBox.shrink();
    }

    // Content-sized (not fixed height): the strip grows to fit the message,
    // up to three lines, so it can never be cramped. The hazard level is
    // conveyed by [color] (and shown in the sheet), so it doesn't compete for
    // horizontal space. Placed in normal layout above the map by the map
    // screen, so there is no overlap to reserve space for.
    final message = warning.messages.isNotEmpty
        ? warning.messages.first
        : 'warning.title'.tr();
    return Material(
      color: warning.level.color,
      child: InkWell(
        onTap: () => _showDetails(context, warning),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: Colors.white, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, WeatherWarning warning) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: warning.level.color),
                  const SizedBox(width: 8),
                  Text(
                    'warning.title'.tr(),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(warning.level.label),
                    backgroundColor: warning.level.color.withValues(alpha: 0.15),
                    side: BorderSide(color: warning.level.color),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              for (final message in warning.messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(child: Text(message)),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => launchUrl(
                    Uri.parse(_sourceUrl),
                    mode: LaunchMode.externalApplication,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text('warning.source'.tr()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

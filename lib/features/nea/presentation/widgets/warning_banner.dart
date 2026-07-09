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

  /// Fixed content height of the strip; the map screen reserves this much
  /// top inset for its controls when a warning is shown.
  static const double height = 52;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warning = ref.watch(warningProvider).value;
    if (warning == null ||
        warning.isEmpty ||
        warning.level == WarningLevel.unknown) {
      return const SizedBox.shrink();
    }

    // Fixed height so the map screen can reserve a matching top inset for its
    // controls without overlap or a gap, whether the message is one or two
    // lines. The hazard level is conveyed by [color] (and shown in the sheet),
    // so it no longer competes for space on the strip.
    final message =
        warning.messages.isNotEmpty ? warning.messages.first : 'warning.title'.tr();
    return Material(
      color: warning.level.color,
      child: InkWell(
        onTap: () => _showDetails(context, warning),
        child: SizedBox(
          height: WarningBanner.height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
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
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Colors.white, size: 20),
              ],
            ),
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

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

const _repoUrl = 'https://github.com/GIS-GEORGIA/amindi';

/// Tappable row that opens the project repository, with a gently animated
/// GitHub mark (continuous "breathing" pulse + a slow shimmer sweep).
class GithubLinkTile extends StatefulWidget {
  const GithubLinkTile({super.key});

  @override
  State<GithubLinkTile> createState() => _GithubLinkTileState();
}

class _GithubLinkTileState extends State<GithubLinkTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final uri = Uri.parse(_repoUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('settings.link_failed'.tr())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      child: InkWell(
        onTap: _open,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              _AnimatedMark(controller: _controller),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'settings.source_code'.tr(),
                      style: theme.textTheme.titleMedium,
                    ),
                    Text(
                      'GIS-GEORGIA/amindi',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedMark extends StatelessWidget {
  const _AnimatedMark({required this.controller});

  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Breathing pulse: scale 1.0 -> 1.12 -> 1.0 across the cycle.
        final t = controller.value;
        final scale = 1 + 0.12 * (0.5 - (t - 0.5).abs()) * 2;
        return Transform.scale(scale: scale, child: child);
      },
      child: FaIcon(FontAwesomeIcons.github, size: 30, color: color),
    );
  }
}

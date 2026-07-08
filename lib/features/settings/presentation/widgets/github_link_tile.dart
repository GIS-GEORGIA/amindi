import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

const _repoUrl = 'https://github.com/GIS-GEORGIA/amindi';

/// Tappable row that opens the project repository, with an animated
/// GitHub logo (Lottie, looping).
class GithubLinkTile extends StatefulWidget {
  const GithubLinkTile({super.key});

  @override
  State<GithubLinkTile> createState() => _GithubLinkTileState();
}

class _GithubLinkTileState extends State<GithubLinkTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this);

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
    return SizedBox(
      width: 40,
      height: 40,
      child: Lottie.asset(
        'assets/lottie/github.json',
        controller: controller,
        onLoaded: (composition) {
          // Match the controller to the animation's own length, then loop.
          controller
            ..duration = composition.duration
            ..repeat();
        },
      ),
    );
  }
}

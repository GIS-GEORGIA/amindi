import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../forecast/domain/entities/weather_model.dart';
import '../../nea/presentation/widgets/official_forecast_section.dart';

class ModelInfoScreen extends ConsumerStatefulWidget {
  const ModelInfoScreen({super.key});

  @override
  ConsumerState<ModelInfoScreen> createState() => _ModelInfoScreenState();
}

class _ModelInfoScreenState extends ConsumerState<ModelInfoScreen> {
  WeatherModel _selected = WeatherModel.ecmwf;

  static const _sections = [
    'provider',
    'resolution',
    'updates',
    'strengths',
    'limits',
    'georgia',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text('model_info.title'.tr())),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('model_info.intro'.tr(), style: theme.textTheme.bodyMedium),
          const SizedBox(height: 16),
          Center(
            child: SegmentedButton<WeatherModel>(
              showSelectedIcon: false,
              style: SegmentedButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
              segments: [
                for (final model in WeatherModel.values)
                  ButtonSegment(value: model, label: Text(model.label)),
              ],
              selected: {_selected},
              onSelectionChanged: (s) => setState(() => _selected = s.first),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_selected.label, style: theme.textTheme.headlineSmall),
                  for (final section in _sections) ...[
                    const SizedBox(height: 12),
                    Text(
                      'model_info.section.$section'.tr(),
                      style: theme.textTheme.labelLarge
                          ?.copyWith(color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'model_info.${_selected.key}.$section'.tr(),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const OfficialForecastSection(),
        ],
      ),
    );
  }
}

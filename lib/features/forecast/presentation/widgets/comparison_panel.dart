import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/forecast_point.dart';
import '../../domain/entities/weather_model.dart';
import '../providers/forecast_providers.dart';

/// Bottom-sheet panel comparing the four models side by side for one point.
class ComparisonPanel extends ConsumerStatefulWidget {
  const ComparisonPanel({
    super.key,
    required this.lat,
    required this.lon,
    required this.scrollController,
  });

  final double lat;
  final double lon;
  final ScrollController scrollController;

  @override
  ConsumerState<ComparisonPanel> createState() => _ComparisonPanelState();
}

class _ComparisonPanelState extends ConsumerState<ComparisonPanel> {
  bool _daily = false;

  Location get _location => (lat: widget.lat, lon: widget.lon);

  @override
  Widget build(BuildContext context) {
    final forecast = ref.watch(forecastProvider(_location));
    final theme = Theme.of(context);

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.lat.toStringAsFixed(3)}, ${widget.lon.toStringAsFixed(3)}',
          style: theme.textTheme.labelMedium,
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: Text('forecast.hourly'.tr())),
            ButtonSegment(value: true, label: Text('forecast.daily'.tr())),
          ],
          selected: {_daily},
          onSelectionChanged: (s) => setState(() => _daily = s.first),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: forecast.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => _ErrorRetry(
              onRetry: () => ref.invalidate(forecastProvider(_location)),
            ),
            data: (bundle) => _ForecastTable(
              bundle: bundle,
              daily: _daily,
              scrollController: widget.scrollController,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  const _ErrorRetry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('forecast.failed'.tr()),
          const SizedBox(height: 8),
          FilledButton.tonal(
            onPressed: onRetry,
            child: Text('forecast.retry'.tr()),
          ),
        ],
      ),
    );
  }
}

class _ForecastTable extends StatelessWidget {
  const _ForecastTable({
    required this.bundle,
    required this.daily,
    required this.scrollController,
  });

  final ForecastBundle bundle;
  final bool daily;
  final ScrollController scrollController;

  static const _timeColumnWidth = 64.0;

  @override
  Widget build(BuildContext context) {
    final models = WeatherModel.values;
    final locale = context.locale.languageCode;

    return Column(
      children: [
        _headerRow(context, models),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            controller: scrollController,
            children:
                daily ? _dailyRows(context, locale) : _hourlyRows(context, locale),
          ),
        ),
      ],
    );
  }

  Widget _headerRow(BuildContext context, List<WeatherModel> models) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          const SizedBox(width: _timeColumnWidth),
          for (final model in models)
            Expanded(
              child: Column(
                children: [
                  Text(model.label,
                      style: theme.textTheme.labelLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    bundle.errors.containsKey(model)
                        ? 'forecast.failed'.tr()
                        : 'models.res.${model.key}'.tr(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: bundle.errors.containsKey(model)
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Times come from the first successful model; the rest are joined on the
  /// shared hour so gaps (e.g. YR past 60 h) render as "—".
  List<Widget> _hourlyRows(BuildContext context, String locale) {
    final master = bundle.forecasts.values.first.hourly;
    final now = DateTime.now().subtract(const Duration(hours: 1));
    final times = master
        .map((p) => p.time)
        .where((t) => t.isAfter(now))
        .take(48)
        .toList();
    final format = DateFormat('EEE HH:mm', locale);

    return [
      for (final time in times)
        _row(
          context,
          label: format.format(time),
          cells: [
            for (final model in WeatherModel.values)
              _HourlyCell(point: bundle.forecasts[model]?.byTime[time]),
          ],
        ),
    ];
  }

  List<Widget> _dailyRows(BuildContext context, String locale) {
    final dates = bundle.forecasts.values.first.daily
        .map((d) => d.date)
        .toList();
    final byModelDate = {
      for (final entry in bundle.forecasts.entries)
        entry.key: {for (final d in entry.value.daily) d.date: d},
    };
    final format = DateFormat('EEE d MMM', locale);

    return [
      for (final date in dates)
        _row(
          context,
          label: format.format(date),
          cells: [
            for (final model in WeatherModel.values)
              _DailyCell(summary: byModelDate[model]?[date]),
          ],
        ),
    ];
  }

  Widget _row(BuildContext context,
      {required String label, required List<Widget> cells}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.4),
          ),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: _timeColumnWidth,
            child: Text(label, style: Theme.of(context).textTheme.labelSmall),
          ),
          for (final cell in cells) Expanded(child: cell),
        ],
      ),
    );
  }
}

class _HourlyCell extends StatelessWidget {
  const _HourlyCell({required this.point});

  final ForecastPoint? point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = point;
    if (p == null || p.temperature == null) {
      return const Center(child: Text('—'));
    }
    final precipitation = p.precipitation ?? 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (p.condition != null) ...[
              Icon(p.condition!.icon,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 3),
            ],
            Text('${p.temperature!.round()}°',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
        Text(
          precipitation > 0
              ? '${precipitation.toStringAsFixed(1)} mm'
              : '${(p.windSpeed ?? 0).toStringAsFixed(1)} m/s',
          style: theme.textTheme.labelSmall?.copyWith(
            color: precipitation > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DailyCell extends StatelessWidget {
  const _DailyCell({required this.summary});

  final DailySummary? summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = summary;
    if (s == null || s.tempMax == null) {
      return const Center(child: Text('—'));
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (s.condition != null) ...[
              Icon(s.condition!.icon,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 3),
            ],
            Text(
              '${s.tempMax!.round()}°/${s.tempMin!.round()}°',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        if (s.precipitation > 0.05)
          Text(
            '${s.precipitation.toStringAsFixed(1)} mm',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.primary),
          ),
      ],
    );
  }
}

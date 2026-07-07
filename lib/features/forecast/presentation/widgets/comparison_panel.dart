import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/forecast_point.dart';
import '../../domain/entities/weather_condition.dart';
import '../../domain/entities/weather_model.dart';
import '../providers/forecast_providers.dart';

/// Bottom-sheet panel comparing the four models side by side for one point.
class ComparisonPanel extends ConsumerStatefulWidget {
  const ComparisonPanel({
    super.key,
    required this.lat,
    required this.lon,
    this.scrollController,
  });

  final double lat;
  final double lon;
  final ScrollController? scrollController;

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
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: theme.colorScheme.outlineVariant,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place_outlined,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 4),
            Text(
              '${widget.lat.toStringAsFixed(3)}, '
              '${widget.lon.toStringAsFixed(3)}',
              style: theme.textTheme.titleSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(value: false, label: Text('forecast.hourly'.tr())),
            ButtonSegment(value: true, label: Text('forecast.daily'.tr())),
          ],
          selected: {_daily},
          onSelectionChanged: (s) => setState(() => _daily = s.first),
        ),
        const SizedBox(height: 10),
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

Color _conditionColor(WeatherCondition condition, ThemeData theme) =>
    switch (condition) {
      WeatherCondition.clear || WeatherCondition.thunder =>
        const Color(0xFFE8A400),
      WeatherCondition.rain ||
      WeatherCondition.sleet =>
        const Color(0xFF2E86D6),
      WeatherCondition.snow => const Color(0xFF64A8DC),
      _ => theme.colorScheme.onSurfaceVariant,
    };

class _ForecastTable extends StatelessWidget {
  const _ForecastTable({
    required this.bundle,
    required this.daily,
    required this.scrollController,
  });

  final ForecastBundle bundle;
  final bool daily;
  final ScrollController? scrollController;

  double get _timeColumnWidth => daily ? 76 : 56;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.languageCode;

    return Column(
      children: [
        _headerRow(context),
        const Divider(height: 1),
        Expanded(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.only(bottom: 16),
            children:
                daily ? _dailyRows(context, locale) : _hourlyRows(context, locale),
          ),
        ),
      ],
    );
  }

  Widget _headerRow(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          SizedBox(width: _timeColumnWidth),
          for (final model in WeatherModel.values)
            Expanded(
              child: Column(
                children: [
                  Text(
                    model.label,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Container(
                    width: 30,
                    height: 3,
                    decoration: BoxDecoration(
                      color: model.color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    bundle.errors.containsKey(model)
                        ? 'forecast.failed'.tr()
                        : 'models.res.${model.key}'.tr(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: bundle.errors.containsKey(model)
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
    final dayFormat = DateFormat('EEEE, d MMMM', locale);
    final hourFormat = DateFormat('HH:mm', locale);

    final rows = <Widget>[];
    DateTime? currentDay;
    var zebra = 0;
    for (final time in times) {
      final day = DateTime(time.year, time.month, time.day);
      if (day != currentDay) {
        currentDay = day;
        zebra = 0;
        rows.add(_dayHeader(context, dayFormat.format(time)));
      }
      rows.add(_row(
        context,
        zebra: zebra.isOdd,
        label: Text(
          hourFormat.format(time),
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        cells: [
          for (final model in WeatherModel.values)
            _HourlyCell(point: bundle.forecasts[model]?.byTime[time]),
        ],
      ));
      zebra++;
    }
    return rows;
  }

  List<Widget> _dailyRows(BuildContext context, String locale) {
    final theme = Theme.of(context);
    final dates =
        bundle.forecasts.values.first.daily.map((d) => d.date).toList();
    final byModelDate = {
      for (final entry in bundle.forecasts.entries)
        entry.key: {for (final d in entry.value.daily) d.date: d},
    };
    final weekdayFormat = DateFormat('EEE', locale);
    final dateFormat = DateFormat('d MMM', locale);

    return [
      for (final (i, date) in dates.indexed)
        _row(
          context,
          zebra: i.isOdd,
          label: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weekdayFormat.format(date),
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                dateFormat.format(date),
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          cells: [
            for (final model in WeatherModel.values)
              _DailyCell(summary: byModelDate[model]?[date]),
          ],
        ),
    ];
  }

  Widget _dayHeader(BuildContext context, String label) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      child: Text(
        label,
        style: theme.textTheme.labelMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _row(BuildContext context,
      {required bool zebra,
      required Widget label,
      required List<Widget> cells}) {
    final theme = Theme.of(context);
    return Container(
      color: zebra
          ? theme.colorScheme.surfaceContainerLow.withValues(alpha: 0.6)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
      child: Row(
        children: [
          SizedBox(width: _timeColumnWidth, child: label),
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
      return Center(
        child: Text('—',
            style: TextStyle(color: theme.colorScheme.outlineVariant)),
      );
    }
    final precipitation = p.precipitation ?? 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (p.condition != null) ...[
              Icon(p.condition!.icon,
                  size: 18, color: _conditionColor(p.condition!, theme)),
              const SizedBox(width: 4),
            ],
            Text(
              '${p.temperature!.round()}°',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          precipitation > 0
              ? '${precipitation.toStringAsFixed(1)} mm'
              : '${(p.windSpeed ?? 0).toStringAsFixed(1)} m/s',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: precipitation > 0
                ? const Color(0xFF2E86D6)
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
      return Center(
        child: Text('—',
            style: TextStyle(color: theme.colorScheme.outlineVariant)),
      );
    }
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (s.condition != null) ...[
              Icon(s.condition!.icon,
                  size: 18, color: _conditionColor(s.condition!, theme)),
              const SizedBox(width: 4),
            ],
            Text(
              '${s.tempMax!.round()}°',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Text(
              ' ${s.tempMin!.round()}°',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        if (s.precipitation > 0.05) ...[
          const SizedBox(height: 2),
          Text(
            '${s.precipitation.toStringAsFixed(1)} mm',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF2E86D6),
            ),
          ),
        ],
      ],
    );
  }
}

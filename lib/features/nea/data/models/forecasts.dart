import 'package:flutter/foundation.dart';

/// ერთი დღის რეგიონული პროგნოზი (/Ge/Regions გვერდიდან).
/// გვერდი დღეებად არის დაყოფილი; თითო დღეს აქვს დასავლეთ და აღმოსავლეთ
/// საქართველოს ცალკე აღწერა.
@immutable
class RegionDayForecast {
  final String date; // მაგ. "9 ივლისს - ხუთშაბათს"
  final String? west; // დასავლეთ საქართველოს ტექსტი
  final String? east; // აღმოსავლეთ საქართველოს ტექსტი

  const RegionDayForecast({required this.date, this.west, this.east});

  Map<String, dynamic> toJson() => {'date': date, 'west': west, 'east': east};

  factory RegionDayForecast.fromJson(Map<String, dynamic> j) => RegionDayForecast(
        date: j['date'] as String? ?? '',
        west: j['west'] as String?,
        east: j['east'] as String?,
      );
}

/// რეგიონული პროგნოზის სრული ნაკრები (რამდენიმე დღე).
@immutable
class RegionForecast {
  final List<RegionDayForecast> days;
  final DateTime fetchedAt;

  const RegionForecast({required this.days, required this.fetchedAt});

  bool get isEmpty => days.isEmpty;

  Map<String, dynamic> toJson() => {
        'days': days.map((d) => d.toJson()).toList(),
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory RegionForecast.fromJson(Map<String, dynamic> j) => RegionForecast(
        days: (j['days'] as List<dynamic>? ?? [])
            .map((e) => RegionDayForecast.fromJson(e as Map<String, dynamic>))
            .toList(),
        fetchedAt: DateTime.tryParse(j['fetchedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

/// გრძელვადიანი პროგნოზი — თვის ან სეზონის. ორივეს ერთი და იგივე ფორმა აქვს:
/// სათაური + სრული ტექსტი + წყაროს ბმული.
@immutable
class LongRangeForecast {
  final String title; // მაგ. "2026 წლის ივლისის თვის პროგნოზი"
  final String body; // სრული ტექსტი
  final String detailUrl; // detail გვერდის URL
  final DateTime fetchedAt;

  const LongRangeForecast({
    required this.title,
    required this.body,
    required this.detailUrl,
    required this.fetchedAt,
  });

  bool get isEmpty => body.trim().isEmpty;

  Map<String, dynamic> toJson() => {
        'title': title,
        'body': body,
        'detailUrl': detailUrl,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory LongRangeForecast.fromJson(Map<String, dynamic> j) => LongRangeForecast(
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        detailUrl: j['detailUrl'] as String? ?? '',
        fetchedAt: DateTime.tryParse(j['fetchedAt'] as String? ?? '') ??
            DateTime.now(),
      );
}

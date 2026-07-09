import 'package:flutter/material.dart';

/// საფრთხის დონე NEA-ს გაფრთხილებებში.
/// ტექსტში გვხვდება: "საფრთხის დონე მაღალი / საშუალო / დაბალი".
enum WarningLevel {
  high, // მაღალი
  medium, // საშუალო
  low, // დაბალი
  unknown;

  /// ქართული ლეიბლი UI-სთვის.
  String get label {
    switch (this) {
      case WarningLevel.high:
        return 'მაღალი';
      case WarningLevel.medium:
        return 'საშუალო';
      case WarningLevel.low:
        return 'დაბალი';
      case WarningLevel.unknown:
        return 'უცნობი';
    }
  }

  /// ბანერის ფერი დონის მიხედვით.
  Color get color {
    switch (this) {
      case WarningLevel.high:
        return const Color(0xFFEF4444); // წითელი
      case WarningLevel.medium:
        return const Color(0xFFF59E0B); // ყვითელი/ნარინჯისფერი
      case WarningLevel.low:
        return const Color(0xFF22C55E); // მწვანე
      case WarningLevel.unknown:
        return const Color(0xFF64748B); // ნაცრისფერი
    }
  }

  /// ტექსტიდან დონის ამოცნობა.
  static WarningLevel fromText(String text) {
    // თანმიმდევრობა მნიშვნელოვანია: ტექსტში შეიძლება ერთდროულად იყოს
    // "მაღალი" და "დაბალი" (ორი განსხვავებული გაფრთხილება). ყველაზე
    // მაღალ დონეს ვირჩევთ — ის უფრო კრიტიკულია მომხმარებლისთვის.
    if (text.contains('მაღალი')) return WarningLevel.high;
    if (text.contains('საშუალო')) return WarningLevel.medium;
    if (text.contains('დაბალი')) return WarningLevel.low;
    return WarningLevel.unknown;
  }
}

/// ერთი გაფრთხილების ჩანაწერი.
@immutable
class WeatherWarning {
  /// ცალკეული გაფრთხილების სტრიქონები (მაგ. "სანაპირო ზოლში ძლიერი ქარი").
  final List<String> messages;

  /// მთელი გაფრთხილების ტექსტი (raw), დონის განსაზღვრისა და ჰეშისთვის.
  final String rawText;

  /// უმაღლესი საფრთხის დონე ამ გაფრთხილებაში.
  final WarningLevel level;

  /// როდის იქნა წაკითხული ეს ინფორმაცია (ლოკალური დრო).
  final DateTime fetchedAt;

  const WeatherWarning({
    required this.messages,
    required this.rawText,
    required this.level,
    required this.fetchedAt,
  });

  /// ცარიელია თუ არა (გაფრთხილება არ არსებობს).
  bool get isEmpty => messages.isEmpty && rawText.trim().isEmpty;

  /// უნიკალური "ხელმოწერა" — გამოიყენება იმის დასადგენად, შეიცვალა თუ არა
  /// გაფრთხილება ბოლო წაკითხვის შემდეგ (push/notification/ქეშისთვის).
  String get signature => rawText.trim();

  /// JSON serialization — ლოკალური ქეშისთვის (shared_preferences / hive).
  Map<String, dynamic> toJson() => {
        'messages': messages,
        'rawText': rawText,
        'level': level.name,
        'fetchedAt': fetchedAt.toIso8601String(),
      };

  factory WeatherWarning.fromJson(Map<String, dynamic> json) {
    return WeatherWarning(
      messages: (json['messages'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      rawText: json['rawText'] as String? ?? '',
      level: WarningLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => WarningLevel.unknown,
      ),
      fetchedAt: DateTime.tryParse(json['fetchedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is WeatherWarning && other.signature == signature;

  @override
  int get hashCode => signature.hashCode;
}

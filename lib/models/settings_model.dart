import 'package:flutter/material.dart';

enum ThemeMode {
  light,
  dark,
  system,
}

class AppSettings {
  final ThemeMode themeMode;
  final bool dailyBriefingEnabled;
  final TimeOfDay briefingTime;
  final String? aiApiKey;
  final String? aiProvider;
  final bool useAiSummarization;

  AppSettings({
    this.themeMode = ThemeMode.system,
    this.dailyBriefingEnabled = true,
    this.briefingTime = const TimeOfDay(hour: 9, minute: 0),
    this.aiApiKey,
    this.aiProvider = 'openai',
    this.useAiSummarization = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    bool? dailyBriefingEnabled,
    TimeOfDay? briefingTime,
    String? aiApiKey,
    String? aiProvider,
    bool? useAiSummarization,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      dailyBriefingEnabled: dailyBriefingEnabled ?? this.dailyBriefingEnabled,
      briefingTime: briefingTime ?? this.briefingTime,
      aiApiKey: aiApiKey ?? this.aiApiKey,
      aiProvider: aiProvider ?? this.aiProvider,
      useAiSummarization: useAiSummarization ?? this.useAiSummarization,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'themeMode': themeMode.name,
      'dailyBriefingEnabled': dailyBriefingEnabled,
      'briefingHour': briefingTime.hour,
      'briefingMinute': briefingTime.minute,
      'aiProvider': aiProvider,
      'useAiSummarization': useAiSummarization,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      themeMode: ThemeMode.values.firstWhere(
        (e) => e.name == json['themeMode'],
        orElse: () => ThemeMode.system,
      ),
      dailyBriefingEnabled: json['dailyBriefingEnabled'] ?? true,
      briefingTime: TimeOfDay(
        hour: json['briefingHour'] ?? 9,
        minute: json['briefingMinute'] ?? 0,
      ),
      aiProvider: json['aiProvider'] ?? 'openai',
      useAiSummarization: json['useAiSummarization'] ?? false,
    );
  }
}

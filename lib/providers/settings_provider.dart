import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings_model.dart';
import '../services/settings_service.dart';
import '../services/summary_service.dart';

// Settings State
class SettingsState {
  final AppSettings settings;
  final bool isLoading;
  final String? error;

  SettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  SettingsState copyWith({
    AppSettings? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Settings Notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(settings: SettingsService.getSettings()));

  Future<void> loadSettings() async {
    state = state.copyWith(isLoading: true);
    try {
      await SettingsService.initialize();
      final settings = SettingsService.getSettings();
      state = SettingsState(settings: settings);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await SettingsService.updateThemeMode(mode);
    state = SettingsState(settings: SettingsService.getSettings());
  }

  Future<void> updateDailyBriefing(bool enabled, {TimeOfDay? time}) async {
    await SettingsService.updateDailyBriefing(enabled, time: time);
    state = SettingsState(settings: SettingsService.getSettings());
  }

  Future<void> updateBriefingTime(TimeOfDay time) async {
    await SettingsService.updateBriefingTime(time);
    state = SettingsState(settings: SettingsService.getSettings());
  }

  Future<void> updateAiKey(String? key) async {
    if (key != null && key.isNotEmpty) {
      await SummaryService.saveAiKey(key);
    } else {
      await SummaryService.deleteAiKey();
    }
    state = SettingsState(settings: SettingsService.getSettings());
  }

  Future<void> updateAiProvider(String provider) async {
    await SummaryService.saveProvider(provider);
    state = SettingsState(settings: SettingsService.getSettings());
  }

  Future<void> updateUseAiSummarization(bool use) async {
    await SettingsService.updateAiSettings(useAi: use);
    state = SettingsState(settings: SettingsService.getSettings());
  }
}

// Settings Provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

// Theme Mode Provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider).settings;
  return settings.themeMode;
});

// Is Dark Mode Provider
final isDarkModeProvider = Provider<bool>((ref) {
  final themeMode = ref.watch(themeModeProvider);
  if (themeMode == ThemeMode.system) {
    return WidgetsBinding.instance.platformDispatcher.platformBrightness == 
        Brightness.dark;
  }
  return themeMode == ThemeMode.dark;
});

// Daily Briefing Enabled Provider
final dailyBriefingEnabledProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).settings.dailyBriefingEnabled;
});

// Briefing Time Provider
final briefingTimeProvider = Provider<TimeOfDay>((ref) {
  return ref.watch(settingsProvider).settings.briefingTime;
});

// Use AI Summarization Provider
final useAiSummarizationProvider = Provider<bool>((ref) {
  return ref.watch(settingsProvider).settings.useAiSummarization;
});

// Has AI Key Provider
final hasAiKeyProvider = FutureProvider<bool>((ref) async {
  return await SummaryService.hasAiKey();
});

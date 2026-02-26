import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';
import 'notification_service.dart';

class SettingsService {
  static const _settingsKey = 'app_settings';
  static SharedPreferences? _prefs;
  
  static Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static AppSettings getSettings() {
    if (_prefs == null) return AppSettings();
    
    final jsonString = _prefs!.getString(_settingsKey);
    if (jsonString == null) return AppSettings();
    
    try {
      final json = jsonDecode(jsonString);
      return AppSettings.fromJson(json);
    } catch (e) {
      return AppSettings();
    }
  }
  
  static Future<void> saveSettings(AppSettings settings) async {
    if (_prefs == null) await initialize();
    
    final json = settings.toJson();
    await _prefs!.setString(_settingsKey, jsonEncode(json));
    
    // Bildirim ayarlarını güncelle
    await _updateNotificationSettings(settings);
  }
  
  static Future<void> _updateNotificationSettings(AppSettings settings) async {
    // Günlük brifing bildirimini ayarla veya kaldır
    if (settings.dailyBriefingEnabled) {
      await NotificationService.scheduleDailyBriefing(
        time: settings.briefingTime,
        title: 'Günaydın! 🌅',
        body: 'Bugünkü planını görmek için tıkla',
      );
    } else {
      await NotificationService.cancelDailyBriefing();
    }
  }
  
  static Future<void> updateThemeMode(ThemeMode mode) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(themeMode: mode));
  }
  
  static Future<void> updateDailyBriefing(bool enabled, {TimeOfDay? time}) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      dailyBriefingEnabled: enabled,
      briefingTime: time ?? settings.briefingTime,
    ));
  }
  
  static Future<void> updateBriefingTime(TimeOfDay time) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(briefingTime: time));
  }
  
  static Future<void> updateAiSettings({
    String? apiKey,
    String? provider,
    bool? useAi,
  }) async {
    final settings = getSettings();
    await saveSettings(settings.copyWith(
      aiApiKey: apiKey,
      aiProvider: provider,
      useAiSummarization: useAi,
    ));
  }
  
  static ThemeMode get themeMode => getSettings().themeMode;
  static bool get dailyBriefingEnabled => getSettings().dailyBriefingEnabled;
  static TimeOfDay get briefingTime => getSettings().briefingTime;
  static bool get useAiSummarization => getSettings().useAiSummarization;
}

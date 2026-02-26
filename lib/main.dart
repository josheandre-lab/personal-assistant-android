import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';
import 'utils/theme.dart';
import 'screens/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize timezone data
  tz_data.initializeTimeZones();
  
  // Initialize services
  await SettingsService.initialize();
  await NotificationService.initialize();
  
  runApp(
    const ProviderScope(
      child: PersonalAssistantApp(),
    ),
  );
}

class PersonalAssistantApp extends ConsumerWidget {
  const PersonalAssistantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    
    return MaterialApp(
      title: 'Kişisel Asistan',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _mapThemeMode(themeMode),
      home: const MainScreen(),
      builder: (context, child) {
        // Status bar rengini ayarla
        return child!;
      },
    );
  }
  
  MaterialThemeMode _mapThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return MaterialThemeMode.light;
      case ThemeMode.dark:
        return MaterialThemeMode.dark;
      case ThemeMode.system:
        return MaterialThemeMode.system;
    }
  }
}

// Material 3 ThemeMode extension
extension on ThemeMode {
  MaterialThemeMode get materialMode {
    switch (this) {
      case ThemeMode.light:
        return MaterialThemeMode.light;
      case ThemeMode.dark:
        return MaterialThemeMode.dark;
      case ThemeMode.system:
        return MaterialThemeMode.system;
    }
  }
}

typedef MaterialThemeMode = ThemeMode;

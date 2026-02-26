import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_assistant/main.dart';
import 'package:personal_assistant/screens/main_screen.dart';

void main() {
  group('Personal Assistant App Tests', () {
    testWidgets('App should build without errors', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: PersonalAssistantApp(),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Main screen should have bottom navigation', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Bugün'), findsOneWidget);
      expect(find.text('Notlarım'), findsOneWidget);
      expect(find.text('Hatırlatmalar'), findsOneWidget);
      expect(find.text('Ayarlar'), findsOneWidget);
    });

    testWidgets('Should navigate between tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Tap on Notes tab
      await tester.tap(find.text('Notlarım'));
      await tester.pumpAndSettle();
      
      expect(find.text('Notlarım'), findsOneWidget);
      
      // Tap on Reminders tab
      await tester.tap(find.text('Hatırlatmalar'));
      await tester.pumpAndSettle();
      
      expect(find.text('Hatırlatmalar'), findsOneWidget);
      
      // Tap on Settings tab
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();
      
      expect(find.text('Ayarlar'), findsOneWidget);
    });

    testWidgets('Today screen should show greeting', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      // Should show greeting based on time of day
      final hour = DateTime.now().hour;
      String greeting;
      if (hour < 6) {
        greeting = 'İyi Geceler';
      } else if (hour < 12) {
        greeting = 'Günaydın';
      } else if (hour < 18) {
        greeting = 'İyi Günler';
      } else {
        greeting = 'İyi Akşamlar';
      }
      
      expect(find.text(greeting), findsOneWidget);
    });

    testWidgets('Today screen should have quick add buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('Hızlı Ekle'), findsOneWidget);
      expect(find.text('Yeni Not'), findsOneWidget);
      expect(find.text('Hatırlatma'), findsOneWidget);
    });

    testWidgets('Today screen should have daily briefing button', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MainScreen(),
          ),
        ),
      );
      
      await tester.pumpAndSettle();
      
      expect(find.text('Günlük Brifing Al'), findsOneWidget);
    });
  });
}

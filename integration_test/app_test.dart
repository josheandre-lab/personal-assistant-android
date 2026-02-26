import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:personal_assistant/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End Tests', () {
    testWidgets('Complete user flow', (WidgetTester tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify main screen is shown
      expect(find.byType(NavigationBar), findsOneWidget);

      // Test 1: Navigate to Notes tab
      await tester.tap(find.text('Notlarım'));
      await tester.pumpAndSettle();
      expect(find.text('Notlarım'), findsOneWidget);

      // Test 2: Navigate to Reminders tab
      await tester.tap(find.text('Hatırlatmalar'));
      await tester.pumpAndSettle();
      expect(find.text('Hatırlatmalar'), findsOneWidget);

      // Test 3: Navigate to Settings tab
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();
      expect(find.text('Ayarlar'), findsOneWidget);

      // Test 4: Navigate back to Today tab
      await tester.tap(find.text('Bugün'));
      await tester.pumpAndSettle();
      expect(find.text('Bugün'), findsOneWidget);

      // Test 5: Verify quick add buttons exist
      expect(find.text('Yeni Not'), findsOneWidget);
      expect(find.text('Hatırlatma'), findsOneWidget);

      // Test 6: Verify daily briefing button exists
      expect(find.text('Günlük Brifing Al'), findsOneWidget);
    });

    testWidgets('Theme switching', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();

      // Verify theme selector exists
      expect(find.text('Görünüm'), findsOneWidget);
      expect(find.text('Açık'), findsOneWidget);
      expect(find.text('Koyu'), findsOneWidget);
      expect(find.text('Sistem'), findsOneWidget);
    });

    testWidgets('Notification settings', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();

      // Verify notification settings exist
      expect(find.text('Bildirimler'), findsOneWidget);
      expect(find.text('Günlük Brifing Bildirimi'), findsOneWidget);
    });

    testWidgets('AI settings', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();

      // Verify AI settings exist
      expect(find.text('Yapay Zeka'), findsOneWidget);
      expect(find.text('AI Özetleme'), findsOneWidget);
    });

    testWidgets('Data export option', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to Settings
      await tester.tap(find.text('Ayarlar'));
      await tester.pumpAndSettle();

      // Verify export option exists
      expect(find.text('Veri'), findsOneWidget);
      expect(find.text('Verileri Dışa Aktar'), findsOneWidget);
    });
  });
}

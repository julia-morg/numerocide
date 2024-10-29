import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numerocide/main.dart';
import 'package:numerocide/game/save.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/components/themes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockSettings extends Mock implements Settings {}
class MockSave extends Mock implements Save {}

void main() {
  late MockSettings mockSettings;
  late MockSave mockSave;

  setUp(() {
    mockSettings = MockSettings();
    mockSave = MockSave();

    when(() => mockSettings.theme).thenReturn('stone');
    when(() => mockSettings.language).thenReturn('en');
    when(() => mockSettings.saveSettings()).thenAnswer((_) async {});
    when(() => mockSave.loadMaxScore()).thenAnswer((_) async => 0);
    when(() => mockSave.hasSavedGame()).thenAnswer((_) async => true);
    when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => true);
  });

  Future<void> pumpMyApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: MyApp(settings: mockSettings, save: mockSave),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Initial theme and locale are set correctly', (WidgetTester tester) async {
    await pumpMyApp(tester);
    await tester.pumpAndSettle();

    final MaterialApp appWidget = tester.widget<MaterialApp>(
      find.descendant(
        of: find.byType(MyApp),
        matching: find.byType(MaterialApp),
      ),
    );

    expect(appWidget.theme?.colorScheme.primary, Themes.getThemeData('stone').colorScheme.primary);
    expect(appWidget.locale, const Locale('en'));
  });

  testWidgets('updateTheme updates theme correctly', (WidgetTester tester) async {
    await pumpMyApp(tester);
    Finder finder = find.byType(MaterialApp).last;
    MyApp.updateTheme(tester.element(finder), Themes.getThemeData('navy'),);
    await tester.pumpAndSettle();
    final MaterialApp appWidget = tester.widget<MaterialApp>(finder);
    expect(appWidget.theme?.colorScheme.primary, Themes.getThemeData('navy').colorScheme.primary);
  });

  testWidgets('setLocale updates locale correctly', (WidgetTester tester) async {
    await pumpMyApp(tester);
    Finder finder = find.byType(MaterialApp).last;
    MyApp.setLocale(tester.element(finder), const Locale('fr'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    final locale = tester.widget<MaterialApp>(finder).locale;
    expect(locale, equals(const Locale('fr')));
  });
}
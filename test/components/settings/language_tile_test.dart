import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/settings/language_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:numerocide/game/settings.dart';

class FakeSettings extends Settings {
  String _language = 'en';

  FakeSettings({required super.sound, required super.vibro, required super.theme, required super.language});

  @override
  String get language => _language;

  @override
  set language(String value) {
    _language = value;
  }

  @override
  Future<void> saveSettings() async {
  }
}

void main() {
  testWidgets('LanguageTile applies correct styles and updates language', (WidgetTester tester) async {
    final fakeSettings = FakeSettings(sound: true, vibro: true, theme: 'light', language: 'en');
    final themeData = ThemeData(
      textTheme: const TextTheme(
        titleSmall: TextStyle(fontSize: 18, color: Colors.blue),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      splashColor: Colors.red,
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: themeData,
        home: Material(
          child: LanguageTile(
            title: 'Language',
            settings: fakeSettings,
          ),
        ),
      ),
    );

    final titleFinder = find.text('Language');
    final titleWidget = tester.widget<Text>(titleFinder);
    expect(titleWidget.style?.fontSize, 18);

    final dropdownFinder = find.byType(DropdownButton<String>);
    expect(dropdownFinder, findsOneWidget);

    await tester.tap(dropdownFinder);
    await tester.pumpAndSettle();

    final newLanguageItemFinder = find.text('Русский').last;
    await tester.tap(newLanguageItemFinder);
    await tester.pumpAndSettle();

    expect(fakeSettings.language, 'ru');
  });
}
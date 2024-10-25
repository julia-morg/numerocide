import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/settings/theme_tile.dart';
import 'package:numerocide/components/themes.dart';
import 'package:numerocide/game/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FakeSettings extends Settings {
  String _theme = Themes.brown;

  FakeSettings({required super.sound, required super.vibro, required super.theme, required super.language});

  @override
  String get theme => _theme;

  @override
  set theme(String newTheme) {
    _theme = newTheme;
  }

  @override
  Future<void> saveSettings() async {
  }
}

void main() {
  testWidgets('ThemeTile displays themes and applies correct styles', (WidgetTester tester) async {
    final fakeSettings = FakeSettings(sound: false, vibro: false, theme: Themes.brown, language: 'en');

    final themeData = ThemeData(
      textTheme: const TextTheme(
        titleSmall: TextStyle(fontSize: 16, color: Colors.black),
        displaySmall: TextStyle(fontSize: 14, color: Colors.grey),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: themeData,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Material(
          child: ThemeTile(settings: fakeSettings),
        ),
      ),
    );

    final titleFinder = find.text(AppLocalizations.of(tester.element(find.byType(ThemeTile)))!.settingsPageTheme);
    final titleWidget = tester.widget<Text>(titleFinder);
    expect(titleWidget.style?.fontSize, 16);
    expect(titleWidget.style?.color, Colors.black);

    for (var themeName in Themes.allThemes) {
      expect(find.textContaining(_getLocalizedTheme(tester, themeName)), findsOneWidget);
    }

    await tester.tap(find.text(_getLocalizedTheme(tester, Themes.navy)));
    await tester.pumpAndSettle();

    expect(fakeSettings.theme, Themes.navy);
  });
}

String _getLocalizedTheme(WidgetTester tester, String themeName) {
  final localizations = AppLocalizations.of(tester.element(find.byType(ThemeTile)))!;
  switch (themeName) {
    case Themes.brown:
      return localizations.settingsPageThemeCocoa;
    case Themes.navy:
      return localizations.settingsPageThemeNavy;
    case Themes.grey:
      return localizations.settingsPageThemeStone;
    case Themes.green:
      return localizations.settingsPageThemeGrass;
    default:
      return '';
  }
}
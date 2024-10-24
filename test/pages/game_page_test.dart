import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:numerocide/components/themes.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/pages/game_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  testWidgets('AddRowsTest', (WidgetTester tester) async {
    Settings settings = Settings(sound: true, vibro: true, theme: Themes.green, language: 'en');
    GamePage gamePage = GamePage(
      title: 'test',
      maxScore: 0,
      mode: GamePage.modeNewGame,
      settings: settings,
    );

    await tester.pumpWidget(MaterialApp(
      home: gamePage,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
    ));

    debugPrint('state: ${gamePage.settings.sound}');

    final finder = find.byKey(const Key('label-container-addButton'));
    expect(finder, findsOneWidget);
    expect(
      find.descendant(
        of: finder,
        matching: find.text(Desk.defaultAddsCount.toString()),
      ),
      findsOneWidget,
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(
      find.descendant(
        of: finder,
        matching: find.text((Desk.defaultAddsCount - 1).toString()),
      ),
      findsOneWidget,
    );
  });
}
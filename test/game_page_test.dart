import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/pages/game_page.dart';

void main() {
  testWidgets('AddRowsTest', (WidgetTester tester) async {
    Settings settings = Settings(sound: true, vibro: true, theme: Settings.green);
    GamePage gamePage = GamePage(
      title: 'test',
      maxScore: 0,
      mode: GamePage.modeNewGame,
      settings: settings,
    );

    await tester.pumpWidget(MaterialApp(
      home: gamePage,
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
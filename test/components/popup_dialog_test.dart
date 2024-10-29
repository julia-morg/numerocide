import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:confetti/confetti.dart';
import 'package:numerocide/components/popup_dialog.dart';

void main() {
  testWidgets('PopupDialog displays title, content, note, actions, and plays confetti when hasConfetti is true', (WidgetTester tester) async {
    final actions = [
      DialogAction(
        text: 'OK',
        onPressed: () {},
      ),
      DialogAction(
        text: 'Cancel',
        onPressed: () {},
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        home: Scaffold(
          body: PopupDialog(
            title: 'Test Title',
            content: 'This is the main content of the dialog.',
            note: 'This is an additional note.',
            actions: actions,
            hasConfetti: true,
          ),
        ),
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('This is the main content of the dialog.'), findsOneWidget);
    expect(find.text('This is an additional note.'), findsOneWidget);

    expect(find.text('OK'), findsOneWidget);
    expect(find.text('CANCEL'), findsOneWidget);

    final confettiWidget = tester.widget<ConfettiWidget>(find.byType(ConfettiWidget));
    expect(confettiWidget.confettiController, isNotNull);
  });

  testWidgets('PopupDialog does not play confetti when hasConfetti is false', (WidgetTester tester) async {
    final actions = [
      DialogAction(
        text: 'OK',
        onPressed: () {},
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        home: Scaffold(
          body: PopupDialog(
            content: 'Dialog content without confetti.',
            actions: actions,
            hasConfetti: false,
          ),
        ),
      ),
    );

    final confettiWidget = tester.widget<ConfettiWidget>(find.byType(ConfettiWidget));
    expect(confettiWidget.confettiController, isNotNull);
  });
}
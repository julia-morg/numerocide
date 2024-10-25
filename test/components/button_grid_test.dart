import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/button_grid.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/field.dart';
import 'package:numerocide/game/hint.dart';


void main() {
  testWidgets('ButtonGrid displays buttons with correct text and styles', (WidgetTester tester) async {
    final desk = Desk(
      1,
      100,
      3,
      {
        0: Field(0, 1, true),
        1: Field(1, 2, false),
        2: Field(2, 3, true),
        3: Field(3, 4, true),
      },
      2,
    );

    const selectedButtons = [0, 2];
    final hint = Hint(1, 3);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ButtonGrid(
            onButtonPressed: (_) {},
            selectedButtons: selectedButtons,
            desk: desk,
            hint: hint,
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    final buttonFinder = find.byType(TextButton);

    final firstButton = tester.widget<TextButton>(buttonFinder.at(0));
    expect(firstButton.style?.backgroundColor?.resolve({}), isNotNull);

    final secondButton = tester.widget<TextButton>(buttonFinder.at(1));
    expect(secondButton.style?.backgroundColor?.resolve({}), isNotNull);

    final thirdButton = tester.widget<TextButton>(buttonFinder.at(2));
    expect(thirdButton.style?.backgroundColor?.resolve({}), isNotNull);

    final fourthButton = tester.widget<TextButton>(buttonFinder.at(3));
    expect(fourthButton.style?.backgroundColor?.resolve({}), isNotNull);
  });

  testWidgets('ButtonGrid calls onButtonPressed when active button is pressed', (WidgetTester tester) async {
    final desk = Desk(
      1,
      100,
      3,
      {
        0: Field(0, 1, true),
        1: Field(1, 2, false),
        2: Field(2, 3, true),
        3: Field(3, 4, true),
      },
      2,
    );

    bool wasPressed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ButtonGrid(
            onButtonPressed: (index) {
              wasPressed = true;
              expect(index, equals(0));
            },
            selectedButtons: [],
            desk: desk,
          ),
        ),
      ),
    );

    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();

    expect(wasPressed, isTrue);
  });

}
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/animated_button.dart';

void main() {
  testWidgets('AnimatedButton displays correct styles and colors', (WidgetTester tester) async {
    const testIcon = Icons.add;
    const testColor = Colors.red;
    const heroTag = 'test-hero';
    const labelCount = 5;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        ),
        home: Scaffold(
          body: AnimatedButton(
            onPressed: () {},
            icon: testIcon,
            color: testColor,
            heroTag: heroTag,
            active: true,
            labelCount: labelCount,
          ),
        ),
      ),
    );

    final iconFinder = find.byIcon(testIcon);
    expect(iconFinder, findsOneWidget);
    final iconWidget = tester.widget<Icon>(iconFinder);
    expect(iconWidget.color, testColor);
    expect(iconWidget.size, 32);

    final labelFinder = find.byKey(const Key('label-container-$heroTag'));
    expect(labelFinder, findsOneWidget);
    final labelText = find.descendant(of: labelFinder, matching: find.text('$labelCount'));
    expect(labelText, findsOneWidget);

    final labelTextWidget = tester.widget<Text>(labelText);
    expect(labelTextWidget.style?.color, Theme.of(tester.element(labelText)).colorScheme.secondary);
  });

  testWidgets('AnimatedButton responds to tap when active and ignores when inactive', (WidgetTester tester) async {
    bool buttonPressed = false;
    const heroTag = 'test-hero';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            onPressed: () {
              buttonPressed = true;
            },
            icon: Icons.add,
            color: Colors.red,
            heroTag: heroTag,
            active: true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(buttonPressed, isTrue);

    buttonPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            onPressed: () {
              buttonPressed = true;
            },
            icon: Icons.add,
            color: Colors.red,
            heroTag: heroTag,
            active: false,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(buttonPressed, isFalse);
  });

  testWidgets('AnimatedButton triggers shake animation', (WidgetTester tester) async {
    const heroTag = 'test-hero';
    final testKey = GlobalKey<AnimatedButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            key: testKey,
            onPressed: () {},
            icon: Icons.add,
            color: Colors.red,
            heroTag: heroTag,
            active: true,
          ),
        ),
      ),
    );

    testKey.currentState!.startShakeAnimation();

    await tester.pump();

    bool hasNonZeroOffset = false;
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 60));
      final transformFinder = find.descendant(
        of: find.byType(AnimatedButton),
        matching: find.byType(Transform),
      );
      final transformWidget = tester.widget<Transform>(transformFinder);

      if (transformWidget.transform.getTranslation().x != 0) {
        hasNonZeroOffset = true;
        break;
      }
    }

    expect(hasNonZeroOffset, isTrue);
    await tester.pumpAndSettle();
  });

  testWidgets('AnimatedButton starts shake animation on startShakeAnimation call', (WidgetTester tester) async {
    const heroTag = 'test-hero';
    final testKey = GlobalKey<AnimatedButtonState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedButton(
            key: testKey,
            onPressed: () {},
            icon: Icons.add,
            color: Colors.red,
            heroTag: heroTag,
            active: true,
          ),
        ),
      ),
    );

    testKey.currentState!.startShakeAnimation(2);

    await tester.pump();

    bool hasNonZeroOffset = false;
    for (int i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 60));
      final transformFinder = find.descendant(
        of: find.byType(AnimatedButton),
        matching: find.byType(Transform),
      );
      final transformWidget = tester.widget<Transform>(transformFinder);

      if (transformWidget.transform.getTranslation().x != 0) {
        hasNonZeroOffset = true;
        break;
      }
    }

    expect(hasNonZeroOffset, isTrue);
    await tester.pumpAndSettle();
  });


}
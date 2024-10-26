import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/text_plate.dart';

void main() {
  testWidgets('TextPlate displays centered and justified text with correct styles', (WidgetTester tester) async {
    const centeredText = 'Centered Text';
    const justifiedText = 'Justified Text';

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(),
        home: const Scaffold(
          body: TextPlate(
            centeredText: centeredText,
            justifiedText: justifiedText,
          ),
        ),
      ),
    );

    expect(find.text(centeredText), findsOneWidget);
    expect(find.text(justifiedText), findsOneWidget);

    final centeredTextWidget = tester.widget<Text>(find.text(centeredText));
    expect(centeredTextWidget.textAlign, TextAlign.center);
    expect(centeredTextWidget.style?.color, Theme.of(tester.element(find.text(centeredText))).textTheme.titleSmall?.color);

    final justifiedTextWidget = tester.widget<Text>(find.text(justifiedText));
    expect(justifiedTextWidget.textAlign, TextAlign.justify);
    expect(justifiedTextWidget.style?.color, Theme.of(tester.element(find.text(justifiedText))).textTheme.titleSmall?.color);
  });
}
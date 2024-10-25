import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/settings/goto_page_tile.dart';

class MockNavigatorObserver extends NavigatorObserver {
  bool didNavigate = false;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    didNavigate = true;
    super.didPush(route, previousRoute);
  }
}

void main() {
  testWidgets('GotoPageTile applies correct styles with given theme', (WidgetTester tester) async {
    final themeData = ThemeData(
      textTheme: const TextTheme(
        titleSmall: TextStyle(fontSize: 18, color: Colors.blue),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      splashColor: Colors.red,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: themeData,
        home: const Material(
          child: GotoPageTile(
            title: 'Navigate',
            nextPage: Scaffold(),
          ),
        ),
      ),
    );

    final titleFinder = find.text('Navigate');
    final textWidget = tester.widget<Text>(titleFinder);
    expect(textWidget.style?.fontSize, 18);
    expect(textWidget.style?.color, Colors.blue);

    final iconFinder = find.byIcon(Icons.arrow_forward);
    final iconWidget = tester.widget<Icon>(iconFinder);
    expect(iconWidget.color, themeData.colorScheme.primary);

    final inkWellFinder = find.byType(InkWell);
    final inkWellWidget = tester.widget<InkWell>(inkWellFinder);
    expect(inkWellWidget.splashColor, themeData.splashColor);
  });

  testWidgets('GotoPageTile applies correct styles and navigates on tap', (WidgetTester tester) async {
    final themeData = ThemeData(
      textTheme: const TextTheme(
        titleSmall: TextStyle(fontSize: 18, color: Colors.blue),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      splashColor: Colors.red,
    );

    final mockObserver = MockNavigatorObserver();

    await tester.pumpWidget(
      MaterialApp(
        theme: themeData,
        home: Material(
          child: Navigator(
            observers: [mockObserver],
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => const Scaffold(
                body: GotoPageTile(
                  title: 'Navigate',
                  nextPage: Placeholder(),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final titleFinder = find.text('Navigate');
    final textWidget = tester.widget<Text>(titleFinder);
    expect(textWidget.style?.fontSize, 18);
    expect(textWidget.style?.color, Colors.blue);

    final iconFinder = find.byIcon(Icons.arrow_forward);
    final iconWidget = tester.widget<Icon>(iconFinder);
    expect(iconWidget.color, themeData.colorScheme.primary);

    final inkWellFinder = find.byType(InkWell);
    final inkWellWidget = tester.widget<InkWell>(inkWellFinder);
    expect(inkWellWidget.splashColor, themeData.splashColor);

    await tester.tap(inkWellFinder);
    await tester.pumpAndSettle();

    expect(mockObserver.didNavigate, isTrue);
    expect(find.byType(Placeholder), findsOneWidget);
  });
}
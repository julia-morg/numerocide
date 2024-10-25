import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numerocide/components/settings/link_tile.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

class MockUrlLauncherPlatform extends UrlLauncherPlatform with Mock {
  bool wasLaunchCalled = false;
  bool shouldLaunchFail = false;

  @override
  Future<bool> canLaunch(String url) async {
    return !shouldLaunchFail;
  }

  @override
  Future<bool> launch(
      String url, {
        required bool useSafariVC,
        required bool useWebView,
        required bool enableJavaScript,
        required bool enableDomStorage,
        required bool universalLinksOnly,
        required Map<String, String> headers,
        String? webOnlyWindowName,
      }) async {
    wasLaunchCalled = true;
    return true;
  }
}

void main() {
  late MockUrlLauncherPlatform mockUrlLauncherPlatform;

  setUpAll(() {
    mockUrlLauncherPlatform = MockUrlLauncherPlatform();
    UrlLauncherPlatform.instance = mockUrlLauncherPlatform;
  });

  testWidgets('LinkTile applies correct styles from theme', (WidgetTester tester) async {
    final themeData = ThemeData(
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 18, color: Colors.blue),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: themeData,
        home: const Material(
          child: LinkTile(
            title: 'Open Link',
            webPagePath: '/example-path',
          ),
        ),
      ),
    );

    final titleFinder = find.text('Open Link');
    final textWidget = tester.widget<Text>(titleFinder);
    expect(textWidget.style?.fontSize, 18);
    expect(textWidget.style?.color, Colors.blue);
    expect(textWidget.style?.decoration, TextDecoration.underline);
    expect(textWidget.style?.decorationColor, themeData.colorScheme.primary);
  });

  testWidgets('LinkTile applies correct styles and opens URL on tap', (WidgetTester tester) async {
    final themeData = ThemeData(
      textTheme: const TextTheme(
        displaySmall: TextStyle(fontSize: 18, color: Colors.blue),
      ),
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
    );

    const testPath = '/example-path';
    await tester.pumpWidget(
      MaterialApp(
        theme: themeData,
        home: const Material(
          child: LinkTile(
            title: 'Open Link',
            webPagePath: testPath,
          ),
        ),
      ),
    );

    final titleFinder = find.text('Open Link');
    final textWidget = tester.widget<Text>(titleFinder);
    expect(textWidget.style?.fontSize, 18);
    expect(textWidget.style?.color, Colors.blue);
    expect(textWidget.style?.decoration, TextDecoration.underline);
    expect(textWidget.style?.decorationColor, themeData.colorScheme.primary);

    await tester.tap(titleFinder);
    await tester.pumpAndSettle();

    expect(mockUrlLauncherPlatform.wasLaunchCalled, isTrue);
  });

  testWidgets('LinkTile shows SnackBar when URL cannot be launched', (WidgetTester tester) async {
    mockUrlLauncherPlatform.shouldLaunchFail = true;

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: LinkTile(
            title: 'Open Link',
            webPagePath: '/example-path',
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Link'));
    await tester.pumpAndSettle();

    expect(find.text('Could not launch the URL'), findsOneWidget);
  });
}
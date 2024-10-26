import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numerocide/components/themes.dart';
import 'package:numerocide/game/save.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/components/default_scaffold.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MockSettings extends Mock implements Settings {}
class MockSave extends Mock implements Save {}

class MockSettingsPage extends StatelessWidget {
  final Settings settings;

  const MockSettingsPage({super.key, required this.settings});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Settings Page')),
      body: const Center(child: Text('Mock Settings Page Body')),
    );
  }
}

void main() {
  late MockSettings mockSettings;
  setUp(() {
    mockSettings = MockSettings();
  });

  testWidgets('DefaultScaffold displays AppBar with title and settings button', (WidgetTester tester) async {
    const testTitle = 'Test Title';
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: DefaultScaffold(
          body: const Text('Test Body'),
          title: testTitle,
          settings: mockSettings,
          save: MockSave(),
        ),
      ),
    );

    expect(find.text(testTitle), findsOneWidget);

    expect(find.byIcon(Icons.settings), findsOneWidget);
  });

  testWidgets('DefaultScaffold navigates to MockSettingsPage on settings button tap', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        home: DefaultScaffold(
          body: const Text('Test Body'),
          title: 'Test Title',
          settings: Settings(sound: true, vibro: true, theme: 'light', language: 'en'),
          save: MockSave(),
        ),
        routes: {
          '/settings': (context) => MockSettingsPage(settings: Settings(sound: true,
              vibro: true, theme: Themes.brown, language: 'ru'),),
        },
      ),
    );

    expect(find.text('Test Title'), findsOneWidget);
    expect(find.text('Test Body'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.settings));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
  });

  testWidgets('DefaultScaffold displays body and floatingActionButton', (WidgetTester tester) async {
    const testBodyText = 'Test Body';
    const testFabKey = Key('testFab');

    await tester.pumpWidget(
      MaterialApp(
        home: DefaultScaffold(
          body: const Text(testBodyText),
          title: 'Test Title',
          settings: mockSettings,
          save: MockSave(),
          floatingActionButton: FloatingActionButton(
            key: testFabKey,
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );

    expect(find.text(testBodyText), findsOneWidget);

    expect(find.byKey(testFabKey), findsOneWidget);
  });

  testWidgets('DefaultScaffold displays correct body', (WidgetTester tester) async {
    final settings = Settings(
        sound: true,
        vibro: true,
        theme: Themes.brown,
        language: 'en'
    );

    await tester.pumpWidget(MaterialApp(
      home: DefaultScaffold(
        title: 'Test Title',
        settings: settings,
        save: MockSave(),
        body: const Center(child: Text('Default Scaffold Body')),
      ),
    ));

    expect(find.text('Default Scaffold Body'), findsOneWidget);
  });
}
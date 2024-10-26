import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numerocide/components/button_grid.dart';
import 'package:numerocide/pages/tutorial_page.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/game/save.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MockSave extends Mock implements Save {}
class MockSettings extends Mock implements Settings {}

void main() {
  late MockSave mockSave;
  late MockSettings mockSettings;

  setUp(() {
    mockSave = MockSave();
    mockSettings = MockSettings();
  });

  testWidgets('TutorialPage initializes first step and displays step 1/9', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: TutorialPage(settings: mockSettings, save: mockSave),
      ),
    );

    expect(find.textContaining('1/9'), findsOneWidget);
  });

  testWidgets('Button press updates state and allows next step if correct', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: TutorialPage(settings: mockSettings, save: mockSave),
      ),
    );

    await tester.tap(find.byType(ButtonGrid).first);
    await tester.pump();
    await tester.tap(find.byType(ButtonGrid).last);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(ElevatedButton, AppLocalizations.of(tester.element(find.byType(TutorialPage)))!.tutorialPageNextStep),
      findsOneWidget,
    );
  });

}
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numerocide/components/popup_dialog.dart';
import 'package:numerocide/components/themes.dart';
import 'package:numerocide/effects/sounds.dart';
import 'package:numerocide/effects/vibro.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/field.dart';
import 'package:numerocide/game/hint.dart';
import 'package:numerocide/pages/tutorial_page.dart';
import 'package:flutter/material.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/game/save.dart';
import 'package:numerocide/game/tutorial.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MockSettings extends Mock implements Settings {
  @override
  final bool sound = true;
  @override
  final bool vibro = true;
  @override
  final String theme = Themes.green;
  @override
  final String language = 'en';
}

class MockDesk extends Mock implements Desk {}

class MockSounds extends Mock implements Sounds {
  @override
  final Settings settings;

  MockSounds({required this.settings});
}

class MockVibro extends Mock implements Vibro {}

class MockSave extends Mock implements Save {}

void main() {
  late MockSettings mockSettings;
  late MockDesk mockDesk;
  late MockSounds mockSounds;
  late MockSave mockSave;
  Tutorial tutorial = Tutorial();
  TutorialPage? tutorialPage;

  setUpAll(() {
    registerFallbackValue(MockDesk());
  });

  setUp(() {
    mockSettings = MockSettings();
    mockDesk = MockDesk();
    mockSounds = MockSounds(settings: mockSettings);
    mockSave = MockSave();

    when(() => mockDesk.checkGameStatus()).thenReturn(true);
    when(() => mockDesk.rowLength).thenReturn(5);
    when(() => mockDesk.numbers).thenReturn({0: Field(0, 5, true), 1: Field(1, 4, true)});
    when(() => mockDesk.getRemainingAddClicks()).thenReturn(1);
    when(() => mockDesk.getScore()).thenReturn(1);
    when(() => mockDesk.getStage()).thenReturn(1);
    when(() => mockDesk.isVictory()).thenReturn(false);
    when(() => mockDesk.move(any(), any())).thenReturn(false);
    when(() => mockSave.loadGame()).thenAnswer((_) async => mockDesk);
    when(() => mockSave.saveGame(any())).thenAnswer((_) async => mockDesk);
    when(() => mockSave.hasSavedGame()).thenAnswer((_) async => true);
    when(() => mockSave.loadMaxScore()).thenAnswer((_) async => 1000);
    when(() => mockSave.saveMaxScore(any())).thenAnswer((_) async => true);
    when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => true);
    when(() => mockSounds.playTapSound()).thenAnswer((_) async {});
    when(() => mockSounds.playDeskClearedSound()).thenAnswer((_) async {});
    when(() => mockSounds.playAddRowSound()).thenAnswer((_) async {});
    when(() => mockSounds.playGameOverLoseSound()).thenAnswer((_) async {});
    when(() => mockSounds.playRemoveNumbersSound()).thenAnswer((_) async {});
    when(() => mockSounds.playNoHintsSound()).thenAnswer((_) async {});
    when(() => mockSounds.playHintSound()).thenAnswer((_) async {});
    when(() => mockSounds.playGameOverWinSound()).thenAnswer((_) async {});
  });

  Future<void> pumpTutorialPage(WidgetTester tester, index) async {
    tutorialPage = TutorialPage(settings: mockSettings, save: mockSave, step: index);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(400, 400), padding: EdgeInsets.all(1)),
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: const [Locale('en', '')],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSwatch().copyWith(primary:Colors.red, secondary: Colors.green, onPrimary: Colors.blue),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          home: tutorialPage,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testStep(int index, Stage stage, WidgetTester tester) async {
    await pumpTutorialPage(tester, index);
    Desk desk = Desk(0, 0, stage.buttonsPerRow, stage.getFields(), stage.buttonsPerRow);

    final buttonsWithNumberKey = tester.widgetList<TextButton>(find.byType(TextButton))
        .where((button) => button.key is ValueKey<String> && (button.key as ValueKey<String>).value.startsWith('number_'));
    expect(buttonsWithNumberKey.length, desk.numbers.length);

    Hint? hint = desk.findHint();
    if (stage.hint != null) {
      expect(hint, isNotNull);
      expect(hint!.hint1, stage.hint!.hint1);
      expect(hint.hint2, stage.hint!.hint2);
    }
    while (hint != null) {
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('number_${hint.hint1}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(Key('number_${hint.hint2}')));

      desk.move(hint.hint1, hint.hint2);
      hint = desk.findHint();
    }
    if (index == tutorial.getSteps().length - 1) {
      State<TutorialPage> state = tester.state(find.byType(TutorialPage));
      debugPrint(state.toString());
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(PopupDialog), findsOneWidget);
      expect(find.textContaining(AppLocalizations.of(tester.element(find.byType(PopupDialog)))!.tutorialPagePopupTitle), findsOneWidget);
      expect(find.textContaining(AppLocalizations.of(tester.element(find.byType(PopupDialog)))!.tutorialPagePopupFinish), findsOneWidget);
      await tester.tap(find.text('Main Menu'.toUpperCase()));
      await tester.pumpAndSettle();
    } else {
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ElevatedButton));
    }
  }


  tutorial.getSteps().asMap().forEach((index, testCase) {
    testWidgets('Test case #$index. ${testCase.text}', (WidgetTester tester) async {
      await testStep(index, testCase, tester);
    });
  });

}
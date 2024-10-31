import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numerocide/components/themes.dart';
import 'package:numerocide/effects/sounds.dart';
import 'package:numerocide/effects/vibro.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/field.dart';
import 'package:numerocide/game/save.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/pages/game_page.dart';
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

  Future<void> pumpGamePage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSwatch().copyWith(primary:Colors.red, secondary: Colors.green, onPrimary: Colors.blue),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: GamePage(
          mode: GamePage.modeLoadGame,
          settings: mockSettings,
          save: mockSave,
          sounds: mockSounds,
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUpAll(() {
    registerFallbackValue(MockDesk());
  });

  testWidgets('Displays game over dialog on losing the game and press return', (WidgetTester tester) async {
    await pumpGamePage(tester);
    when(() => mockDesk.checkGameStatus()).thenReturn(false);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOne);
    expect(find.textContaining('GAME OVER'), findsOneWidget);
    expect(find.textContaining('SCORE'), findsOneWidget);
    await tester.tap(find.text('RETURN'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Displays game over dialog on win the game and press return', (WidgetTester tester) async {
    when(() => mockDesk.getScore()).thenReturn(2000);
    await pumpGamePage(tester);
    when(() => mockDesk.isVictory()).thenReturn(true);
    when(() => mockDesk.checkGameStatus()).thenReturn(false);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.byType(AlertDialog), findsOne);
    expect(find.textContaining('GAME OVER'), findsOneWidget);
    expect(find.textContaining('SCORE: 2000'), findsOneWidget);
    expect(find.textContaining('Best\n2000'), findsOneWidget);
    expect(find.textContaining('best score'), findsOneWidget);
    await tester.tap(find.text('RETURN'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Displays game over dialog on losing the game and taps outside', (WidgetTester tester) async {
    await pumpGamePage(tester);
    when(() => mockDesk.checkGameStatus()).thenReturn(false);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOne);
    expect(find.textContaining('GAME OVER'), findsOneWidget);
    expect(find.textContaining('SCORE'), findsOneWidget);
    await tester.tapAt(const Offset(0, 0));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('Processes button press', (WidgetTester tester) async {
    when(() => mockDesk.isCorrectMove(0, 1)).thenReturn(false);
    when(() => mockDesk.move(any(), any())).thenReturn(false);
    await pumpGamePage(tester);
    await tester.tap(find.byKey(const Key('number_0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('number_1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
    verifyNever(() => mockSounds.playRemoveNumbersSound());
    TextButton btn = tester.widget<TextButton>(find.byKey(const Key('number_0')));
    Color? backgroundColor = btn.style?.backgroundColor?.resolve({WidgetState.pressed});
    expect(backgroundColor, equals(Colors.green));
    btn = tester.widget<TextButton>(find.byKey(const Key('number_1')));
    backgroundColor = btn.style?.backgroundColor?.resolve({WidgetState.pressed});
    expect(backgroundColor, equals(Colors.blue));
    await tester.tap(find.byKey(const Key('number_1')));
    await tester.pumpAndSettle();

    when(() => mockDesk.isCorrectMove(0, 1)).thenReturn(true);
    when(() => mockDesk.move(any(), any())).thenReturn(false);
    await pumpGamePage(tester);
    await tester.tap(find.byKey(const Key('number_0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('number_1')));
    await tester.pumpAndSettle();
    await tester.pump(const Duration(milliseconds: 100));
     verify(() => mockSounds.playRemoveNumbersSound()).called(1);
  });

  testWidgets('Check button press', (WidgetTester tester) async {
    when(() => mockDesk.isCorrectMove(0, 1)).thenReturn(true);
    when(() => mockDesk.move(any(), any())).thenReturn(false);
    await pumpGamePage(tester);
    TextButton btn = tester.widget<TextButton>(find.byKey(const Key('number_0')));
    Color? backgroundColor = btn.style?.backgroundColor?.resolve({WidgetState.pressed});
    expect(backgroundColor, equals(Colors.green));
    await tester.tap(find.byKey(const Key('number_0')));
    await tester.pumpAndSettle();
    btn = tester.widget<TextButton>(find.byKey(const Key('number_0')));
    backgroundColor = btn.style?.backgroundColor?.resolve({WidgetState.pressed});
    expect(backgroundColor, equals(Colors.blue));
    await tester.tap(find.byKey(const Key('number_0')));
    await tester.pumpAndSettle();
    btn = tester.widget<TextButton>(find.byKey(const Key('number_0')));
    backgroundColor = btn.style?.backgroundColor?.resolve({WidgetState.pressed});
    expect(backgroundColor, equals(Colors.green));
  });


  testWidgets('Check game state updates and score tracking',
      (WidgetTester tester) async {
    await pumpGamePage(tester);

    when(() => mockDesk.checkGameStatus()).thenReturn(false);
    when(() => mockDesk.getScore()).thenReturn(150);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    verify(() => mockSounds.playAddRowSound()).called(1);
    expect(find.text('150'), findsOneWidget);
  });

  testWidgets(
      'Shows hint and triggers sound and vibration when hint button pressed',
      (WidgetTester tester) async {
    await pumpGamePage(tester);

    when(() => mockDesk.findHint()).thenReturn(null);

    await tester.tap(find.byIcon(Icons.lightbulb));
    await tester.pumpAndSettle();

    verify(() => mockSounds.playNoHintsSound()).called(1);
  });

  testWidgets('AddRowsTest', (WidgetTester tester) async {
    Settings settings = Settings(sound: true, vibro: true, theme: Themes.green, language: 'en');
    GamePage gamePage = GamePage(
      mode: GamePage.modeNewGame,
      settings: settings,
      save: Save(),
    );

    await tester.pumpWidget(MaterialApp(
      home: gamePage,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
      ],
    ));

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

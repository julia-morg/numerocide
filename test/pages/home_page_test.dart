import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/material.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/field.dart';
import 'package:numerocide/pages/home_page.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/game/save.dart';
import 'package:numerocide/components/popup_dialog.dart';
import 'package:numerocide/pages/game_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:numerocide/pages/tutorial_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockSave extends Mock implements Save {}

class MockDesk extends Mock implements Desk {}

void main() {
  late Settings settings;
  late MockSave mockSave;

  setUp(() {
    settings =
        Settings(sound: true, vibro: true, theme: 'navy', language: 'en');
    mockSave = MockSave();
    when(() => mockSave.loadMaxScore()).thenAnswer((_) async => 12);
    when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => false);
    when(() => mockSave.hasSavedGame()).thenAnswer((_) async => false);
    when(() => mockSave.saveTutorialPassed()).thenAnswer((_) async => true);
    when(() => mockSave.saveGame(any())).thenAnswer((_) async => true);
    when(() => mockSave.loadGame())
        .thenAnswer((_) async => Desk(1, 100, 3, {0: Field(0, 5, true)}));
  });

  setUpAll(() {
    registerFallbackValue(MockDesk());
  });

  testWidgets(
      'HomePage displays max score, new game, and continue game buttons',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        home: HomePage(settings: settings, save: mockSave),
      ),
    );

    expect(find.textContaining('NUMEROCIDE'.toUpperCase()), findsOneWidget);
    expect(find.textContaining('Best Result'.toUpperCase()), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNWidgets(2));
  });

  testWidgets('New game button shows tutorial dialog if tutorial not passed',
      (tester) async {
    when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => false);
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        home: HomePage(settings: settings, save: mockSave),
      ),
    );

    await tester.tap(find.textContaining('New Game'.toUpperCase()));
    await tester.pump();

    expect(find.byType(PopupDialog), findsOneWidget);
    expect(find.textContaining('How to play'), findsOneWidget);
  });

  testWidgets(
      'Continue game button navigates to game page if there is a saved game',
      (tester) async {
    Save save = Save();
    Desk desk = Desk(1, 100, 3, {0: Field(0, 5, true)});
    SharedPreferences.setMockInitialValues({});
    await save.saveGame(desk);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: ThemeData(
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
        home: HomePage(settings: settings, save: save),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Continue Game'.toUpperCase()));
    await tester.pumpAndSettle();

    expect(find.byType(GamePage), findsOneWidget);
  });

  Future<void> initializeHomePage(WidgetTester tester) async {
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
            size: Size(400, 400), padding: EdgeInsets.all(1)),
        child: MaterialApp(
          theme: ThemeData(
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
          ),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: HomePage(settings: settings, save: mockSave),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HomePage - _onNewGamePressed', () {
    testWidgets('Show tutorial popup. Confirm', (WidgetTester tester) async {
      when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => false);
      await initializeHomePage(tester);

      await tester.tap(find.textContaining('New Game'.toUpperCase()));
      await tester.pumpAndSettle();

      expect(find.textContaining('TUTORIAL'), findsOneWidget);
      await tester.tap(find.textContaining('TUTORIAL'.toUpperCase()));
      await tester.pumpAndSettle();
      expect(find.byType(TutorialPage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'The rules are always available in the settings menu.'),
          findsOneWidget);
    });

    testWidgets('Show tutorial popup. Cancel', (WidgetTester tester) async {
      when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => false);
      await initializeHomePage(tester);

      await tester.tap(find.textContaining('New Game'.toUpperCase()));
      await tester.pumpAndSettle();

      expect(find.textContaining('TUTORIAL'), findsOneWidget);
      await tester.tap(find.textContaining('GO TO GAME'));
      await tester.pumpAndSettle();
      expect(find.byType(GamePage), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
      expect(
          find.textContaining(
              'The rules are always available in the settings menu.'),
          findsOneWidget);
    });

    testWidgets('Show save game popup. Confirm', (WidgetTester tester) async {
      when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => true);
      when(() => mockSave.hasSavedGame()).thenAnswer((_) async => true);

      await initializeHomePage(tester);
      await tester.tap(find.textContaining('New Game'.toUpperCase()));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle();
      expect(find.textContaining('You have a saved game'), findsOneWidget);
      expect(find.textContaining('Your current progress will be lost'),
          findsOneWidget);
      final dialog = find.byType(Dialog);
      final newGameButton = find.descendant(
          of: dialog, matching: find.textContaining('NEW GAME'));
      await tester.tap(newGameButton);
      await tester.pumpAndSettle();
    });

    testWidgets('Show save game popup. Cancel', (WidgetTester tester) async {
      when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => true);
      when(() => mockSave.hasSavedGame()).thenAnswer((_) async => true);

      await initializeHomePage(tester);

      await tester.tap(find.textContaining('NEW GAME'));
      await tester.pumpAndSettle();

      final dialog = find.byType(Dialog);
      final newGameButton =
          find.descendant(of: dialog, matching: find.textContaining('BACK'));
      await tester.tap(newGameButton);
      await tester.pumpAndSettle();
    });

    testWidgets('New game', (WidgetTester tester) async {
      when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => true);
      when(() => mockSave.hasSavedGame()).thenAnswer((_) async => false);

      await initializeHomePage(tester);

      await tester.tap(find.textContaining('NEW GAME'));
      await tester.pumpAndSettle();

      expect(find.byType(GamePage), findsOneWidget);
    });

    testWidgets('Continue game', (WidgetTester tester) async {
      when(() => mockSave.isTutorialPassed()).thenAnswer((_) async => true);
      when(() => mockSave.hasSavedGame()).thenAnswer((_) async => true);

      await initializeHomePage(tester);

      await tester.tap(find.textContaining('CONTINUE GAME'));
      await tester.pumpAndSettle();

      expect(find.byType(GamePage), findsOneWidget);
    });
  });
}

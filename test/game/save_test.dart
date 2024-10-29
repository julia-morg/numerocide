import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numerocide/game/save.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Save class tests', () {
    late Save save;

    setUp(() {
      save = Save();
      SharedPreferences.setMockInitialValues({});
    });

    test('should save and load tutorial passed status', () async {
      await save.saveTutorialPassed();
      bool isPassed = await save.isTutorialPassed();
      expect(isPassed, true);
    });

    test('should save and load max score', () async {
      await save.saveMaxScore(100);
      int maxScore = await save.loadMaxScore();
      expect(maxScore, 100);
    });

    test('should save and load game', () async {
      Desk desk = Desk(1, 100, 3, {0: Field(0, 5, true)});
      await save.saveGame(desk);

      Desk loadedDesk = await save.loadGame();
      expect(loadedDesk.getScore(), 100);
      expect(loadedDesk.getStage(), 1);
      expect(loadedDesk.getRemainingAddClicks(), 3);
      expect(loadedDesk.numbers[0]?.number, 5);
      expect(loadedDesk.numbers[0]?.isActive, true);
    });

    test('should remove saved game', () async {
      Desk desk = Desk(1, 100, 3, {0: Field(0, 5, true)});
      await save.saveGame(desk);
      save.removeGame();

      expect(() async => await save.loadGame(), throwsException);
    });

    test('should check if there is a saved game', () async {
      bool hasSavedGame = await save.hasSavedGame();
      expect(hasSavedGame, false);

      Desk desk = Desk(1, 100, 3, {0: Field(0, 5, true)});
      await save.saveGame(desk);

      hasSavedGame = await save.hasSavedGame();
      expect(hasSavedGame, true);
    });

    test('should overwrite existing saved game', () async {
      Desk initialDesk = Desk(1, 100, 3, {0: Field(0, 5, true)});
      await save.saveGame(initialDesk);

      Desk newDesk = Desk(2, 200, 5, {0: Field(1, 10, false)});
      await save.saveGame(newDesk);

      Desk loadedDesk = await save.loadGame();
      expect(loadedDesk.getScore(), 200);
      expect(loadedDesk.getStage(), 2);
      expect(loadedDesk.getRemainingAddClicks(), 5);
      expect(loadedDesk.numbers[0]?.number, 10);
      expect(loadedDesk.numbers[0]?.isActive, false);
    });
  });
}
import 'package:numerocide/game/field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'desk.dart';

class Save {
  static String paramTutorialPassed = 'tutorial_passed';
  static String paramMaxScore = 'maxScore';
  static String paramSavedGameScore = 'score';
  static String paramSavedGameStage= 'stage';
  static String paramSavedGameRemainingAdds = 'remainingAddClicks';
  static String paramSavedGamNumbersPrefix = 'field_number_';
  static String paramSavedGamStatusPrefix = 'field_isActive_';

  Future<bool> hasSavedGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('${paramSavedGamNumbersPrefix}0');
  }

  Future<bool> isTutorialPassed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(paramTutorialPassed) ?? false;
  }

  Future<bool> saveTutorialPassed() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool(paramTutorialPassed, true);
  }

  Future<void> saveGame(Desk desk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()) {
      if (key.startsWith(paramSavedGamNumbersPrefix) ||
          key.startsWith(paramSavedGamStatusPrefix)) {
        await prefs.remove(key);
      }
    }
    Map<int, Field> numbersCopy = Map.from(desk.numbers);
    for (var entry in numbersCopy.entries) {
      int index = entry.key;
      Field field = entry.value;
      await prefs.setInt('$paramSavedGamNumbersPrefix$index', field.number);
      await prefs.setBool('$paramSavedGamStatusPrefix$index', field.isActive);
    }
    await prefs.setInt(paramSavedGameScore, desk.score);
    await prefs.setInt(paramSavedGameStage, desk.stage);
    await prefs.setInt(paramSavedGameRemainingAdds, desk.remainingAddClicks);
  }

  Future<bool> saveMaxScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int maxScore = prefs.getInt(paramMaxScore) ?? 0;

    if (score > maxScore) {
      await prefs.setInt(paramMaxScore, score);
      return true;
    }
    return false;
  }

  Future<int> loadMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(paramMaxScore) ?? 0;
  }

  Future<Desk> loadGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().any((key) => key.startsWith(paramSavedGamNumbersPrefix))) {
      Map<int, Field> numbers = {};
      int index = 0;
      for (String key in prefs.getKeys()) {
        if (key.startsWith(paramSavedGamNumbersPrefix)) {
          int? number = prefs.getInt('$paramSavedGamNumbersPrefix$index');
          bool? isActive = prefs.getBool('$paramSavedGamStatusPrefix$index');
          if (number != null && isActive != null) {
            numbers[index] = Field(index, number, isActive);
            index++;
          }
        }
      }
      return Desk(
        prefs.getInt(paramSavedGameStage) ?? 1,
        prefs.getInt(paramSavedGameScore) ?? 0,
        prefs.getInt(paramSavedGameRemainingAdds) ?? 0,
        numbers,
      );
    }
    throw Exception('No saved game found');
  }

  void removeGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()) {
      if (key.startsWith(paramSavedGamNumbersPrefix) ||
          key.startsWith(paramSavedGamStatusPrefix)) {
        await prefs.remove(key);
      }
    }
    await prefs.remove(paramSavedGameScore);
    await prefs.remove(paramSavedGameStage);
    await prefs.remove(paramSavedGameRemainingAdds);
  }
}

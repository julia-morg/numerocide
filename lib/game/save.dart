import 'package:numerocide/game/field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'desk.dart';

class Save {

  Future<bool> hasSavedGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('field_index_0');
  }


  Future<void> saveGame(Desk desk) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()) {
      if (key.startsWith('field_index_') ||
          key.startsWith('field_number_') ||
          key.startsWith('field_isActive_')) {
        await prefs.remove(key);
      }
    }
    Map<int, Field> numbersCopy = Map.from(desk.numbers);
    for (var entry in numbersCopy.entries) {
      int index = entry.key;
      Field field = entry.value;
      await prefs.setInt('field_index_$index', field.i);
      await prefs.setInt('field_number_$index', field.number);
      await prefs.setBool('field_isActive_$index', field.isActive);
    }
    await prefs.setInt('score', desk.score);
    await prefs.setInt('stage', desk.stage);
    await prefs.setInt('remainingAddClicks', desk.remainingAddClicks);
  }

  Future<bool> saveMaxScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int maxScore = prefs.getInt('maxScore') ?? 0;

    if (score > maxScore) {
      await prefs.setInt('maxScore', score);
      return true;
    }
    return false;
  }

  Future<int> loadMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('maxScore') ?? 0;
  }

  Future<Desk> loadGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getKeys().any((key) => key.startsWith('field_index_'))) {
      Map<int, Field> numbers = {};

      for (String key in prefs.getKeys()) {
        if (key.startsWith('field_index_')) {
          int index = int.parse(key.replaceFirst('field_index_', ''));
          int? number = prefs.getInt('field_number_$index');
          bool? isActive = prefs.getBool('field_isActive_$index');

          if (number != null && isActive != null) {
            numbers[index] = Field(index, number, isActive);
          }
        }
      }
      return Desk(
        prefs.getInt('stage') ?? 1,
        prefs.getInt('score') ?? 0,
        prefs.getInt('remainingAddClicks') ?? 0,
        numbers,
      );
    }
    throw Exception('No saved game found');
  }

  void removeGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()) {
      if (key.startsWith('field_index_') ||
          key.startsWith('field_number_') ||
          key.startsWith('field_isActive_')) {
        await prefs.remove(key);
      }
    }
    await prefs.remove('score');
    await prefs.remove('stage');
    await prefs.remove('remainingAddClicks');
  }
}

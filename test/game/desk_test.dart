import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/field.dart';
import 'package:numerocide/game/hint.dart';

void main() {
  group('Desk', () {
    late Desk desk;

    setUp(() {
      desk = Desk.newGame();
    });

    test('newGame should initialize a new desk with default values', () {
      final newDesk = Desk.newGame();
      expect(newDesk.getStage(), 1);
      expect(newDesk.getScore(), 0);
      expect(newDesk.getRemainingAddClicks(), Desk.defaultAddsCount);
      expect(newDesk.numbers.length, Desk.initialButtonsCount);
    });

    test('addFields should add new active fields if clicks remain', () {
      final initialLength = desk.numbers.length;
      desk.addFields();
      expect(desk.numbers.length, greaterThan(initialLength));
      expect(desk.getRemainingAddClicks(), Desk.defaultAddsCount - 1);
    });

    test('addFields should not add fields if no clicks remain', () {
      desk.setRemainingAddClicks(0);
      final initialLength = desk.numbers.length;
      desk.addFields();
      expect(desk.numbers.length, initialLength);
    });

    test('generateRandomNumbers should generate the correct number of fields',
        () {
      final numbers = Desk.generateRandomNumbers(5);
      expect(numbers.length, 5);
    });

    test('newStage should reset the desk for the next stage', () {
      desk.newStage(10);
      expect(desk.getStage(), 2);
      expect(desk.getRemainingAddClicks(), Desk.defaultAddsCount);
      expect(desk.numbers.length, 10);
    });

    test('checkGameStatus should return true for victory', () {
      desk.numbers.updateAll((key, value) => Field(key, value.number, false));
      expect(desk.checkGameStatus(), true);
    });

    test('isCorrectMove should return true for valid move', () {
      desk.numbers[0] = Field(0, 5, true);
      desk.numbers[1] = Field(1, 5, true);
      expect(desk.isCorrectMove(0, 1), true);
    });

    test('isCorrectMove should return false for invalid move', () {
      desk.numbers[0] = Field(0, 5, true);
      desk.numbers[1] = Field(1, 3, true);
      expect(desk.isCorrectMove(0, 1), false);
    });

    test('findHint should return a valid hint if available', () {
      desk.numbers[0] = Field(0, 5, true);
      desk.numbers[1] = Field(1, 5, true);
      expect(desk.findHint(), isA<Hint>());
    });

    test('findHint should return null if no hint is available', () {
      desk.numbers.updateAll((key, value) => Field(key, value.number, false));
      expect(desk.findHint(), null);
    });

    test('move should deactivate fields and update score for valid move', () {
      desk.numbers[0] = Field(0, 5, true);
      desk.numbers[1] = Field(1, 5, true);
      desk.move(0, 1);
      expect(desk.numbers[0]!.isActive, false);
      expect(desk.numbers[1]!.isActive, false);
      expect(desk.getScore(), 2 * desk.getStage());
    });

    test('move should return false for invalid move', () {
      desk.numbers[0] = Field(0, 5, true);
      desk.numbers[1] = Field(1, 3, true);
      final moved = desk.move(0, 1);
      expect(moved, false);
    });

    test('isVictory should return true if all fields are inactive', () {
      desk.numbers.updateAll((key, value) => Field(key, value.number, false));
      expect(desk.isVictory(), true);
    });

    test('isVictory should return false if any field is active', () {
      desk.numbers[0] = Field(0, 5, true);
      expect(desk.isVictory(), false);
    });
  });
  test('toString should return correct string representation of Desk', () {
    final desk = Desk(1, 100, 2, {
      0: Field(0, 5, true),
      1: Field(1, 3, false),
      2: Field(2, 7, true),
    });

    final expectedString = 'Desk{stage: 1, score: 100, remainingAddClicks: 2, rowLength: 9}\nnumbers: \n5/a 3/d 7/a\n';
    expect(desk.toString(), expectedString);
  });

  test('toString should return correct string representation of Desk with more numbers than row length', () {
    final desk = Desk(1, 100, 2, {
      0: Field(0, 5, true),
      1: Field(1, 3, false),
      2: Field(2, 7, true),
      3: Field(3, 2, true),
      4: Field(4, 8, false),
      5: Field(5, 1, true),
    }, 3);

    final expectedString = 'Desk{stage: 1, score: 100, remainingAddClicks: 2, rowLength: 3}\nnumbers: \n5/a 3/d 7/a\n2/a 8/d 1/a\n';
    expect(desk.toString(), expectedString);
  });
}

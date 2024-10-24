import 'package:flutter/cupertino.dart';

import 'field.dart';
import 'hint.dart';
import 'dart:math';

class Desk {
  static const defaultAddsCount = 3;
  static const initialButtonsCount = 36;
  static const defaultRowLength = 9;
  int stage = 0;
  int score = 0;
  int remainingAddClicks = defaultAddsCount;
  Map<int, Field> numbers = {};
  int rowLength;

  Desk(this.stage, this.score, this.remainingAddClicks, this.numbers, [this.rowLength = defaultRowLength]);

  static Desk newGame() {
    debugPrint('newGame');
    return Desk(1, 0, defaultAddsCount, generateRandomNumbers(initialButtonsCount));
  }

  void addFields() {
    if (remainingAddClicks == 0) return;
    remainingAddClicks--;
    List<Field> activeFields = [];
    for(int i = 0; i < numbers.length; i++) {
      if (numbers[i]?.isActive == true) {
        activeFields.add(numbers[i]!);
      }
    }

    int currentSize = numbers.length;
    for (int i = 0; i < activeFields.length; i++) {
      numbers[currentSize + i] =
          Field(currentSize + i, activeFields[i].number, true);
    }
  }

  static Map<int, Field> generateRandomNumbers(int count) {
    return List.generate(count, (_) => Random().nextInt(9) + 1)
        .asMap()
        .map((index, number) => MapEntry(index, Field(index, number, true)));
  }

  void newStage(int count) {
    stage++;
    remainingAddClicks = Desk.defaultAddsCount;
    numbers.clear();
    numbers = generateRandomNumbers(count);
  }

  bool? checkGameStatus() {
    if (isVictory()) {
      return true;
    } else if (remainingAddClicks == 0 && findHint() == null) {
      return false;
    }
    return null;
  }

  bool isCorrectMove(int firstIndex, int secondIndex) {
    int firstButtonIndex = numbers[firstIndex]!.i;
    int secondButtonIndex = numbers[secondIndex]!.i;
    int firstButtonValue = numbers[firstIndex]!.number;
    int secondButtonValue = numbers[secondIndex]!.number;

    if ((firstButtonValue == secondButtonValue ||
        firstButtonValue + secondButtonValue == 10) &&
        (_isFirstAndLastButton(firstButtonIndex, secondButtonIndex) ||
            _areButtonsInSameRow(firstButtonIndex, secondButtonIndex) &&
                _areButtonsIsolated(firstButtonIndex, secondButtonIndex) ||
            _areCellsCoherent(firstButtonIndex, secondButtonIndex) ||
            _areButtonsInSameColumn(firstButtonIndex, secondButtonIndex) &&
                _areButtonsIsolated(firstButtonIndex, secondButtonIndex) ||
            _areButtonsOnSameDiagonal(firstButtonIndex, secondButtonIndex) &&
                _areButtonsIsolated(firstButtonIndex, secondButtonIndex))) {
      return true;
    }
    return false;
  }

  Hint? findHint() {
    for (int i = 0; i < numbers.length; i++) {
      if (numbers[i]?.isActive == true) {
        for (int j = i + 1; j < numbers.length; j++) {
          if (numbers[j]?.isActive == true &&
              (numbers[i]!.number == numbers[j]!.number ||
                  numbers[i]!.number + numbers[j]!.number == 10)) {
            if (isCorrectMove(i, j)) {
              return Hint(i, j);
            }
          }
        }
      }
    }
    return null;
  }

  bool move(int firstIndex, int secondIndex) {
    if (isCorrectMove(firstIndex, secondIndex)) {
      numbers[firstIndex]!.isActive = false;
      numbers[secondIndex]!.isActive = false;
      score += 2*stage;
      return _checkAndRemoveEmptyRows();
    }
    return false;
  }

  bool isVictory() {
    return numbers.values.every((field) => !field.isActive);
  }

  bool _areButtonsInSameRow(int firstIndex, int secondIndex) {
    return firstIndex ~/ rowLength == secondIndex ~/ rowLength;
  }

  bool _areButtonsInSameColumn(int firstIndex, int secondIndex) {
    return firstIndex % rowLength == secondIndex % rowLength;
  }

  bool _areButtonsOnSameDiagonal(int firstIndex, int secondIndex) {
    int row1 = firstIndex ~/ rowLength;
    int col1 = firstIndex % rowLength;
    int row2 = secondIndex ~/ rowLength;
    int col2 = secondIndex % rowLength;

    return (row1 - col1 == row2 - col2) || (row1 + col1 == row2 + col2);
  }

  bool _areCellsCoherent(int firstIndex, int secondIndex) {
    int start = min(firstIndex, secondIndex).toInt();
    int end = max(firstIndex, secondIndex);
    for (int i = start + 1; i < end; i++) {
      if (numbers[i]?.isActive == true) {
        return false;
      }
    }
    return true;
  }

  bool _areButtonsIsolated(int firstIndex, int secondIndex) {
    if (_areButtonsInSameRow(firstIndex, secondIndex)) {
      int start = min(firstIndex, secondIndex) + 1;
      int end = max(firstIndex, secondIndex);
      for (int i = start; i < end; i++) {
        if (numbers[i]?.isActive == true) return false;
      }
    } else if (_areButtonsInSameColumn(firstIndex, secondIndex)) {
      int start = min(firstIndex, secondIndex);
      int end = max(firstIndex, secondIndex);
      for (int i = start + rowLength; i < end; i += rowLength) {
        if (numbers[i]?.isActive == true) return false;
      }
    } else if (_areButtonsOnSameDiagonal(firstIndex, secondIndex)) {
      int rowStart = firstIndex ~/ rowLength;
      int rowEnd = secondIndex ~/ rowLength;
      int colStart = firstIndex % rowLength;
      int colEnd = secondIndex % rowLength;

      int rowIncrement = rowEnd > rowStart ? 1 : -1;
      int colIncrement = colEnd > colStart ? 1 : -1;

      int i = firstIndex;
      while (i != secondIndex) {
        i += rowIncrement * rowLength + colIncrement;
        if (i == secondIndex) break;
        if (numbers[i]?.isActive == true) return false;
      }
    }
    return true;
  }

  bool _isFirstAndLastButton(int firstIndex, int secondIndex) {
    int firstActiveIndex = -1;
    for (int i = 0; i < numbers.length; i++) {
      if (numbers[i]?.isActive == true) {
        firstActiveIndex = i;
        break;
      }
    }

    int lastActiveIndex = -1;
    for (int i = numbers.length - 1; i >= 0; i--) {
      if (numbers[i]?.isActive == true) {
        lastActiveIndex = i;
        break;
      }
    }

    return (firstIndex == firstActiveIndex && secondIndex == lastActiveIndex) ||
        (firstIndex == lastActiveIndex && secondIndex == firstActiveIndex);
  }

  bool _checkAndRemoveEmptyRows() {
    int totalRows = (numbers.length / rowLength).ceil();
    bool removed = false;
    for (int rowIndex = totalRows - 1; rowIndex >= 0; rowIndex--) {
      if (_isRowEmpty(rowIndex)) {
        _removeRow(rowIndex);
        removed = true;
      }
    }
    return removed;
  }

  void _removeRow(int rowIndex) {
    int startIndex = rowIndex * rowLength;

    for (int i = startIndex; i < startIndex + rowLength; i++) {
      numbers.remove(i);
    }

    _recalculateFieldIndices(numbers, startIndex, rowLength);
  }

  void _recalculateFieldIndices(
      Map<int, Field> numbers, int startIndex, int rowLength) {
    Map<int, Field> updatedNumbers = {};
    int shift = rowLength;

    numbers.forEach((key, field) {
      if (key >= startIndex) {
        updatedNumbers[key - shift] =
            Field(key - shift, field.number, field.isActive);
      } else {
        updatedNumbers[key] = field;
      }
    });

    numbers.clear();
    numbers.addAll(updatedNumbers);
  }

  bool _isRowEmpty(int rowIndex) {
    for (int i = rowIndex * rowLength; i < (rowIndex + 1) * rowLength; i++) {
      if (numbers[i]?.isActive == true) {
        return false;
      }
    }
    return true;
  }

  @override
  String toString() {
    StringBuffer buffer = StringBuffer();
    int counter = 0;

    numbers.forEach((index, field) {
      buffer.write('${field.number} ');  // Добавляем число в строку
      counter++;

      // Если набрали rowLength элементов, добавляем перенос строки
      if (counter % rowLength == 0) {
        buffer.write('\n');
      }
    });


    return 'Desk{stage: $stage, score: $score, remainingAddClicks: $remainingAddClicks, rowLength: $rowLength}\nnumbers: \n${buffer.toString().trim()}\n';
  }
}

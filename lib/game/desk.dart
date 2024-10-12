import 'field.dart';
import 'hint.dart';
import 'dart:math';

class Desk {
  static const DEFAULT_HINTS_COUNT = 3;
  int stage = 0;
  int score = 0;
  int remainingAddClicks = DEFAULT_HINTS_COUNT;
  Map<int, Field> numbers = {};
  int rowLength = 0;

  Desk(this.stage, this.score, this.remainingAddClicks, this.numbers, this.rowLength);

  void addFields() {
    if (remainingAddClicks == 0) return;
    remainingAddClicks--;
    List<Field> activeFields = [];
    for (var entry in numbers.entries) {
      if (entry.value.isActive) {
        activeFields.add(entry.value);
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
    remainingAddClicks = Desk.DEFAULT_HINTS_COUNT;
    numbers.clear();
    numbers = generateRandomNumbers(count);
  }

  bool addExtraStage() {
    if (remainingAddClicks > 0) {
      remainingAddClicks--;
      List<Field> activeFields = [];
      for (var entry in numbers.entries) {
        if (entry.value.isActive) {
          activeFields.add(entry.value);
        }
      }

      int currentSize = numbers.length;
      for (int i = 0; i < activeFields.length; i++) {
        numbers[currentSize + i] =
            Field(currentSize + i, activeFields[i].number, true);
      }
      return true;
    } else {
      return false;
    }
  }

  bool? checkGameStatus() {
    if (isVictory()) {
      return true;
    } else if (remainingAddClicks == 0 && findHint() == null) {
      return false;
    }
    return null;
  }

  void move(int firstIndex, int secondIndex) {
    if (isCorrectMove(firstIndex, secondIndex)) {
      numbers[firstIndex]!.isActive = false;
      numbers[secondIndex]!.isActive = false;
      score += stage;
      checkAndRemoveEmptyRows();
    }
  }

  bool isVictory() {
    return numbers.values.every((field) => !field.isActive);
  }

  bool areButtonsInSameRow(int firstIndex, int secondIndex) {
    return firstIndex ~/ rowLength == secondIndex ~/ rowLength;
  }

  bool areButtonsInSameColumn(int firstIndex, int secondIndex) {
    return firstIndex % rowLength == secondIndex % rowLength;
  }

  bool areButtonsOnSameDiagonal(int firstIndex, int secondIndex) {
    int row1 = firstIndex ~/ rowLength;
    int col1 = firstIndex % rowLength;
    int row2 = secondIndex ~/ rowLength;
    int col2 = secondIndex % rowLength;

    return (row1 - col1 == row2 - col2) || (row1 + col1 == row2 + col2);
  }

  bool areCellsCoherent(int firstIndex, int secondIndex) {
    int start = min(firstIndex, secondIndex).toInt();
    int end = max(firstIndex, secondIndex);
    for (int i = start + 1; i < end; i++) {
      if (numbers[i]?.isActive == true) {
        return false;
      }
    }
    return true;
  }

  bool areButtonsIsolated(int firstIndex, int secondIndex) {
    if (areButtonsInSameRow(firstIndex, secondIndex)) {
      int start = min(firstIndex, secondIndex) + 1;
      int end = max(firstIndex, secondIndex);
      for (int i = start; i < end; i++) {
        if (numbers[i]?.isActive == true) return false;
      }
    } else if (areButtonsInSameColumn(firstIndex, secondIndex)) {
      int start = min(firstIndex, secondIndex);
      int end = max(firstIndex, secondIndex);
      for (int i = start + rowLength; i < end; i += rowLength) {
        if (numbers[i]?.isActive == true) return false;
      }
    } else if (areButtonsOnSameDiagonal(firstIndex, secondIndex)) {
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

  bool isFirstAndLastButton(int firstIndex, int secondIndex) {
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

  bool isCorrectMove(int firstIndex, int secondIndex) {
    int firstButtonIndex = numbers[firstIndex]!.i;
    int secondButtonIndex = numbers[secondIndex]!.i;
    int firstButtonValue = numbers[firstIndex]!.number;
    int secondButtonValue = numbers[secondIndex]!.number;

    if ((firstButtonValue == secondButtonValue ||
            firstButtonValue + secondButtonValue == 10) &&
        (isFirstAndLastButton(firstButtonIndex, secondButtonIndex) ||
            areButtonsInSameRow(firstButtonIndex, secondButtonIndex) &&
                areButtonsIsolated(firstButtonIndex, secondButtonIndex) ||
            areCellsCoherent(firstButtonIndex, secondButtonIndex) ||
            areButtonsInSameColumn(firstButtonIndex, secondButtonIndex) &&
                areButtonsIsolated(firstButtonIndex, secondButtonIndex) ||
            areButtonsOnSameDiagonal(firstButtonIndex, secondButtonIndex) &&
                areButtonsIsolated(firstButtonIndex, secondButtonIndex))) {
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

  bool checkAndRemoveEmptyRows() {
    int totalRows = (numbers.length / rowLength).floor();
    bool removed = false;
    for (int rowIndex = totalRows - 1; rowIndex >= 0; rowIndex--) {
      if (isRowEmpty(rowIndex)) {
        removeRow(rowIndex);
        removed = true;
      }
    }
    return removed;
  }

  void removeRow(int rowIndex) {
    int startIndex = rowIndex * rowLength;

    for (int i = startIndex; i < startIndex + rowLength; i++) {
      numbers.remove(i);
    }

    recalculateFieldIndices(numbers, startIndex, rowLength);
  }

  void recalculateFieldIndices(
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

  bool isRowEmpty(int rowIndex) {
    for (int i = rowIndex * rowLength; i < (rowIndex + 1) * rowLength; i++) {
      if (numbers[i]?.isActive == true) {
        return false;
      }
    }
    return true;
  }
}

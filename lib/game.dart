import 'package:flutter/material.dart';
import 'dart:math';
import 'game/button_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'game/field.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.title,
    required this.buttonSize,
    required this.buttonsPerRow,
    required this.initialButtonCount,
  });

  final String title;
  final double buttonSize;
  final int buttonsPerRow;
  final int initialButtonCount;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  int _counter = 0;
  int _score = 0;
  List<Map<String, int>> selectedButtons = [];
  Map <int, Field> numbers = {};

  @override
  void initState() {
    super.initState();
    _loadGameState();
  }

  void _initializeGame() {
    List<int> randomNumbers = [];
    Map<int, bool> activeButtons = {};
    randomNumbers = List.generate(
        widget.initialButtonCount, (_) => Random().nextInt(9) + 1);
    activeButtons = {
      for (var i = 0; i < widget.initialButtonCount; i++) i: true
    };
    setState(() {
      numbers = {
        for (var i = 0; i < widget.initialButtonCount; i++)
          i: Field(i, randomNumbers[i], true)
      };
      _counter = 0;
      _score = 0;
      selectedButtons.clear();
      _saveGameState();
    });
  }

  void _clearSavedGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < numbers.length; i++) {
      await prefs.remove('field_index_$i');
      await prefs.remove('field_number_$i');
      await prefs.remove('field_isActive_$i');
    }
    await prefs.remove('score');
    await prefs.remove('counter');
  }

  Future<void> _saveGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('numbers');
    for (var entry in numbers.entries) {
      int index = entry.key;
      Field field = entry.value;
      await prefs.setInt('field_index_$index', field.i);
      await prefs.setInt('field_number_$index', field.number);
      await prefs.setBool('field_isActive_$index', field.isActive);
    }

    await prefs.setInt('score', _score);
    await prefs.setInt('counter', _counter);
  }

  Future<void> _saveMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int maxScore = prefs.getInt('maxScore') ?? 0;

    if (_score > maxScore) {
      await prefs.setInt('maxScore', _score);
    }
  }

  Future<void> _loadGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('field_index_0')) {
      setState(() {
        numbers.clear();

        for (int i = 0; i < widget.initialButtonCount; i++) {
          int? index = prefs.getInt('field_index_$i');
          int? number = prefs.getInt('field_number_$i');
          bool? isActive = prefs.getBool('field_isActive_$i');

          if (index != null && number != null && isActive != null) {
            numbers[index] = Field(index, number, isActive);
          }
        }

        _score = prefs.getInt('score') ?? 0;
        _counter = prefs.getInt('counter') ?? 0;
      });
    } else {
      _initializeGame();
    }
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
    });
  }

  void _addCopiesOfButtons() {
    setState(() {
      List<Field> activeFields = [];
      for (var entry in numbers.entries) {
        if (entry.value.isActive) {
          activeFields.add(entry.value);
        }
      }

      int currentSize = numbers.length;
      for (int i = 0; i < activeFields.length; i++) {
        numbers[currentSize + i] = Field(currentSize + i, activeFields[i].number, true);
      }

      _counter++;
      _saveGameState();
    });
  }

  void _scoreCounter(int value1, int value2) {
    setState(() {
      _score += value1 + value2;
      _saveGameState();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.onSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
        ),
        titleTextStyle: TextStyle(
          color: colorLight,
          fontSize: 18,
        ),
        backgroundColor: colorDark,
        iconTheme: IconThemeData(
          color: colorLight,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorLight),
            onPressed: _restartGame,
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Score: $_score',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: colorDark),
                  ),
                  Text(
                    'Batches added: $_counter',
                    style: Theme.of(context)
                        .textTheme
                        .labelSmall!
                        .copyWith(color: colorDark),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: ScrollBehavior()
                    .copyWith(overscroll: false, scrollbars: false),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: ButtonGrid(
                    onButtonPressed: onButtonPressed,
                    selectedButtons: selectedButtons,
                    numbers: numbers,
                    buttonSize: widget.buttonSize,
                    buttonsPerRow: widget.buttonsPerRow,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isGameOver()
          ? null
          : FloatingActionButton(
              onPressed: _addCopiesOfButtons,
              tooltip: 'add',
              child: Icon(Icons.add, color: colorDark),
            ),
    );
  }

  void _showGameOverDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int maxScore = prefs.getInt('maxScore') ?? 0;

    if (_score > maxScore) {
      await prefs.setInt('maxScore', _score);
      maxScore = _score;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'CONGRATS! YOU WON!',
            textAlign: TextAlign.center,
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Text(
                'Your score: $_score',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '${_score == maxScore ? "This is your max score ever!" : ""}',
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Nice'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  bool areButtonsInSameRow(int firstIndex, int secondIndex) {
    return firstIndex ~/ widget.buttonsPerRow ==
        secondIndex ~/ widget.buttonsPerRow;
  }

  bool areButtonsInSameColumn(int firstIndex, int secondIndex) {
    return firstIndex % widget.buttonsPerRow ==
        secondIndex % widget.buttonsPerRow;
  }

  bool areButtonsOnSameDiagonal(int firstIndex, int secondIndex) {
    int row1 = firstIndex ~/ widget.buttonsPerRow;
    int col1 = firstIndex % widget.buttonsPerRow;
    int row2 = secondIndex ~/ widget.buttonsPerRow;
    int col2 = secondIndex % widget.buttonsPerRow;

    return (row1 - col1 == row2 - col2) || (row1 + col1 == row2 + col2);
  }

  bool areCellsCoherent(int firstIndex, int secondIndex) {
    int start = min(firstIndex, secondIndex);
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
      for (int i = start + widget.buttonsPerRow; i < end; i += widget.buttonsPerRow) {
        if (numbers[i]?.isActive == true) return false;
      }
    } else if (areButtonsOnSameDiagonal(firstIndex, secondIndex)) {
      int rowStart = firstIndex ~/ widget.buttonsPerRow;
      int rowEnd = secondIndex ~/ widget.buttonsPerRow;
      int colStart = firstIndex % widget.buttonsPerRow;
      int colEnd = secondIndex % widget.buttonsPerRow;

      int rowIncrement = rowEnd > rowStart ? 1 : -1;
      int colIncrement = colEnd > colStart ? 1 : -1;

      int i = firstIndex;
      while (i != secondIndex) {
        i += rowIncrement * widget.buttonsPerRow + colIncrement;
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

  void onButtonPressed(int index, int value, Function removeButton) {
    setState(() {
      if (selectedButtons.isNotEmpty && selectedButtons[0]['index'] == index) {
        selectedButtons.clear();
        return;
      }

      if (selectedButtons.isEmpty) {
        selectedButtons.add({'index': index, 'value': value});
      } else if (selectedButtons.length == 1) {
        selectedButtons.add({'index': index, 'value': value});

        int firstButtonIndex = selectedButtons[0]['index']!;
        int secondButtonIndex = selectedButtons[1]['index']!;
        int firstButtonValue = selectedButtons[0]['value']!;
        int secondButtonValue = selectedButtons[1]['value']!;

        // Проверяем, соответствуют ли значения кнопок и их положение
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
          selectedButtons.add({'index': index, 'value': value});

          Future.delayed(const Duration(milliseconds: 50), () {
            numbers[firstButtonIndex] = Field(firstButtonIndex, numbers[firstButtonIndex]!.number, false);
            numbers[secondButtonIndex] = Field(secondButtonIndex, numbers[secondButtonIndex]!.number, false);

            _scoreCounter(firstButtonValue, secondButtonValue);

            setState(() {
              selectedButtons.clear();
            });

            if (isGameOver()) {
              _saveMaxScore();
              _clearSavedGameState();
              _showGameOverDialog();
            }

            checkAndRemoveEmptyRows(numbers, widget.buttonsPerRow, () {
              setState(() {
                // Обновляем сетку для перерисовки
              });
            });
          });
        } else {
          // Если кнопки не соответствуют условиям, сбрасываем выбор
          selectedButtons.clear();
          selectedButtons.add({'index': index, 'value': value});
        }
      }
    });
  }

  bool isGameOver() {
    return numbers.values.every((field) => !field.isActive);
  }

  void checkAndRemoveEmptyRows(Map<int, Field> numbers, int buttonsPerRow, Function updateGrid) {
    int totalRows = (numbers.length / buttonsPerRow).floor();

    // Проходим по всем рядам с конца, чтобы избежать проблем с индексами при удалении
    for (int rowIndex = totalRows - 1; rowIndex >= 0; rowIndex--) {
      if (isRowEmpty(rowIndex, buttonsPerRow, numbers)) {
        // Удаляем кнопки и числа, если ряд пуст
        removeRow(rowIndex, buttonsPerRow, numbers);
      }
    }

    // Обновляем интерфейс
    updateGrid();
  }

  void removeRow(int rowIndex, int buttonsPerRow, Map<int, Field> numbers) {
    int startIndex = rowIndex * buttonsPerRow;

    // Удаляем все кнопки из ряда
    for (int i = startIndex; i < startIndex + buttonsPerRow; i++) {
      numbers.remove(i);
    }

    // Пересчитываем индексы оставшихся кнопок
    recalculateFieldIndices(numbers, startIndex, buttonsPerRow);
  }

  void recalculateFieldIndices(Map<int, Field> numbers, int startIndex, int buttonsPerRow) {
    Map<int, Field> updatedNumbers = {};
    int shift = buttonsPerRow; // Количество индексов для сдвига после удаления ряда

    numbers.forEach((key, field) {
      if (key >= startIndex) {
        updatedNumbers[key - shift] = Field(key - shift, field.number, field.isActive);
      } else {
        updatedNumbers[key] = field;
      }
    });

    numbers.clear();
    numbers.addAll(updatedNumbers);
  }

// Функция для проверки, пуст ли ряд
  bool isRowEmpty(int rowIndex, int buttonsPerRow, Map<int, Field> numbers) {
    for (int i = rowIndex * buttonsPerRow; i < (rowIndex + 1) * buttonsPerRow; i++) {
      if (numbers[i]?.isActive == true) {
        return false; // Ряд не пуст
      }
    }
    return true; // Все кнопки в ряду неактивны
  }

}

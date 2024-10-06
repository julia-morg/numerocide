import 'package:flutter/material.dart';
import 'dart:math';
import 'game/button_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({
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
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _score = 0;
  List<Map<String, int>> selectedButtons = [];
  List<int> randomNumbers = [];
  Map<int, bool> activeButtons = {};

  @override
  void initState() {
    super.initState();
    _loadGameState();
  }

  void _initializeGame() {
    setState(() {
      randomNumbers = List.generate(
          widget.initialButtonCount, (_) => Random().nextInt(9) + 1);
      activeButtons = {
        for (var i = 0; i < widget.initialButtonCount; i++) i: true
      };
      _counter = 0;
      _score = 0;
      selectedButtons.clear();
      _saveGameState();
    });
  }

  void _clearSavedGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('randomNumbers');
    await prefs.remove('score');
    await prefs.remove('counter');
    for (var i = 0; i < randomNumbers.length; i++) {
      await prefs.remove('activeButton_$i');
    }
  }

  Future<void> _saveGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('randomNumbers',
        randomNumbers.map((e) => e.toString()).toList());
    await prefs.setInt('score', _score);
    await prefs.setInt('counter', _counter);
    for (var i = 0; i < randomNumbers.length; i++) {
      await prefs.setBool('activeButton_$i', activeButtons[i] ?? true);
    }
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
    if (prefs.containsKey('randomNumbers')) {
      setState(() {
        randomNumbers = (prefs.getStringList('randomNumbers') ?? [])
            .map((e) => int.parse(e))
            .toList();
        _score = prefs.getInt('score') ?? 0;
        _counter = prefs.getInt('counter') ?? 0;
        activeButtons = {
          for (var i = 0; i < randomNumbers.length; i++)
            i: prefs.getBool('activeButton_$i') ?? true
        };
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
      List<int> activeNumbers = [];
      for (int i = 0; i < randomNumbers.length; i++) {
        if (activeButtons[i] == true) {
          activeNumbers.add(randomNumbers[i]);
        }
      }

      randomNumbers.addAll(activeNumbers);

      for (int i = randomNumbers.length - activeNumbers.length;
          i < randomNumbers.length;
          i++) {
        activeButtons[i] = true;
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
                    randomNumbers: randomNumbers,
                    activeButtons: activeButtons,
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
      if (activeButtons[i] == true) {
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
        if (activeButtons[i] == true) return false;
      }
    } else if (areButtonsInSameColumn(firstIndex, secondIndex)) {
      int start = min(firstIndex, secondIndex);
      int end = max(firstIndex, secondIndex);
      for (int i = start + widget.buttonsPerRow;
          i < end;
          i += widget.buttonsPerRow) {
        if (activeButtons[i] == true) return false;
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
        if (activeButtons[i] == true)
          return false;
      }
    }
    return true;
  }

  bool isFirstAndLastButton(int firstIndex, int secondIndex) {
    int firstActiveIndex = -1;
    for (int i = 0; i < randomNumbers.length; i++) {
      if (activeButtons[i] == true) {
        firstActiveIndex = i;
        break;
      }
    }

    int lastActiveIndex = -1;
    for (int i = randomNumbers.length - 1; i >= 0; i--) {
      if (activeButtons[i] == true) {
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
          removeButton(firstButtonIndex);
          removeButton(secondButtonIndex);
          _scoreCounter(firstButtonValue, secondButtonValue);

          Future.delayed(const Duration(milliseconds: 200), () {
            setState(() {
              selectedButtons.clear();
            });
            if (isGameOver()) {
              _saveMaxScore();
              _clearSavedGameState();
              _showGameOverDialog();
            }
          });
        } else {
          selectedButtons.clear();
          selectedButtons.add({'index': index, 'value': value});
        }
      }
    });
  }

  bool isGameOver() {
    return activeButtons.values.every((isActive) => !isActive);
  }
}

import 'package:flutter/material.dart';
import 'dart:math';
import 'game/button_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'game/field.dart';
import 'game/hint.dart';
import 'game/numbers.dart';

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

class _GamePageState extends State<GamePage> with SingleTickerProviderStateMixin {
  Numbers desk = Numbers(0, 0, {}, 0);
  Hint? currentHint;
  List<int> selectedButtons = [];
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _loadGameState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _shakeAnimation = Tween<double>(begin: 0, end: 8)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_shakeController);
  }

  void _initializeGame() {
    List<int> randomNumbers = List.generate(
        widget.initialButtonCount, (_) => Random().nextInt(9) + 1);
    setState(() {
      Map<int, Field> numbers = {
        for (var i = 0; i < widget.initialButtonCount; i++)
          i: Field(i, randomNumbers[i], true)
      };
      desk = Numbers(0, 0, numbers, widget.buttonsPerRow);
      selectedButtons.clear();
      _saveGameState();
    });
  }

  void _clearSavedGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < desk!.numbers.length; i++) {
      await prefs.remove('field_index_$i');
      await prefs.remove('field_number_$i');
      await prefs.remove('field_isActive_$i');
    }
    await prefs.remove('score');
    await prefs.remove('stage');
  }

  Future<void> _saveGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (String key in prefs.getKeys()) {
      if (key.startsWith('field_index_') || key.startsWith('field_number_') || key.startsWith('field_isActive_')) {
        await prefs.remove(key);
      }
    }
    for (var entry in desk.numbers.entries) {
      int index = entry.key;
      Field field = entry.value;
      await prefs.setInt('field_index_$index', field.i);
      await prefs.setInt('field_number_$index', field.number);
      await prefs.setBool('field_isActive_$index', field.isActive);
    }
    await prefs.setInt('score', desk.score);
    await prefs.setInt('stage', desk.stage);
  }

  Future<void> _saveMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int maxScore = prefs.getInt('maxScore') ?? 0;

    if (desk!.score > maxScore) {
      await prefs.setInt('maxScore', desk!.score);
    }
  }

  Future<void> _loadGameState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Проверяем, есть ли хотя бы один сохранённый элемент
    if (prefs.getKeys().any((key) => key.startsWith('field_index_'))) {
      Map<int, Field> numbers = {};

      // Ищем все ключи, соответствующие шаблону 'field_index_'
      for (String key in prefs.getKeys()) {
        if (key.startsWith('field_index_')) {
          // Извлекаем индекс из ключа
          int index = int.parse(key.replaceFirst('field_index_', ''));
          int? number = prefs.getInt('field_number_$index');
          bool? isActive = prefs.getBool('field_isActive_$index');

          // Если данные валидны, добавляем в numbers
          if (number != null && isActive != null) {
            numbers[index] = Field(index, number, isActive);
          }
        }
      }

      // Обновляем состояние
      setState(() {
        desk = Numbers(
          prefs.getInt('stage') ?? 0,
          prefs.getInt('score') ?? 0,
          numbers,
          widget.buttonsPerRow,
        );
      });
    } else {
      // Если нет данных, начинаем новую игру
      _initializeGame();
    }
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
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
                    'Score: ${desk!.score}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: colorDark),
                  ),
                  Text(
                    'Batches added: ${desk!.stage}',
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
                    desk: desk!,
                    buttonSize: widget.buttonSize,
                    buttonsPerRow: widget.buttonsPerRow,
                    hint: currentHint,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: desk!.isGameOver()
          ? null
          : Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "hintButton",
            onPressed: _onShowHintPressed,
            tooltip: 'Hint',
            child: Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _shakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_shakeAnimation.value, 0),
                child: FloatingActionButton(
                  heroTag: "addButton",
                  onPressed: _onAddButtonPressed,
                  tooltip: 'Add',
                  child: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _onAddButtonPressed() {
    setState(() {
      desk.newStage();
      _saveGameState();
    });
  }

  void _showGameOverDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setInt('maxScore', desk!.score);
    int maxScore = prefs.getInt('maxScore') ?? 0;

    if (desk!.score > maxScore) {
      await prefs.setInt('maxScore', desk!.score);
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
                'Your score: ${desk!.score}',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                desk!.score > maxScore ? "This is your max score ever!" : "",
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

  void onButtonPressed(int index, int value, Function removeButton) {
    setState(() {
      if (selectedButtons.isNotEmpty && selectedButtons[0] == index) {
        selectedButtons.clear();
        return;
      }

      if (selectedButtons.isEmpty) {
        selectedButtons.add(index);
      } else if (selectedButtons.length == 1) {
        selectedButtons.add(index);
        int firstButtonIndex = selectedButtons[0];
        int secondButtonIndex = selectedButtons[1];
        if(desk!.isCorrectMove(firstButtonIndex, secondButtonIndex)) {
          Future.delayed(const Duration(milliseconds: 50), () {
            desk!.move(firstButtonIndex, secondButtonIndex);
            setState(() {
              selectedButtons.clear();
              currentHint = null;
            });

            _saveGameState();

            if (desk!.isGameOver()) {
              _saveMaxScore();
              _clearSavedGameState();
              _showGameOverDialog();
            }
          });
        } else {
          selectedButtons.clear();
          selectedButtons.add(index);
        }
      }
    });
  }

  void _onShowHintPressed() {
    setState(() {
      currentHint = desk!.findHint();
      if (currentHint == null) {
        _animateAddButton();
      }
    });
  }

  void _animateAddButton() {
    _shakeController.forward(from: 0).then((_) {
      _shakeController.reverse();
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }
}

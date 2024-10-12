import 'package:flutter/material.dart';
import 'game/button_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'game/field.dart';
import 'game/hint.dart';
import 'game/desk.dart';
import 'game/animated_button.dart';

class GamePage extends StatefulWidget {
  const GamePage({
    super.key,
    required this.title,
    required this.buttonSize,
    required this.buttonsPerRow,
    required this.initialButtonCount,
    required this.maxScore,
    required this.mode,
  });

  final String title;
  final double buttonSize;
  final int buttonsPerRow;
  final int initialButtonCount;
  final int maxScore;
  final bool mode;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  Desk desk = Desk(0, 0, 0, {}, 0);
  Hint? currentHint;
  List<int> selectedButtons = [];
  late final GlobalKey<AnimatedButtonState> _addButtonKey =
      GlobalKey<AnimatedButtonState>();

  @override
  void initState() {
    super.initState();
    if(widget.mode) {
      _initializeGame();
    } else {
      _loadGameState();
    }
  }

  void _initializeGame() {
    setState(() {
      desk = Desk(1, 0, Desk.DEFAULT_HINTS_COUNT, Desk.generateRandomNumbers(widget.initialButtonCount), widget.buttonsPerRow);
      selectedButtons.clear();
      _saveGameState();
    });
    _checkGameState();
  }

  void _clearSavedGameState() async {
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

  Future<void> _saveGameState() async {
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

  Future<void> _saveMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int maxScore = prefs.getInt('maxScore') ?? 0;

    if (desk.score > maxScore) {
      await prefs.setInt('maxScore', desk.score);
    }
  }

  Future<void> _loadGameState() async {
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

      setState(() {
        desk = Desk(
          prefs.getInt('stage') ?? 1,
          prefs.getInt('score') ?? 0,
          prefs.getInt('remainingAddClicks') ?? 0,
          numbers,
          widget.buttonsPerRow,
        );
      });
    } else {
      _initializeGame();
    }
    _checkGameState();
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
          fontSize: 22,
          fontWeight: FontWeight.w600,
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Best\n${widget.maxScore}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: colorDark,  fontWeight: FontWeight.w600,),
                  ),
                  Text(
                    '${desk.score}',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(color: colorDark, fontWeight: FontWeight.w600,),
                  ),
                  Text(
                    'Stage\n${desk.stage}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .labelMedium!
                        .copyWith(color: colorDark, fontWeight: FontWeight.w600,),
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
                    desk: desk,
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
      floatingActionButton: desk.isVictory()
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AnimatedButton(
                    onPressed: _onShowHintPressed,
                    icon: Icons.lightbulb,
                    color: Theme.of(context).colorScheme.primary,
                    heroTag: 'hintButton',
                    active: true,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: AnimatedButton(
                    key: _addButtonKey,
                    onPressed: _onAddButtonPressed,
                    icon: Icons.add,
                    color: Theme.of(context).colorScheme.primary,
                    heroTag: 'addButton',
                    active: desk.remainingAddClicks > 0,
                    labelCount: desk.remainingAddClicks,
                  ),
                ),
              ],
            ),
    );
  }

  void _onAddButtonPressed() {
    setState(() {
      desk.addFields();
      _saveGameState();
    });
  }

  void _showGameOverDialog() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int maxScore = prefs.getInt('maxScore') ?? 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'GAME OVER',
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
                'Your score: ${desk.score}',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                desk.score >= maxScore ? "This is your max score ever!" : "",
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
              child: const Text('OK'),
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
        if (desk.isCorrectMove(firstButtonIndex, secondButtonIndex)) {
          Future.delayed(const Duration(milliseconds: 50), () {
            desk.move(firstButtonIndex, secondButtonIndex);
            setState(() {
              selectedButtons.clear();
              currentHint = null;
            });

            _saveMaxScore();
            _checkGameState();

          });
        } else {
          selectedButtons.clear();
          selectedButtons.add(index);
        }
      }
    });
  }

  void _checkGameState() {
    bool? state = desk.checkGameStatus();
    if (state == null) {
      _saveGameState();
    } else if (state == false) {
      _clearSavedGameState();
      _showGameOverDialog();
    } else {
      desk.newStage(widget.initialButtonCount);
      _saveGameState();
    }
  }

  void _onShowHintPressed() {
    setState(() {
      currentHint = desk.findHint();
      if (currentHint == null && desk.remainingAddClicks > 0) {
        _addButtonKey.currentState?.startShakeAnimation();
      }
    });
  }
}

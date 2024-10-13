import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'game/button_grid.dart';
import 'game/field.dart';
import 'game/hint.dart';
import 'game/desk.dart';
import 'game/animated_button.dart';
import 'game/settings.dart';
import 'game/sounds.dart';
import 'game/vibro.dart';

class GamePage extends StatefulWidget {
  GamePage({
    super.key,
    required this.title,
    required this.buttonSize,
    required this.buttonsPerRow,
    required this.initialButtonCount,
    required this.maxScore,
    required this.mode,
    required this.settings,
  });

  final String title;
  final double buttonSize;
  final int buttonsPerRow;
  final int initialButtonCount;
  int maxScore;
  final bool mode;
  final Settings settings;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>  with SingleTickerProviderStateMixin {
  Desk desk = Desk(0, 0, 0, {}, 0);
  Hint? currentHint;
  List<int> selectedButtons = [];
  late Sounds sounds;
  late Vibro vibro;
  late final GlobalKey<AnimatedButtonState> _addButtonKey =
      GlobalKey<AnimatedButtonState>();


  @override
  void initState() {
    super.initState();
    sounds = Sounds(settings: widget.settings);
    vibro = Vibro(settings: widget.settings);
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
    _checkGameState(false);
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

  Future<bool> _saveMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int maxScore = prefs.getInt('maxScore') ?? 0;

    if (desk.score > maxScore) {
      await prefs.setInt('maxScore', desk.score);
      return true;
    }
    return false;
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
    _checkGameState(false);
  }

  void _restartGame() {
    setState(() {
      _initializeGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        titleTextStyle: TextStyle(
          color: colorLight,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: colorDark,
        iconTheme: IconThemeData(
          color: colorLight,
          size: 40.0,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorLight),
            onPressed: _restartGame,
          ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(settings: widget.settings,),
                  ),
                );
              },
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
    sounds.playAddRowSound();
    vibro.vibrateMedium();
    setState(() {
      desk.addFields();
      _saveGameState();
    });
  }

  void _showGameOverDialog(bool isVictory) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: _handleGameOver,
            child: WillPopScope(
            onWillPop: () async {
              _handleGameOver();
          return false;
        },
          child: AlertDialog(
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
                isVictory ? "This is your max score ever!" : "",
                style: Theme.of(context)
                    .textTheme
                    .labelMedium!
                    .copyWith(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                child: const Text('RETURN'),
                onPressed: _handleGameOver,
                style: ElevatedButton.styleFrom(
                  elevation: 5,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), // Отступы
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // Закругленные углы
                  ),
                ),
              ),
            ),

          ],
        )
            ),
        );
      },
    );
  }

  void _handleGameOver(){
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(settings: widget.settings)),
          (Route<dynamic> route) => false,
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
        sounds.playTapSound();
      } else if (selectedButtons.length == 1) {
        selectedButtons.add(index);
        int firstButtonIndex = selectedButtons[0];
        int secondButtonIndex = selectedButtons[1];
        if (desk.isCorrectMove(firstButtonIndex, secondButtonIndex)) {
          Future.delayed(const Duration(milliseconds: 50), () {
            bool rowRemoved = desk.move(firstButtonIndex, secondButtonIndex);
            setState(() {
              selectedButtons.clear();
              currentHint = null;
            });
            _checkGameState(rowRemoved);

          });
        } else {
          selectedButtons.clear();
          selectedButtons.add(index);
          sounds.playTapSound();
        }
      }
    });
  }

  void _checkGameState(bool isRowRemoved) {
    bool? state = desk.checkGameStatus();
    if (state == null) {
      isRowRemoved ? sounds.playRemoveRowSound() : sounds.playRemoveNumbersSound();
      isRowRemoved ? vibro.vibrateHeavy() : vibro.vibrateLight();
      _saveGameState();
      return;
    }
    if (state == false) {
      bool isVictory = false;
      if (desk.score > widget.maxScore) {
        widget.maxScore = desk.score;
        isVictory = true;
        _saveMaxScore();
      }

      isVictory ? sounds.playGameOverWinSound() : sounds.playGameOverLoseSound();
      _clearSavedGameState();
      _showGameOverDialog(isVictory);
    } else {
      desk.newStage(widget.initialButtonCount);
      _saveGameState();
      sounds.playDeskClearedSound();
    }
    vibro.vibrateHeavy();

  }

  void _onShowHintPressed() {
    vibro.vibrateLight();
    setState(() {
      currentHint = desk.findHint();
      if (currentHint == null && desk.remainingAddClicks > 0) {
        _addButtonKey.currentState?.startShakeAnimation();
      }
      currentHint == null ? sounds.playNoHintsSound() : sounds.playHintSound();
    });
  }

}

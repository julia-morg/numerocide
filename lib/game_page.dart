import 'package:flutter/material.dart';
import 'home_page.dart';
import 'settings_page.dart';
import 'game/button_grid.dart';
import 'game/hint.dart';
import 'game/desk.dart';
import 'game/animated_button.dart';
import 'game/settings.dart';
import 'game/sounds.dart';
import 'game/vibro.dart';
import 'game/save.dart';

class GamePage extends StatefulWidget {
  GamePage({
    super.key,
    required this.title,
    required this.maxScore,
    required this.mode,
    required this.settings,
  });

  final String title;
  int maxScore;
  final bool mode;
  final Settings settings;

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>  with SingleTickerProviderStateMixin {
  Desk desk = Desk(0, 0, 0, {});
  Hint? currentHint;
  List<int> selectedButtons = [];
  late Sounds sounds;
  late Vibro vibro;
  Save save = Save();
  late int _maxScore = 0;
  late final GlobalKey<AnimatedButtonState> _addButtonKey =
      GlobalKey<AnimatedButtonState>();


  @override
  void initState() {
    super.initState();
    sounds = Sounds(settings: widget.settings);
    vibro = Vibro(settings: widget.settings);
    _loadMaxScore();
    widget.mode ? _initializeGame() : _loadGameState();
  }

  void _initializeGame() {

    setState(() {
      desk = Desk.newGame();
      selectedButtons.clear();
      _saveGameState();
    });
  }

  void _clearSavedGameState() async {
    save.removeGame();
  }

  Future<void> _saveGameState() async {
    save.saveGame(desk);
  }

  Future<bool> _saveMaxScore() async {
    return save.saveMaxScore(desk.score);
  }

  Future<void> _loadGameState() async {
    Desk savedGame = await save.loadGame();
    setState(() {
      desk = savedGame;
    });
  }

  Future<void> _loadMaxScore() async {
    int maxScore = await save.loadMaxScore();
    setState(() {
      _maxScore = maxScore;
    });
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
        title: Center(
          child: Text(widget.title),
        ),
        titleTextStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: colorLight,
              fontSize: 24,
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
                  builder: (context) => SettingsPage(
                    settings: widget.settings,
                  ),
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
                    'Best\n${_maxScore}',
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
                    onButtonPressed: _onButtonPressed,
                    selectedButtons: selectedButtons,
                    desk: desk,
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
                'SCORE: ${desk.score}',
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

  void _onButtonPressed(int index, int value, Function removeButton) {

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
          vibro.vibrateLight();
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
      if (desk.score > _maxScore) {
        _maxScore = desk.score;
        isVictory = true;
      }
      isVictory ? sounds.playGameOverWinSound() : sounds.playGameOverLoseSound();
      _clearSavedGameState();
      _showGameOverDialog(isVictory);
      _saveMaxScore();
    } else {
      desk.newStage(Desk.initialButtonsCount);
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
    _checkGameState(false);
  }

}

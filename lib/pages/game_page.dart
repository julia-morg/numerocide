import 'package:flutter/material.dart';
import 'package:numerocide/components/dialog_action.dart';
import '../components/default_scaffold.dart';
import '../components/popup_dialog.dart';
import 'home_page.dart';
import '../components/button_grid.dart';
import '../game/hint.dart';
import '../game/desk.dart';
import '../components/animated_button.dart';
import '../game/settings.dart';
import '../effects/sounds.dart';
import '../effects/vibro.dart';
import '../game/save.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GamePage extends StatefulWidget {
  static const modeNewGame = 'new';
  static const modeLoadGame = 'load';

  GamePage({
    super.key,
    required this.mode,
    required this.settings,
    required this.save,
    Sounds? sounds}): sounds = sounds ?? Sounds(settings: settings);

  final Save save;
  final String mode;
  final Settings settings;
  final Sounds sounds;


  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>  with SingleTickerProviderStateMixin {
  late Desk desk;
  Hint? currentHint;
  List<int> selectedButtons = [];
  late Sounds sounds;
  late Vibro vibro;
  late int _maxScore = 0;
  late final GlobalKey<AnimatedButtonState> _addButtonKey =
      GlobalKey<AnimatedButtonState>();
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    sounds = widget.sounds;
    vibro = Vibro(settings: widget.settings);
    _loadMaxScore();
    (widget.mode == GamePage.modeNewGame) ? _initializeGame() : _loadGameState();
  }

  Future<void> _initializeGame() async {
    setState(() {
      desk = Desk.newGame();
      selectedButtons.clear();
      _saveGameState();
    });
    _checkGameState();
  }

  void _clearSavedGameState() async {
    widget.save.removeGame();
  }

  Future<void> _saveGameState() async {
    widget.save.saveGame(desk);
  }

  Future<bool> _saveMaxScore() async {
    return widget.save.saveMaxScore(desk.getScore());
  }

  Future<void> _loadGameState() async {
    setState(() {
      _isLoading = true;
    });
    Desk savedGame = await widget.save.loadGame();
    setState(() {
      desk = savedGame;
      _isLoading = false;
    });
    _checkGameState();
  }

  Future<void> _loadMaxScore() async {
    int maxScore = await widget.save.loadMaxScore();
    setState(() {
      _maxScore = maxScore;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return DefaultScaffold(
      title: AppLocalizations.of(context)!.appTitle,
      settings: widget.settings,
      save: widget.save,
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    '${AppLocalizations.of(context)!.gamePageBest}\n$_maxScore',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  Text(
                    '${desk.getScore()}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.gamePageStage}\n${desk.getStage()}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ScrollConfiguration(
                behavior: const ScrollBehavior()
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
                    active: desk.getRemainingAddClicks() > 0,
                    labelCount: desk.getRemainingAddClicks(),
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
      _checkGameState();
    });
  }

  void _showGameOverDialog(bool isVictory) async {
    String? bestScore = isVictory ? AppLocalizations.of(context)!.gamePageGameOverPopupBest : null;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: _handleGameOver,
          child: PopScope(
            onPopInvokedWithResult: (bool didPop, dynamic result) {
              if (!didPop) {
                _handleGameOver();
              }
            },
            child: PopupDialog(
              title:AppLocalizations.of(context)!.gamePageGameOverPopupTitle,
              content: '${AppLocalizations.of(context)!.gamePageGameOverPopupScore}${desk.getScore()} \n',
              note: bestScore,
              actions: [
                DialogAction(
                    onPressed: _handleGameOver,
                    text: AppLocalizations.of(context)!.gamePageGameOverPopupConfirm,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleGameOver(){
    Navigator.of(context).pop();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage(settings: widget.settings, save: widget.save)),
          (Route<dynamic> route) => false,
    );
  }

  void _onButtonPressed(int index) {

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
            rowRemoved ? sounds.playRemoveRowSound() : sounds.playRemoveNumbersSound();
            rowRemoved ? vibro.vibrateHeavy() : vibro.vibrateLight();
            _checkGameState();

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

  void _checkGameState() {
    bool? state = desk.checkGameStatus();
    if (state == null) {
      _saveGameState();
      return;
    }
    if (state == false) {
      bool isVictory = false;
      if (desk.getScore() > _maxScore) {
        _maxScore = desk.getScore();
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
      if (currentHint == null && desk.getRemainingAddClicks() > 0) {
        _addButtonKey.currentState?.startShakeAnimation();
      }
      currentHint == null ? sounds.playNoHintsSound() : sounds.playHintSound();
    });
  }
}

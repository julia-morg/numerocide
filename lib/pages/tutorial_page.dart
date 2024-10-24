import 'package:flutter/material.dart';
import 'package:numerocide/components/default_scaffold.dart';
import 'package:numerocide/components/dialog_action.dart';
import 'package:numerocide/components/popup_dialog.dart';
import 'package:numerocide/game/hint.dart';
import 'package:numerocide/components/text_plate.dart';
import '../game/desk.dart';
import '../game/field.dart';
import '../components/button_grid.dart';
import '../game/settings.dart';
import '../effects/sounds.dart';
import '../effects/vibro.dart';
import 'home_page.dart';

class Stage {
  final String text;
  final int buttonsPerRow;
  final List<int> numbers;
  final Hint hint;
  final List<int> inactiveNumbers;

  Stage(this.text, this.buttonsPerRow, this.numbers, this.hint,
      [this.inactiveNumbers = const []]);
}

class TutorialPage extends StatefulWidget {
  @override
  State<TutorialPage> createState() => _TutorialPageState();

  const TutorialPage({
    super.key,
    required this.settings,
  });

  final Settings settings;
}

class _TutorialPageState extends State<TutorialPage> {
  late Sounds sounds;
  late Vibro vibro;
  List<int> selectedButtons = [];
  List<Stage> stages = [];
  late Desk desk;
  late String hintText;
  late Hint? hint;
  late int rowLength;
  int step = 0;
  bool stageCompleted = false;

  @override
  void initState() {
    super.initState();
    sounds = Sounds(settings: widget.settings);
    vibro = Vibro(settings: widget.settings);
    _initializeTutorial();
  }

  void _initializeTutorial() {
    stages = [
      Stage(
          'You can remove cells with numbers that are equal or add up to 10 if they are adjacent to each other',
          6,
          [1, 9, 4, 5, 3, 8],
          Hint(0, 1)),
      Stage('… or are located one above the other',
          6,
          [3, 9, 2, 5, 8, 4, 7, 5],
          Hint(0, 6)),
      Stage(
          'Even if there was a line break between the cells, but they are adjacent, you can still remove them',
          6,
          [3, 2, 1, 5, 8, 4, 6, 5],
          Hint(5, 6)),
      Stage(
          'If the cells are diagonal to each other, you can also remove them',
          6,
          [4, 9, 3, 5, 7, 2, 1, 5, 4, 2],
          Hint(1, 6)),
      Stage('The direction of the diagonal doesn’t matter',
          6,
          [2, 4, 1, 5, 7, 9, 5, 8, 3, 8],
          Hint(0, 7)),
      Stage(
          'This is true for any diagonals, as long as there are no active cells on them',
          6,
          [2, 4, 1, 5, 7, 9, 5, 8, 3, 4, 8, 5, 1, 8, 9],
          Hint(2, 12),
          [7]),
      Stage('You can also remove the first and last cells on a desk', 6,
          [3, 5, 2, 5, 7, 4, 9, 6, 1, 4, 2, 5, 3, 8, 7], Hint(0, 14)),
      Stage(''
          'If you remove all the cells in a row, the row is destroyed',
          6,
          [3, 8, 3, 1, 5, 3, 9, 6, 1, 4, 2, 5, 4, 5, 4],
          Hint(3, 8),
          [6,7,9,10,11,]),
      Stage(
          'If you clear the entire board, you advance to the next level',
          6,
          [3, 5, 5, 7, 4, 9, 6, 7, 4, 2, 4, 1, 8, 7],
          Hint(-10, -14)),
    ];

    _applyStage(stages[0]);
  }

  void _applyStage(Stage stage) {
    setState(() {
      Map<int, Field> numbers = stage.numbers.asMap().map((index, number) =>
          MapEntry(index,
              Field(index, number, !stage.inactiveNumbers.contains(index))));
      desk = Desk(0, 0, stage.buttonsPerRow, numbers);
      desk.rowLength = stage.buttonsPerRow;
      hintText = stage.text;
      hint = stage.hint;
      rowLength = stage.buttonsPerRow;
      stageCompleted = false;
      selectedButtons.clear();
    });
  }

  void _nextStep() {
    if (!isNextStepAvailable()) {
      goToMainMenu();
      return;
    }
    setState(() {
      step++;
      if (step < stages.length) {
        _applyStage(stages[step]);
      }
    });
  }

  bool isNextStepAvailable() {
    return step < stages.length - 1;
  }

  void goToMainMenu() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => HomePage(settings: widget.settings,)),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    int stepsCount = stages.length;
    return DefaultScaffold(
      settings: widget.settings,
      title: 'How to play',
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextPlate(
              centeredText: '${step+1}/$stepsCount\n',
              justifiedText: hintText
          ),
          const SizedBox(height: 20,),
          SizedBox(
            height: 260,
            child: ButtonGrid(
              onButtonPressed: _onButtonPressed,
              selectedButtons: selectedButtons,
              desk: desk,
              hint: hint,
            ),
          ),
          const SizedBox(height: 20,),
          ElevatedButton(
            onPressed: stageCompleted ? _nextStep : null,
            child: Text(
              isNextStepAvailable() ? 'Next Step' : 'Got it! To Main Menu',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(color: stageCompleted ? null: Theme.of(context).colorScheme.onSecondary),
            ),
          ),
          const SizedBox(height: 60,),
        ],
      ),
    );
  }

  void _onButtonPressed(int index) {
    sounds.playTapSound();
    vibro.vibrateLight();
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
              hint = null;
            });
            stageCompleted = true;
            if (desk.isVictory()) {
              if (!mounted) return;
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return PopupDialog(
                    title: 'Hooraay!',
                    content: 'The tutorial is completed and you are ready to play the game!',
                    actions: [
                      DialogAction(
                        text: 'Restart',
                        onPressed: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (context) => TutorialPage(settings: widget.settings,)),
                          );
                        },
                      ),
                      DialogAction(
                        text: 'Main Menu',
                        onPressed: () => goToMainMenu(),
                      ),
                    ],
                  );
                },
              );
            }
          });
        } else {
          selectedButtons.clear();
          selectedButtons.add(index);
        }
      }
    });
  }
}

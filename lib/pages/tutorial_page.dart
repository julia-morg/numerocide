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
import '../game/tutorial.dart';
import 'home_page.dart';

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
    stages = Tutorial().getSteps();
    _applyStage(stages[0]);
  }

  void _applyStage(Stage stage) {
    setState(() {
      Map<int, Field> numbers = stage.numbers.asMap().map((index, number) =>
          MapEntry(index,
              Field(index, number, !stage.inactiveNumbers.contains(index))));
      desk = Desk(0, 0, stage.buttonsPerRow, numbers, stage.buttonsPerRow);
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

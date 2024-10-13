import 'package:flutter/material.dart';
import 'package:numerocide/game/hint.dart';
import 'package:numerocide/settings_page.dart';
import 'game/desk.dart';
import 'game/field.dart';
import 'game/button_grid.dart';
import 'game/settings.dart';
import 'game/sounds.dart';
import 'game/vibro.dart';

class Stage {
  final String text;
  final int buttonsPerRow;
  final Map<int, Field> numbers;
  final Hint hint;


  Stage(this.text, this.buttonsPerRow, this.numbers, this.hint);
}

class TutorialPage extends StatefulWidget {
  @override
  _TutorialPageState createState() => _TutorialPageState();
  TutorialPage({
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

  @override
  void initState() {
    super.initState();
    sounds = Sounds(settings: widget.settings);
    vibro = Vibro(settings: widget.settings);
    _initializeTutorial();
  }

  void _initializeTutorial() {
    stages = [
      Stage('Click on number 1 and then 9 to remove them both', 4, {
        0: Field(0, 1, true),
        1: Field(1, 9, true),
        2: Field(2, 4, true),
        3: Field(3, 5, true),
        4: Field(4, 3, true),
        5: Field(5, 8, true),
      }, Hint(0, 1)),
      Stage('Click on number 3 and then 7 to remove them both', 4, {
        0: Field(0, 3, true),
        1: Field(1, 9, true),
        2: Field(2, 2, true),
        3: Field(3, 5, true),
        4: Field(4, 7, true),
      }, Hint(0, 4)),
      Stage('Click on number 3 and then 7 to remove them both', 4, {
        0: Field(0, 3, true),
        1: Field(1, 2, true),
        2: Field(2, 1, true),
        3: Field(3, 5, true),
        4: Field(4, 8, true),
        5: Field(4, 4, true),
      }, Hint(1, 4)),      Stage('Click on number 3 and then 7 to remove them both', 4, {
        0: Field(0, 4, true),
        1: Field(1, 2, true),
        2: Field(2, 1, true),
        3: Field(3, 5, true),
        4: Field(4, 8, true),
        5: Field(4, 5, true),
        6: Field(6, 4, true),
      }, Hint(0, 6)),
    ];

    _applyStage(stages[0]);
  }

  void _applyStage(Stage stage) {
    setState(() {
      desk = Desk(0, 0, stage.buttonsPerRow, stage.numbers);
      desk.rowLength = stage.buttonsPerRow;
      hintText = stage.text;
      hint = stage.hint;
      rowLength = stage.buttonsPerRow;
    });
  }

  void _nextStep() {
    if(!isNextStepAvailable()) {
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

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
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
      body: Column(
        children: [
          Expanded(
            child: ButtonGrid(
              onButtonPressed: _onButtonPressed,
              selectedButtons: selectedButtons,
              desk: desk,
              buttonSize: 30.0,
              buttonsPerRow: rowLength,
              hint: hint,
            ),
          ),
          Text('Step $step: $hintText'),
          ElevatedButton(
            onPressed: isNextStepAvailable() ? _nextStep : null,
            child: Text(isNextStepAvailable() ? 'Next Step': 'Finished'),
          ),
          Transform.scale(
            scale: 0.8,
            child: Center(
              child: Image.asset('assets/pic/example.png'),
            ),
          ),
        ],
      ),
    );
  }
  void _onButtonPressed(int index, int value, Function removeButton) {
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
            _nextStep();
          });
        }
        else {
          selectedButtons.clear();
          selectedButtons.add(index);
        }
      }
    });
  }

}
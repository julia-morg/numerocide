import 'package:flutter/material.dart';
import 'dart:math';

const int buttonsPerRow = 10;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Numbers'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _score = 0;
  List<Map<String, int>> selectedButtons = [];
  List<int> randomNumbers = List.generate(40, (_) => Random().nextInt(9) + 1);
  Map<int, bool> activeButtons = {for (var i = 0; i < 40; i++) i: true};

  void _addCopiesOfButtons() {
    setState(() {
      List<int> activeNumbers = [];
      for (int i = 0; i < randomNumbers.length; i++) {
        if (activeButtons[i] == true) {
          activeNumbers.add(randomNumbers[i]);
        }
      }
      randomNumbers.addAll(activeNumbers);
      for (int i = randomNumbers.length - activeNumbers.length; i < randomNumbers.length; i++) {
        activeButtons[i] = true;
      }
      _counter++;
    });
  }

  void _scoreCounter(int value1, int value2) {
    setState(() {
      _score += value1 + value2;
    });
  }

  void onButtonPressed(int index, int value, Function removeButton) {
    setState(() {
      if (selectedButtons.isNotEmpty && selectedButtons[0]['index'] == index) {
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

        if (firstButtonValue == secondButtonValue || firstButtonValue + secondButtonValue == 10) {
          removeButton(firstButtonIndex);
          removeButton(secondButtonIndex);
          _scoreCounter(firstButtonValue, secondButtonValue);

          Future.delayed(const Duration(milliseconds: 100), () {
            setState(() {
              selectedButtons.clear();
            });
          });
        } else {
          selectedButtons.clear();
          selectedButtons.add({'index': index, 'value': value});
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Rows added: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Score: $_score',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ButtonGrid(
                  onButtonPressed: onButtonPressed,
                  selectedButtons: selectedButtons,
                  randomNumbers: randomNumbers,
                  activeButtons: activeButtons,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCopiesOfButtons,
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ButtonGrid extends StatefulWidget {
  final Function(int, int, Function(int)) onButtonPressed;
  final List<Map<String, int>> selectedButtons;
  final List<int> randomNumbers;
  final Map<int, bool> activeButtons;

  const ButtonGrid({Key? key, required this.onButtonPressed, required this.selectedButtons, required this.randomNumbers, required this.activeButtons}) : super(key: key);

  @override
  _ButtonGridState createState() => _ButtonGridState();
}

class _ButtonGridState extends State<ButtonGrid> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: buttonsPerRow,
      ),
      itemCount: widget.randomNumbers.length,
      itemBuilder: (context, index) {
        int buttonNumber = widget.randomNumbers[index];

        return Opacity(
          opacity: widget.activeButtons[index] == false ? 0.2 : 1.0,
          child: FloatingActionButton(
            backgroundColor: widget.selectedButtons.any((element) => element['index'] == index)
                ? Theme.of(context).colorScheme.primary
                : null,
            onPressed: () {
              if (widget.activeButtons[index] == true) {
                widget.onButtonPressed(index, buttonNumber, (idx) {
                  setState(() {
                    widget.activeButtons[idx] = false;
                  });
                });
              }
            },
            child: Text('$buttonNumber'),
          ),
        );
      },
    );
  }
}
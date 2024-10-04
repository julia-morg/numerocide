import 'package:flutter/material.dart';
import 'dart:math';

const int numberOfButtons = 40;
const int buttonsPerRow = 10;
const int numberOfRows = 4;

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
  List<Map<String, int>> selectedButtons = []; // Список, который будет хранить индексы и значения нажатых кнопок

  // Теперь _scoreCounter принимает сумму двух значений
  void _scoreCounter(int value1, int value2) {
    setState(() {
      _score += value1 + value2; // Добавляем сумму значений кнопок
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  void onButtonPressed(int index, int value, Function removeButton) {
    setState(() {
      // Проверяем, если кнопка уже была нажата
      if (selectedButtons.any((element) => element['index'] == index)) {
        return;
      }
      selectedButtons.add({'index': index, 'value': value});

      // Когда нажаты две кнопки
      if (selectedButtons.length == 2) {
        int firstButtonIndex = selectedButtons[0]['index']!;
        int secondButtonIndex = selectedButtons[1]['index']!;
        int firstButtonValue = selectedButtons[0]['value']!;
        int secondButtonValue = selectedButtons[1]['value']!;

        // Проверяем, равны ли значения двух нажатых кнопок или их сумма равна 10
        if (firstButtonValue == secondButtonValue || firstButtonValue + secondButtonValue == 10) {
          // Удаляем кнопки и добавляем их значения к счету
          removeButton(firstButtonIndex);
          removeButton(secondButtonIndex);
          _scoreCounter(firstButtonValue, secondButtonValue); // Добавляем значения обеих кнопок
        }

        // Очищаем список выбранных кнопок в любом случае
        selectedButtons.clear();
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
            ButtonList(onButtonPressed: onButtonPressed, selectedButtons: selectedButtons),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'add',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ButtonList extends StatefulWidget {
  final Function(int, int, Function(int)) onButtonPressed;
  final List<Map<String, int>> selectedButtons;

  const ButtonList({Key? key, required this.onButtonPressed, required this.selectedButtons}) : super(key: key);

  @override
  _ButtonListState createState() => _ButtonListState();
}

class _ButtonListState extends State<ButtonList> {
  List<List<int>> randomNumbers = List.generate(
    numberOfRows,
        (_) => List.generate(buttonsPerRow, (_) => Random().nextInt(9) + 1),
  );

  Map<int, bool> activeButtons = {};

  @override
  void initState() {
    super.initState();
    // Инициализация состояния кнопок
    for (int i = 0; i < numberOfButtons; i++) {
      activeButtons[i] = true;
    }
  }

  void removeButton(int index) {
    setState(() {
      activeButtons[index] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numberOfRows, (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(buttonsPerRow, (buttonIndex) {
            int buttonNumber = randomNumbers[rowIndex][buttonIndex];
            int buttonIndexFlat = rowIndex * buttonsPerRow + buttonIndex;

            if (!activeButtons[buttonIndexFlat]!) {
              return const SizedBox.shrink(); // Если кнопка была удалена, она исчезает
            }

            return FloatingActionButton(
              backgroundColor: widget.selectedButtons.any((element) => element['index'] == buttonIndexFlat)
                  ? Colors.red
                  : null,
              onPressed: () => widget.onButtonPressed(buttonIndexFlat, buttonNumber, removeButton),
              child: Text('$buttonNumber'),
            );
          }),
        );
      }),
    );
  }
}
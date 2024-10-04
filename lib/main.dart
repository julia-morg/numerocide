import 'package:flutter/material.dart';
import 'dart:math';

const int buttonsPerRow = 10; // Количество кнопок в строке

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
  List<int> randomNumbers = List.generate(40, (_) => Random().nextInt(9) + 1); // Изначально 40 кнопок (4 ряда по 10 кнопок)
  Map<int, bool> activeButtons = {for (var i = 0; i < 40; i++) i: true}; // Инициализация всех кнопок как активных

  // Метод для копирования только активных кнопок
  void _addCopiesOfButtons() {
    setState(() {
      // Копируем только активные кнопки и добавляем их в конец списка
      List<int> activeNumbers = [];
      for (int i = 0; i < randomNumbers.length; i++) {
        if (activeButtons[i] == true) {
          activeNumbers.add(randomNumbers[i]);
        }
      }
      randomNumbers.addAll(activeNumbers);

      // Добавляем состояние для новых кнопок как активных
      for (int i = randomNumbers.length - activeNumbers.length; i < randomNumbers.length; i++) {
        activeButtons[i] = true;
      }

      // Увеличиваем счётчик "Rows added"
      _counter++;
    });
  }

  // Метод для обновления очков, когда кнопки удалены
  void _scoreCounter(int value1, int value2) {
    setState(() {
      _score += value1 + value2;
    });
  }

  // Логика нажатия на кнопку
  void onButtonPressed(int index, int value, Function removeButton) {
    setState(() {
      // Проверяем, если кнопка уже была нажата (для снятия выделения при повторном клике)
      if (selectedButtons.any((element) => element['index'] == index)) {
        selectedButtons.removeWhere((element) => element['index'] == index); // Снимаем выделение
        return;
      }

      // Добавляем кнопку в список выделенных
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
          _scoreCounter(firstButtonValue, secondButtonValue);
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
            // Добавляем прокрутку с помощью SingleChildScrollView
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
        onPressed: _addCopiesOfButtons, // Копируем существующие кнопки и увеличиваем счётчик
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
      shrinkWrap: true, // Убедимся, что GridView не занимает больше места, чем необходимо
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: buttonsPerRow, // Количество кнопок в строке
      ),
      itemCount: widget.randomNumbers.length,
      itemBuilder: (context, index) {
        int buttonNumber = widget.randomNumbers[index];

        return Opacity(
          opacity: widget.activeButtons[index] == false ? 0.2 : 1.0, // Установим непрозрачность для удалённых кнопок
          child: FloatingActionButton(
            backgroundColor: widget.selectedButtons.any((element) => element['index'] == index)
                ? Theme.of(context).colorScheme.primary // Синий цвет для активных кнопок
                : null,
            onPressed: () {
              if (widget.activeButtons[index] == true) {
                widget.onButtonPressed(index, buttonNumber, (idx) {
                  setState(() {
                    widget.activeButtons[idx] = false; // Убираем кнопку (становится "неактивной")
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
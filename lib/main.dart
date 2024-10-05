import 'package:flutter/material.dart';
import 'dart:math';

const int buttonsPerRow = 10;
const double buttonSize = 30;
const double buttonScaleFactor = 0.5;
const int initialButtonCount = 40;
const int windowWidth = 300;
const int windowHeight = 600;

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
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.primary, // Используем основной цвет для заголовка
          titleTextStyle: const TextStyle(
            color: Colors.white, // Белый текст заголовка
            fontSize: 20,
          ),
          iconTheme: const IconThemeData(
            color: Colors.white, // Белые иконки
          ),
        ),
      ),
      home: const MyHomePage(title: 'Numbers'),
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: windowWidth.toDouble(),
            height: windowHeight.toDouble(),
            child: child,
          ),
        );
      },
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
  List<int> randomNumbers = List.generate(initialButtonCount, (_) => Random().nextInt(9) + 1);
  Map<int, bool> activeButtons = {for (var i = 0; i < initialButtonCount; i++) i: true};

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

          Future.delayed(const Duration(milliseconds: 200), () {
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
    Color textColor = Colors.indigo[900]!; // Темно-синий цвет для текста

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Theme.of(context).colorScheme.primary, // Цвет заголовка, как у вас
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Score: $_score',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: textColor), // Темно-синий цвет для "Score"
                  ),
                  Text(
                    'Batches added: $_counter',
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(color: textColor), // Темно-синий цвет для "Batches added"
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
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
    int totalRowsInView = (windowHeight / (buttonSize * buttonScaleFactor + 1)).floor(); // Количество строк, которые могут поместиться в видимой области
    int totalButtonsToShow = totalRowsInView * buttonsPerRow; // Полное количество кнопок до конца экрана
    int additionalButtons = max(totalButtonsToShow - widget.randomNumbers.length, buttonsPerRow * 2); // Добавляем минимум два ряда

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Отключаем прокрутку GridView
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: buttonsPerRow, // 10 кнопок в строке
        childAspectRatio: 1, // Кнопки квадратные
        mainAxisSpacing: 1, // Минимальное пространство между кнопками по вертикали
        crossAxisSpacing: 1, // Минимальное пространство между кнопками по горизонтали
      ),
      itemCount: widget.randomNumbers.length + additionalButtons, // Добавляем пустые места
      itemBuilder: (context, index) {
        if (index >= widget.randomNumbers.length) {
          // Пустые кнопки, без цифр
          return SizedBox(
            width: buttonSize * buttonScaleFactor,
            height: buttonSize * buttonScaleFactor,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200], // Пустые кнопки с приглушенным фоном
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero, // Прямоугольные границы
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: null, // Пустые кнопки неактивны
              child: null,
            ),
          );
        }

        int buttonNumber = widget.randomNumbers[index];
        bool isSelected = widget.selectedButtons.any((element) => element['index'] == index);

        return Opacity(
          opacity: widget.activeButtons[index] == false ? 0.2 : 1.0,
          child: SizedBox(
            width: buttonSize * buttonScaleFactor,
            height: buttonSize * buttonScaleFactor,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.5) // Полупрозрачная подсветка
                    : null,
                shape: RoundedRectangleBorder( // Прямоугольные границы, без скругления углов
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                if (widget.activeButtons[index] == true) {
                  widget.onButtonPressed(index, buttonNumber, (idx) {
                    setState(() {
                      widget.activeButtons[idx] = false;
                    });
                  });
                }
              },
              child: Text(
                '$buttonNumber',
                style: TextStyle(
                  fontSize: 18,
                  color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary, // Цвет текста, чтобы он был видим при выделении
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
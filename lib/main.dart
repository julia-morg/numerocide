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

  bool areButtonsInSameRow(int firstIndex, int secondIndex) {
    return firstIndex ~/ buttonsPerRow == secondIndex ~/ buttonsPerRow;
  }

  bool areButtonsInSameColumn(int firstIndex, int secondIndex) {
    return firstIndex % buttonsPerRow == secondIndex % buttonsPerRow;
  }

  bool areButtonsOnSameDiagonal(int firstIndex, int secondIndex) {
    int row1 = firstIndex ~/ buttonsPerRow;
    int col1 = firstIndex % buttonsPerRow;
    int row2 = secondIndex ~/ buttonsPerRow;
    int col2 = secondIndex % buttonsPerRow;

    // Проверка обеих диагоналей: вправо (X+1, Y+1) и влево (X-1, Y+1)
    return (row1 - col1 == row2 - col2) || (row1 + col1 == row2 + col2);
  }

  bool areCellsCoherent(int firstIndex, int secondIndex) {
    // Убедимся, что индексы идут в правильном порядке
    int start = min(firstIndex, secondIndex);
    int end = max(firstIndex, secondIndex);

    // Проходим по клеткам между первой и второй
    for (int i = start + 1; i < end; i++) {
      if (activeButtons[i] == true) {
        return false; // Если есть активная клетка между ними, возвращаем false
      }
    }

    // Если нет активных клеток между первой и второй, возвращаем true
    return true;
  }

  bool areButtonsIsolated(int firstIndex, int secondIndex) {
    if (areButtonsInSameRow(firstIndex, secondIndex)) {
      // Проверка между кнопками в строке
      int start = min(firstIndex, secondIndex) + 1;
      int end = max(firstIndex, secondIndex);
      for (int i = start; i < end; i++) {
        if (activeButtons[i] == true) return false;
      }
    } else if (areButtonsInSameColumn(firstIndex, secondIndex)) {
      // Проверка между кнопками в колонке
      int start = min(firstIndex, secondIndex);
      int end = max(firstIndex, secondIndex);
      for (int i = start + buttonsPerRow; i < end; i += buttonsPerRow) {
        if (activeButtons[i] == true) return false;
      }
    } else if (areButtonsOnSameDiagonal(firstIndex, secondIndex)) {
      // Проверка между кнопками по диагонали
      int rowStart = firstIndex ~/ buttonsPerRow;
      int rowEnd = secondIndex ~/ buttonsPerRow;
      int colStart = firstIndex % buttonsPerRow;
      int colEnd = secondIndex % buttonsPerRow;

      int rowIncrement = rowEnd > rowStart ? 1 : -1;
      int colIncrement = colEnd > colStart ? 1 : -1;

      int i = firstIndex;
      while (i != secondIndex) {
        i += rowIncrement * buttonsPerRow + colIncrement;
        if (i == secondIndex) break;
        if (activeButtons[i] == true) return false;  // Проверка, если есть активные кнопки на пути
      }
    }
    return true;
  }

  bool isFirstAndLastButton(int firstIndex, int secondIndex) {
    // Найдем первую активную кнопку
    int firstActiveIndex = -1;
    for (int i = 0; i < randomNumbers.length; i++) {
      if (activeButtons[i] == true) {
        firstActiveIndex = i;
        break;
      }
    }

    // Найдем последнюю активную кнопку
    int lastActiveIndex = -1;
    for (int i = randomNumbers.length - 1; i >= 0; i--) {
      if (activeButtons[i] == true) {
        lastActiveIndex = i;
        break;
      }
    }

    return (firstIndex == firstActiveIndex && secondIndex == lastActiveIndex) ||
        (firstIndex == lastActiveIndex && secondIndex == firstActiveIndex);
  }

  void onButtonPressed(int index, int value, Function removeButton) {
    setState(() {
      // Если уже есть выделение и повторно кликнули на ту же кнопку — снять выделение
      if (selectedButtons.isNotEmpty && selectedButtons[0]['index'] == index) {
        selectedButtons.clear(); // Снимаем выделение
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

        if ((firstButtonValue == secondButtonValue || firstButtonValue + secondButtonValue == 10) &&
            (isFirstAndLastButton(firstButtonIndex, secondButtonIndex) ||
                areButtonsInSameRow(firstButtonIndex, secondButtonIndex) && areButtonsIsolated(firstButtonIndex, secondButtonIndex) ||
                areCellsCoherent(firstButtonIndex, secondButtonIndex) ||
                areButtonsInSameColumn(firstButtonIndex, secondButtonIndex) && areButtonsIsolated(firstButtonIndex, secondButtonIndex) ||
                areButtonsOnSameDiagonal(firstButtonIndex, secondButtonIndex) && areButtonsIsolated(firstButtonIndex, secondButtonIndex))) {
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
        child: Icon(
          Icons.add,
          color: Theme.of(context).colorScheme.primary, // Цвет иконки "add"
        ),
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


//количество кноп
import 'package:flutter/material.dart';
import 'dart:math';

class ButtonGrid extends StatefulWidget {
  final Function(int, int, Function(int)) onButtonPressed;
  final List<Map<String, int>> selectedButtons;
  final List<int> randomNumbers;
  final Map<int, bool> activeButtons;
  final double buttonSize;
  final int buttonsPerRow;

  const ButtonGrid({
    Key? key,
    required this.onButtonPressed,
    required this.selectedButtons,
    required this.randomNumbers,
    required this.activeButtons,
    required this.buttonSize,
    required this.buttonsPerRow,
  }) : super(key: key);

  @override
  _ButtonGridState createState() => _ButtonGridState();
}

class _ButtonGridState extends State<ButtonGrid> {
  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight =
        Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;

    double availableHeight = screenHeight - appBarHeight;

    int totalRowsInView =
        (availableHeight / (widget.buttonSize * 2 + 1)).floor() - 1;
    int totalButtonsToShow = totalRowsInView * widget.buttonsPerRow;

    int buttonsInLastRow = widget.randomNumbers.length % widget.buttonsPerRow;

    int emptyCellsToAdd =
        buttonsInLastRow > 0 ? widget.buttonsPerRow - buttonsInLastRow : 0;

    int initialEmptyCells = totalButtonsToShow - widget.randomNumbers.length;

    int finalItemCount = widget.randomNumbers.length +
        max(emptyCellsToAdd, 0).toInt() +
        max(initialEmptyCells, 0).toInt() +
        widget.buttonsPerRow;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.buttonsPerRow,
        childAspectRatio: 1,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: finalItemCount,
      itemBuilder: (context, index) {
        if (index >= widget.randomNumbers.length) {
          return SizedBox(
            width: widget.buttonSize,
            height: widget.buttonSize,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.zero,
              ),
              onPressed: null,
              child: null,
            ),
          );
        }

        int buttonNumber = widget.randomNumbers[index];
        bool isSelected = widget.selectedButtons
            .any((element) => element['index'] == index); // Определяем, выбрана ли кнопка

        return SizedBox(
          width: widget.buttonSize,
          height: widget.buttonSize,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.activeButtons[index] == true
                  ? (isSelected
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.5) // Подсветка выбранной кнопки
                  : null) // Оставляем стандартный цвет для остальных активных кнопок
                  : Colors.grey[300], // Серый фон для неактивных кнопок
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              padding: EdgeInsets.zero,
            ),
            onPressed: widget.activeButtons[index] == true
                ? () {
              widget.onButtonPressed(index, buttonNumber, (idx) {
                setState(() {
                  widget.activeButtons[idx] = false;
                });
              });
            }
                : null, // Неактивные кнопки
            child: Text(
              '$buttonNumber',
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'field.dart';
import 'hint.dart';
import 'desk.dart';
import 'dart:math';

class ButtonGrid extends StatefulWidget {
  final Function(int, int, Function(int)) onButtonPressed;
  final List<int> selectedButtons;
  final double buttonSize;
  final int buttonsPerRow;
  final Hint? hint;
  final Desk desk;

  const ButtonGrid({
    Key? key,
    required this.onButtonPressed,
    required this.selectedButtons,
    required this.desk,
    required this.buttonSize,
    required this.buttonsPerRow,
    this.hint,
  }) : super(key: key);

  @override
  _ButtonGridState createState() => _ButtonGridState();
}

class _ButtonGridState extends State<ButtonGrid> {
  bool isRowBeingRemoved = false;
  List<int> crossedOutIndexes = [];

  void startRemoveRowAnimation(int rowIndex) async {
    setState(() {
      crossedOutIndexes = List.generate(widget.buttonsPerRow, (i) => rowIndex * widget.buttonsPerRow + i);
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      crossedOutIndexes.clear();
      widget.desk.numbers.removeWhere((key, _) => crossedOutIndexes.contains(key));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight =
        Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;

    double availableHeight = screenHeight - appBarHeight;

    int totalRowsInView =
        (availableHeight / (widget.buttonSize * 2 + 1)).floor() - 1;
    int totalButtonsToShow = totalRowsInView * widget.buttonsPerRow;

    int buttonsInLastRow = widget.desk.numbers.length % widget.buttonsPerRow;

    int emptyCellsToAdd = buttonsInLastRow > 0 ? widget.buttonsPerRow - buttonsInLastRow : 0;

    int initialEmptyCells = max(totalButtonsToShow - widget.desk.numbers.length, 0).toInt();

    int finalItemCount = widget.desk.numbers.length +
        emptyCellsToAdd +
        initialEmptyCells +
        widget.buttonsPerRow.toInt();
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
        if (index >= widget.desk.numbers.length) {
          return SizedBox(
            width: widget.buttonSize,
            height: widget.buttonSize,
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.grey[300], // Единый цвет для пустых ячеек
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: EdgeInsets.zero,
              ),
              onPressed: null,
              child: const Text(''),
            ),
          );
        }

        Field buttonField = widget.desk.numbers[index]!;
        int buttonNumber = buttonField.number;
        bool isSelected = widget.selectedButtons.contains(index);
        bool isHint = widget.hint != null &&
            (index == widget.hint!.hint1 || index == widget.hint!.hint2);

        return TextButton(
          style: TextButton.styleFrom(
            backgroundColor: buttonField.isActive
                ? (isSelected
                ? Theme.of(context).colorScheme.primary.withOpacity(0.5) // Цвет для выделенной кнопки
                : isHint
                ? Colors.green.withOpacity(0.5) // Подсветка для хинта
                : Colors.grey[300]) // Цвет для активной кнопки (тот же фон, что и для пустых ячеек)
                : Colors.grey[300], // Цвет для неактивной кнопки (тот же фон, что и для пустых ячеек)
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding: EdgeInsets.zero,
          ),
          onPressed: buttonField.isActive
              ? () {
            widget.onButtonPressed(index, buttonNumber, (idx) {
              setState(() {
                widget.desk.numbers[idx] = Field(idx, buttonNumber, false);
              });
            });
          }
              : null,
          child: Text(
            '$buttonNumber',
            style: TextStyle(
              fontSize: 18,
              color: isSelected
                  ? Theme.of(context).colorScheme.onPrimary // Цвет текста для выделенной кнопки
                  : buttonField.isActive
                  ? Theme.of(context).colorScheme.primary // Цвет текста для активной кнопки
                  : Colors.grey[400], // Цвет текста для неактивной кнопки
              decoration: crossedOutIndexes.contains(index)
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
            ),
          ),
        );
      },
    );
  }
}
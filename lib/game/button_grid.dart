import 'package:flutter/material.dart';
import 'field.dart';
import 'hint.dart';
import 'desk.dart';
import 'dart:math';

class ButtonGrid extends StatefulWidget {
  final Function(int, int, Function(int)) onButtonPressed;
  final List<int> selectedButtons;
  final Hint? hint;
  final Desk desk;

  const ButtonGrid({
    super.key,
    required this.onButtonPressed,
    required this.selectedButtons,
    required this.desk,
    this.hint,
  });

  @override
  State<ButtonGrid> createState() => _ButtonGridState();
}

class _ButtonGridState extends State<ButtonGrid> {
  bool isRowBeingRemoved = false;
  List<int> crossedOutIndexes = [];

  void startRemoveRowAnimation(int rowIndex) async {
    setState(() {
      crossedOutIndexes = List.generate(widget.desk.rowLength, (i) => rowIndex * widget.desk.rowLength + i);
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      crossedOutIndexes.clear();
      widget.desk.numbers.removeWhere((key, _) => crossedOutIndexes.contains(key));
    });
  }

  @override
  Widget build(BuildContext context) {
    double buttonSize = (MediaQuery.of(context).size.width / widget.desk.rowLength).ceil().toDouble();
    double screenHeight = MediaQuery.of(context).size.height;
    double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    double availableHeight = screenHeight - appBarHeight;
    int totalRowsInView = (availableHeight / (buttonSize + 1)).floor() - 1;
    int totalButtonsToShow = totalRowsInView * widget.desk.rowLength;
    int buttonsInLastRow = widget.desk.numbers.length % widget.desk.rowLength;
    int emptyCellsToAdd = buttonsInLastRow > 0 ? widget.desk.rowLength - buttonsInLastRow : 0;
    int initialEmptyCells = max(totalButtonsToShow - widget.desk.numbers.length, 0).toInt();
    int finalItemCount = widget.desk.numbers.length +
        emptyCellsToAdd +
        initialEmptyCells +
        widget.desk.rowLength.toInt();
    Color backgroundColor = Theme.of(context).colorScheme.secondary;
    Color highlightColor = Theme.of(context).colorScheme.primary.withOpacity(0.7);
    Color hintColor = Theme.of(context).colorScheme.outline;
    Color inactiveTextColor = Theme.of(context).colorScheme.onSecondary;
    Color activeTextColor = Theme.of(context).colorScheme.primary;
    Color highlightTextColor = Theme.of(context).colorScheme.surface;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.desk.rowLength,
        childAspectRatio: 1,
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
      ),
      itemCount: finalItemCount,
      itemBuilder: (context, index) {
        if (index >= widget.desk.numbers.length) {
          return SizedBox(
            child: TextButton(
              style: TextButton.styleFrom(
                backgroundColor: backgroundColor,
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
                    ? highlightColor
                    : isHint
                        ? hintColor
                        : backgroundColor)
                : backgroundColor,
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
              fontSize: 26,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? highlightTextColor
                  : buttonField.isActive
                      ? activeTextColor
                      : inactiveTextColor,
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
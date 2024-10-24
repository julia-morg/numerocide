import 'package:flutter/material.dart';
import '../game/hint.dart';
import '../game/desk.dart';
import 'dart:math';

class ButtonGrid extends StatefulWidget {
  final Function(int) onButtonPressed;
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
      crossedOutIndexes = List.generate(
          widget.desk.rowLength, (i) => rowIndex * widget.desk.rowLength + i);
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    setState(() {
      crossedOutIndexes.clear();
      widget.desk.numbers
          .removeWhere((key, _) => crossedOutIndexes.contains(key));
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    double buttonSize = (screenWidth / widget.desk.rowLength).ceil().toDouble();
    double availableHeight = screenHeight - appBarHeight;
    int totalRowsInView = (availableHeight /buttonSize).floor() - 1;
    int totalButtonsToShow = totalRowsInView * widget.desk.rowLength;
    int buttonsInLastRow = widget.desk.numbers.length % widget.desk.rowLength;
    int emptyCellsToAdd = buttonsInLastRow > 0 ? widget.desk.rowLength - buttonsInLastRow : 0;
    int initialEmptyCells = max(totalButtonsToShow - widget.desk.numbers.length, 0).toInt();
    int finalItemCount = widget.desk.numbers.length +
        emptyCellsToAdd +
        initialEmptyCells +
        widget.desk.rowLength.toInt();
    int finalRows = (finalItemCount / widget.desk.rowLength).ceil();
    Color highlightColor = Theme.of(context).colorScheme.onPrimary;

    return Container(
        padding: const EdgeInsets.all(0),
        decoration: BoxDecoration(
          color: highlightColor,
          border: Border.all(
            color: highlightColor,
            width: 1,
          ),
        ),
        child: SizedBox(
            height: finalRows * (buttonSize - 0.5),
            child: GridView.builder(
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
                String text = index < widget.desk.numbers.length
                    ? '${widget.desk.numbers[index]!.number}'
                    : '';
                bool isActive = index < widget.desk.numbers.length
                    ? widget.desk.numbers[index]!.isActive
                    : false;
                bool isSelected = widget.selectedButtons.contains(index);
                bool isHint = widget.hint != null && widget.hint!.isHint(index);
                return buildButton(index, text, isActive, isSelected, isHint);
              },
            )));
  }

  buildButton(int index, String text, bool isActive, bool isSelected, bool isHint) {
    Color highlightColor = Theme.of(context).colorScheme.onPrimary;
    Color hintColor = Theme.of(context).colorScheme.outline;
    Color inactiveTextColor = Theme.of(context).colorScheme.onSecondary;
    Color activeTextColor = Theme.of(context).colorScheme.primary;
    Color highlightTextColor = Theme.of(context).colorScheme.secondary;
    Color buttonColor = isActive
        ? (isSelected
            ? highlightColor
            : isHint
                ? hintColor
                : highlightTextColor)
        : highlightTextColor;
    Color textColor = isSelected
        ? highlightTextColor
        : isActive
            ? activeTextColor
            : inactiveTextColor;
    return SizedBox(
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: buttonColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero),
          padding: EdgeInsets.zero,
        ),
        onPressed: isActive
            ? () => widget.onButtonPressed(index)
            : null,
        child: Text(
          text,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: textColor),
        ),
      ),
    );
  }

}

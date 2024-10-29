import 'package:flutter/material.dart';
import '../game/hint.dart';
import '../game/desk.dart';

class ButtonGrid extends StatefulWidget {
  final Function(int) onButtonPressed;
  final List<int> selectedButtons;
  final Hint? hint;
  final Desk desk;
  final int rows;
  final bool withScroll;

  const ButtonGrid({
    super.key,
    required this.onButtonPressed,
    required this.selectedButtons,
    required this.desk,
    this.hint,
    this.rows = 0,
    this.withScroll = true,
  });

  @override
  State<ButtonGrid> createState() => _ButtonGridState();
}

class _ButtonGridState extends State<ButtonGrid> {
  bool isRowBeingRemoved = false;
  List<int> crossedOutIndexes = [];

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    double appBarHeight = Scaffold.of(context).appBarMaxHeight ?? kToolbarHeight;
    double availableHeight = screenHeight - appBarHeight;

    double buttonSize = (screenWidth / widget.desk.rowLength).ceil().toDouble() - 2.0;

    int totalRowsInView = widget.rows > 0 ? widget.rows : (availableHeight /buttonSize).floor() - 1;
    int totalButtonsToShow = totalRowsInView * widget.desk.rowLength;
    int buttonsInLastRow = widget.desk.numbers.length % widget.desk.rowLength;
    int emptyCellsToAdd = totalButtonsToShow - widget.desk.numbers.length > 0
        ? totalButtonsToShow - widget.desk.numbers.length
        : widget.desk.rowLength * 2 + buttonsInLastRow > 0
            ? widget.desk.rowLength - buttonsInLastRow
            : 0;
    int finalItemCount = emptyCellsToAdd + widget.desk.numbers.length;
    Color highlightColor = Theme.of(context).colorScheme.onPrimary;

    final ScrollController? scrollController = widget.withScroll ? ScrollController() : null;

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
        height: totalRowsInView * (buttonSize),
        width: widget.desk.rowLength * (buttonSize),
        child: Scrollable(
          controller: scrollController,
          viewportBuilder: (context, offset) {
            return Viewport(
              axisDirection: AxisDirection.down,
              offset: offset,
              slivers: [
                SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: widget.desk.rowLength,
                    childAspectRatio: 1,
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
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
                    childCount: finalItemCount,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
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
        key: (text != '') ? Key('number_$index') : Key('empty_$index'),
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

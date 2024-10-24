import 'hint.dart';

class Stage {
  final String text;
  final int buttonsPerRow;
  final List<int> numbers;
  final Hint hint;
  final List<int> inactiveNumbers;

  Stage(this.text, this.buttonsPerRow, this.numbers, this.hint,
      [this.inactiveNumbers = const []]);
}

class Tutorial {
  List<Stage> getSteps() {
    List<Stage> stages = [
      Stage(
         'You can remove cells with numbers that are equal or add up to 10 if they are adjacent to each other',
          6,
          [1, 9, 4, 5, 3, 8],
          Hint(0, 1)),
      Stage(
           '… or are located one above the other',
          6,
          [3, 9, 2, 5, 8, 4, 7, 5],
          Hint(0, 6)),
      Stage(
          'Even if there was a line break between the cells, but they are adjacent, you can still remove them',
          6,
          [3, 2, 1, 5, 8, 4, 6, 5],
          Hint(5, 6)),
      Stage(
          'If the cells are diagonal to each other, you can also remove them',
          6,
          [4, 9, 3, 5, 7, 2, 1, 5, 4, 2],
          Hint(1, 6)),
      Stage(
          'The direction of the diagonal doesn’t matter',
          6,
          [2, 4, 1, 5, 7, 9, 5, 8, 3, 8],
          Hint(0, 7)),
      Stage(
           'This is true for any diagonals, as long as there are no active cells on them',
          6,
          [2, 4, 1, 5, 7, 9, 5, 8, 3, 4, 8, 5, 1, 8, 9],
          Hint(2, 12),
          [7]),
      Stage(
          'You can also remove the first and last cells on a desk',
          6,
          [3, 1, 7, 1, 7, 4, 5, 6, 2, 6, 2, 5, 3, 1, 5, 7], Hint(0, 15)),
      Stage(
           'If you remove all the cells in a row, the row is destroyed',
          6,
          [3, 8, 3, 1, 5, 3, 9, 6, 1, 4, 2, 5, 4, 5, 4],
          Hint(3, 8),
          [6, 7, 9, 10, 11,]
      ),
      Stage(
          'If you clear the entire board, you advance to the next level',
          6,
          [3, 5, 5, 7, 4, 9, 6, 7, 4, 2, 4, 1, 8, 7],
          Hint(-10, -14)),
    ];
    return stages;
  }
}

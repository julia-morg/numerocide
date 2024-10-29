import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/game/hint.dart';
import 'package:numerocide/game/desk.dart';
import 'package:numerocide/game/field.dart';
import 'package:numerocide/game/tutorial.dart';

void main() {
  group('Tutorial steps', () {
    test('Each step should have only one valid move as per hint', () {
      Tutorial tutorial = Tutorial();
      List<Stage> stages = tutorial.getSteps();
      int step = 1;
      for (Stage stage in stages) {
        Map<int, Field> numbers = stage.numbers.asMap().map((index, number) =>
            MapEntry(index,
                Field(index, number, !stage.inactiveNumbers.contains(index))));
        Desk desk = Desk(0, 0, 0, numbers, stage.buttonsPerRow);
        if (stage.hint == null) {
          continue;
        }
        bool isHintCorrect = desk.isCorrectMove(stage.hint!.hint1, stage.hint!.hint2);
        expect(isHintCorrect, isTrue,
            reason:
                'Hint move should be correct for stage: $step. ${stage.text}');
        desk.move(stage.hint!.hint1, stage.hint!.hint2).toString();
        Hint? hint = desk.findHint();
        expect(hint, isNull,
            reason:
                'No valid moves should remain for stage: $step. ${stage.text}. Found hint: ${hint?.toString()}');
        step++;
      }
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/game/hint.dart';

void main() {
  group('Hint class tests', () {
    test('should correctly identify hints', () {
      Hint hint = Hint(1, 2);

      expect(hint.isHint(1), true);
      expect(hint.isHint(2), true);
      expect(hint.isHint(3), false);
    });

    test('should return correct string representation', () {
      Hint hint = Hint(1, 2);

      expect(hint.toString(), '[1; 2]');
    });
  });
}
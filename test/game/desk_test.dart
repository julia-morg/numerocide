import 'package:flutter_test/flutter_test.dart';
import 'package:numberocide/game/desk.dart';
import 'package:numberocide/game/field.dart';
import 'package:numberocide/game/hint.dart';

void main() {
  group('Desk', () {
    late Desk desk;

    setUp(() {
      // Начальные данные для игры
      Map<int, Field> numbers = {
        0: Field(0, 5, true),
        1: Field(1, 5, true),
        2: Field(2, 2, true),
        3: Field(3, 8, true),
        4: Field(4, 3, true),
        5: Field(5, 7, true),
      };
      desk = Desk(0, 0, numbers, 3); // 3 кнопки в ряду
    });

    test('newStage увеличивает количество стадий и добавляет активные клетки', () {
      desk.newStage();
      expect(desk.stage, 1);
      expect(desk.numbers.length, 12); // Увеличено на активные клетки
    });

    test('isCorrectMove возвращает true для корректных ходов', () {
      expect(desk.isCorrectMove(0, 1), isTrue); // Одинаковые значения
      expect(desk.isCorrectMove(2, 3), isTrue); // Сумма равна 10
    });

    test('isCorrectMove возвращает false для некорректных ходов', () {
      expect(desk.isCorrectMove(0, 2), isFalse); // Разные значения, не дают 10
      expect(desk.isCorrectMove(3, 4), isFalse); // Разные значения
    });

    test('move правильно удаляет клетки и увеличивает счет', () {
      desk.move(0, 1); // Одинаковые числа 5 и 5
      expect(desk.numbers[0]!.isActive, isFalse);
      expect(desk.numbers[1]!.isActive, isFalse);
      expect(desk.score, 10); // Счет должен увеличиться на 10
    });

    test('findHint находит правильные подсказки', () {
      Hint? hint = desk.findHint();
      expect(hint, isNotNull);
      expect(hint!.hint1, 0); // Первые одинаковые клетки
      expect(hint.hint2, 1);
    });

    test('findHint возвращает null, если нет возможных ходов', () {
      // Все клетки неактивны
      desk.numbers[0]!.isActive = false;
      desk.numbers[1]!.isActive = false;
      desk.numbers[2]!.isActive = false;
      desk.numbers[3]!.isActive = false;
      desk.numbers[4]!.isActive = false;
      desk.numbers[5]!.isActive = false;

      Hint? hint = desk.findHint();
      expect(hint, isNull);
    });

    test('isGameOver возвращает true, если все клетки неактивны', () {
      desk.numbers[0]!.isActive = false;
      desk.numbers[1]!.isActive = false;
      desk.numbers[2]!.isActive = false;
      desk.numbers[3]!.isActive = false;
      desk.numbers[4]!.isActive = false;
      desk.numbers[5]!.isActive = false;

      expect(desk.isGameOver(), isTrue);
    });

    test('isGameOver возвращает false, если хотя бы одна клетка активна', () {
      desk.numbers[0]!.isActive = false;
      desk.numbers[1]!.isActive = false;
      expect(desk.isGameOver(), isFalse);
    });

    test('checkAndRemoveEmptyRows удаляет пустые ряды', () {
      // Делаем 0 и 1 клетки неактивными, чтобы они составили пустую строку
      desk.numbers[0]!.isActive = false;
      desk.numbers[1]!.isActive = false;
      desk.numbers[2]!.isActive = false;

      bool removed = desk.checkAndRemoveEmptyRows();
      expect(removed, isTrue); // Пустой ряд должен быть удален
      expect(desk.numbers.length, 3); // Количество должно уменьшиться
    });

    test('isRowEmpty возвращает true для пустого ряда', () {
      desk.numbers[0]!.isActive = false;
      desk.numbers[1]!.isActive = false;
      desk.numbers[2]!.isActive = false;
      expect(desk.isRowEmpty(0), isTrue);
    });

    test('isRowEmpty возвращает false для непустого ряда', () {
      desk.numbers[0]!.isActive = false;
      desk.numbers[1]!.isActive = true;
      desk.numbers[2]!.isActive = false;
      expect(desk.isRowEmpty(0), isFalse);
    });
  });
}
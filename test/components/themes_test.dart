import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/themes.dart';

void main() {
  group('Themes', () {
    test('themeDisplayName should capitalize theme name', () {
      expect(Themes.themeDisplayName(Themes.navy), 'Water');
      expect(Themes.themeDisplayName(Themes.brown), 'Cocoa');
    });

    test('getColorScheme returns correct colors for each theme', () {
      final navyScheme = Themes.getColorScheme(Themes.navy);
      expect(navyScheme.primary, isNotNull);
      expect(navyScheme.secondaryContainer, Colors.blueGrey[100]!);

      final brownScheme = Themes.getColorScheme(Themes.brown);
      expect(brownScheme.primary, isNotNull);
      expect(brownScheme.secondaryContainer, Colors.brown[100]!);

      final greyScheme = Themes.getColorScheme(Themes.grey);
      expect(greyScheme.primary, isNotNull);
      expect(greyScheme.secondaryContainer, Colors.blueGrey[100]!);

      final greenScheme = Themes.getColorScheme(Themes.green);
      expect(greenScheme.primary, isNotNull);
      expect(greenScheme.secondaryContainer, Colors.teal[50]!);
    });

    testWidgets('getThemeData generates correct ThemeData', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (BuildContext context) {
              final themeData = Themes.getThemeData(Themes.navy, context);
              expect(themeData.colorScheme.primary, isNotNull);
              expect(themeData.appBarTheme.backgroundColor, themeData.colorScheme.primary);
              expect(themeData.textTheme.headlineMedium!.color, themeData.colorScheme.secondary);
              expect(themeData.elevatedButtonTheme.style?.backgroundColor?.resolve({}), themeData.colorScheme.secondaryContainer);
              return Container(); // Возвращаем пустой контейнер, так как тестируем только данные темы
            },
          ),
        ),
      );
    });

    group('getSwitchThemeData', () {
      final colorScheme = ColorScheme.fromSwatch(
        primarySwatch: Colors.blue,
        accentColor: Colors.green,
        backgroundColor: Colors.white,
      );

      test('returns correct thumbColor for selected and unselected states', () {
        final switchThemeData = Themes.getSwitchThemeData(colorScheme);
        final thumbColorSelected = switchThemeData.thumbColor!.resolve({WidgetState.selected});
        expect(thumbColorSelected, colorScheme.secondary);
        final thumbColorUnselected = switchThemeData.thumbColor!.resolve({});
        expect(thumbColorUnselected, colorScheme.primary);
      });

      test('returns correct trackColor for selected and unselected states', () {
        final switchThemeData = Themes.getSwitchThemeData(colorScheme);
        final trackColorSelected = switchThemeData.trackColor!.resolve({WidgetState.selected});
        expect(trackColorSelected, colorScheme.primary);
        final trackColorUnselected = switchThemeData.trackColor!.resolve({});
        expect(trackColorUnselected, colorScheme.secondary);
      });

      test('returns correct trackOutlineColor for selected and unselected states', () {
        final switchThemeData = Themes.getSwitchThemeData(colorScheme);
        final trackOutlineColorSelected = switchThemeData.trackOutlineColor!.resolve({WidgetState.selected});
        expect(trackOutlineColorSelected, colorScheme.primary);
        final trackOutlineColorUnselected = switchThemeData.trackOutlineColor!.resolve({});
        expect(trackOutlineColorUnselected, colorScheme.primary);
      });
    });
  });
}
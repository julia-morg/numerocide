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

    test('getThemeData generates correct ThemeData', () {
      final themeData = Themes.getThemeData(Themes.navy);

      expect(themeData.colorScheme.primary, isNotNull);
      expect(themeData.appBarTheme.backgroundColor, themeData.colorScheme.primary);
      expect(themeData.textTheme.headlineMedium!.color, themeData.colorScheme.secondary);
      expect(themeData.elevatedButtonTheme.style?.backgroundColor?.resolve({}), themeData.colorScheme.secondaryContainer);
    });
  });
}
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Settings {
  bool sound;
  bool vibro;
  String theme;

  Settings({required this.sound, required this.vibro, required this.theme});

  // Метод для сохранения настроек
  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', sound);
    await prefs.setBool('vibro', vibro);
    await prefs.setString('theme', theme);
  }

  // Метод для загрузки настроек
  static Future<Settings> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool sound = prefs.getBool('sound') ?? false; // false по умолчанию
    bool vibro = prefs.getBool('vibro') ?? true;  // true по умолчанию
    String theme = prefs.getString('theme') ?? 'blue'; // 'blue' по умолчанию

    return Settings(sound: sound, vibro: vibro, theme: theme);
  }

  // Список доступных тем
  static List<String> availableThemes() {
    return ['blue', 'brown', 'grey', 'green', 'red'];
  }

  // Отображаемое название для каждой темы
  static String themeDisplayName(String theme) {
    switch (theme) {
      case 'blue':
        return 'Blue';
      case 'brown':
        return 'Brown';
      case 'grey':
        return 'Grey';
      case 'green':
        return 'Green';
      case 'red':
        return 'Red';
      default:
        return 'Unknown';
    }
  }
  // Метод для получения цветовой схемы в зависимости от темы
  static ThemeData getThemeData(String theme) {
    switch (theme) {
      case 'brown':
        return ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.brown,
            onPrimary: Colors.white,
            secondary: Colors.brown[300]!,
            onSecondary: Colors.white,
          ),
        );
      case 'grey':
        return ThemeData(
          colorScheme: ColorScheme.light(
            primary: Colors.grey,
            onPrimary: Colors.white,
            secondary: Colors.grey[700]!,
            onSecondary: Colors.white,
          ),
        );
      case 'green':
        return ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Colors.green,
            onPrimary: Colors.white,
            secondary: Colors.greenAccent,
            onSecondary: Colors.white,
          ),
        );
      case 'red':
        return ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Colors.red,
            onPrimary: Colors.white,
            secondary: Colors.redAccent,
            onSecondary: Colors.white,
          ),
        );
      case 'blue':
      default:
        return ThemeData(
          colorScheme: const ColorScheme.light(
            primary: Colors.blue,
            onPrimary: Colors.white,
            secondary: Colors.blueAccent,
            onSecondary: Colors.white,
          ),
        );
    }
  }

  // Получение основных цветов для палитры
  static List<Color> getThemeColors(String theme) {
    ThemeData themeData = getThemeData(theme);
    return [
      themeData.primaryColor,
      themeData.secondaryHeaderColor,
      themeData.primaryColorLight,
      themeData.scaffoldBackgroundColor,
      themeData.colorScheme.primary,
    ];
  }
}
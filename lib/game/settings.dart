import 'package:numerocide/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Settings {
  bool sound;
  bool vibro;
  String theme;
  static const String navy = 'water';
  static const String brown = 'cocoa';
  static const String grey = 'stone';
  static const String green = 'grass';
  static List<String> get allThemes => [navy, brown, grey, green];

  Settings({required this.sound, required this.vibro, required this.theme});

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_sound', sound);
    await prefs.setBool('settings_vibro', vibro);
    await prefs.setString('settings_theme', theme);
  }

  static Future<Settings> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool sound = prefs.getBool('settings_sound') ?? false;
    bool vibro = prefs.getBool('settings_vibro') ?? true;
    String theme = prefs.getString('settings_theme') ?? navy;

    return Settings(sound: sound, vibro: vibro, theme: theme);
  }
  
  static String themeDisplayName(String theme) {
    return theme.capitalize();
  }

  static ThemeData getThemeData(String theme) {
    TextTheme textTheme = const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.bold),
      headlineMedium: TextStyle(fontWeight: FontWeight.bold),
      headlineSmall: TextStyle(fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontWeight: FontWeight.bold),
      titleSmall: TextStyle(fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(fontWeight: FontWeight.bold),
      bodyMedium: TextStyle(fontWeight: FontWeight.bold),
      bodySmall: TextStyle(fontWeight: FontWeight.bold),
      labelLarge: TextStyle(fontWeight: FontWeight.bold),
      labelMedium: TextStyle(fontWeight: FontWeight.bold),
      labelSmall: TextStyle(fontWeight: FontWeight.bold),
    );
    switch (theme) {
      case brown:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink).copyWith(
            onSecondary: Colors.grey[400],
            onSecondaryContainer: Colors.grey[200]!,
            secondary: Colors.blueGrey[50]!,
            outline: Colors.green.withOpacity(0.5),
          ),
          textTheme: textTheme,
          useMaterial3: true,
        );
      case grey:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey, dynamicSchemeVariant: DynamicSchemeVariant.neutral,).copyWith(
            onSecondary: Colors.grey[400],
            onSecondaryContainer: Colors.grey[200]!,
            secondary: Colors.blueGrey[50]!,
            outline: Colors.green.withOpacity(0.5),
          ),
          textTheme: textTheme,
          useMaterial3: true,
        );
      case green:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green).copyWith(
            onSecondary: Colors.grey[400],
            onSecondaryContainer: Colors.grey[200]!,
            secondary: Colors.blueGrey[50]!,
            outline: Colors.green.withOpacity(0.5),
          ),
          textTheme: textTheme,
          useMaterial3: true,
        );
      case navy:
      default:
        ThemeData theme = ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent).copyWith(
            onSecondary: Colors.grey[400],
            onSecondaryContainer: Colors.grey[200]!,
            secondary: Colors.blueGrey[50]!,
            outline: Colors.green.withOpacity(0.5),
          ),
          textTheme: textTheme,
          useMaterial3: true,
        );
        return theme;
    }
  }

  static List<Color> getThemeColors(String theme) {
    ThemeData themeData = getThemeData(theme);
    return [
      themeData.colorScheme.primary,
      themeData.colorScheme.secondaryContainer,
      themeData.colorScheme.secondary,
      themeData.colorScheme.onSecondary,
      themeData.colorScheme.onSecondaryContainer,
      themeData.colorScheme.surface,
      themeData.colorScheme.primary.withOpacity(0.7),
    ];
  }
}
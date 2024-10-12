import 'package:numerocide/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Settings {
  bool sound;
  bool vibro;
  String theme;
  static const String navy = 'navy';
  static const String brown = 'brown';
  static const String grey = 'grey';
  static const String green = 'green';
  static const String red = 'red';
  static List<String> get allThemes => [navy, brown, grey, green, red];

  Settings({required this.sound, required this.vibro, required this.theme});

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', sound);
    await prefs.setBool('vibro', vibro);
    await prefs.setString('theme', theme);
  }

  static Future<Settings> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool sound = prefs.getBool('sound') ?? false;
    bool vibro = prefs.getBool('vibro') ?? true;
    String theme = prefs.getString('theme') ?? navy;

    return Settings(sound: sound, vibro: vibro, theme: theme);
  }
  
  static String themeDisplayName(String theme) {
    return theme.capitalize();
  }

  static ThemeData getThemeData(String theme) {
    switch (theme) {
      case brown:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.pink).copyWith(
            onSecondary: Colors.grey[400],
            onSecondaryContainer: Colors.grey[200]!,
            secondary: Colors.blueGrey[50]!,
            outline: Colors.green.withOpacity(0.5),
          ),
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
          useMaterial3: true,
        );
      case red:
        return ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.red, dynamicSchemeVariant: DynamicSchemeVariant.vibrant,).copyWith(
            onSecondary: Colors.grey[400],
            onSecondaryContainer: Colors.grey[200]!,
            secondary: Colors.blueGrey[50]!,
            outline: Colors.green.withOpacity(0.5),
          ),
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
          useMaterial3: true,
        );
       // theme. = Colors.white;
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
      themeData.colorScheme.primary.withOpacity(0.5),
    ];
  }
}
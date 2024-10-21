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
    ColorScheme colorScheme =
        ColorScheme.fromSeed(seedColor: Colors.blueAccent).copyWith(
      onSecondary: Colors.grey[400],
      onSecondaryContainer: Colors.grey[200]!,
      secondary: Colors.blueGrey[50]!,
      outline: Colors.green.withOpacity(0.5),
    );

    if (theme == brown) {
      colorScheme =
          ColorScheme.fromSeed(seedColor: Colors.pink).copyWith(
        onSecondary: Colors.grey[400],
        onSecondaryContainer: Colors.grey[200]!,
        secondary: Colors.blueGrey[50]!,
        outline: Colors.green.withOpacity(0.5),
      );
    } else if (theme == grey) {
      colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blueGrey,
        dynamicSchemeVariant: DynamicSchemeVariant.neutral,
      ).copyWith(
        onSecondary: Colors.grey[400],
        onSecondaryContainer: Colors.grey[200]!,
        secondary: Colors.blueGrey[50]!,
        outline: Colors.green.withOpacity(0.5),
      );
    } else if (theme == green) {
      colorScheme = ColorScheme.fromSeed(seedColor: Colors.green).copyWith(
        secondaryContainer: Colors.green[50]!,
        onSecondary: Colors.grey[400],
        onSecondaryContainer: Colors.grey[200]!,
        secondary: Colors.blueGrey[50]!,
        outline: Colors.green.withOpacity(0.5),
      );
    }

    TextStyle mainTextStyle = TextStyle(
      color: colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
    TextStyle headlineTextStyle = TextStyle(
      color: colorScheme.surface,
      fontWeight: FontWeight.bold,
    );
    AppBarTheme  appBarTheme = AppBarTheme(
      backgroundColor: colorScheme.primary,
      titleTextStyle: TextStyle(
        color: colorScheme.surface,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.surface,
        size: 40.0,
      ),
    );
    TextTheme textTheme = TextTheme(
      headlineLarge: headlineTextStyle,
      headlineMedium: headlineTextStyle,
      headlineSmall: headlineTextStyle,
      titleLarge: mainTextStyle,
      titleMedium: mainTextStyle,
      titleSmall: mainTextStyle,
      bodyLarge: mainTextStyle,
      bodyMedium: mainTextStyle,
      bodySmall: mainTextStyle,
      labelLarge: mainTextStyle,
      labelMedium: mainTextStyle,
      labelSmall: mainTextStyle,
      displayLarge: mainTextStyle,
      displayMedium: mainTextStyle,
      displaySmall: mainTextStyle,

    );
    ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    IconThemeData iconTheme = IconThemeData(
      color: colorScheme.primary,
      size: 40.0,
    );

    return ThemeData(
      colorScheme: colorScheme,
      appBarTheme: appBarTheme,
      textTheme: textTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      iconTheme: iconTheme,
      primaryIconTheme: iconTheme,
      useMaterial3: true,
    );
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
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
    ColorScheme colorScheme = getColorScheme(theme);

    TextStyle mainTextStyle = TextStyle(
      color: colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
    TextStyle headlineTextStyle = TextStyle(
      color: colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    AppBarTheme  appBarTheme = AppBarTheme(
      backgroundColor: colorScheme.primary,
      titleTextStyle: TextStyle(
        color: colorScheme.secondary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: colorScheme.secondary,
        size: 40.0,
      ),
    );
    TextTheme textTheme = TextTheme(
      headlineLarge: headlineTextStyle,
      headlineMedium: headlineTextStyle,
      headlineSmall: headlineTextStyle,
      titleLarge: mainTextStyle.copyWith(fontSize: 30),
      titleMedium: mainTextStyle,
      titleSmall: mainTextStyle,
      bodyLarge: mainTextStyle,
      bodyMedium: mainTextStyle,
      bodySmall: mainTextStyle,
      labelLarge: mainTextStyle.copyWith( fontWeight: FontWeight.w900),
      labelMedium: mainTextStyle.copyWith( fontWeight: FontWeight.w900),
      labelSmall: mainTextStyle.copyWith( fontWeight: FontWeight.w900),
      displayLarge: mainTextStyle,
      displayMedium: mainTextStyle,
      displaySmall: mainTextStyle,

    );
    ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
        backgroundColor: colorScheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    IconThemeData iconTheme = IconThemeData(
      color: colorScheme.primary,
      size: 40.0,
    );
    SwitchThemeData switchThemeData = SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.secondary;
          }
          return colorScheme.primary;
        },
      ),
      trackColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.secondary;
        },
      ),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return colorScheme.primary;
        },
      ),
    );

    return ThemeData(
      scaffoldBackgroundColor: colorScheme.secondary,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme,
      textTheme: textTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      iconTheme: iconTheme,
      primaryIconTheme: iconTheme,
      useMaterial3: true,
      switchTheme: switchThemeData,
    );
  }

  static ColorScheme getColorScheme(String theme) {
    ColorScheme colorScheme = ColorScheme(
      primary: Colors.deepPurple,
      onPrimary: Colors.white,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      onSecondary: Colors.grey[400]!,
      secondary: Colors.blueGrey[50]!,
      brightness: Brightness.light,
      outline: Colors.green[200]!.withOpacity(0.8),
    );

    if (theme == navy) {
      ColorScheme navyScheme = ColorScheme.fromSeed(seedColor: Colors.blue, dynamicSchemeVariant: DynamicSchemeVariant.fidelity);
      colorScheme = colorScheme.copyWith(
        primary: navyScheme.onSecondaryFixedVariant,
        secondary: Colors.blueGrey[50]!,
        secondaryContainer: Colors.blueGrey[100]!,
      );
    }

    if (theme == brown) {
      ColorScheme brownScheme = ColorScheme.fromSeed(seedColor: Colors.pink);
      colorScheme = colorScheme.copyWith(
        primary: brownScheme.secondary,
        secondary: Colors.brown[50]!,
        secondaryContainer: Colors.brown[100]!,
      );
    }
    if (theme == grey) {
      ColorScheme greyScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey,);
      colorScheme = colorScheme.copyWith(
        primary: greyScheme.secondary,
        secondary: Colors.blueGrey[50]!,
        secondaryContainer: Colors.blueGrey[100]!,
      );
    }
    if (theme == green) {
      ColorScheme greenScheme = ColorScheme.fromSeed(seedColor: Colors.green);
      colorScheme = colorScheme.copyWith(
        primary: greenScheme.primary,
        secondary: Colors.blueGrey[50]!,
        secondaryContainer: Colors.blueGrey[100]!,
      );
    }
    return colorScheme;
  }

  static List<Color> getThemeColors(String theme) {
    ThemeData themeData = getThemeData(theme);
    return [
      themeData.colorScheme.primary, // primary color
      themeData.colorScheme.primary.withOpacity(0.7), // highlight color
      themeData.colorScheme.secondaryContainer, // menu buttons highlight
      themeData.colorScheme.secondary, // background color
      themeData.colorScheme.onSecondary, // inactive elements color
      themeData.colorScheme.outline, // hint color
    ];
  }
}
import 'package:numerocide/main.dart';
import 'package:flutter/material.dart';

class Themes {

  static const String navy = 'water';
  static const String brown = 'cocoa';
  static const String grey = 'stone';
  static const String green = 'grass';
  static List<String> get allThemes => [navy, brown, grey, green];

  Themes();


  static String themeDisplayName(String theme) {
    return theme.capitalize();
  }

  static ThemeData getThemeData(String theme) {
    ColorScheme colorScheme = getColorScheme(theme);
    TextTheme textTheme = getTextTheme(colorScheme);
    SwitchThemeData switchThemeData = getSwitchThemeData(colorScheme);

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

    ElevatedButtonThemeData elevatedButtonTheme = ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        backgroundColor: colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    
    IconThemeData iconTheme = IconThemeData(
      color: colorScheme.primary,
      size: 40.0,
    );

    DialogTheme dialogTheme = DialogTheme(
      backgroundColor: colorScheme.secondary,
      titleTextStyle: textTheme.headlineMedium,
      contentTextStyle: textTheme.bodyMedium,
    );

    DividerThemeData dividerThemeData = DividerThemeData(
      color: colorScheme.primary,
    );
    DropdownMenuThemeData dropdownButtonTheme =  DropdownMenuThemeData(
      inputDecorationTheme: InputDecorationTheme(
        fillColor: colorScheme.secondaryContainer,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: colorScheme.primary,
          ),
        ),
      ),
      textStyle: textTheme.bodyMedium,
    );


    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.secondary,
      colorScheme: colorScheme,
      appBarTheme: appBarTheme,
      textTheme: textTheme,
      elevatedButtonTheme: elevatedButtonTheme,
      iconTheme: iconTheme,
      primaryIconTheme: iconTheme,
      switchTheme: switchThemeData,
      dialogTheme: dialogTheme,
      dividerTheme: dividerThemeData,
      dropdownMenuTheme: dropdownButtonTheme,
    );
  }

  static TextTheme getTextTheme(ColorScheme colorScheme) {
    TextStyle mainTextStyle = TextStyle(
      color: colorScheme.primary,
      fontWeight: FontWeight.bold,
    );
    TextStyle headlineTextStyle = TextStyle(
      color: colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    return TextTheme(
      headlineLarge: headlineTextStyle,
      headlineMedium: headlineTextStyle,
      headlineSmall: headlineTextStyle,
      titleLarge: mainTextStyle.copyWith(fontSize: 30),
      titleMedium: mainTextStyle.copyWith(fontSize: 24),
      titleSmall: mainTextStyle.copyWith(fontSize: 20),
      bodyLarge: mainTextStyle,
      bodyMedium: mainTextStyle,
      bodySmall: mainTextStyle,
      labelLarge: mainTextStyle.copyWith( fontWeight: FontWeight.w900),
      labelMedium: mainTextStyle.copyWith( fontWeight: FontWeight.w900),
      labelSmall: mainTextStyle.copyWith(fontSize: 12, fontWeight: FontWeight.w900),
      displayLarge: mainTextStyle,
      displayMedium: mainTextStyle,
      displaySmall: mainTextStyle.copyWith(fontSize: 16),
    );
  }

  static SwitchThemeData getSwitchThemeData(ColorScheme colorScheme){
    return SwitchThemeData(
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
  }

  static ColorScheme getColorScheme(String theme) {
    ColorScheme colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Colors.deepPurple,
      onPrimary: Colors.purple,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
      onSecondary: Colors.grey[400]!,
      secondary: Colors.white,
      outline: Colors.green[200]!.withOpacity(0.8),
    );

    if (theme == navy) {
      ColorScheme navyScheme = ColorScheme.fromSeed(seedColor: Colors.blue, dynamicSchemeVariant: DynamicSchemeVariant.fidelity);
      colorScheme = colorScheme.copyWith(
        primary: navyScheme.onSecondaryFixedVariant,
        onPrimary: navyScheme.onSecondaryFixedVariant.withOpacity(0.7),
      //  secondary: Colors.blueGrey[50]!,
        secondaryContainer: Colors.blueGrey[100]!,
      );
    }

    if (theme == brown) {
      ColorScheme brownScheme = ColorScheme.fromSeed(seedColor: Colors.pink);
      colorScheme = colorScheme.copyWith(
        primary: brownScheme.secondary,
        onPrimary: brownScheme.secondary.withOpacity(0.7),
      //  secondary: Colors.brown[50]!,
        secondaryContainer: Colors.brown[100]!,
      );
    }
    if (theme == grey) {
      ColorScheme greyScheme = ColorScheme.fromSeed(seedColor: Colors.blueGrey,);
      colorScheme = colorScheme.copyWith(
        primary: greyScheme.secondary,
        onPrimary: greyScheme.secondary.withOpacity(0.7),
      //  secondary: Colors.blueGrey[50]!,
        secondaryContainer: Colors.blueGrey[100]!,
      );
    }
    if (theme == green) {
      ColorScheme greenScheme = ColorScheme.fromSeed(seedColor: Colors.green);
      colorScheme = colorScheme.copyWith(
        primary: greenScheme.primary,
        onPrimary: greenScheme.primary.withOpacity(0.7),
     //   secondary: Colors.white.withOpacity(1),
        secondaryContainer: Colors.teal[50]!,
      );
    }
    return colorScheme;
  }

  static List<Color> getThemeColors(String theme) {
    ThemeData themeData = getThemeData(theme);
    return [
      themeData.colorScheme.primary, // primary color
      themeData.colorScheme.onPrimary, // highlight color
      themeData.colorScheme.secondaryContainer, // menu buttons highlight
      themeData.colorScheme.secondary, // background color
      themeData.colorScheme.onSecondary, // inactive elements color
      themeData.colorScheme.outline, // hint color
    ];
  }
}
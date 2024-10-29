import 'package:flutter/material.dart';
import 'components/themes.dart';
import 'game/save.dart';
import 'pages/home_page.dart';
import 'game/settings.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Settings settings = await Settings.loadSettings();
  Save save = Save();
  runApp(MyApp(settings: settings, save: save));
}

class MyApp extends StatefulWidget {
  final Settings settings;
  final Save save;

  const MyApp({super.key, required this.settings, required this.save});

  @override
  State<MyApp> createState() => _MyAppState();

  static void updateTheme(BuildContext context, ThemeData newTheme) {
    _MyAppState? m =  context.findAncestorStateOfType<_MyAppState>();
    if (m != null) {
      m.updateTheme(newTheme);
    }
  }

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState? state = context.findAncestorStateOfType<_MyAppState>();
    state?.changeLanguage(newLocale);
  }
}

class _MyAppState extends State<MyApp> {
  late ThemeData _themeData;
  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _themeData = Themes.getThemeData(widget.settings.theme);

    if (widget.settings.language.isNotEmpty) {
      _locale = Locale(widget.settings.language);
    }
  }

  void updateTheme(ThemeData newTheme) {
    setState(() {
      _themeData = newTheme;
    });
  }

  void changeLanguage(Locale locale) {
    setState(() {
      _locale = locale;
      widget.settings.language = locale.languageCode;
      widget.settings.saveSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numerocide',
      theme: _themeData,
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,

      localeResolutionCallback: (locale, supportedLocales) {
        if (_locale == null) {
          return locale;
        }

        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == _locale!.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },

      home: HomePage(settings: widget.settings, save: widget.save),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
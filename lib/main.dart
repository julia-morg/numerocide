import 'package:flutter/material.dart';
import 'home_page.dart';
import 'game/settings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Settings settings = await Settings.loadSettings();
  runApp(MyApp(settings: settings));
}

class MyApp extends StatefulWidget {
  final Settings settings;

  const MyApp({super.key, required this.settings});

  @override
  State<MyApp> createState() => _MyAppState();

  static void updateTheme(BuildContext context, ThemeData newTheme) {
    _MyAppState? m =  context.findAncestorStateOfType<_MyAppState>();
    if (m != null) {
      m.updateTheme(newTheme);
    }
  }
}

class _MyAppState extends State<MyApp> {
  late ThemeData _themeData;

  @override
  void initState() {
    super.initState();
    _themeData = Settings.getThemeData(widget.settings.theme);
  }

  void updateTheme(ThemeData newTheme) {
    setState(() {
      _themeData = newTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numerocide',
      theme: _themeData,
      home: HomePage(settings: widget.settings,),
      builder: (context, child) {
        return Center(
          child: SizedBox(
            child: child,
          ),
        );
      },
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
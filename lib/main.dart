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

  const MyApp({Key? key, required this.settings}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  // Метод для доступа к состоянию приложения
  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
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
      // theme: ThemeData(
      //   colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      //   useMaterial3: true,
      // ),
      home: const HomePage(),
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
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _maxScore = 0;
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _loadMaxScore();
    _checkSavedGame();
  }

  // Загружаем максимальный счет из SharedPreferences
  Future<void> _loadMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxScore = prefs.getInt('maxScore') ?? 0;
    });
  }

  // Проверяем, есть ли сохраненная игра
  Future<void> _checkSavedGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSavedGame = prefs.containsKey('randomNumbers'); // Проверяем наличие сохранённых данных
    });
  }

  // Метод для запуска новой игры
  void _startNewGame(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Очищаем сохранённое состояние игры
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyHomePage(
          title: 'Numerocide',
          buttonSize: 15.0,
          buttonsPerRow: 10,
          initialButtonCount: 40,
        ),
      ),
    ).then((_) {
      _loadMaxScore(); // Обновляем Max Score при возвращении на главную страницу
      _checkSavedGame(); // Проверяем сохранённую игру
    });
  }

  // Метод для продолжения сохраненной игры
  void _continueGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const MyHomePage(
          title: 'Numerocide',
          buttonSize: 15.0,
          buttonsPerRow: 10,
          initialButtonCount: 22,
        ),
      ),
    ).then((_) {
      _loadMaxScore(); // Обновляем Max Score при возвращении на главную страницу
      _checkSavedGame(); // Проверяем сохранённую игру
    });
  }

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.onSecondary;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorLight,
        title: const Text('Numerocide'),
        titleTextStyle: TextStyle(
          color: colorDark,
          fontSize: 18,
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Max Score: $_maxScore', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _startNewGame(context),
              child: const Text('Start new game'),
            ),
            ElevatedButton(
              onPressed: _hasSavedGame ? () => _continueGame(context) : null,
              child: const Text('Continue game'),
            ),
          ],
        ),
      ),
    );
  }
}
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
  String _title = 'Numerocide';

  @override
  void initState() {
    super.initState();
    _loadMaxScore();
    _checkSavedGame();
  }

  Future<void> _loadMaxScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _maxScore = prefs.getInt('maxScore') ?? 0;
    });
  }

  Future<void> _checkSavedGame() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSavedGame = prefs
          .containsKey('randomNumbers');
    });
  }

  void _startNewGame(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: _title,
          buttonSize: 15.0,
          buttonsPerRow: 10,
          initialButtonCount: 40,
        ),
      ),
    ).then((_) {
      _loadMaxScore();
      _checkSavedGame();
    });
  }

  void _continueGame(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(
          title: _title,
          buttonSize: 15.0,
          buttonsPerRow: 10,
          initialButtonCount: 22,
        ),
      ),
    ).then((_) {
      _loadMaxScore();
      _checkSavedGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.onSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title.toUpperCase(),
        ),
        titleTextStyle: TextStyle(
          color: colorLight,
          fontSize: 24,
        ),
        backgroundColor: colorDark,
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        iconTheme: IconThemeData(
          color: colorLight,
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Center(
            child: Text(
              'BEST RESULT: $_maxScore',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(color: colorDark),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: () => _startNewGame(context),
              child: const Text(
                'NEW GAME',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _hasSavedGame ? () => _continueGame(context) : null,
              child: const Text(
                'CONTINUE GAME',
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 40,
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkSavedGame();
  }
}

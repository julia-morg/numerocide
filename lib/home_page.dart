import 'package:flutter/material.dart';
import 'game_page.dart';
import 'settings_page.dart';
import 'game/settings.dart';
import 'game/save.dart';

class HomePage extends StatefulWidget {
  final Settings settings;
  const HomePage({super.key, required this.settings});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _maxScore = 0;
  bool _hasSavedGame = false;
  final String _title = 'Numerocide';
  Save save = Save();

  @override
  void initState() {
    super.initState();
    _loadMaxScore();
    _checkSavedGame();
  }

  Future<void> _loadMaxScore() async {
    save.loadMaxScore().then((value) {
      setState(() {
        _maxScore = value;
      });
    });
  }

  Future<void> _checkSavedGame() async {
    save.hasSavedGame().then((value) {
      setState(() {
        _hasSavedGame = value;
      });
    });
  }

  void _goToGame(BuildContext context, String mode) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          title: _title,
          maxScore: _maxScore,
          settings: widget.settings,
          mode: mode,
        ),
      ),
    ).then((_) {
      _loadMaxScore();
      _checkSavedGame();
    });
  }

  @override
  Widget build(BuildContext context) {
    Color colorStar = Colors.amberAccent;
    TextStyle largeTextStyle = Theme.of(context).textTheme.titleLarge!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title.toUpperCase(),
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.12,
        titleTextStyle: Theme.of(context).textTheme.headlineLarge,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(settings: widget.settings),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 60),
          Center(
            child: Column(
              children: [
                const Text('BEST RESULT',),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, color: colorStar, size: 30),
                    const SizedBox(width: 5),
                    Text(
                      '$_maxScore',
                      style: largeTextStyle,
                    ),
                    const SizedBox(width: 5),
                    Icon(Icons.star, color: colorStar, size: 30),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: ElevatedButton(
              onPressed: () => _onNewGamePressed(context),
              child: Text('NEW GAME',   style: largeTextStyle,),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _hasSavedGame ? () => _goToGame(context, GamePage.modeLoadGame) : null,
              child: Text('CONTINUE GAME', style: largeTextStyle),
            ),
          ),
          const Spacer(),

        ],
      ),
    );
  }

  void _onNewGamePressed(BuildContext context) {
    if (_hasSavedGame) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Warning'),
            content: const Text('You have a saved game. Are you sure you want to start a new game? Your current progress will be lost.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _goToGame(context, GamePage.modeNewGame);
                },
                child: const Text('Yes, go to new game'),
              ),
            ],
          );
        },
      );
    } else {
      _goToGame(context, GamePage.modeNewGame);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkSavedGame();
    _loadMaxScore();
  }
}

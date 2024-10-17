import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'donate_page.dart';
import 'game_page.dart';
import 'settings_page.dart';
import 'tutorial_page.dart';
import 'game/settings.dart';
import 'game/save.dart';

class HomePage extends StatefulWidget {
  final Settings settings;
  const HomePage({super.key, required this.settings});

  @override
  _HomePageState createState() => _HomePageState();
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

  void _goToGame(BuildContext context, bool mode) {
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

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialPage(settings: widget.settings,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.surface;
    Color colorStar = Colors.amberAccent;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _title.toUpperCase(),
        ),
        titleTextStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
              color: colorLight,
            ),
        backgroundColor: colorDark,
        toolbarHeight: MediaQuery.of(context).size.height * 0.15,
        iconTheme: IconThemeData(
          color: colorLight,
          size: 40.0,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
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
                Text(
                  'BEST RESULT',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall!
                      .copyWith(color: colorDark, fontSize: 15),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  // Чтобы Row занял только необходимую ширину
                  children: [
                    Icon(Icons.star, color: colorStar, size: 30),
                    const SizedBox(width: 5),
                    Text(
                      '$_maxScore',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(color: colorDark, fontSize: 30),
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
              onPressed: () => _goToGame(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'NEW GAME',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _hasSavedGame ? () => _goToGame(context, false) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('CONTINUE GAME',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),
          const Spacer(),

        ],
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkSavedGame();
    _loadMaxScore();
  }
}

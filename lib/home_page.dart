import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_page.dart';
import 'settings_page.dart';
import 'game/settings.dart';

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
      _hasSavedGame = prefs.containsKey('field_index_0');
    });
  }

  void _startNewGame(BuildContext context) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(
          title: _title,
          buttonSize: 15.0,
          buttonsPerRow: 9,
          initialButtonCount: 36,
          maxScore: _maxScore,
          settings: widget.settings,
          mode: true,
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
        builder: (context) => GamePage(
          title: _title,
          buttonSize: 15.0,
          buttonsPerRow: 9,
          initialButtonCount: 36,
          maxScore: _maxScore,
          settings: widget.settings,
          mode: false,
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
    Color colorLight = Theme.of(context).colorScheme.surface;
    Color colorStar =  Colors.amberAccent;

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
                  builder: (context) => SettingsPage(settings:widget.settings),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
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
                  mainAxisSize: MainAxisSize.min, // Чтобы Row занял только необходимую ширину
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
          const SizedBox(height: 60),
          Center(
            child: ElevatedButton(
              onPressed: () => _startNewGame(context),
              child: const Text( 'NEW GAME', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, ),),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
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
              child: const Text('CONTINUE GAME', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, )),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
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
    _loadMaxScore();
  }
}

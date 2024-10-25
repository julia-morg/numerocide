import 'package:flutter/material.dart';
import 'package:numerocide/components/dialog_action.dart';
import 'package:numerocide/pages/tutorial_page.dart';
import '../components/popup_dialog.dart';
import 'game_page.dart';
import 'settings_page.dart';
import '../game/settings.dart';
import '../game/save.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final Settings settings;
  const HomePage({super.key, required this.settings});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _maxScore = 0;
  bool _hasSavedGame = false;
  bool _isTutorialPassed = false;
  String _title = 'Numerocide';
  Save save = Save();

  @override
  void initState() {
    super.initState();
    _loadMaxScore();
    _checkSavedGame();
    _checkTutorial();
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

  Future<void> _checkTutorial() async {
    save.isTutorialPassed().then((value) {
      setState(() {
        _isTutorialPassed = value;
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

  void _goToTutorial(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialPage(
          settings: widget.settings,
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
    Color inactiveColor = Theme.of(context).colorScheme.onSecondary;
    _title = AppLocalizations.of(context)!.appTitle;
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
                Text(AppLocalizations.of(context)!.homePageBestResult,),
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
              child: Text(AppLocalizations.of(context)!.homePageNewGame, style: largeTextStyle,),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ElevatedButton(
              onPressed: _hasSavedGame ? () => _goToGame(context, GamePage.modeLoadGame) : null,
              child: Text(AppLocalizations.of(context)!.homePageContinueGame,
                  style: largeTextStyle.copyWith(color: _hasSavedGame ? null : inactiveColor)),
            ),
          ),
          const Spacer(),

        ],
      ),
    );
  }

  void _onNewGamePressed(BuildContext context) {

    if(!_isTutorialPassed){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopupDialog(
            title: AppLocalizations.of(context)!.suggestTutorialPopupTitle,
            content: AppLocalizations.of(context)!.suggestTutorialPopupText,
            actions: [
              DialogAction(
                text: AppLocalizations.of(context)!.suggestTutorialPopupCancel,
                onPressed: () {
                  Navigator.of(context).pop();
                  _goToGame(context, GamePage.modeNewGame);
                  _showSnackBar();
                  _isTutorialPassed = true;
                  save.saveTutorialPassed();
                },
              ),
              DialogAction(
                text: AppLocalizations.of(context)!.suggestTutorialPopupConfirm,
                onPressed: () {
                  Navigator.of(context).pop();
                  _goToTutorial(context);
                  _showSnackBar();
                  _isTutorialPassed = true;
                  save.saveTutorialPassed();
                },
              ),
            ],
          );
        },
      );
    }
    else if (_hasSavedGame) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return PopupDialog(
            title: AppLocalizations.of(context)!.homePageSavedGamePopupTitle,
            content: AppLocalizations.of(context)!.homePageSavedGamePopupText,
            actions: [
              DialogAction(
                text: AppLocalizations.of(context)!.homePageSavedGamePopupCancel,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              DialogAction(
                text: AppLocalizations.of(context)!.homePageSavedGamePopupConfirm,
                onPressed: () {
                  Navigator.of(context).pop();
                  _goToGame(context, GamePage.modeNewGame);
                },
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

  void _showSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        content: Text(AppLocalizations.of(context)!.suggestTutorialPopupOnCancel),
      ),
    );
  }

}

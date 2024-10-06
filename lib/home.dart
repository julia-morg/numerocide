import 'package:flutter/material.dart';
import 'game.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
        child: ElevatedButton(
          onPressed: () {
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
            );
          },
          child: const Text('Start new game'),
        ),
      ),
    );
  }
}

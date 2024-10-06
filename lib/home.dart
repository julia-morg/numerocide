import 'package:flutter/material.dart';
import 'game.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Numbers Game'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Пример использования
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MyHomePage(
                  title: 'Numbers',
                  buttonSize: 15.0,
                  totalRowsInView: 20,
                  buttonsPerRow: 10,
                  initialButtonCount: 40,
                ),
              ),
            );
          },
          child: const Text('Start Game'),
        ),
      ),
    );
  }
}

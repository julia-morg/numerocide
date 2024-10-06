import 'package:flutter/material.dart';
import 'game.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Numerocide'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Пример использования
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

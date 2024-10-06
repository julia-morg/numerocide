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
            // Переход на страницу игры
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Numbers')),
            );
          },
          child: const Text('Start Game'),
        ),
      ),
    );
  }
}
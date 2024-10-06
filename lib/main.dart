// main.dart
import 'package:flutter/material.dart';
import 'home.dart';

void main() {
  runApp(const MyApp());
}

const int windowWidth = 300;
const int windowHeight = 600;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers Game',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const HomePage(),
      builder: (context, child) {
        return Center(
          child: SizedBox(
            width: windowWidth.toDouble(),
            height: windowHeight.toDouble(),
            child: child,
          ),
        );
      },
    );
  }
}

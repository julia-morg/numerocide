import 'package:flutter/material.dart';
import 'dart:math';

const int numberOfButtons = 40;
const int buttonsPerRow = 10;
const int numberOfRows = 4;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Numbers',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Numbers'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  int _score = 0;

  void _scoreCounter() {
    setState(() {
      _score += 10;
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Rows added: $_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              'Score: $_score',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            ButtonList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'add',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


class ButtonList extends StatefulWidget {
  @override
  _ButtonListState createState() => _ButtonListState();
}

class _ButtonListState extends State<ButtonList> {
  List<List<int>> randomNumbers = List.generate(
    numberOfRows,
        (_) => List.generate(buttonsPerRow, (_) => Random().nextInt(10)),
  );

  void _scoreCounter() {
    // Логика при нажатии
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(numberOfRows, (rowIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(buttonsPerRow, (buttonIndex) {
            return FloatingActionButton(
              onPressed: _scoreCounter,
              child: Text('${randomNumbers[rowIndex][buttonIndex]}'),
            );
          }),
        );
      }),
    );
  }
}
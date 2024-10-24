import 'package:flutter/material.dart';

class TextPlate extends StatelessWidget {
  final String centeredText;
  final String justifiedText;

  const TextPlate({
    super.key,
    required this.centeredText,
    required this.justifiedText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            centeredText,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          Text(
            justifiedText,
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }
}
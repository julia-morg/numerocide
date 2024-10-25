import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'dialog_action.dart';

class PopupDialog extends StatefulWidget {
  final String? title;
  final String content;
  final String? note;
  final List<DialogAction> actions;
  final bool hasConfetti;

  const PopupDialog({
    super.key,
    this.title,
    required this.content,
    this.note,
    required this.actions,
    this.hasConfetti = false,
  });

  @override
  State<PopupDialog> createState() => _PopupDialogState();
}

class _PopupDialogState extends State<PopupDialog> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 5));
    if(widget.hasConfetti){
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AlertDialog(
          title: widget.title != null
              ? Text(
            widget.title!,
            style: Theme.of(context).textTheme.titleSmall!,
            textAlign: TextAlign.center,
          )
              : null,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.content,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.justify,
              ),
              if (widget.note != null) ...[
                Text(
                  widget.note!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.justify,
                ),
              ],
            ],
          ),
          actions: widget.actions.map((action) {
            return ElevatedButton(
              onPressed: action.onPressed,
              style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 10)),
              ),
              child: Text(action.text.toUpperCase()),
            );
          }).toList(),
        ),
        Align(
          alignment: Alignment.center,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [Colors.red, Colors.green, Colors.blue, Colors.orange, Colors.purple],
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';
import 'dialog_action.dart';

class PopupDialog extends StatelessWidget {
  final String? title;
  final String content;
  final String? note;
  final List<DialogAction> actions;

  const PopupDialog({
    super.key,
    this.title,
    required this.content,
    this.note,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null
          ? Text(
        title!,
        style: Theme.of(context).textTheme.titleSmall!,
        textAlign: TextAlign.center,
      )
          : null,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            content,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (note != null) ...[
            Text(
              note!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: actions.map((action) {
        return ElevatedButton(
          onPressed: action.onPressed,
          child: Text(action.text.toUpperCase()),
        );
      }).toList(),
    );
  }
}
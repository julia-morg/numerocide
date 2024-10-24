import 'package:flutter/material.dart';

class DialogAction {
  final String text;
  final VoidCallback onPressed;

  DialogAction({
    required this.text,
    required this.onPressed,
  });
}
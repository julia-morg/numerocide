import 'settings.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

class Vibro {
  const Vibro({
    required this.settings,
  });

  final Settings settings;

  void vibrateLight() {
    if (settings.vibro && Vibration.hasVibrator() != null) {
      HapticFeedback.lightImpact();
    }
  }
  void vibrateMedium() {
    if (settings.vibro && Vibration.hasVibrator() != null) {
      HapticFeedback.mediumImpact();
    }
  }
  void vibrateHeavy() {
    if (settings.vibro && Vibration.hasVibrator() != null) {
      HapticFeedback.vibrate();
    }
  }
}

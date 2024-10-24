import '../game/settings.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

class Vibro {
  Vibro({
    required this.settings,
  }) {
    _initVibration();
  }

  final Settings settings;
  bool hasVibrator = false;

  Future<void> _initVibration() async {
    final bool? result = await Vibration.hasVibrator();
    hasVibrator = result ?? false;
  }

  void vibrateLight() {
    if (hasVibrator && settings.vibro ) {
      HapticFeedback.lightImpact();
    }
  }
  void vibrateMedium() {
    if (hasVibrator && settings.vibro) {
      HapticFeedback.mediumImpact();
    }
  }
  void vibrateHeavy() {
    if (hasVibrator && settings.vibro) {
      HapticFeedback.vibrate();
    }
  }
}

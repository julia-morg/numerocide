import '../game/settings.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/services.dart';

class HapticFeedbackWrapper {
  void lightImpact() {
    HapticFeedback.lightImpact();
  }

  void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  void vibrate() {
    HapticFeedback.vibrate();
  }
}

class Vibro {
  Vibro({
    required this.settings,
    HapticFeedbackWrapper? hapticFeedback,
  }) : _hapticFeedback = hapticFeedback ?? HapticFeedbackWrapper() {
    _initVibration();
  }

  final Settings settings;
  final HapticFeedbackWrapper _hapticFeedback;
  bool hasVibrator = false;

  Future<void> _initVibration() async {
    final bool? result = await Vibration.hasVibrator();
    hasVibrator = result ?? false;
  }

  void vibrateLight() {
    if (hasVibrator && settings.vibro ) {
      _hapticFeedback.lightImpact();
    }
  }

  void vibrateMedium() {
    if (hasVibrator && settings.vibro) {
      _hapticFeedback.mediumImpact();
    }
  }

  void vibrateHeavy() {
    if (hasVibrator && settings.vibro) {
      _hapticFeedback.vibrate();
    }
  }
}

import 'package:audioplayers/audioplayers.dart';
import 'package:volume_control/volume_control.dart';
import 'package:flutter/material.dart';
import '../game/settings.dart';

class Sounds {
  const Sounds({
    required this.settings,
  });

  final Settings settings;
  static const String soundTap = 'tap.aiff';
  static const String soundRemoveRow = 'remove_row.mp3';
  static const String soundRemoveNumbers = 'remove_numbers.mp3';
  static const String soundNoHints = 'no_hints.mp3';
  static const String soundHint = 'hint.wav';
  static const String soundGameOverWin = 'gameover-victory.flac';
  static const String soundGameOverLose = 'gameover-lose.mp3';
  static const String soundDeskCleared = 'desk_cleared.wav';
  static const String soundAddRow = 'add_rows.mp3';

  static final player = AudioPlayer();

  void playTapSound() async {
    _playSound(soundTap);
  }

  void playRemoveRowSound() async {
    _playSound(soundRemoveRow);
  }

  void playRemoveNumbersSound() async {
    _playSound(soundRemoveNumbers);
  }

  void playNoHintsSound() async {
    _playSound(soundNoHints);
  }

  void playGameOverWinSound() async {
    _playSound(soundGameOverWin);
  }

  void playHintSound() async {
    _playSound(soundHint);
  }

  void playGameOverLoseSound() async {
    _playSound(soundGameOverLose);
  }

  void playDeskClearedSound() async {
    _playSound(soundDeskCleared);
  }

  void playAddRowSound() async {
    _playSound(soundAddRow);
  }

  void _playSound(String filename) async {
    if (!settings.sound) {
      return;
    }
    await player.stop();
    double deviceVolume = await VolumeControl.volume;
    debugPrint(filename);
    player.play(
      AssetSource('sounds/$filename'),
      volume: deviceVolume,
    );
  }
}

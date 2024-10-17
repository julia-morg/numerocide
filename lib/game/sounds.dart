import 'package:audioplayers/audioplayers.dart';
import 'package:volume_control/volume_control.dart';
import 'package:flutter/material.dart';
import 'settings.dart';

class Sounds {
  const Sounds({
    required this.settings,
  });

  final Settings settings;
  static const String sound_tap = 'tap.aiff';
  static const String sound_remove_row = 'remove_row.mp3';
  static const String sound_remove_numbers = 'remove_numbers.mp3';
  static const String sound_no_hints = 'no_hints.mp3';
  static const String sound_hint = 'hint.wav';
  static const String sound_gameover_win = 'gameover-victory.flac';
  static const String sound_gameover_lose = 'gameover-lose.mp3';
  static const String sound_desk_cleared = 'desk_cleared.wav';
  static const String sound_add_row = 'add_rows.mp3';

  static final player = AudioPlayer();

  void playTapSound() async {
    _playSound(sound_tap);
  }

  void playRemoveRowSound() async {
    _playSound(sound_remove_row);
  }

  void playRemoveNumbersSound() async {
    _playSound(sound_remove_numbers);
  }

  void playNoHintsSound() async {
    _playSound(sound_no_hints);
  }

  void playGameOverWinSound() async {
    _playSound(sound_gameover_win);
  }

  void playHintSound() async {
    _playSound(sound_hint);
  }

  void playGameOverLoseSound() async {
    _playSound(sound_gameover_lose);
  }

  void playDeskClearedSound() async {
    _playSound(sound_desk_cleared);
  }

  void playAddRowSound() async {
    _playSound(sound_add_row);
  }

  void _playSound(String filename) async {
    if (!settings.sound) {
      return;
    }
    await player.stop();
    double deviceVolume = await VolumeControl.volume;
    debugPrint(filename);
    player.play(
      AssetSource('sounds/${filename}'),
      volume: deviceVolume,
    );
  }
}

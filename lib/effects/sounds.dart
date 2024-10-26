import 'package:audioplayers/audioplayers.dart';
import 'package:volume_control/volume_control.dart';
import '../game/settings.dart';

class Sounds {
  Sounds({
    required this.settings,
    AudioPlayer? player,
  }) : _player = player ?? AudioPlayer();

  final Settings settings;
  final AudioPlayer _player;

  static const String soundTap = 'tap.aiff';
  static const String soundRemoveRow = 'remove_row.mp3';
  static const String soundRemoveNumbers = 'remove_numbers.mp3';
  static const String soundNoHints = 'no_hints.mp3';
  static const String soundHint = 'hint.wav';
  static const String soundGameOverWin = 'gameover-victory.flac';
  static const String soundGameOverLose = 'gameover-lose.mp3';
  static const String soundDeskCleared = 'desk_cleared.wav';
  static const String soundAddRow = 'add_rows.mp3';

  Future<void> playTapSound() async {
    await _playSound(soundTap);
  }

  Future<void> playRemoveRowSound() async {
    await _playSound(soundRemoveRow);
  }

  Future<void> playRemoveNumbersSound() async {
    await _playSound(soundRemoveNumbers);
  }

  Future<void> playNoHintsSound() async {
    await _playSound(soundNoHints);
  }

  Future<void> playGameOverWinSound() async {
    await _playSound(soundGameOverWin);
  }

  Future<void> playHintSound() async {
    await _playSound(soundHint);
  }

  Future<void> playGameOverLoseSound() async {
    await _playSound(soundGameOverLose);
  }

  Future<void> playDeskClearedSound() async {
    await _playSound(soundDeskCleared);
  }

  Future<void> playAddRowSound() async {
    await _playSound(soundAddRow);
  }

  Future<void> _playSound(String filename) async {
    if (!settings.sound) {
      return;
    }
    await _player.stop();
    double deviceVolume = await VolumeControl.volume;
    await _player.play(
      AssetSource('sounds/$filename'),
      volume: deviceVolume,
    );
  }
}
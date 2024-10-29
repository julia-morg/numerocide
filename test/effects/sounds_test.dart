import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:numerocide/effects/sounds.dart';
import 'package:numerocide/game/settings.dart';

class MockAudioPlayer extends Mock implements AudioPlayer {}
class MockSettings extends Mock implements Settings {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const MethodChannel volumeControlChannel = MethodChannel('volume_control');
  late MockAudioPlayer mockPlayer;
  late MockSettings mockSettings;
  late Sounds sounds;

  setUpAll(() {
    registerFallbackValue(AssetSource(''));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(volumeControlChannel, (MethodCall methodCall) async {
      if (methodCall.method == 'getVolume') {
        return 0.5;
      }
      return null;
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(volumeControlChannel, null);
  });

  setUp(() {
    mockPlayer = MockAudioPlayer();
    mockSettings = MockSettings();
    sounds = Sounds(settings: mockSettings, player: mockPlayer);

    when(() => mockPlayer.stop()).thenAnswer((_) async {});
    when(() => mockPlayer.play(any(), volume: any(named: 'volume'))).thenAnswer((_) async {});
  });

  test('playTapSound calls play with correct sound if sound is enabled', () async {
    when(() => mockSettings.sound).thenReturn(true);
    sounds.playTapSound();
    await Future.delayed(const Duration(milliseconds: 30));
    verify(() => mockPlayer.stop()).called(1);
    final captured = verify(() => mockPlayer.play(captureAny(), volume: 0.5)).captured;
    expect((captured.first as AssetSource).path, equals('sounds/tap.aiff'));
  });


  test('playTapSound does not play sound if sound is disabled', () {
    when(() => mockSettings.sound).thenReturn(false);
    sounds.playTapSound();
    verifyNever(() => mockPlayer.play(any(), volume: any(named: 'volume')));
  });

  test('playRemoveRowSound calls play with correct sound and volume', () async {
    when(() => mockSettings.sound).thenReturn(true);
    sounds.playRemoveRowSound();
    await Future.delayed(const Duration(milliseconds: 30));
    verify(() => mockPlayer.stop()).called(1);
    final captured = verify(() => mockPlayer.play(captureAny(), volume: 0.5)).captured;
    expect((captured.first as AssetSource).path, equals('sounds/remove_row.mp3'));
  });

  test('playRemoveNumbersSound calls play with correct sound if sound is enabled', () async {
    when(() => mockSettings.sound).thenReturn(true);
    sounds.playRemoveNumbersSound();
    await Future.delayed(const Duration(milliseconds: 30));
    verify(() => mockPlayer.stop()).called(1);
    final captured = verify(() => mockPlayer.play(captureAny(), volume: 0.5)).captured;
    expect((captured.first as AssetSource).path, equals('sounds/${Sounds.soundRemoveNumbers}'));
  });

  test('playNoHintsSound calls play with correct sound if sound is enabled', () async {
    when(() => mockSettings.sound).thenReturn(true);
    sounds.playNoHintsSound();
    await Future.delayed(const Duration(milliseconds: 30));
    verify(() => mockPlayer.stop()).called(1);
    final captured = verify(() => mockPlayer.play(captureAny(), volume: 0.5)).captured;
    expect((captured.first as AssetSource).path, equals('sounds/${Sounds.soundNoHints}'));
  });

  test('playGameOverWinSound calls play with correct sound if sound is enabled', () async {
    when(() => mockSettings.sound).thenReturn(true);
    sounds.playGameOverWinSound();
    await Future.delayed(const Duration(milliseconds: 30));
    verify(() => mockPlayer.stop()).called(1);
    final captured = verify(() => mockPlayer.play(captureAny(), volume: 0.5)).captured;
    expect((captured.first as AssetSource).path, equals('sounds/gameover-victory.flac'));
  });
  test('playHintSound calls play with correct sound if sound is enabled', () async {
    when(() => mockSettings.sound).thenReturn(true);
    sounds.playHintSound();
    await Future.delayed(const Duration(milliseconds: 30));
    verify(() => mockPlayer.stop()).called(1);
    final captured = verify(() => mockPlayer.play(captureAny(), volume: 0.5)).captured;
    expect((captured.first as AssetSource).path, equals('sounds/${Sounds.soundHint}'));
  });
  test('playGameOverLoseSound calls play with correct sound if sound is enabled', () async {
    when(() => mockSettings.sound).thenReturn(true);
    sounds.playGameOverLoseSound();
    await Future.delayed(const Duration(milliseconds: 30));
    verify(() => mockPlayer.stop()).called(1);
    final captured = verify(() => mockPlayer.play(captureAny(), volume: 0.5)).captured;
    expect((captured.first as AssetSource).path, equals('sounds/gameover-lose.mp3'));
  });
  test('playDeskClearedSound calls play with correct sound if sound is enabled', () async {
    when(() => mockSettings.sound).thenReturn(true);
    sounds.playDeskClearedSound();
    await Future.delayed(const Duration(milliseconds: 30));
    verify(() => mockPlayer.stop()).called(1);
    final captured = verify(() => mockPlayer.play(captureAny(), volume: 0.5)).captured;
    expect((captured.first as AssetSource).path, equals('sounds/desk_cleared.wav'));
  });
}
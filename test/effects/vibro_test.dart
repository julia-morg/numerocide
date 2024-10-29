import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:numerocide/effects/vibro.dart';
import 'package:numerocide/game/settings.dart';

class MockSettings extends Mock implements Settings {}
class MockHapticFeedbackWrapper extends Mock implements HapticFeedbackWrapper {}


void main() {
  late MockSettings mockSettings;
  late MockHapticFeedbackWrapper mockHapticFeedback;
  late Vibro vibro;

  setUp(() {
    mockSettings = MockSettings();
    mockHapticFeedback = MockHapticFeedbackWrapper();
    vibro = Vibro(settings: mockSettings, hapticFeedback: mockHapticFeedback);

    vibro.hasVibrator = true;

    when(() => mockSettings.vibro).thenReturn(true);
  });

  test('vibrateLight calls HapticFeedbackWrapper.lightImpact if hasVibrator is true and vibro setting is enabled', () {
    vibro.hasVibrator = true;
    vibro.vibrateLight();

    verify(() => mockHapticFeedback.lightImpact()).called(1);
  });

  test('vibrateLight does not call HapticFeedbackWrapper.lightImpact if hasVibrator is false', () {
    vibro.hasVibrator = false;

    vibro.vibrateLight();

    verifyNever(() => mockHapticFeedback.lightImpact());
  });

  test('vibrateMedium calls HapticFeedbackWrapper.mediumImpact if hasVibrator is true and vibro setting is enabled', () {
    vibro.hasVibrator = true;
    vibro.vibrateMedium();
    verify(() => mockHapticFeedback.mediumImpact()).called(1);
  });

  test('vibrateMedium does not call HapticFeedbackWrapper.mediumImpact if hasVibrator is false', () {
    vibro.hasVibrator = false;

    vibro.vibrateMedium();

    verifyNever(() => mockHapticFeedback.mediumImpact());
  });

  test('vibrateHeavy calls HapticFeedbackWrapper.vibrate if hasVibrator is true and vibro setting is enabled', () {
    vibro.hasVibrator = true;
    vibro.vibrateHeavy();
    verify(() => mockHapticFeedback.vibrate()).called(1);
  });

  test('vibrateHeavy does not call HapticFeedbackWrapper.vibrate if hasVibrator is false', () {
    vibro.hasVibrator = false;

    vibro.vibrateHeavy();

    verifyNever(() => mockHapticFeedback.vibrate());
  });

  test('vibrateLight does not call HapticFeedbackWrapper.lightImpact if vibro setting is disabled', () {
    when(() => mockSettings.vibro).thenReturn(false);

    vibro.vibrateLight();

    verifyNever(() => mockHapticFeedback.lightImpact());
  });

  test('vibrateMedium does not call HapticFeedbackWrapper.mediumImpact if vibro setting is disabled', () {
    when(() => mockSettings.vibro).thenReturn(false);

    vibro.vibrateMedium();

    verifyNever(() => mockHapticFeedback.mediumImpact());
  });

  test('vibrateHeavy does not call HapticFeedbackWrapper.vibrate if vibro setting is disabled', () {
    when(() => mockSettings.vibro).thenReturn(false);
    vibro.hasVibrator = false;
    vibro.vibrateHeavy();

    verifyNever(() => mockHapticFeedback.vibrate());
  });

}
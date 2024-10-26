import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/components/themes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Settings class tests', () {
    late Settings settings;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      settings = Settings(sound: true, vibro: false, theme: Themes.navy, language: 'en');
    });

    test('should save and load settings', () async {
      await settings.saveSettings();

      Settings loadedSettings = await Settings.loadSettings();
      expect(loadedSettings.sound, true);
      expect(loadedSettings.vibro, false);
      expect(loadedSettings.theme, Themes.navy);
      expect(loadedSettings.language, 'en');
    });

    test('should load default settings if none are saved', () async {
      Settings defaultSettings = await Settings.loadSettings();
      expect(defaultSettings.sound, false);
      expect(defaultSettings.vibro, true);
      expect(defaultSettings.theme, Themes.navy);
      expect(defaultSettings.language, 'en');
    });

    test('should overwrite existing settings', () async {
      await settings.saveSettings();

      Settings newSettings = Settings(sound: false, vibro: true, theme: Themes.brown, language: 'fr');
      await newSettings.saveSettings();

      Settings loadedSettings = await Settings.loadSettings();
      expect(loadedSettings.sound, false);
      expect(loadedSettings.vibro, true);
      expect(loadedSettings.theme, Themes.brown);
      expect(loadedSettings.language, 'fr');
    });
  });
}
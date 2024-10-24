import 'package:numerocide/components/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings {
  bool sound;
  bool vibro;
  String theme;
  String language;
  Settings({required this.sound, required this.vibro, required this.theme, required this.language});

  Future<void> saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings_sound', sound);
    await prefs.setBool('settings_vibro', vibro);
    await prefs.setString('settings_theme', theme);
    await prefs.setString('settings_language', language);
  }

  static Future<Settings> loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool sound = prefs.getBool('settings_sound') ?? false;
    bool vibro = prefs.getBool('settings_vibro') ?? true;
    String theme = prefs.getString('settings_theme') ?? Themes.navy;
    String language = prefs.getString('settings_language') ?? 'en';

    return Settings(sound: sound, vibro: vibro, theme: theme, language: language);
  }

}
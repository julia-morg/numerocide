import 'package:flutter/material.dart';
import 'game/settings.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Settings settings;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    settings = await Settings.loadSettings();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.onSecondary;
    TextStyle labelStyle = TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );
    TextStyle themeLabelStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.primary,
    );

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        titleTextStyle: TextStyle(
          color: colorLight,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: colorDark,
        iconTheme: IconThemeData(
          color: colorLight,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sound настройки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Sound', style: labelStyle),
                Switch(
                  value: settings.sound,
                  onChanged: (bool value) {
                    setState(() {
                      settings.sound = value;
                    });
                    settings.saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Vibration настройки
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Vibration', style: labelStyle),
                Switch(
                  value: settings.vibro,
                  onChanged: (bool value) {
                    setState(() {
                      settings.vibro = value;
                    });
                    settings.saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Theme', style: labelStyle),
            Column(
              children: Settings.availableThemes().map((themeName) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      settings.theme = themeName;
                    });
                    settings.saveSettings();
                    // Применяем тему
                    MyApp.of(context)?.updateTheme(Settings.getThemeData(settings.theme));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: settings.theme == themeName
                          ? Colors.grey[300]
                          : Colors.transparent, // Подсвечиваем выбранную тему
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              Settings.themeDisplayName(themeName),
                              style: themeLabelStyle,
                            ),
                          ),
                        ),
                        Row(
                          children: Settings.getThemeColors(themeName).map((color) {
                            return Container(
                              width: 20,
                              height: 20,
                              color: color,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'game/settings.dart';
import 'main.dart';

class SettingsPage extends StatefulWidget {
  Settings settings;
  SettingsPage({Key? key,  required this.settings}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    Color colorLight = Theme.of(context).colorScheme.surface;
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        iconTheme: IconThemeData(
          color: colorLight,
          size: 40.0,
        ),
        titleTextStyle: TextStyle(
          color: colorLight,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: colorDark,
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
                  value: widget.settings.sound,
                  onChanged: (bool value) {
                    setState(() {
                      widget.settings.sound = value;
                    });
                    widget.settings.saveSettings();
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
                  value: widget.settings.vibro,
                  onChanged: (bool value) {
                    setState(() {
                      widget.settings.vibro = value;
                    });
                    widget.settings.saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Theme', style: labelStyle),
            Column(
              children: Settings.allThemes.map((themeName) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.settings.theme = themeName;
                    });
                    widget.settings.saveSettings();
                    // Применяем тему
                    MyApp.of(context)?.updateTheme(Settings.getThemeData(widget.settings.theme));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.settings.theme == themeName
                          ? Theme.of(context).colorScheme.secondaryContainer
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
                              width: 30,
                              height: 30,
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
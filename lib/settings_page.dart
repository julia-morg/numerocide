import 'package:flutter/material.dart';
import 'game/settings.dart';

class SettingsPage extends StatefulWidget {
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
    TextStyle labelStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Theme',
                    style: labelStyle
                ),
                const SizedBox(height: 10),
                Column(
                  children: Settings.availableThemes().map((theme) {
                    return RadioListTile<String>(
                      title: Text(Settings.themeDisplayName(theme)),
                      value: theme,
                      groupValue: settings.theme,
                      onChanged: (String? value) {
                        setState(() {
                          settings.theme = value!;
                        });
                        settings.saveSettings();
                      },
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  }).toList(),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
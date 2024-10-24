import 'package:flutter/material.dart';
import 'package:numerocide/pages/tutorial_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'donate_page.dart';
import '../game/settings.dart';
import '../main.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;

  const SettingsPage({super.key, required this.settings});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color colorDark = Theme.of(context).colorScheme.primary;
    TextStyle labelStyle = Theme.of(context).textTheme.titleSmall!;
    TextStyle themeLabelStyle = Theme.of(context).textTheme.displaySmall!;
    TextStyle linkStyle = Theme.of(context).textTheme.displaySmall!.copyWith(
          decoration: TextDecoration.underline,
          decorationColor: Theme.of(context).colorScheme.primary,
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  widget.settings.sound = !widget.settings.sound;
                });
                widget.settings.saveSettings();
              },
              child: Row(
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
            ),
            const SizedBox(height: 8),
            Divider(color: Theme.of(context).colorScheme.primary,),
            InkWell(
              onTap: () {
                setState(() {
                  widget.settings.vibro = !widget.settings.vibro;
                });
                widget.settings.saveSettings();
              },
              child: Row(
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
            ),
            const SizedBox(height: 8),
            const Divider(),
            Text('Theme', style: labelStyle),
            Column(
              children: Settings.allThemes.map((themeName) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      widget.settings.theme = themeName;
                    });
                    widget.settings.saveSettings();
                    MyApp.updateTheme(context,
                        Settings.getThemeData(widget.settings.theme));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: widget.settings.theme == themeName
                          ? Theme.of(context).colorScheme.secondaryContainer
                          : Colors.transparent,
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
                          children:
                              Settings.getThemeColors(themeName).map((color) {
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
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 8),
            Text('Info', style: labelStyle),
            InkWell(
              onTap: _showTutorial,
              splashColor: Theme.of(context).splashColor,
              highlightColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'How to play',
                      style: labelStyle,
                    ),
                    Icon(Icons.arrow_forward, color: colorDark,),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonatePage(
                      settings: widget.settings,
                    ),
                  ),
                );
              },
              splashColor: Theme.of(context).splashColor,
              highlightColor: Colors.transparent,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Donate',
                      style: labelStyle,
                    ),
                    Icon(Icons.arrow_forward, color: colorDark),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Uri url = Uri(scheme: 'https', host: 'julia_morg.tilda.ws', path: 'privacy_policy');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Privacy Policy',
                      style: linkStyle,
                    ),
                  ],
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Uri url = Uri(scheme: 'https', host: 'julia_morg.tilda.ws', path: 'terms_of_service');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terms of Service',
                      style: linkStyle,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showTutorial() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorialPage(
          settings: widget.settings,
        ),
      ),
    );
  }
}

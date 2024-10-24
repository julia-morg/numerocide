import 'package:flutter/material.dart';
import 'package:numerocide/components/themes.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ThemeTile extends StatefulWidget {
  final Settings settings;

  const ThemeTile({
    super.key,
    required this.settings,
  });

  @override
  State<ThemeTile> createState() => _ThemeTileState();
}

class _ThemeTileState extends State<ThemeTile> {
  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = Theme.of(context).textTheme.titleSmall!;
    TextStyle themeLabelStyle = Theme.of(context).textTheme.displaySmall!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.settingsPageTheme,
          style: labelStyle,
        ),
        const SizedBox(height: 10),
        Column(
          children: Themes.allThemes.map((themeName) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  widget.settings.theme = themeName;
                });
                widget.settings.saveSettings();
                MyApp.updateTheme(
                    context, Themes.getThemeData(widget.settings.theme));
              },
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: widget.settings.theme == themeName
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Colors.transparent,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        Themes.themeDisplayName(themeName),
                        style: themeLabelStyle,
                      ),
                    ),
                    Row(
                      children: Themes.getThemeColors(themeName).map((color) {
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
    );
  }
}
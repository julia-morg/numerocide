import 'package:flutter/material.dart';
import 'package:numerocide/game/settings.dart';

class SettingsSwitchTile extends StatefulWidget {
  final String label;
  final Settings settings;
  final bool Function(Settings) getValue;
  final void Function(Settings, bool) setValue;

  const SettingsSwitchTile({
    super.key,
    required this.label,
    required this.settings,
    required this.getValue,
    required this.setValue,
  });

  @override
  State<SettingsSwitchTile> createState() => _SettingsSwitchTileState();
}

class _SettingsSwitchTileState extends State<SettingsSwitchTile> {
  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = Theme.of(context).textTheme.titleSmall!;
    return InkWell(
      onTap: () {
        setState(() {
          bool newValue = !widget.getValue(widget.settings);
          widget.setValue(widget.settings, newValue);
          widget.settings.saveSettings();
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.label,
            style: labelStyle,
          ),
          Switch(
            value: widget.getValue(widget.settings),
            onChanged: (bool value) {
              setState(() {
                widget.setValue(widget.settings, value);
                widget.settings.saveSettings();
              });
            },
          ),
        ],
      ),
    );
  }
}
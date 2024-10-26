import 'package:flutter/material.dart';
import 'package:numerocide/game/settings.dart';
import 'package:numerocide/pages/settings_page.dart';

import '../game/save.dart';

class DefaultScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final List<Widget>? actions;
  final Settings settings;
  final Save save;
  final Widget? floatingActionButton;

  const DefaultScaffold({
    super.key,
    required this.body,
    required this.title,
    required this.settings,
    this.actions,
    this.floatingActionButton,
    required this.save,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsPage(
                    settings: settings,
                    save: save,
                  ),
                ),
              );
            },
          ),
          if (actions != null) ...actions!,
        ],
      ),
      body: body,
        floatingActionButton: floatingActionButton
    );
  }
}

import 'package:flutter/material.dart';
import 'package:numerocide/components/settings/language_tile.dart';
import 'package:numerocide/components/settings/theme_tile.dart';
import 'package:numerocide/pages/tutorial_page.dart';
import '../components/settings/goto_page_tile.dart';
import '../components/settings/link_tile.dart';
import '../components/settings/setting_switch_tile.dart';
import '../game/save.dart';
import 'donate_page.dart';
import '../game/settings.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final Settings settings;
  final Save save;

  const SettingsPage({super.key, required this.settings, required this.save});

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
    TextStyle labelStyle = Theme.of(context).textTheme.titleSmall!;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settingsPageHeader),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSwitchTile(
                label: AppLocalizations.of(context)!.settingsPageSound,
                settings: widget.settings,
                getValue: (settings) => settings.sound,
                setValue: (settings, value) => settings.sound = value,
              ),
              Divider(
                color: Theme.of(context).colorScheme.primary,
              ),
              SettingsSwitchTile(
                label: AppLocalizations.of(context)!.settingsPageVibro,
                settings: widget.settings,
                getValue: (settings) => settings.vibro,
                setValue: (settings, value) => settings.vibro = value,
              ),
              const Divider(),
              ThemeTile(settings: widget.settings),
              const Divider(),
              LanguageTile(
                  title: AppLocalizations.of(context)!.settingsPageLang,
                  settings: widget.settings),
              const Divider(),
              Text(AppLocalizations.of(context)!.settingsPageInfo,
                  style: labelStyle),
              GotoPageTile(
                title: AppLocalizations.of(context)!.tutorialPageHeader,
                nextPage: TutorialPage(
                  settings: widget.settings,
                  save: widget.save,
                ),
              ),
              GotoPageTile(
                title: AppLocalizations.of(context)!.donatePageHeader,
                nextPage: DonatePage(
                  settings: widget.settings,
                  save: widget.save,
                ),
              ),
              LinkTile(
                title: AppLocalizations.of(context)!.settingsPagePrivacyPolicy,
                webPagePath: 'privacy_policy',
              ),
              LinkTile(
                title: AppLocalizations.of(context)!.settingsPageTermsOfService,
                webPagePath: 'terms_of_service',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

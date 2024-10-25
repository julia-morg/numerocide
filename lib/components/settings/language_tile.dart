import 'package:flutter/material.dart';
import '../../game/settings.dart';
import '../../main.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LanguageTile extends StatefulWidget {
  final Settings settings;
  final String title;

  const LanguageTile({super.key, required this.title, required this.settings});

  @override
  State<LanguageTile> createState() => _LanguageTileState();
}

class _LanguageTileState extends State<LanguageTile> {
  late String _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.settings.language;
  }

  @override
  Widget build(BuildContext context) {
    TextStyle labelStyle = Theme.of(context).textTheme.titleSmall!;
    TextStyle langOptionStyle = Theme.of(context).textTheme.displaySmall!;

    List<DropdownMenuItem<String>> languageItems =
        AppLocalizations.supportedLocales
            .map((locale) => DropdownMenuItem(
                  value: locale.languageCode,
                  child: Text(_getLanguageName(locale.languageCode, context)),
                ))
            .toList();
    String selectedLanguage = AppLocalizations.supportedLocales.any((locale) => locale.languageCode == widget.settings.language) ? widget.settings.language : 'en';
    return  Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.title, style: labelStyle),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: DropdownButton<String>(
              value: selectedLanguage,
              icon: Icon(Icons.arrow_drop_down,
                  color: Theme.of(context).colorScheme.primary),
              style: langOptionStyle,
              items: languageItems,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLanguage = newValue!;
                  widget.settings.language = _selectedLanguage;
                  widget.settings.saveSettings();
                  MyApp.setLocale(context, Locale(_selectedLanguage));
                });
              },
            ),
          ),
        ],
    );
  }

  String _getLanguageName(String languageCode, BuildContext context) {
    Locale locale = Locale(languageCode);
    AppLocalizations? localizations = lookupAppLocalizations(locale);
    return localizations.languageName;
  }
}

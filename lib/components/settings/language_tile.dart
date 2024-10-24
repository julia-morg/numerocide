import 'package:flutter/material.dart';
import '../../game/settings.dart';
import '../../main.dart';

class LanguageTile extends StatefulWidget {
  final Settings settings;

  const LanguageTile({super.key, required this.settings});

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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Select Language', style: Theme.of(context).textTheme.bodyLarge),
        DropdownButton<String>(
          value: _selectedLanguage,
          items: const [
            DropdownMenuItem(
              value: 'en',
              child: Text('English'),
            ),
            DropdownMenuItem(
              value: 'ru',
              child: Text('Русский'),
            ),
          ],
          onChanged: (String? newValue) {
            setState(() {
              _selectedLanguage = newValue!;
              widget.settings.language = _selectedLanguage;
              widget.settings.saveSettings();
              MyApp.setLocale(context, Locale(_selectedLanguage));
            });
          },
        ),
      ],
    );
  }
}
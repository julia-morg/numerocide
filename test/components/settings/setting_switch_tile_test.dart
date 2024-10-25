import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:numerocide/components/settings/setting_switch_tile.dart';
import 'package:numerocide/game/settings.dart';

class FakeSettings extends Settings {
  bool value = false;
  bool saveSettingsCalled = false;

  FakeSettings({required super.sound, required super.vibro, required super.theme, required super.language});

  @override
  Future<void> saveSettings() async {
    saveSettingsCalled = true;
  }
}

void main() {
  testWidgets('SettingsSwitchTile toggles switch and calls saveSettings on row tap', (WidgetTester tester) async {
    final fakeSettings = FakeSettings(sound: false, vibro: false, theme: 'light', language: 'en');

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SettingsSwitchTile(
            label: 'Switch Setting',
            settings: fakeSettings,
            getValue: (settings) => (settings as FakeSettings).value,
            setValue: (settings, newValue) {
              (settings as FakeSettings).value = newValue;
            },
          ),
        ),
      ),
    );

    expect(fakeSettings.value, isFalse);

    final inkWellFinder = find.byType(InkWell);
    await tester.tap(inkWellFinder);
    await tester.pumpAndSettle();

    expect(fakeSettings.value, isTrue);
    expect(fakeSettings.saveSettingsCalled, isTrue);
  });

  testWidgets('SettingsSwitchTile toggles switch and calls saveSettings on switch toggle', (WidgetTester tester) async {
    final fakeSettings = FakeSettings(sound: false, vibro: false, theme: 'light', language: 'en');

    await tester.pumpWidget(
      MaterialApp(
        home: Material(
          child: SettingsSwitchTile(
            label: 'Switch Setting',
            settings: fakeSettings,
            getValue: (settings) => (settings as FakeSettings).value,
            setValue: (settings, newValue) {
              (settings as FakeSettings).value = newValue;
            },
          ),
        ),
      ),
    );

    final switchFinder = find.byType(Switch);
    expect(fakeSettings.value, isFalse);

    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    expect(fakeSettings.value, isTrue);
    expect(fakeSettings.saveSettingsCalled, isTrue);
  });
}
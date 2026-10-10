import 'package:flutter/material.dart' hide Text, Icon;
import 'package:{{projectName}}/localization/localization.dart';
import 'package:{{projectName}}/settings/app_settings.dart';
import 'package:{{projectName}}/theme/app_spacing.dart';
import 'package:{{projectName}}/ui/language_sheet.dart';
import 'package:{{projectName}}/ui/widgets/page_frame.dart';
import 'package:{{projectName}}/ui/widgets/settings_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({required this.settings, super.key});

  final AppSettings settings;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) {
        return PageFrame(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: AppSpacing.lg,
              children: [
                SettingsSection(
                  title: 'Appearance',
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: SegmentedButton<ThemeMode>(
                        expandedInsets: EdgeInsets.zero,
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('Auto'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Latte'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Mocha'),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (selection) =>
                            settings.themeMode = selection.first,
                      ),
                    ),
                  ],
                ),
                if (L10n.languages.length > 1)
                  SettingsSection(
                    title: 'Language',
                    children: [
                      ListTile(
                        title: const Text('Language'),
                        subtitle: Text(_languageName(settings.language)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => _pickLanguage(context),
                      ),
                    ],
                  ),
                SettingsSection(
                  title: 'Updates',
                  children: [
                    SwitchListTile(
                      title: const Text('Check for updates'),
                      subtitle: const Text(
                        'Look for a newer version when the app starts',
                      ),
                      value: settings.checkUpdates,
                      onChanged: (value) => settings.checkUpdates = value,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _languageName(String code) {
    if (code == L10n.system) return 'System default'.tr;
    for (final language in L10n.languages) {
      if (language.code == code) return language.name;
    }
    return code;
  }

  Future<void> _pickLanguage(BuildContext context) async {
    final picked = await showLanguageSheet(context, settings.language);
    if (picked != null) settings.language = picked;
  }
}

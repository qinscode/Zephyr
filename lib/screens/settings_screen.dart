import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(AppLocalizations.of(context).settings),
      ),
      body: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              const _SectionHeader(title: 'Style'),
              _SettingsItem(
                title: AppLocalizations.of(context).fontSize,
                value: settings.fontSize.name,
                onTap: () => _showFontSizeDialog(context, settings),
              ),
              _SettingsItem(
                title: AppLocalizations.of(context).sort,
                value: settings.sortBy.name,
                onTap: () => _showSortDialog(context, settings),
              ),
              _SettingsItem(
                title: AppLocalizations.of(context).layout,
                value: settings.layout.name,
                onTap: () => _showLayoutDialog(context, settings),
              ),
              
              // 添加语言设置部分
              const _SectionHeader(title: 'Language'),
              _SettingsItem(
                title: 'Language',
                value: settings.locale.languageCode == 'en' ? 'English' : '中文',
                onTap: () => _showLanguageDialog(context, settings),
              ),

              const _SectionHeader(title: 'Quick features'),
              const ListTile(
                title: Text('Quick notes'),
                trailing: Icon(CupertinoIcons.right_chevron),
              ),
              const _SectionHeader(title: 'Reminders'),
              SwitchListTile(
                title: const Text('High-priority reminders'),
                subtitle: const Text(
                  'Play sound even when Silent or DND mode is on',
                ),
                value: settings.highPriorityReminders,
                onChanged: (value) {
                  settings.setHighPriorityReminders(value);
                },
              ),
              const _SectionHeader(title: 'OTHER'),
              const ListTile(
                title: Text('Privacy Policy'),
                trailing: Icon(CupertinoIcons.right_chevron),
              ),
              const ListTile(
                title: Text('Notes Third Party Data Sharing Statement'),
                trailing: Icon(CupertinoIcons.right_chevron),
              ),
              const ListTile(
                title: Text('Permissions details'),
                trailing: Icon(CupertinoIcons.right_chevron),
              ),
            ],
          );
        },
      ),
    );
  }

  // 添加语言选择对话框
  void _showLanguageDialog(BuildContext context, SettingsModel settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: const Text('English'),
                value: const Locale('en', 'US'),
                groupValue: settings.locale,
                onChanged: (value) {
                  if (value != null) {
                    settings.setLocale(value);
                    Navigator.pop(context);
                  }
                },
              ),
              RadioListTile<Locale>(
                title: const Text('中文'),
                value: const Locale('zh', 'CN'),
                groupValue: settings.locale,
                onChanged: (value) {
                  if (value != null) {
                    settings.setLocale(value);
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(AppLocalizations.of(context).cancel),
            ),
          ],
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsModel settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Font size'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: FontSize.values.map((size) {
              return RadioListTile<FontSize>(
                title: Text(size.name),
                value: size,
                groupValue: settings.fontSize,
                onChanged: (value) {
                  if (value != null) {
                    settings.setFontSize(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showSortDialog(BuildContext context, SettingsModel settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sort'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortBy.values.map((sort) {
              return RadioListTile<SortBy>(
                title: Text(sort.name),
                value: sort,
                groupValue: settings.sortBy,
                onChanged: (value) {
                  if (value != null) {
                    settings.setSortBy(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showLayoutDialog(BuildContext context, SettingsModel settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Layout'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: NoteLayout.values.map((layout) {
              return RadioListTile<NoteLayout>(
                title: Text(layout.name),
                value: layout,
                groupValue: settings.layout,
                onChanged: (value) {
                  if (value != null) {
                    settings.setLayout(value);
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(color: Colors.grey[600]),
          ),
          const Icon(CupertinoIcons.right_chevron),
        ],
      ),
      onTap: onTap,
    );
  }
}

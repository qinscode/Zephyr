import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n.settings),
      ),
      body: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return ListView(
            children: [
              _SectionHeader(title: l10n.style),
              _SettingsItem(
                title: l10n.fontSize,
                value: l10n.getFontSizeOption(settings.fontSize.name),  // 使用辅助方法获取本地化的字体大小名称
                onTap: () => _showFontSizeDialog(context, settings),
              ),
              _SettingsItem(
                title: l10n.sort,
                value: l10n.getSortOption(settings.sortBy.name),  // 使用辅助方法获取本地化的排序方式名称
                onTap: () => _showSortDialog(context, settings),
              ),
              _SettingsItem(
                title: l10n.layout,
                value: l10n.getLayoutOption(settings.layout.name),  // 使用辅助方法获取本地化的布局名称
                onTap: () => _showLayoutDialog(context, settings),
              ),
              
              // 语言设置
              _SectionHeader(title: l10n.language['title']!),
              _SettingsItem(
                title: l10n.language['title']!,
                value: settings.locale.languageCode == 'en' 
                    ? l10n.language['english']! 
                    : l10n.language['chinese']!,
                onTap: () => _showLanguageDialog(context, settings),
              ),

              // 快捷功能
              _SectionHeader(title: l10n.getSettingsValue('quickFeatures', 'title')),
              ListTile(
                title: Text(l10n.getSettingsValue('quickNotes', 'title')),
                trailing: const Icon(CupertinoIcons.right_chevron),
              ),

              // 提醒设置
              _SectionHeader(title: l10n.getSettingsValue('reminders', 'title')),
              SwitchListTile(
                title: Text(l10n.getSettingsValue('highPriorityReminders', 'title')),
                subtitle: Text(l10n.getSettingsValue('highPriorityReminders', 'desc')),
                value: settings.highPriorityReminders,
                onChanged: (value) {
                  settings.setHighPriorityReminders(value);
                },
              ),

              // 其他设置
              _SectionHeader(title: l10n.getSettingsValue('other', 'title')),
              ListTile(
                title: Text(l10n.getSettingsValue('privacyPolicy', 'title')),
                trailing: const Icon(CupertinoIcons.right_chevron),
              ),
              ListTile(
                title: Text(l10n.getSettingsValue('dataSharing', 'title')),
                trailing: const Icon(CupertinoIcons.right_chevron),
              ),
              ListTile(
                title: Text(l10n.getSettingsValue('permissions', 'title')),
                trailing: const Icon(CupertinoIcons.right_chevron),
              ),
            ],
          );
        },
      ),
    );
  }

  // 语言选择对话框
  void _showLanguageDialog(BuildContext context, SettingsModel settings) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.language['selectLanguage']!),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<Locale>(
                title: Text(l10n.language['english']!),
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
                title: Text(l10n.language['chinese']!),
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
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsModel settings) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.getSettingsValue('fontSize', 'title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: FontSize.values.map((size) {
              return RadioListTile<FontSize>(
                title: Text(l10n.getSettingsValue('fontSize', size.name)),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showSortDialog(BuildContext context, SettingsModel settings) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.getSettingsValue('sort', 'title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: SortBy.values.map((sort) {
              String sortName = sort == SortBy.byCreationDate 
                  ? 'byCreationDate' 
                  : 'byModificationDate';
              return RadioListTile<SortBy>(
                title: Text(l10n.getSettingsValue('sort', sortName)),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }

  void _showLayoutDialog(BuildContext context, SettingsModel settings) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.getSettingsValue('layout', 'title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: NoteLayout.values.map((layout) {
              return RadioListTile<NoteLayout>(
                title: Text(l10n.getSettingsValue('layout', layout.name)),
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
          ],
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

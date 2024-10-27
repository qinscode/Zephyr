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
              _SectionHeader(title: l10n.language['title'] ?? 'Language'),
              _SettingsItem(
                title: l10n.language['title'] ?? 'Language',
                value: _getLanguageName(settings.locale, l10n),  // 使用辅助方法获取语言名称
                onTap: () => _showLanguageDialog(context, settings),
              ),

              // 快捷功能
              _SectionHeader(title: l10n.settingsMap['quickFeatures'] as String),
              ListTile(
                title: Text(
                  l10n.settingsMap['quickNotes'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,  // 加粗标题
                  ),
                ),
                trailing: const Icon(CupertinoIcons.right_chevron),
              ),

              // 提醒设置
              _SectionHeader(title: l10n.settingsMap['reminders'] as String),
              SwitchListTile(
                title: Text(
                  l10n.settingsMap['highPriorityReminders'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,  // 加粗标题
                  ),
                ),
                subtitle: Text(l10n.settingsMap['highPriorityRemindersDesc'] as String),
                value: settings.highPriorityReminders,
                onChanged: (value) {
                  settings.setHighPriorityReminders(value);
                },
              ),

              // 其他设置
              _SectionHeader(title: l10n.settingsMap['other'] as String),
              ListTile(
                title: Text(
                  l10n.settingsMap['privacyPolicy'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,  // 加粗标题
                  ),
                ),
                trailing: const Icon(CupertinoIcons.right_chevron),
              ),
              ListTile(
                title: Text(
                  l10n.settingsMap['dataSharing'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,  // 加粗标题
                  ),
                ),
                trailing: const Icon(CupertinoIcons.right_chevron),
              ),
              ListTile(
                title: Text(
                  l10n.settingsMap['permissions'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,  // 加粗标题
                  ),
                ),
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
          title: Text(l10n.language['selectLanguage'] ?? 'Select Language'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLanguageOption(context, l10n, settings, 'en', 'US', 'english'),
                _buildLanguageOption(context, l10n, settings, 'zh', 'CN', 'chinese'),
                _buildLanguageOption(context, l10n, settings, 'zh', 'TW', 'traditionalChinese'),
                _buildLanguageOption(context, l10n, settings, 'es', 'ES', 'spanish'),
                _buildLanguageOption(context, l10n, settings, 'ja', 'JP', 'japanese'),
                _buildLanguageOption(context, l10n, settings, 'ko', 'KR', 'korean'),
                _buildLanguageOption(context, l10n, settings, 'th', 'TH', 'thai'),
                _buildLanguageOption(context, l10n, settings, 'fr', 'FR', 'french'),
                _buildLanguageOption(context, l10n, settings, 'ru', 'RU', 'russian'),
                _buildLanguageOption(context, l10n, settings, 'pt', 'BR', 'portuguese'),
              ],
            ),
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

  // 添加一个辅助方法来构建语言选项
  Widget _buildLanguageOption(
    BuildContext context,
    AppLocalizations l10n,
    SettingsModel settings,
    String languageCode,
    String countryCode,
    String languageKey,
  ) {
    final locale = Locale(languageCode, countryCode);
    return RadioListTile<Locale>(
      title: Text(l10n.language[languageKey] ?? languageKey),
      value: locale,
      groupValue: settings.locale,
      onChanged: (value) {
        if (value != null) {
          settings.setLocale(value);
          Navigator.pop(context);
        }
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

  // 添加一个辅助方法来获取语言名称
  String _getLanguageName(Locale locale, AppLocalizations l10n) {
    switch (locale.languageCode) {
      case 'en':
        return l10n.language['english'] ?? 'English';
      case 'zh':
        return locale.countryCode == 'TW' 
            ? l10n.language['traditionalChinese'] ?? '繁體中文'
            : l10n.language['chinese'] ?? '中文';
      case 'es':
        return l10n.language['spanish'] ?? 'Español';
      case 'ja':
        return l10n.language['japanese'] ?? '日本語';
      case 'ko':
        return l10n.language['korean'] ?? '한국어';
      case 'th':
        return l10n.language['thai'] ?? 'ไทย';
      case 'fr':
        return l10n.language['french'] ?? 'Français';
      case 'ru':
        return l10n.language['russian'] ?? 'Русский';
      case 'pt':
        return l10n.language['portuguese'] ?? 'Português';
      default:
        return 'English';
    }
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
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,  // 加粗标题
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,  // 增大选项值的字体大小
            ),
          ),
          const SizedBox(width: 4),  // 添加一点间距
          const Icon(CupertinoIcons.right_chevron),
        ],
      ),
      onTap: onTap,
    );
  }
}

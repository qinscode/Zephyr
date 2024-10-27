import 'package:flutter/material.dart';
import 'translations/translation_keys.dart';
import 'translations/en_us.dart';
import 'translations/zh_cn.dart';

class AppLocalizations {
  final Locale locale;
  late final TranslationKeys _translations;

  AppLocalizations(this.locale) {
    _translations = _getTranslations(locale);
  }

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static TranslationKeys _getTranslations(Locale locale) {
    // 确保总是返回一个有效的翻译，默认返回英文
    switch (locale.languageCode) {
      case 'zh':
        return zhCN;
      case 'en':
      default:
        return enUS;  // 默认返回英文翻译
    }
  }

  // 添加一个方法来检查语言是否支持
  static bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  // Notes
  String get notes => _translations.notes['title']!;
  String get noNotes => _translations.notes['noNotes']!;
  String get title => _translations.notes['title']!;
  String get startTyping => _translations.notes['startTyping']!;
  String get untitled => _translations.notes['untitled']!;
  String get noText => _translations.notes['noText']!;
  String get searchNotes => _translations.notes['searchNotes']!;
  String get characters => _translations.notes['characters']!;

  // Folders
  String get folders => _translations.folders['title']!;
  String get newFolder => _translations.folders['newFolder']!;
  String get folderName => _translations.folders['folderName']!;
  String get all => _translations.folders['all']!;
  String get uncategorized => _translations.folders['uncategorized']!;
  String get moveToFolder => _translations.folders['moveToFolder']!;
  String get createFolder => _translations.folders['createFolder']!;
  String get renameFolder => _translations.folders['renameFolder']!;
  String get deleteFolder => _translations.folders['deleteFolder']!;
  String get deleteFolderConfirm => _translations.folders['deleteFolderConfirm']!;

  // Tasks
  String get tasks => _translations.tasks['title']!;
  String get noTasks => _translations.tasks['noTasks']!;
  String get addSubtask => _translations.tasks['addSubtask']!;
  String get setReminder => _translations.tasks['setReminder']!;

  // Actions
  String get create => _translations.actions['create']!;
  String get rename => _translations.actions['rename']!;
  String get delete => _translations.actions['delete']!;
  String get cancel => _translations.actions['cancel']!;
  String get save => _translations.actions['save']!;
  String get done => _translations.actions['done']!;
  String get share => _translations.actions['share']!;
  String get moveToTrash => _translations.actions['moveToTrash']!;
  String get exitConfirm => _translations.actions['exitConfirm']!;
  String get exit => _translations.actions['exit']!;

  // Settings
  String get settings => _translations.settings['title']!;
  String get style => _translations.settings['style']!;
  String get fontSize => _translations.settings['fontSize']!;
  String get sort => _translations.settings['sort']!;
  String get layout => _translations.settings['layout']!;
  String get darkMode => _translations.settings['darkMode']!;

  // Time
  String get today => _translations.time['today']!;
  String get yesterday => _translations.time['yesterday']!;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.isSupported(locale);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return Future.value(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

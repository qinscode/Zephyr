import 'package:flutter/material.dart';
import 'translations/translation_keys.dart';
import 'translations/en_us.dart';
import 'translations/zh_cn.dart';
import 'translations/es_es.dart';
import 'translations/ja_jp.dart';
import 'translations/ko_kr.dart';
import 'translations/th_th.dart';
import 'translations/zh_tw.dart';
import 'translations/fr_fr.dart';
import 'translations/ru_ru.dart';
import 'translations/pt_br.dart';

class AppLocalizations {
  final Locale locale;
  final TranslationKeys _translations;

  AppLocalizations(this.locale) : _translations = _getTranslations(locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static TranslationKeys _getTranslations(Locale locale) {
    switch (locale.languageCode) {
      case 'zh':
        return locale.countryCode == 'TW' ? zhTW : zhCN;
      case 'es':
        return esES;
      case 'ja':
        return jaJP;
      case 'ko':
        return koKR;
      case 'th':
        return thTH;
      case 'fr':
        return frFR;
      case 'ru':
        return ruRU;
      case 'pt':
        return ptBR;
      case 'en':
      default:
        return enUS;
    }
  }

  // Notes
  String get notes => _translations.notes['title']!;
  String get noNotes => _translations.notes['noNotes']!;
  String get title => _translations.notes['title']!;
  String get noText => _translations.notes['noText']!;
  String get searchNotes => _translations.notes['searchNotes']!;
  String get characters => _translations.notes['characters']!;
  String get untitled => _translations.notes['untitled']!;
  String get inputStartTyping => _translations.notes['startTyping']!;

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

  // Settings
  String get settings => _translations.settings['title']!;
  String get style => _translations.settings['style']!;
  String get fontSize => _translations.settings['fontSize']!['title']!;
  String get sort => _translations.settings['sort']!['title']!;
  String get layout => _translations.settings['layout']!['title']!;
  Map<String, dynamic> get settingsMap => _translations.settings;

  // Time
  String get today => _translations.time['today']!;
  String get yesterday => _translations.time['yesterday']!;
  Map<String, dynamic> get time => _translations.time;

  // Language
  Map<String, dynamic> get language => _translations.language;

  // Alerts
  Map<String, dynamic> get alerts => _translations.alerts;
  String get exitConfirm => _translations.alerts['exitConfirm']!;
  String get exit => _translations.alerts['exit']!;
  String get emptyTrashConfirm => _translations.alerts['emptyTrashConfirm']!;
  String get searching => _translations.alerts['searching']!;
  String get startTyping => _translations.alerts['startTyping']!;
  String get itemsInTrash => _translations.alerts['itemsInTrash']!;
  String get noItemsInTrash => _translations.alerts['noItemsInTrash']!;

  // Share
  Map<String, dynamic> get shareMap => _translations.share;

  // Editor
  Map<String, dynamic> get editor => _translations.editor;

  // Date Format
  Map<String, dynamic> get dateFormat => _translations.dateFormat;

  // Common Actions
  Map<String, dynamic> get actions => _translations.actions;
  String get create => _translations.actions['create']!;
  String get rename => _translations.actions['rename']!;
  String get delete => _translations.actions['delete']!;
  String get cancel => _translations.actions['cancel']!;
  String get save => _translations.actions['save']!;
  String get done => _translations.actions['done']!;
  String get share => _translations.actions['share']!;
  String get moveToTrash => _translations.actions['moveToTrash']!;
  String get restore => _translations.actions['restore']!;
  String get deletePermanently => _translations.actions['deletePermanently']!;
  String get tryAgain => _translations.actions['tryAgain']!;

  // Static methods
  static bool isSupported(Locale locale) {
    return ['en', 'zh', 'es', 'ja', 'ko', 'th', 'fr', 'ru', 'pt'].contains(locale.languageCode);
  }

  // 辅助方法，用于安全地获取嵌套的值
  String? getNestedValue(String section, String key) {
    final sectionMap = _translations.toJson()[section];
    if (sectionMap is Map<String, dynamic>) {
      final value = sectionMap[key];
      if (value is Map<String, dynamic>) {
        return value.toString();
      }
      return value?.toString();
    }
    return null;
  }

  // 获取设置中的嵌套值
  String getSettingsValue(String key, String subKey) {
    final settingsMap = _translations.settings[key];
    if (settingsMap is Map<String, dynamic>) {
      return settingsMap[subKey]?.toString() ?? '';
    }
    return '';
  }

  // 获取分享中的值
  String getShareValue(String key) {
    return _translations.share[key]?.toString() ?? '';
  }

  // 获取字体大小选项
  String getFontSizeOption(String option) {
    return _translations.settings['fontSize']![option]?.toString() ?? '';
  }

  // 获取排序选项
  String getSortOption(String option) {
    return _translations.settings['sort']![option]?.toString() ?? '';
  }

  // 获取布局选项
  String getLayoutOption(String option) {
    return _translations.settings['layout']![option]?.toString() ?? '';
  }
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

class TranslationKeys {
  final Map<String, dynamic> notes;
  final Map<String, dynamic> folders;
  final Map<String, dynamic> tasks;
  final Map<String, dynamic> actions;
  final Map<String, dynamic> settings;
  final Map<String, dynamic> time;
  final Map<String, dynamic> language;
  final Map<String, dynamic> alerts;
  final Map<String, dynamic> share;
  final Map<String, dynamic> editor;
  final Map<String, dynamic> dateFormat;

  const TranslationKeys({
    required this.notes,
    required this.folders,
    required this.tasks,
    required this.actions,
    required this.settings,
    required this.time,
    required this.language,
    required this.alerts,
    required this.share,
    required this.editor,
    required this.dateFormat,
  });

  // 添加 toJson 方法
  Map<String, dynamic> toJson() => {
    'notes': notes,
    'folders': folders,
    'tasks': tasks,
    'actions': actions,
    'settings': settings,
    'time': time,
    'language': language,
    'alerts': alerts,
    'share': share,
    'editor': editor,
    'dateFormat': dateFormat,
  };

  // 辅助方法，用于安全地获取嵌套的值
  String? getNestedValue(Map<String, dynamic> map, String key, String subKey) {
    final value = map[key];
    if (value is Map<String, dynamic>) {
      return value[subKey]?.toString();
    }
    return null;
  }
}

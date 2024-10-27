class TranslationKeys {
  final Map<String, String> notes;
  final Map<String, String> folders;
  final Map<String, String> tasks;
  final Map<String, String> actions;
  final Map<String, String> settings;
  final Map<String, String> time;
  final Map<String, String> language;  // 新增语言设置
  final Map<String, String> alerts;    // 新增提醒对话框
  final Map<String, String> share;     // 新增分享选项
  final Map<String, String> editor;    // 新增编辑器选项

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
  });
}

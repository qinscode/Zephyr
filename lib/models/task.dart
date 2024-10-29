// lib/models/task.dart 中添加 expanded 字段

class Task {
  final String id;
  final String title;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? reminder;
  final List<SubTask> subtasks;
  final bool expanded; // 新增字段

  Task({
    required this.id,
    required this.title,
    this.isCompleted = false,
    required this.createdAt,
    this.reminder,
    this.subtasks = const [],
    this.expanded = true, // 默认展开
  });

  // 在 copyWith 方法中添加 expanded 参数
  Task copyWith({
    String? id,
    String? title,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? reminder,
    List<SubTask>? subtasks,
    bool? expanded,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      reminder: reminder ?? this.reminder,
      subtasks: subtasks ?? this.subtasks,
      expanded: expanded ?? this.expanded,
    );
  }

  // 修改 toJson 和 fromJson 方法
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'reminder': reminder?.toIso8601String(),
      'subtasks': subtasks.map((subtask) => subtask.toJson()).toList(),
      'expanded': expanded,
    };
  }

  static Task fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
      createdAt: DateTime.parse(json['createdAt']),
      reminder: json['reminder'] != null ? DateTime.parse(json['reminder']) : null,
      subtasks: (json['subtasks'] as List)
          .map((subtaskMap) => SubTask.fromJson(subtaskMap))
          .toList(),
      expanded: json['expanded'] ?? true,
    );
  }
}

class SubTask {
  final String id;
  final String title;
  final bool isCompleted;

  SubTask({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  static SubTask fromJson(Map<String, dynamic> json) {
    return SubTask(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }

  SubTask copyWith({
    String? id,
    String? title,
    bool? isCompleted,
  }) {
    return SubTask(
      id: id ?? this.id,
      title: title ?? this.title,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
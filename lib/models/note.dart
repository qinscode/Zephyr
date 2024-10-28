import 'package:flutter/foundation.dart';
import 'note_background.dart';  // 确保导入 note_background.dart

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? folderId;
  final Map<String, dynamic>? metadata;
  final DateTime? deletedAt;
  final List<String> tags;
  final bool isPinned;
  final bool isLocked;
  final String? color;
  final NoteBackground? background;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    this.folderId,
    this.metadata,
    this.deletedAt,
    this.tags = const [],
    this.isPinned = false,
    this.isLocked = false,
    this.color,
    this.background,
  });

  // 从JSON创建Note实例
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      folderId: json['folderId'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      isPinned: json['isPinned'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      color: json['color'] as String?,
      background: json['background'] != null
          ? NoteBackground.fromJson(json['background'] as Map<String, dynamic>)
          : null,  // 从JSON解析背景
    );
  }

  // 将Note实例转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'folderId': folderId,
      'metadata': metadata,
      'deletedAt': deletedAt?.toIso8601String(),
      'tags': tags,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'color': color,
      'background': background?.toJson(),  // 转换背景为JSON
    };
  }

  // 创建Note的副本并修改指定字段
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? folderId,
    Map<String, dynamic>? metadata,
    DateTime? deletedAt,
    List<String>? tags,
    bool? isPinned,
    bool? isLocked,
    String? color,
    NoteBackground? background,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      folderId: folderId ?? this.folderId,
      metadata: metadata ?? this.metadata,
      deletedAt: deletedAt ?? this.deletedAt,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isLocked: isLocked ?? this.isLocked,
      color: color ?? this.color,
      background: background ?? this.background,  // 复制背景
    );
  }

  // 获取预览文本
  String get preview {
    final cleanContent = content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanContent.isEmpty) return '';
    return cleanContent.length > 100
        ? '${cleanContent.substring(0, 100)}...'
        : cleanContent;
  }

  // 获取字数统计
  int get wordCount {
    final words = content.trim().split(RegExp(r'\s+'));
    return words.where((word) => word.isNotEmpty).length;
  }

  // 获取字符���统计（包括标题）
  int get characterCount {
    return title.length + content.length;
  }

  // 检查笔记是否为空
  bool get isEmpty {
    return title.isEmpty && content.trim().isEmpty;
  }

  // 检查笔记是否在垃圾箱中
  bool get isDeleted {
    return deletedAt != null;
  }

  // 检查笔记是否包含特定标签
  bool hasTag(String tag) {
    return tags.contains(tag);
  }

  // 添加标签
  Note addTag(String tag) {
    if (!tags.contains(tag)) {
      return copyWith(tags: [...tags, tag]);
    }
    return this;
  }

  // 删除标签
  Note removeTag(String tag) {
    return copyWith(tags: tags.where((t) => t != tag).toList());
  }

  // 移动到文件夹
  Note moveToFolder(String? newFolderId) {
    return copyWith(
      folderId: newFolderId,
      modifiedAt: DateTime.now(),
    );
  }

  // 将笔记移到垃圾箱
  Note moveToTrash() {
    return copyWith(
      deletedAt: DateTime.now(),
      modifiedAt: DateTime.now(),
    );
  }

  // 从垃圾箱恢复
  Note restore() {
    return copyWith(
      deletedAt: null,
      modifiedAt: DateTime.now(),
    );
  }

  // 切换置顶状态
  Note togglePin() {
    return copyWith(
      isPinned: !isPinned,
      modifiedAt: DateTime.now(),
    );
  }

  // 切换锁定状态
  Note toggleLock() {
    return copyWith(
      isLocked: !isLocked,
      modifiedAt: DateTime.now(),
    );
  }

  // 更改颜色
  Note changeColor(String? newColor) {
    return copyWith(
      color: newColor,
      modifiedAt: DateTime.now(),
    );
  }

  // 更新内容
  Note updateContent({
    String? newTitle,
    String? newContent,
  }) {
    return copyWith(
      title: newTitle ?? title,
      content: newContent ?? content,
      modifiedAt: DateTime.now(),
    );
  }

  // 比较两个Note是否相等
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Note &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.createdAt == createdAt &&
        other.modifiedAt == modifiedAt &&
        other.folderId == folderId &&
        other.deletedAt == deletedAt &&
        other.isPinned == isPinned &&
        other.isLocked == isLocked &&
        other.color == color &&
        listEquals(other.tags, tags);
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      content,
      createdAt,
      modifiedAt,
      folderId,
      deletedAt,
      isPinned,
      isLocked,
      color,
      Object.hashAll(tags),
    );
  }

  // 更改背��
  Note changeBackground(NoteBackground? newBackground) {
    return copyWith(
      background: newBackground,
      modifiedAt: DateTime.now(),
    );
  }
}

// 辅助函数：比较两个列表是否相等
bool listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

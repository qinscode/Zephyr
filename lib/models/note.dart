import 'package:flutter/material.dart';
import 'note_background.dart';  // 确保导入 note_background.dart

// 定义富文本样式类型
enum TextStyleType {
  normal,
  h1,
  h2,
  h3,
  bold,
  highlight,
}

// 定义富文本段落类
class RichParagraph {
  final String text;
  final TextStyleType styleType;
  final Color? highlightColor;
  final List<dynamic>? deltaJson;  // 添加这个属性

  const RichParagraph({
    required this.text,
    this.styleType = TextStyleType.normal,
    this.highlightColor,
    this.deltaJson,  // 添加这个参数
  });

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'styleType': styleType.name,
      'highlightColor': highlightColor?.value,
      'deltaJson': deltaJson,  // 添加这个字段
    };
  }

  // 从 JSON 创建
  factory RichParagraph.fromJson(Map<String, dynamic> json) {
    return RichParagraph(
      text: json['text'] as String,
      styleType: TextStyleType.values.firstWhere(
        (e) => e.name == json['styleType'],
        orElse: () => TextStyleType.normal,
      ),
      highlightColor: json['highlightColor'] != null
          ? Color(json['highlightColor'] as int)
          : null,
      deltaJson: json['deltaJson'] as List<dynamic>?,  // 添加这个字段
    );
  }

  // 获取文本样式
  TextStyle getStyle() {
    switch (styleType) {
      case TextStyleType.h1:
        return const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.5,
        );
      case TextStyleType.h2:
        return const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          height: 1.5,
        );
      case TextStyleType.h3:
        return const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          height: 1.5,
        );
      case TextStyleType.bold:
        return const TextStyle(
          fontWeight: FontWeight.bold,
          height: 1.5,
        );
      case TextStyleType.highlight:
        return TextStyle(
          backgroundColor: highlightColor ?? Colors.yellow.withOpacity(0.3),
          height: 1.5,
        );
      case TextStyleType.normal:
      default:
        return const TextStyle(height: 1.5);
    }
  }

  // 复制并修改
  RichParagraph copyWith({
    String? text,
    TextStyleType? styleType,
    Color? highlightColor,
    List<dynamic>? deltaJson,
  }) {
    return RichParagraph(
      text: text ?? this.text,
      styleType: styleType ?? this.styleType,
      highlightColor: highlightColor ?? this.highlightColor,
      deltaJson: deltaJson ?? this.deltaJson,
    );
  }
}

class Note {
  final String id;
  final String title;
  final List<RichParagraph> content;  // 修改为富文本内容
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
  final List<dynamic>? titleDeltaJson;  // 添加这个属性

  const Note({
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
    this.titleDeltaJson,  // 添加这个参数
  });

  // 从纯文本创建富文本内容
  static List<RichParagraph> textToRichParagraphs(String text) {
    return text.split('\n').map((line) => RichParagraph(text: line)).toList();
  }

  // 将富文本内容转换为纯文本
  String get plainText {
    return content.map((p) => p.text).join('\n');
  }

  // 从 JSON 创建
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] as String,
      title: json['title'] as String,
      content: (json['content'] as List)
          .map((p) => RichParagraph.fromJson(p as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      folderId: json['folderId'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      deletedAt: json['deletedAt'] != null
          ? DateTime.parse(json['deletedAt'] as String)
          : null,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? const [],
      isPinned: json['isPinned'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      color: json['color'] as String?,
      background: json['background'] != null
          ? NoteBackground.fromJson(json['background'] as Map<String, dynamic>)
          : null,
      titleDeltaJson: json['titleDeltaJson'] as List<dynamic>?,  // 添加这个字段
    );
  }

  // 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'folderId': folderId,
      'metadata': metadata,
      'deletedAt': deletedAt?.toIso8601String(),
      'tags': tags,
      'isPinned': isPinned,
      'isLocked': isLocked,
      'color': color,
      'background': background?.toJson(),
      'titleDeltaJson': titleDeltaJson,  // 添加这个字段
    };
  }

  // 复制并修改
  Note copyWith({
    String? id,
    String? title,
    List<RichParagraph>? content,
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
    List<dynamic>? titleDeltaJson,
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
      background: background ?? this.background,
      titleDeltaJson: titleDeltaJson ?? this.titleDeltaJson,
    );
  }

  // 获取预览文本
  String get preview {
    final cleanContent = content.map((p) => p.text).join('\n').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (cleanContent.isEmpty) return '';
    return cleanContent.length > 100
        ? '${cleanContent.substring(0, 100)}...'
        : cleanContent;
  }

  // 获取字数统计
  int get wordCount {
    final words = content.map((p) => p.text).join('\n').trim().split(RegExp(r'\s+'));
    return words.where((word) => word.isNotEmpty).length;
  }

  // 获取字符统计（包括标题）
  int get characterCount {
    return title.length + content.map((p) => p.text).join('\n').length;
  }

  // 检查笔记是否为空
  bool get isEmpty {
    return title.isEmpty && content.map((p) => p.text).join('\n').trim().isEmpty;
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
      content: newContent != null
          ? textToRichParagraphs(newContent)
          : content,
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

  // 更改背
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

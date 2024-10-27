// lib/models/note.dart
import 'package:flutter/material.dart';

class Note {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isPinned;
  final bool isFinished;
  final String type; // 'idea', 'task', 'shopping', etc.
  final List<String> labels;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.isPinned = false,
    this.isFinished = false,
    required this.type,
    this.labels = const [],
  });

  // 添加复制方法以便于更新笔记
  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPinned,
    bool? isFinished,
    String? type,
    List<String>? labels,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPinned: isPinned ?? this.isPinned,
      isFinished: isFinished ?? this.isFinished,
      type: type ?? this.type,
      labels: labels ?? this.labels,
    );
  }

  // 添加工厂构造函数用于创建新笔记
  factory Note.create({
    required String title,
    required String content,
    required String type,
    bool isPinned = false,
    List<String> labels = const [],
  }) {
    final now = DateTime.now();
    return Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      createdAt: now,
      updatedAt: now,
      isPinned: isPinned,
      isFinished: false,
      type: type,
      labels: labels,
    );
  }
}

// 添加笔记类型枚举
enum NoteType {
  idea,
  task,
  shopping,
  general
}

// 扩展方法用于获取笔记类型的显示名称
extension NoteTypeExtension on NoteType {
  String get displayName {
    switch (this) {
      case NoteType.idea:
        return 'Idea';
      case NoteType.task:
        return 'Task';
      case NoteType.shopping:
        return 'Shopping';
      case NoteType.general:
        return 'General';
    }
  }

  IconData get icon {
    switch (this) {
      case NoteType.idea:
        return Icons.lightbulb_outline;
      case NoteType.task:
        return Icons.check_box_outline_blank;
      case NoteType.shopping:
        return Icons.shopping_bag_outlined;
      case NoteType.general:
        return Icons.note_outlined;
    }
  }
}
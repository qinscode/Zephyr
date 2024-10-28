// lib/models/trash_model.dart
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import 'note.dart';
import 'task.dart';

class TrashItem {
  final String id;
  final String title;
  final List<RichParagraph>? content;
  final DateTime deletedAt;
  final DateTime expiresAt;
  final ItemType type;
  final dynamic originalItem;

  TrashItem({
    required this.id,
    required this.title,
    this.content,
    required this.deletedAt,
    required this.expiresAt,
    required this.type,
    this.originalItem,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content?.map((p) => p.toJson()).toList(),
      'deletedAt': deletedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'type': type.toString(),
      'originalItem': originalItem is Map
          ? originalItem
          : (originalItem as dynamic).toJson(),
    };
  }

  factory TrashItem.fromJson(Map<String, dynamic> json) {
    return TrashItem(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] != null
          ? (json['content'] as List)
              .map((p) => RichParagraph.fromJson(p as Map<String, dynamic>))
              .toList()
          : null,
      deletedAt: DateTime.parse(json['deletedAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      type: ItemType.values.firstWhere(
            (e) => e.toString() == json['type'],
      ),
      originalItem: json['originalItem'],
    );
  }
}

enum ItemType {
  note,
  task,
}

class TrashModel extends ChangeNotifier {
  final StorageService _storage;
  List<TrashItem> _trashedItems = [];
  bool _isLoading = false;
  String? _error;

  TrashModel(this._storage) {
    _loadTrashedItems();
  }

  // Getters
  List<TrashItem> get trashedItems => List.unmodifiable(_trashedItems);
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 添加项目到垃圾箱
  Future<void> addToTrash(dynamic item) async {
    final now = DateTime.now();
    late TrashItem trashItem;

    if (item is Note) {
      trashItem = TrashItem(
        id: item.id,
        title: item.title,
        content: item.content,
        deletedAt: now,
        expiresAt: now.add(const Duration(days: 30)),
        type: ItemType.note,
        originalItem: item,
      );
    } else if (item is Task) {
      trashItem = TrashItem(
        id: item.id,
        title: item.title,
        deletedAt: now,
        expiresAt: now.add(const Duration(days: 30)),
        type: ItemType.task,
        originalItem: item,
      );
    } else {
      throw ArgumentError('Unsupported item type');
    }

    _trashedItems.insert(0, trashItem);
    await _saveTrashedItems();
    notifyListeners();
  }

  // 从垃圾箱恢复项目
  Future<dynamic> restoreItem(String id) async {
    final itemIndex = _trashedItems.indexWhere((item) => item.id == id);
    if (itemIndex == -1) return null;

    final item = _trashedItems[itemIndex];
    _trashedItems.removeAt(itemIndex);
    await _saveTrashedItems();
    notifyListeners();

    return item.originalItem;
  }

  // 永久删除项目
  Future<void> deletePermanently(String id) async {
    _trashedItems.removeWhere((item) => item.id == id);
    await _saveTrashedItems();
    notifyListeners();
  }

  // 清空垃圾箱
  Future<void> emptyTrash() async {
    _trashedItems.clear();
    await _saveTrashedItems();
    notifyListeners();
  }

  // 获取项目的剩余保留时间
  Duration? getItemRetentionTime(String id) {
    final item = _trashedItems.firstWhere(
          (item) => item.id == id,
      orElse: () => throw Exception('Item not found'),
    );

    final now = DateTime.now();
    if (item.expiresAt.isBefore(now)) return null;
    return item.expiresAt.difference(now);
  }

  // 加载垃圾箱项目
  Future<void> _loadTrashedItems() async {
    _isLoading = true;
    notifyListeners();

    try {
      final List<dynamic> items = await _storage.loadTrash();
      _trashedItems = items
          .map((item) => TrashItem.fromJson(item as Map<String, dynamic>))
          .toList();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // 保存垃圾箱项目
  Future<void> _saveTrashedItems() async {
    try {
      final items = _trashedItems.map((item) => item.toJson()).toList();
      await _storage.saveTrash(items);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  // 清理过期项目
  Future<void> cleanupExpiredItems() async {
    final now = DateTime.now();
    final initialLength = _trashedItems.length;
    _trashedItems.removeWhere((item) => item.expiresAt.isBefore(now));

    if (_trashedItems.length != initialLength) {
      await _saveTrashedItems();
      notifyListeners();
    }
  }

  // 批量操作
  Future<void> restoreMultipleItems(List<String> ids) async {
    for (final id in ids) {
      await restoreItem(id);
    }
  }

  Future<void> deleteMultipleItems(List<String> ids) async {
    for (final id in ids) {
      await deletePermanently(id);
    }
  }

  // 获取指定类型的项目
  List<TrashItem> getItemsByType(ItemType type) {
    return _trashedItems.where((item) => item.type == type).toList();
  }

  // 检查项目是否在垃圾箱中
  bool isItemInTrash(String id) {
    return _trashedItems.any((item) => item.id == id);
  }

  // 刷新
  Future<void> refresh() async {
    await _loadTrashedItems();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

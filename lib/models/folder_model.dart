// lib/models/folder_model.dart
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../services/storage_service.dart';

class Folder {
  final String id;
  final String name;
  final int noteCount;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final String? color;

  Folder({
    required this.id,
    required this.name,
    this.noteCount = 0,
    required this.createdAt,
    required this.modifiedAt,
    this.color,
  });

  Folder copyWith({
    String? id,
    String? name,
    int? noteCount,
    DateTime? createdAt,
    DateTime? modifiedAt,
    String? color,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      noteCount: noteCount ?? this.noteCount,
      createdAt: createdAt ?? this.createdAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'noteCount': noteCount,
      'createdAt': createdAt.toIso8601String(),
      'modifiedAt': modifiedAt.toIso8601String(),
      'color': color,
    };
  }

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'] as String,
      name: json['name'] as String,
      noteCount: json['noteCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      modifiedAt: DateTime.parse(json['modifiedAt'] as String),
      color: json['color'] as String?,
    );
  }
}

class FolderModel extends ChangeNotifier {
  final StorageService _storage;
  List<Folder> _folders = [];
  String? _selectedFolderId;
  bool _isLoading = false;
  String? _error;

  FolderModel(this._storage) {
    _loadFolders();
  }

  // Getters
  List<Folder> get folders => List.unmodifiable(_folders);
  String? get selectedFolderId => _selectedFolderId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 获取文件夹名称
  String getFolderName(String folderId) {
    return _folders.firstWhere(
          (folder) => folder.id == folderId,
      orElse: () => Folder(
        id: '',
        name: 'Uncategorized',
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
      ),
    ).name;
  }


  // 获取所有笔记的总数
  int get totalNoteCount => _folders.fold(
    0,
        (sum, folder) => sum + folder.noteCount,
  );

  // 创建新文件夹
  Folder createFolder(String name) {
    final now = DateTime.now();
    final newFolder = Folder(
      id: const Uuid().v4(),
      name: name,
      createdAt: now,
      modifiedAt: now,
    );

    _folders.add(newFolder);
    _saveFolders();
    notifyListeners();
    return newFolder;
  }

  // 重命名文件夹
  void renameFolder(String id, String newName) {
    final index = _folders.indexWhere((folder) => folder.id == id);
    if (index != -1) {
      _folders[index] = _folders[index].copyWith(
        name: newName,
        modifiedAt: DateTime.now(),
      );
      _saveFolders();
      notifyListeners();
    }
  }

  // 删除文件夹
  void deleteFolder(String id) {
    _folders.removeWhere((folder) => folder.id == id);
    if (_selectedFolderId == id) {
      _selectedFolderId = null;
    }
    _saveFolders();
    notifyListeners();
  }

  // 选择文件夹
  void selectFolder(String? id) {
    print('FolderModel.selectFolder called with id: $id');
    if (id == 'hide') {
      // 特殊状态：隐藏标签栏
      _selectedFolderId = 'hide';
    } else {
      _selectedFolderId = id;
    }
    print('_selectedFolderId set to: $_selectedFolderId');
    notifyListeners();
  }

  // 更新文件夹中的笔记数量
  void updateNoteCounts(Map<String, int> counts) {
    bool hasChanges = false;
    for (var i = 0; i < _folders.length; i++) {
      final count = counts[_folders[i].id] ?? 0;
      if (_folders[i].noteCount != count) {
        _folders[i] = _folders[i].copyWith(noteCount: count);
        hasChanges = true;
      }
    }
    if (hasChanges) {
      _saveFolders();
      notifyListeners();
    }
  }

  // 重新排序文件夹
  void reorderFolders(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final folder = _folders.removeAt(oldIndex);
    _folders.insert(newIndex, folder);
    _saveFolders();
    notifyListeners();
  }

  // 检查文件夹是否存在
  bool folderExists(String name) {
    return _folders.any((folder) =>
    folder.name.toLowerCase() == name.toLowerCase()
    );
  }

  // 加载文件夹
  Future<void> _loadFolders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _folders = await _storage.loadFolders();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // 保存文件夹
  Future<void> _saveFolders() async {
    try {
      await _storage.saveFolders(_folders);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  // 刷新数据
  Future<void> refresh() async {
    await _loadFolders();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

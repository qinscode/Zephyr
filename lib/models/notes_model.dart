// lib/models/notes_model.dart
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import 'note.dart';

class NotesModel extends ChangeNotifier {
  final StorageService _storage;
  List<Note> _notes = [];
  bool _isLoading = false;
  String? _error;

  // 获取笔记列表的不同视图
  List<Note> get notes => List.unmodifiable(_notes);
  List<Note> get pinnedNotes => _notes.where((note) => note.isPinned).toList();
  List<Note> get unpinnedNotes => _notes.where((note) => !note.isPinned).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  NotesModel(this._storage) {
    _loadNotes();
  }

  // 初始化加载笔记
  Future<void> _loadNotes() async {
    _setLoading(true);
    try {
      _notes = await _storage.loadNotes();
      _error = null;
    } catch (e) {
      _error = 'Failed to load notes: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // 设置加载状态
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // 添加新笔记
  Future<void> addNote(Note note) async {
    try {
      _notes.insert(0, note);
      await _saveNotes();
      notifyListeners();
    } catch (e) {
      _notes.removeWhere((n) => n.id == note.id);
      rethrow;
    }
  }

  // 更新笔记
  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      try {
        _notes[index] = note;
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        _notes[index] = _notes[index]; // 恢复原始状态
        rethrow;
      }
    }
  }

  // 删除笔记
  Future<void> deleteNote(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final deletedNote = _notes[index];
      try {
        _notes.removeAt(index);
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        _notes.insert(index, deletedNote);
        rethrow;
      }
    }
  }

  // 移动笔记到文件夹
  Future<void> moveNoteToFolder(String noteId, String? folderId) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      final originalNote = _notes[index];
      try {
        _notes[index] = originalNote.moveToFolder(folderId);
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        _notes[index] = originalNote;
        rethrow;
      }
    }
  }

  // 切换笔记置顶状态
  Future<void> toggleNotePin(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final originalNote = _notes[index];
      try {
        _notes[index] = originalNote.togglePin();
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        _notes[index] = originalNote;
        rethrow;
      }
    }
  }

  // 切换笔记锁定状态
  Future<void> toggleNoteLock(String id) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final originalNote = _notes[index];
      try {
        _notes[index] = originalNote.toggleLock();
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        _notes[index] = originalNote;
        rethrow;
      }
    }
  }

  // 更改笔记颜色
  Future<void> changeNoteColor(String id, String? color) async {
    final index = _notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      final originalNote = _notes[index];
      try {
        _notes[index] = originalNote.changeColor(color);
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        _notes[index] = originalNote;
        rethrow;
      }
    }
  }

  // 添加标签到笔记
  Future<void> addTagToNote(String noteId, String tag) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      final originalNote = _notes[index];
      try {
        _notes[index] = originalNote.addTag(tag);
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        _notes[index] = originalNote;
        rethrow;
      }
    }
  }

  // 从笔记中移除标签
  Future<void> removeTagFromNote(String noteId, String tag) async {
    final index = _notes.indexWhere((note) => note.id == noteId);
    if (index != -1) {
      final originalNote = _notes[index];
      try {
        _notes[index] = originalNote.removeTag(tag);
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        _notes[index] = originalNote;
        rethrow;
      }
    }
  }

  // 按文件夹获取笔记
  List<Note> getNotesByFolder(String? folderId) {
    return _notes.where((note) => note.folderId == folderId).toList();
  }

  // 获取带有特定标签的笔记
  List<Note> getNotesByTag(String tag) {
    return _notes.where((note) => note.hasTag(tag)).toList();
  }

  // 按颜色获取笔记
  List<Note> getNotesByColor(String color) {
    return _notes.where((note) => note.color == color).toList();
  }

  // 搜索笔记
  List<Note> searchNotes(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _notes.where((note) {
      return note.title.toLowerCase().contains(lowercaseQuery) ||
          note.content.toLowerCase().contains(lowercaseQuery) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  // 获取所有使用的标签
  Set<String> get allTags {
    return _notes.fold<Set<String>>(
      {},
          (tags, note) => tags..addAll(note.tags),
    );
  }

  // 获取所有使用的颜色
  Set<String> get allColors {
    return _notes
        .where((note) => note.color != null)
        .map((note) => note.color!)
        .toSet();
  }

  // 批量操作
  Future<void> batchDeleteNotes(List<String> ids) async {
    final deletedNotes = <int, Note>{};
    for (final id in ids) {
      final index = _notes.indexWhere((note) => note.id == id);
      if (index != -1) {
        deletedNotes[index] = _notes[index];
        _notes.removeAt(index);
      }
    }

    if (deletedNotes.isNotEmpty) {
      try {
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        // 恢复删除的笔记
        deletedNotes.forEach((index, note) {
          _notes.insert(index, note);
        });
        rethrow;
      }
    }
  }

  Future<void> batchMoveNotesToFolder(List<String> ids, String? folderId) async {
    final originalNotes = <int, Note>{};
    bool hasChanges = false;

    for (final id in ids) {
      final index = _notes.indexWhere((note) => note.id == id);
      if (index != -1) {
        originalNotes[index] = _notes[index];
        _notes[index] = _notes[index].moveToFolder(folderId);
        hasChanges = true;
      }
    }

    if (hasChanges) {
      try {
        await _saveNotes();
        notifyListeners();
      } catch (e) {
        // 恢复原始状态
        originalNotes.forEach((index, note) {
          _notes[index] = note;
        });
        rethrow;
      }
    }
  }

  // 保存笔记到存储
  Future<void> _saveNotes() async {
    try {
      await _storage.saveNotes(_notes);
    } catch (e) {
      _error = 'Failed to save notes: ${e.toString()}';
      throw e;
    }
  }

  // 重新加载笔记
  Future<void> refresh() async {
    await _loadNotes();
  }

  // 清除错误状态
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
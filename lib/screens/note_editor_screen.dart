// lib/screens/note_editor_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';

import '../models/note.dart';
import '../models/notes_model.dart';
import '../models/folder_model.dart';
import '../models/trash_model.dart';
import '../widgets/folder_selector.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;
  final String? initialFolderId;

  const NoteEditorScreen({
    super.key,
    this.note,
    this.initialFolderId,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late FocusNode _titleFocusNode;
  late FocusNode _contentFocusNode;
  bool _isEdited = false;
  String? _currentFolderId;
  int _characterCount = 0;
  late DateTime _lastModified;
  final List<String> _undoHistory = [];
  final List<String> _redoHistory = [];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _currentFolderId = widget.note?.folderId ?? widget.initialFolderId;
    _lastModified = widget.note?.modifiedAt ?? DateTime.now();

    // 添加文本变化监听
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);

    // 初始化字符计数
    _updateCharacterCount();

    // 保存初始状态用于撤销
    _saveState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    if (!_isEdited) {
      setState(() {
        _isEdited = true;
      });
    }
    _updateCharacterCount();
    _saveState();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _titleController.text.length + _contentController.text.length;
    });
  }

  void _saveState() {
    final currentState = json.encode({
      'title': _titleController.text,
      'content': _contentController.text,
    });

    if (_undoHistory.isEmpty || _undoHistory.last != currentState) {
      _undoHistory.add(currentState);
      _redoHistory.clear();
    }
  }

  Future<void> _saveNote() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    try {
      if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
        Navigator.pop(context);
        return;
      }

      final notesModel = Provider.of<NotesModel>(context, listen: false);
      final now = DateTime.now();

      if (widget.note == null) {
        // 创建新笔记
        final newNote = Note(
          id: const Uuid().v4(),
          title: _titleController.text,
          content: _contentController.text,
          createdAt: now,
          modifiedAt: now,
          folderId: _currentFolderId,
        );
        await notesModel.addNote(newNote);
      } else {
        // 更新现有笔记
        final updatedNote = widget.note!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          modifiedAt: now,
          folderId: _currentFolderId,
        );
        await notesModel.updateNote(updatedNote);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _undo() {
    if (_undoHistory.length > 1) {
      final currentState = _undoHistory.removeLast();
      _redoHistory.add(currentState);
      final previousState = json.decode(_undoHistory.last);

      setState(() {
        _titleController.text = previousState['title'];
        _contentController.text = previousState['content'];
      });
    }
  }

  void _redo() {
    if (_redoHistory.isNotEmpty) {
      final nextState = json.decode(_redoHistory.removeLast());
      _saveState();

      setState(() {
        _titleController.text = nextState['title'];
        _contentController.text = nextState['content'];
      });
    }
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.share),
              title: const Text('Share note'),
              onTap: () {
                Navigator.pop(context);
                _showShareOptions();
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.folder),
              title: const Text('Move to folder'),
              onTap: () {
                Navigator.pop(context);
                _showFolderSelector();
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.delete),
              title: const Text('Move to trash'),
              onTap: () {
                Navigator.pop(context);
                _moveToTrash();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Share note'),
              onTap: () {
                Navigator.pop(context);
                // 实现分享功能
              },
            ),
            ListTile(
              title: const Text('Share note as text'),
              onTap: () {
                Navigator.pop(context);
                // 实现文本分享功能
              },
            ),
            ListTile(
              title: const Text('Share note as picture'),
              onTap: () {
                Navigator.pop(context);
                // 实现图片分享功能
              },
            ),
            ListTile(
              title: const Text('Export as Markdown'),
              onTap: () {
                Navigator.pop(context);
                // 实现 Markdown 导出功能
              },
            ),
            ListTile(
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showFolderSelector() async {
    final newFolderId = await showDialog<String>(
      context: context,
      builder: (context) => FolderSelector(
        currentFolderId: _currentFolderId,
      ),
    );

    if (newFolderId != null && mounted) {
      setState(() {
        _currentFolderId = newFolderId;
        _isEdited = true;
      });
    }
  }

  Future<void> _moveToTrash() async {
    if (widget.note != null) {
      final trashModel = Provider.of<TrashModel>(context, listen: false);
      final notesModel = Provider.of<NotesModel>(context, listen: false);

      await trashModel.addToTrash(widget.note!);
      await notesModel.deleteNote(widget.note!.id);

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        
        if (_isEdited) {
          await _saveNote();
        }
        if (mounted) {
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white, // 确保背景色始终为白色
          surfaceTintColor: Colors.transparent, // 添加这一行，移除 Material 3 的色调
          elevation: 0,
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () {
              if (_isEdited) {
                _saveNote();
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            if (_undoHistory.length > 1)
              IconButton(
                icon: const Icon(CupertinoIcons.arrow_counterclockwise),
                onPressed: _undo,
              ),
            if (_redoHistory.isNotEmpty)
              IconButton(
                icon: const Icon(CupertinoIcons.arrow_clockwise),
                onPressed: _redo,
              ),
            IconButton(
              icon: const Icon(CupertinoIcons.ellipsis_vertical),
              onPressed: _showOptionsMenu,
            ),
          ],
        ),
        body: Column(
          children: [
            // 文件夹指示器
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: GestureDetector(
                onTap: _showFolderSelector,
                child: Align( // 添加 Align 组件
                  alignment: Alignment.centerLeft, // 设置左对齐
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // 保持这个属性
                      children: [
                        const Icon(CupertinoIcons.folder, size: 18),
                        const SizedBox(width: 4),
                        Consumer<FolderModel>(
                          builder: (context, folderModel, child) {
                            final folderName = _currentFolderId != null
                                ? folderModel.getFolderName(_currentFolderId!)
                                : 'Uncategorized';
                            return Text(folderName);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // 编辑区域
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextField(
                    controller: _titleController,
                    focusNode: _titleFocusNode,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) {
                      _contentFocusNode.requestFocus();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      '${DateFormat('MMMM d h:mm a').format(_lastModified)} | $_characterCount characters',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ),
                  TextField(
                    controller: _contentController,
                    focusNode: _contentFocusNode,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Start typing',
                      border: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
            // 工具栏
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                  ),
                ),
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(CupertinoIcons.list_bullet),
                      onPressed: () {
                        // 实现列表格式化
                      },
                      color: Colors.grey[700],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.photo),
                      onPressed: () {
                        // 实现图片插入
                      },
                      color: Colors.grey[700],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.pencil),
                      onPressed: () {
                        // 实现绘画功能
                      },
                      color: Colors.grey[700],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.checkmark_square),
                      onPressed: () {
                        // 实现任务列表
                      },
                      color: Colors.grey[700],
                    ),
                    IconButton(
                      icon: const Icon(CupertinoIcons.textformat),
                      onPressed: () {
                        // 实现文本格式化
                      },
                      color: Colors.grey[700],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

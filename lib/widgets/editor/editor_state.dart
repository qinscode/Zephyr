import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../models/note_background.dart';

class EditorState extends ChangeNotifier {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final List<String> undoHistory = [];
  final List<String> redoHistory = [];
  bool isEdited = false;
  NoteBackground? currentBackground;
  Color toolbarColor = Colors.white.withOpacity(0.9);
  bool showFormatToolbar = false;
  String? _folderId;

  String? get folderId => _folderId;

  EditorState({
    required this.titleController,
    required this.contentController,
    this.currentBackground,
    String? initialFolderId,
  }) : _folderId = initialFolderId {
    titleController.addListener(_onTextChanged);
    contentController.addListener(_onTextChanged);
    _saveState();
    
    // 如果初始化时有背景，立即更新工具栏颜色
    if (currentBackground != null && 
        currentBackground!.type != BackgroundType.none && 
        currentBackground!.assetPath != null) {
      _updateToolbarColor();
    }
  }

  void _onTextChanged() {
    if (!isEdited) {
      isEdited = true;
      notifyListeners();
    }
    _saveState();
  }

  void _saveState() {
    final currentState = json.encode({
      'title': titleController.text,
      'content': contentController.text,
    });

    if (undoHistory.isEmpty || undoHistory.last != currentState) {
      undoHistory.add(currentState);
      redoHistory.clear();
      notifyListeners();
    }
  }

  void undo() {
    if (undoHistory.length > 1) {
      final currentState = undoHistory.removeLast();
      redoHistory.add(currentState);
      final previousState = json.decode(undoHistory.last);

      titleController.text = previousState['title'];
      contentController.text = previousState['content'];
      notifyListeners();
    }
  }

  void redo() {
    if (redoHistory.isNotEmpty) {
      final nextState = json.decode(redoHistory.removeLast());
      _saveState();

      titleController.text = nextState['title'];
      contentController.text = nextState['content'];
      notifyListeners();
    }
  }

  // 添加私有方法来更新工具栏颜色
  Future<void> _updateToolbarColor() async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        AssetImage(currentBackground!.assetPath!),
        size: const Size(100, 100),
      );

      toolbarColor = paletteGenerator.dominantColor?.color.withOpacity(0.9) ??
                     paletteGenerator.lightVibrantColor?.color.withOpacity(0.9) ??
                     Colors.white.withOpacity(0.9);
      notifyListeners();
    } catch (e) {
      debugPrint('Error generating palette: $e');
      toolbarColor = Colors.white.withOpacity(0.9);
      notifyListeners();
    }
  }

  Future<void> setBackground(NoteBackground background) async {
    currentBackground = background;
    isEdited = true;
    
    // 更新工具栏颜色
    if (background.type != BackgroundType.none && background.assetPath != null) {
      await _updateToolbarColor();
    } else {
      toolbarColor = Colors.white.withOpacity(0.9);
      notifyListeners();
    }
  }

  void setToolbarColor(Color color) {
    toolbarColor = color;
    notifyListeners();
  }

  void toggleFormatToolbar() {
    showFormatToolbar = !showFormatToolbar;
    notifyListeners();
  }

  void setFolderId(String? id) {
    if (_folderId != id) {
      _folderId = id;
      isEdited = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    contentController.removeListener(_onTextChanged);
    super.dispose();
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../models/note_background.dart';

class EditorState extends ChangeNotifier {
  final QuillController titleController;
  final QuillController contentController;
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
      'title': titleController.document.toDelta().toJson(),
      'content': contentController.document.toDelta().toJson(),
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

      titleController.document = Document.fromJson(previousState['title']);
      contentController.document = Document.fromJson(previousState['content']);
      notifyListeners();
    }
  }

  void redo() {
    if (redoHistory.isNotEmpty) {
      final nextState = json.decode(redoHistory.removeLast());
      _saveState();

      titleController.document = Document.fromJson(nextState['title']);
      contentController.document = Document.fromJson(nextState['content']);
      notifyListeners();
    }
  }

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
    
    if (background.type != BackgroundType.none && background.assetPath != null) {
      await _updateToolbarColor();
    } else {
      toolbarColor = Colors.white.withOpacity(0.9);
      notifyListeners();
    }
  }

  void toggleBold() {
    contentController.formatSelection(Attribute.bold);
    notifyListeners();
  }

  void setFolderId(String? id) {
    if (_folderId != id) {
      _folderId = id;
      isEdited = true;
      notifyListeners();
    }
  }

  void toggleFormatToolbar() {
    showFormatToolbar = !showFormatToolbar;
    notifyListeners();
  }

  // 修改格式化方法
  void applyHighlight(Color color) {
    contentController.formatSelection(const BackgroundAttribute('#FFFF00'));
  }

  void applyHeading(int level) {
    // 获取当前选中文本的样式
    final formats = contentController.getSelectionStyle().attributes;
    // 检查当前的标题级别
    final currentLevel = formats[Attribute.header.key]?.value;
    
    // 切换标题状态
    if (currentLevel == level) {
      // 如果当前已经是这个级别的标题，则移除标题格式
      contentController.formatSelection(Attribute.clone(Attribute.header, null));
    } else {
      // 如果是其他级别或没有标题，则设置为指定级别的标题
      contentController.formatSelection(HeaderAttribute(level: level));
    }
    notifyListeners();
  }

  void applyBold() {
    // 获取当前选中文本的样式
    final formats = contentController.getSelectionStyle().attributes;
    // 检查是否已经加粗
    final isBold = formats[Attribute.bold.key] == Attribute.bold;
    
    // 切换加粗状态
    if (isBold) {
      // 如果已经加粗，则移除加粗
      contentController.formatSelection(Attribute.clone(Attribute.bold, null));
    } else {
      // 如果未加粗，则添加加粗
      contentController.formatSelection(Attribute.bold);
    }
    notifyListeners();
  }

  @override
  void dispose() {
    titleController.removeListener(_onTextChanged);
    contentController.removeListener(_onTextChanged);
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }
}

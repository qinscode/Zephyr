// lib/screens/note_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_quill/flutter_quill.dart' hide EditorState;
import '../models/note.dart';
import '../models/note_background.dart';
import '../models/notes_model.dart';
import '../models/trash_model.dart';
import '../services/share/share_service.dart';
import '../widgets/editor/editor_app_bar.dart';
import '../widgets/editor/editor_toolbar.dart';
import '../widgets/editor/folder_indicator.dart';
import '../widgets/editor/editor_content.dart';
import '../widgets/editor/editor_state.dart';
import '../widgets/editor/background_container.dart';
import '../widgets/editor/theme_selector.dart';
import '../widgets/editor/share_options.dart';
import '../widgets/editor/more_options.dart';
import '../widgets/folder_selector.dart';
import 'package:flutter/foundation.dart';

class SaveNoteData {
  final String titleText;
  final String contentText;
  final List<dynamic> titleDeltaJson;
  final List<dynamic> contentDeltaJson;
  final String? folderId;
  final NoteBackground? background;
  final String? noteId;
  final DateTime? createdAt;

  SaveNoteData({
    required this.titleText,
    required this.contentText,
    required this.titleDeltaJson,
    required this.contentDeltaJson,
    this.folderId,
    this.background,
    this.noteId,
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'titleText': titleText,
      'contentText': contentText,
      'titleDeltaJson': titleDeltaJson,
      'contentDeltaJson': contentDeltaJson,
      'folderId': folderId,
      'background': background?.toJson(),
      'noteId': noteId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  static SaveNoteData fromJson(Map<String, dynamic> json) {
    return SaveNoteData(
      titleText: json['titleText'] as String,
      contentText: json['contentText'] as String,
      titleDeltaJson: json['titleDeltaJson'] as List<dynamic>,
      contentDeltaJson: json['contentDeltaJson'] as List<dynamic>,
      folderId: json['folderId'] as String?,
      background: json['background'] != null 
          ? NoteBackground.fromJson(json['background'] as Map<String, dynamic>)
          : null,
      noteId: json['noteId'] as String?,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}

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
  late final EditorState _editorState;
  late final FocusNode _titleFocusNode;
  late final FocusNode _contentFocusNode;
  late final DateTime _lastModified;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    print('NoteEditorScreen - initState');
    
    // 从保存的 Delta JSON 创建文档
    Document titleDoc;
    if (widget.note?.titleDeltaJson != null) {
      titleDoc = Document.fromJson(widget.note!.titleDeltaJson!);
    } else {
      titleDoc = Document()..insert(0, widget.note?.title ?? '');
    }
    
    Document contentDoc;
    if (widget.note?.content.isNotEmpty == true && 
        widget.note!.content.first.deltaJson != null) {
      contentDoc = Document.fromJson(widget.note!.content.first.deltaJson!);
    } else {
      contentDoc = Document()..insert(0, widget.note?.plainText ?? '');
    }

    _editorState = EditorState(
      titleController: QuillController(
        document: titleDoc,
        selection: const TextSelection.collapsed(offset: 0),
      ),
      contentController: QuillController(
        document: contentDoc,
        selection: const TextSelection.collapsed(offset: 0),
      ),
      currentBackground: widget.note?.background,
    );
    
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _lastModified = widget.note?.modifiedAt ?? DateTime.now();
    _updateCharacterCount();

    // 添加监听器以更新字符计数
    _editorState.titleController.addListener(_updateCharacterCount);
    _editorState.contentController.addListener(_updateCharacterCount);
  }

  @override
  void dispose() {
    print('NoteEditorScreen - dispose');
    // 如果有未保存的编辑，在页面销毁前保存
    if (_editorState.isEdited) {
      _saveNote();
    }
    _editorState.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _editorState.titleController.document.length +
          _editorState.contentController.document.length;
    });
  }

  // 修改保存笔记的方法
  Future<bool> _saveNote() async {
    print('NoteEditorScreen - _saveNote - 开始');
    print('开始保存笔记...');
    
    if (_editorState.titleController.document.length == 0 && 
        _editorState.contentController.document.length == 0) {
      print('笔记内容为空，直接返回');
      return true;
    }

    try {
      print('准备保存数据...');
      final notesModel = Provider.of<NotesModel>(context, listen: false);
      final now = DateTime.now();

      // 直接创建 Note 对象
      final note = Note(
        id: widget.note?.id ?? const Uuid().v4(),
        title: _editorState.titleController.document.toPlainText().trim(),
        content: [
          RichParagraph(
            text: _editorState.contentController.document.toPlainText(),
            deltaJson: _editorState.contentController.document.toDelta().toJson(),
          )
        ],
        createdAt: widget.note?.createdAt ?? now,
        modifiedAt: now,
        folderId: _editorState.folderId,
        background: _editorState.currentBackground,
        titleDeltaJson: _editorState.titleController.document.toDelta().toJson(),
      );

      print('开始保存到数据库...');
      if (widget.note == null) {
        await notesModel.addNote(note);
        print('新笔记保存完成');
      } else {
        await notesModel.updateNote(note);
        print('笔记更新完成');
      }
      
      print('保存成功');
      return true;
    } catch (e, stackTrace) {
      print('保存失败: $e');
      print('错误堆栈: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save note: $e')),
        );
      }
      return false;
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

  void _showThemeOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) => ThemeSelector(
        currentBackground: _editorState.currentBackground,
        onBackgroundChanged: (background) async {
          Navigator.pop(context);
          await _editorState.setBackground(background);
        },
      ),
    );
  }

  void _showShareOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ShareOptions(
        onShareAsImage: () => _shareAsImage(),
        onShareAsText: () {},  // TODO: Implement
        onShareNote: () {},    // TODO: Implement
        onExportMarkdown: () {}, // TODO: Implement
      ),
    );
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => MoreOptions(
        onMoveToFolder: () => _showFolderSelector(),
        onMoveToTrash: () => _moveToTrash(),
      ),
    );
  }

  Future<void> _shareAsImage() async {
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black26,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );

    overlayState.insert(overlayEntry);

    try {
      final previewKey = GlobalKey();
      final previewWidget = RepaintBoundary(
        key: previewKey,
        child: Material(
          color: Colors.white,
          child: ShareService.buildNotePreviewWidget(
            Note(
              id: widget.note?.id ?? const Uuid().v4(),
              title: _editorState.titleController.document.toPlainText(),
              content: [
                RichParagraph(
                  text: _editorState.contentController.document.toPlainText(),
                  deltaJson: _editorState.contentController.document.toDelta().toJson(),
                )
              ],
              createdAt: widget.note?.createdAt ?? DateTime.now(),
              modifiedAt: DateTime.now(),
              background: _editorState.currentBackground,
              titleDeltaJson: _editorState.titleController.document.toDelta().toJson(),  // 添加这一行
            ),
          ),
        ),
      );

      // 将预览 widget 插入到 overlay 中
      final previewOverlay = OverlayEntry(
        builder: (context) => Positioned(
          left: -9999, // 放在屏幕外
          child: previewWidget,
        ),
      );
      overlayState.insert(previewOverlay);

      // 等待下一帧确保 widget 已经渲染
      await Future.delayed(const Duration(milliseconds: 100));

      // 生成图片
      final note = Note(
        id: widget.note?.id ?? const Uuid().v4(),
        title: _editorState.titleController.document.toPlainText(),
        content: [
          RichParagraph(
            text: _editorState.contentController.document.toPlainText(),
            deltaJson: _editorState.contentController.document.toDelta().toJson(),
          )
        ],
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
        background: _editorState.currentBackground,
        titleDeltaJson: _editorState.titleController.document.toDelta().toJson(),  // 添加这一行
      );

      await ShareService.shareNoteAsImage(note, previewKey, context);
      
      // 移除预览 widget
      previewOverlay.remove();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share note as image: $e')),
        );
      }
    } finally {
      overlayEntry.remove();
    }
  }

  @override
  Widget build(BuildContext context) {
    print('NoteEditorScreen - build');
    return ListenableBuilder(
      listenable: _editorState,
      builder: (context, child) {
        print('NoteEditorScreen - ListenableBuilder rebuild');
        return BackgroundContainer(
          background: _editorState.currentBackground,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: EditorAppBar(
              isEdited: _editorState.isEdited,
              onBack: () async {
                print('点击返回按钮');
                if (_editorState.isEdited) {
                  print('笔记已编辑，准备保存');
                  final saved = await _saveNote();
                  print('保存结果: $saved');
                  if (!saved) {
                    print('保存失败，取消返回');
                    return;
                  }
                }
                if (mounted) {
                  print('执行返回操作');
                  Navigator.pop(context);
                }
              },
              onUndo: _editorState.undoHistory.length > 1 ? _editorState.undo : () {},
              onRedo: _editorState.redoHistory.isNotEmpty ? _editorState.redo : () {},
              onTheme: _showThemeOptions,
              onShare: _showShareOptions,
              onMore: _showMoreOptions,
              canUndo: _editorState.undoHistory.length > 1,
              canRedo: _editorState.redoHistory.isNotEmpty,
              iconColor: _editorState.currentBackground?.textColor,  // 只传递图标颜色
            ),
            body: Column(
              children: [
                FolderIndicator(
                  folderId: _editorState.folderId,  // 使用 EditorState 中的文件夹ID
                  onTap: _showFolderSelector,
                ),
                Expanded(
                  child: EditorContent(
                    titleController: _editorState.titleController,
                    contentController: _editorState.contentController,
                    titleFocusNode: _titleFocusNode,
                    contentFocusNode: _contentFocusNode,
                    textColor: _editorState.currentBackground?.textColor ?? Colors.black,
                    characterCount: _characterCount,
                    lastModified: _lastModified,
                  ),
                ),
                EditorToolbar(
                  backgroundColor: _editorState.toolbarColor,
                  showFormatToolbar: _editorState.showFormatToolbar,
                  onFormatPressed: () => _editorState.toggleFormatToolbar(),
                  onCloseFormat: () => _editorState.toggleFormatToolbar(),
                  onHighlight: () => _editorState.applyHighlight(Colors.yellow.withOpacity(0.5)),
                  onH1: () => _editorState.applyHeading(1),
                  onH2: () => _editorState.applyHeading(2),
                  onH3: () => _editorState.applyHeading(3),
                  onBold: () => _editorState.applyBold(),
                  onChecklist: () => _editorState.toggleChecklist(),
                  onInsertImage: () => _editorState.insertImage(),  // 添加这行
                  onOrderedList: () => _editorState.toggleOrderedList(),  // 添加这一行
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFolderSelector() async {
    final newFolderId = await showDialog<String>(
      context: context,
      builder: (context) => FolderSelector(
        currentFolderId: widget.note?.folderId ?? widget.initialFolderId,
      ),
    );

    if (newFolderId != null && mounted) {
      final notesModel = Provider.of<NotesModel>(context, listen: false);
      
      if (widget.note != null) {
        // 如果是编辑现有笔记，直接更新笔记的文件夹
        await notesModel.moveNoteToFolder(widget.note!.id, newFolderId);
      } else {
        // 如果是新笔记，更新 EditorState 中的文件夹ID
        setState(() {
          _editorState.setFolderId(newFolderId);
        });
      }
    }
  }
}

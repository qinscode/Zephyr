// lib/screens/note_editor_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../models/note_background.dart';
import '../models/notes_model.dart';
import '../models/trash_model.dart';
import '../services/share_service.dart';
import '../services/text_formatter_service.dart';
import '../widgets/editor/editor_app_bar.dart';
import '../widgets/editor/editor_toolbar.dart';
import '../widgets/editor/folder_indicator.dart';
import '../widgets/editor/editor_content.dart';
import '../widgets/editor/editor_state.dart';
import '../widgets/editor/background_container.dart';
import '../widgets/editor/theme_selector.dart';
import '../widgets/editor/share_options.dart';
import '../widgets/editor/more_options.dart';
import '../widgets/editor/opacity_slider.dart';
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
  late final EditorState _editorState;
  late final FocusNode _titleFocusNode;
  late final FocusNode _contentFocusNode;
  late final DateTime _lastModified;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _editorState = EditorState(
      titleController: TextEditingController(text: widget.note?.title ?? ''),
      contentController: TextEditingController(text: widget.note?.content ?? ''),
      currentBackground: widget.note?.background,
    );
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _lastModified = widget.note?.modifiedAt ?? DateTime.now();
    _updateCharacterCount();
  }

  @override
  void dispose() {
    _editorState.dispose();
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    super.dispose();
  }

  void _updateCharacterCount() {
    setState(() {
      _characterCount = _editorState.titleController.text.length +
          _editorState.contentController.text.length;
    });
  }

  Future<void> _saveNote() async {
    if (_editorState.titleController.text.isEmpty && 
        _editorState.contentController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final notesModel = Provider.of<NotesModel>(context, listen: false);
    final now = DateTime.now();

    if (widget.note == null) {
      final newNote = Note(
        id: const Uuid().v4(),
        title: _editorState.titleController.text,
        content: _editorState.contentController.text,
        createdAt: now,
        modifiedAt: now,
        folderId: _editorState.folderId,  // 使用 EditorState 中的文件夹ID
        background: _editorState.currentBackground,
      );
      await notesModel.addNote(newNote);
    } else {
      final updatedNote = widget.note!.copyWith(
        title: _editorState.titleController.text,
        content: _editorState.contentController.text,
        modifiedAt: now,
        folderId: _editorState.folderId,  // 使用 EditorState 中的文件夹ID
        background: _editorState.currentBackground,
      );
      await notesModel.updateNote(updatedNote);
    }

    if (mounted) {
      Navigator.pop(context);
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
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeSelector(
            currentBackground: _editorState.currentBackground,
            onBackgroundChanged: (background) async {
              Navigator.pop(context);
              await _editorState.setBackground(background);
            },
          ),
          if (_editorState.currentBackground != null && 
              _editorState.currentBackground!.type != BackgroundType.none)
            OpacitySlider(
              opacity: _editorState.currentBackground!.opacity ?? 1.0,
              onChanged: (value) async {
                await _editorState.setBackground(
                  _editorState.currentBackground!.copyWith(opacity: value),
                );
              },
            ),
        ],
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
      final tempKey = GlobalKey();
      final note = Note(
        id: widget.note?.id ?? const Uuid().v4(),
        title: _editorState.titleController.text,
        content: _editorState.contentController.text,
        createdAt: widget.note?.createdAt ?? DateTime.now(),
        modifiedAt: DateTime.now(),
        background: _editorState.currentBackground,
      );

      await ShareService.shareNoteAsImage(note, tempKey, context);
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
    return ListenableBuilder(
      listenable: _editorState,
      builder: (context, child) {
        return PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            if (_editorState.isEdited) {
              await _saveNote();
            }
            if (mounted) {
              Navigator.pop(context);
            }
          },
          child: BackgroundContainer(
            background: _editorState.currentBackground,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: EditorAppBar(
                isEdited: _editorState.isEdited,
                onBack: () {
                  if (_editorState.isEdited) {
                    _saveNote();
                  } else {
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
                    onHighlight: () => TextFormatterService.applyHighlight(
                      _editorState.contentController,
                      Colors.yellow,
                    ),
                    onH1: () => TextFormatterService.applyHeading(
                      _editorState.contentController,
                      1,
                    ),
                    onH2: () => TextFormatterService.applyHeading(
                      _editorState.contentController,
                      2,
                    ),
                    onH3: () => TextFormatterService.applyHeading(
                      _editorState.contentController,
                      3,
                    ),
                    onBold: () => TextFormatterService.applyBold(
                      _editorState.contentController,
                    ),
                  ),
                ],
              ),
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

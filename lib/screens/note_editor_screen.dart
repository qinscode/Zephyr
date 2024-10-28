// lib/screens/note_editor_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:palette_generator/palette_generator.dart';
import '../services/share_service.dart';

import '../models/note.dart';
import '../models/note_background.dart';
import '../models/notes_model.dart';
import '../models/folder_model.dart';
import '../models/trash_model.dart';
import '../widgets/folder_selector.dart';
import '../l10n/app_localizations.dart';

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
  NoteBackground? _currentBackground;
  Color _toolbarColor = Colors.white.withOpacity(0.9);
  final GlobalKey _shareKey = GlobalKey();
  bool _showFormatToolbar = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _currentFolderId = widget.note?.folderId ?? widget.initialFolderId;
    _lastModified = widget.note?.modifiedAt ?? DateTime.now();
    _currentBackground = widget.note?.background;

    // 添加文本变化监听
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);

    // 初始化字符计数
    _updateCharacterCount();

    // 保存初始状态用于撤销
    _saveState();

    // 如果有背景，初始化工具栏颜色
    if (widget.note?.background != null && widget.note!.background!.type != BackgroundType.none) {
      final imageProvider = AssetImage(widget.note!.background!.assetPath!);
      _updateToolbarColor(imageProvider);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    // 移除未完成的输入法组合文本
    final titleText = _titleController.text.replaceAll(RegExp(r'[\uFE00-\uFE0F]'), '');
    final contentText = _contentController.text.replaceAll(RegExp(r'[\uFE00-\uFE0F]'), '');
    
    setState(() {
      _characterCount = titleText.characters.length + contentText.characters.length;
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
          background: _currentBackground, // 添加背景
        );
        await notesModel.addNote(newNote);
      } else {
        // 更新现有笔记
        final updatedNote = widget.note!.copyWith(
          title: _titleController.text,
          content: _contentController.text,
          modifiedAt: now,
          folderId: _currentFolderId,
          background: _currentBackground ?? widget.note!.background, // 更新背景
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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(CupertinoIcons.folder),
              title: Text(l10n.moveToFolder),
              onTap: () {
                Navigator.pop(context);
                _showFolderSelector();
              },
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.delete),
              title: Text(l10n.moveToTrash),
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
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.getShareValue('shareNote')),  // 使用辅助方法
              onTap: () {
                Navigator.pop(context);
                // 实现分享功能
              },
            ),
            ListTile(
              title: Text(l10n.getShareValue('shareAsText')),  // 使用辅助方法
              onTap: () {
                Navigator.pop(context);
                // 实现本分享功能
              },
            ),
            ListTile(
              title: Text(l10n.getShareValue('shareAsImage')),
              leading: const Icon(Icons.image),
              onTap: () {
                Navigator.pop(context);
                _shareAsImage();
              },
            ),
            ListTile(
              title: Text(l10n.getShareValue('exportAsMarkdown')),  // 使助方法
              onTap: () {
                Navigator.pop(context);
                // 实现 Markdown 导出功能
              },
            ),
            ListTile(
              title: Text(l10n.cancel),
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

  void _showThemeOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final currentBackground = widget.note?.background ?? _currentBackground;
          final opacity = currentBackground?.opacity ?? 1.0;

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Choose Background',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 背景选项列表
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Default (white) background
                      _buildThemeOption(
                        label: 'Default',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () {
                          _applyBackground(NoteBackground.defaultBackground);
                          Navigator.pop(context);
                        },
                      ),
                      // Cloud
                      _buildThemeOption(
                        label: 'Cloud',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            image: const DecorationImage(
                              image: AssetImage('assets/images/cloud_pattern.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () {
                          _applyBackground(NoteBackground.cloudBackground);
                          Navigator.pop(context);
                        },
                      ),
                      // Snow
                      _buildThemeOption(
                        label: 'Snow',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/snow_pattern.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () {
                          _applyBackground(NoteBackground.snowBackground);
                          Navigator.pop(context);
                        },
                      ),
                      // Banana
                      _buildThemeOption(
                        label: 'Banana',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            image: const DecorationImage(
                              image: AssetImage('assets/images/banana_pattern.png'),
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onTap: () {
                          _applyBackground(NoteBackground.bananaBackground);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
                // 添加透明度滑块
                if (currentBackground != null && currentBackground.type != BackgroundType.none)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Opacity',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: Slider(
                                value: opacity,
                                min: 0.1,
                                max: 1.0,
                                onChanged: (value) {
                                  setState(() {
                                    _applyBackground(
                                      NoteBackground(
                                        type: currentBackground.type,
                                        assetPath: currentBackground.assetPath,
                                        opacity: value,
                                      ),
                                    );
                                  });
                                },
                              ),
                            ),
                            Text(
                              '${(opacity * 100).round()}%',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeOption({
    required String label,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _updateToolbarColor(ImageProvider imageProvider) async {
    try {
      final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        size: const Size(100, 100), // 使用较小的图片尺寸以提高性能
      );

      if (mounted) {
        setState(() {
          _toolbarColor = paletteGenerator.dominantColor?.color.withOpacity(0.9) ??
                         paletteGenerator.lightVibrantColor?.color.withOpacity(0.9) ??
                         Colors.white.withOpacity(0.9);
        });
      }
    } catch (e) {
      debugPrint('Error generating palette: $e');
    }
  }

  // 修改工具栏的构建
  Widget _buildToolbar() {
    return Container(
      decoration: BoxDecoration(
        color: _toolbarColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: _showFormatToolbar ? _buildFormatToolbar() : _buildMainToolbar(),
        ),
      ),
    );
  }

  // 添加主工具栏构建方法
  Widget _buildMainToolbar() {
    return Row(
      key: const ValueKey<String>('mainToolbar'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Tooltip(
          message: AppLocalizations.of(context).editor['list']!,
          child: IconButton(
            icon: const Icon(CupertinoIcons.list_bullet),
            onPressed: () {
              // 实现列表格式化
            },
            color: Colors.grey[700],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).editor['image']!,
          child: IconButton(
            icon: const Icon(CupertinoIcons.photo),
            onPressed: () {
              // 实现图片插入
            },
            color: Colors.grey[700],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).editor['draw']!,
          child: IconButton(
            icon: const Icon(CupertinoIcons.pencil),
            onPressed: () {
              // 实现绘画功能
            },
            color: Colors.grey[700],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).editor['checkList']!,
          child: IconButton(
            icon: const Icon(CupertinoIcons.checkmark_square),
            onPressed: () {
              // 实现任务列表
            },
            color: Colors.grey[700],
          ),
        ),
        Tooltip(
          message: AppLocalizations.of(context).editor['format']!,
          child: IconButton(
            icon: const Icon(CupertinoIcons.textformat),
            onPressed: () {
              setState(() {
                _showFormatToolbar = true;
              });
            },
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  // 添加格式化工具栏构建方法
  Widget _buildFormatToolbar() {
    return Row(
      key: const ValueKey<String>('formatToolbar'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.marker),
          onPressed: () {
            // 实现文本高亮功能
          },
          color: Colors.grey[700],
        ),
        TextButton(
          onPressed: () {
            // 实现 H1 标题
          },
          child: const Text('H1', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          )),
        ),
        TextButton(
          onPressed: () {
            // 实现 H2 标题
          },
          child: const Text('H2', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          )),
        ),
        TextButton(
          onPressed: () {
            // 实现 H3 标题
          },
          child: const Text('H3', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          )),
        ),
        TextButton(
          onPressed: () {
            // 实现文本加粗
          },
          child: const Text('B', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          )),
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () {
            setState(() {
              _showFormatToolbar = false;
            });
          },
          color: Colors.grey[700],
        ),
      ],
    );
  }

  Future<void> _shareAsImage() async {
    // 创建一个临时的 Overlay Entry 来显示加载指示器
    final overlayState = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black26,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );

    // 显示加载指示器
    overlayState.insert(overlayEntry);

    try {
      // 创建一个临时的 RepaintBoundary
      final tempKey = GlobalKey();
      final tempWidget = RepaintBoundary(
        key: tempKey,
        child: Material(
          child: ShareService.buildNotePreviewWidget(
            Note(
              id: widget.note?.id ?? const Uuid().v4(),
              title: _titleController.text,
              content: _contentController.text,
              createdAt: widget.note?.createdAt ?? DateTime.now(),
              modifiedAt: DateTime.now(),
              background: _currentBackground,
            ),
          ),
        ),
      );

      // 将临时 widget 插入到 Overlay 中（不可见）
      final tempOverlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          left: -99999, // 放在屏幕外
          child: tempWidget,
        ),
      );
      overlayState.insert(tempOverlayEntry);

      // 等待下一帧以确保 widget 已经完全渲染
      await Future.delayed(const Duration(milliseconds: 100));

      // 生成并分享图片
      await ShareService.shareNoteAsImage(
        Note(
          id: widget.note?.id ?? const Uuid().v4(),
          title: _titleController.text,
          content: _contentController.text,
          createdAt: widget.note?.createdAt ?? DateTime.now(),
          modifiedAt: DateTime.now(),
          background: _currentBackground,
        ),
        tempKey,
        context,
      );

      // 移除临时 widget
      tempOverlayEntry.remove();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share note as image: $e')),
        );
      }
    } finally {
      // 移除加载指示器
      overlayEntry.remove();
    }
  }

  // 添加 _applyBackground 方法
  void _applyBackground(NoteBackground background) async {
    setState(() {
      _currentBackground = background;
      _isEdited = true;
    });

    // 提取背景颜色
    if (background.type != BackgroundType.none) {
      final imageProvider = AssetImage(background.assetPath!);
      await _updateToolbarColor(imageProvider);
    } else {
      setState(() {
        _toolbarColor = Colors.white.withOpacity(0.9);
      });
    }
    
    // 如果是已有笔记，立即更新
    if (widget.note != null && mounted) {
      final notesModel = Provider.of<NotesModel>(context, listen: false);
      final updatedNote = widget.note!.copyWith(
        background: background,
        modifiedAt: DateTime.now(),
      );
      notesModel.updateNote(updatedNote);
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = _currentBackground ?? widget.note?.background;
    final textColor = background?.textColor ?? Colors.black;
    
    Widget buildBackgroundContainer(Widget child) {
      if (background == null || background.type == BackgroundType.none) {
        return Container(
          color: Colors.white,
          child: child,
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage(background.assetPath!),
            fit: background.isTileable ? BoxFit.none : BoxFit.cover,
            repeat: background.isTileable ? ImageRepeat.repeat : ImageRepeat.noRepeat,
            opacity: background.opacity ?? 1.0,
          ),
        ),
        child: child,
      );
    }

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
      child: buildBackgroundContainer(  // 将整个 Scaffold 包裹在背景容器中
        Scaffold(
          backgroundColor: Colors.transparent,  // 使 Scaffold 背景透明
          appBar: AppBar(
            backgroundColor: Colors.transparent,  // 使 AppBar 背景透明
            surfaceTintColor: Colors.transparent,
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
                icon: const FaIcon(FontAwesomeIcons.shirt), // 使用 FontAwesome t-shirt 图标
                onPressed: _showThemeOptions,
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.share),
                onPressed: _showShareOptions,
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.ellipsis_vertical),
                onPressed: _showOptionsMenu,
              ),
            ],
            iconTheme: IconThemeData(color: textColor),
          ),
          body: Column(
            children: [
              // 文件夹指示器
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: GestureDetector(
                  onTap: _showFolderSelector,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),  // 降低透明度
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
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
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).title,
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: textColor.withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) {
                        _contentFocusNode.requestFocus();
                      },
                      onChanged: (_) => _updateCharacterCount(),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        AppLocalizations.of(context).dateFormat['charactersCount']!
                            .replaceAll('{}', _characterCount.toString()) +
                        ' | ' +
                        DateFormat(AppLocalizations.of(context).dateFormat['fullDateTime']!)
                            .format(_lastModified),
                        style: TextStyle(
                          color: textColor.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ),
                    TextField(
                      controller: _contentController,
                      focusNode: _contentFocusNode,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: textColor,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).inputStartTyping,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: textColor.withOpacity(0.4),
                        ),
                        border: InputBorder.none,
                      ),
                      onChanged: (_) => _updateCharacterCount(),
                    ),
                  ],
                ),
              ),
              // 工具栏
              _buildToolbar(),
            ],
          ),
        ),
      ),
    );
  }
}

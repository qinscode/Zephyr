// lib/screens/note_editor_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:palette_generator/palette_generator.dart';
import 'package:image_cropper/image_cropper.dart';
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

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.content ?? '');
    _titleFocusNode = FocusNode();
    _contentFocusNode = FocusNode();
    _currentFolderId = widget.note?.folderId ?? widget.initialFolderId;
    _lastModified = widget.note?.modifiedAt ?? DateTime.now();
    _currentBackground = widget.note?.background; // 初始化背景

    // 添加文本变化监听
    _titleController.addListener(_onTextChanged);
    _contentController.addListener(_onTextChanged);

    // 初始化字符计数
    _updateCharacterCount();

    // 保存初始状态用于撤销
    _saveState();

    // 如果有背景，初始化工具栏颜色
    if (widget.note?.background != null && widget.note!.background!.type != BackgroundType.none) {
      ImageProvider imageProvider;
      if (widget.note!.background!.type == BackgroundType.preset) {
        imageProvider = AssetImage(widget.note!.background!.assetPath!);
      } else {
        imageProvider = FileImage(File(widget.note!.background!.customImagePath!));
      }
      _updateToolbarColor(imageProvider);
    }
  }

  @override
  void dispose() {
    // 在销毁时清理未使用的背景图片
    _cleanupUnusedBackgrounds();
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
              title: Text(l10n.getShareValue('exportAsMarkdown')),  // 使辅助方法
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
      builder: (context) => StatefulBuilder( // 使用 StatefulBuilder 以支持透明度调节
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
                        label: 'Cloud',  // 改为 Cloud
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
                        label: 'Snow',  // 改为 Snow
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
                        label: 'Banana',  // 改为 Banana
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
                      // Custom image option
                      _buildThemeOption(
                        label: 'Custom',
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            CupertinoIcons.photo,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _pickCustomBackground();
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
                                        customImagePath: currentBackground.customImagePath,
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

  Future<void> _pickCustomBackground() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,  // 限制最大宽度
      maxHeight: 1920, // 限制最大高度
    );
    
    if (image != null && mounted) {
      // 裁剪图片
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1), // 可选的宽高比
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Edit Background',
            toolbarColor: Colors.orange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            hideBottomControls: false,
          ),
          IOSUiSettings(
            title: 'Edit Background',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile != null && mounted) {
        bool isTileable = false;  // 将变量移到外部作用域
        
        // 显示背景设置对话框
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Background Settings'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 预览
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: FileImage(File(croppedFile.path)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // 平铺选项
                StatefulBuilder(
                  builder: (context, setState) {
                    return CheckboxListTile(
                      title: const Text('Tile Background'),
                      subtitle: const Text('Repeat the image to fill the screen'),
                      value: isTileable,
                      onChanged: (value) {
                        setState(() {
                          isTileable = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    );
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  
                  // 保存图片到应用目录
                  final directory = await getApplicationDocumentsDirectory();
                  final String imagePath = '${directory.path}/backgrounds/${DateTime.now().millisecondsSinceEpoch}.jpg';
                  
                  // 确保目录存在
                  await Directory('${directory.path}/backgrounds').create(recursive: true);
                  
                  // 复制图片到应用目录
                  await File(croppedFile.path).copy(imagePath);
                  
                  // 应用自定义背景
                  if (mounted) {
                    _applyBackground(
                      NoteBackground(
                        type: BackgroundType.custom,
                        customImagePath: imagePath,
                        isTileable: isTileable,  // 现在可以访问这个变量了
                      ),
                    );
                  }
                },
                child: const Text('Apply'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _applyBackground(NoteBackground background) async {
    setState(() {
      _currentBackground = background;
      _isEdited = true;
    });

    // 提取背景颜色
    if (background.type != BackgroundType.none) {
      ImageProvider imageProvider;
      if (background.type == BackgroundType.preset) {
        imageProvider = AssetImage(background.assetPath!);
      } else {
        imageProvider = FileImage(File(background.customImagePath!));
      }
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

  // 添加从图片提取颜色的方法
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
            color: Colors.grey[300]!,  // 修改为更浅的灰色
            width: 0.5,  // 添加更细的边框
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
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
                  // 实现文本格式化
                },
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 添加图片清理方法
  Future<void> _cleanupUnusedBackgrounds() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final backgroundsDir = Directory('${directory.path}/backgrounds');
      
      if (await backgroundsDir.exists()) {
        final files = await backgroundsDir.list().toList();
        final notesModel = Provider.of<NotesModel>(context, listen: false);
        final usedBackgrounds = notesModel.notes
            .where((note) => note.background?.customImagePath != null)
            .map((note) => note.background!.customImagePath!)
            .toSet();

        for (var file in files) {
          if (file is File && !usedBackgrounds.contains(file.path)) {
            await file.delete();
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning up backgrounds: $e');
    }
  }

  Future<void> _shareAsImage() async {
    // 显示预览对话框
    await showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: RepaintBoundary(
                key: _shareKey,
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
            ),
            ButtonBar(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context).cancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ShareService.shareNoteAsImage(
                      Note(
                        id: widget.note?.id ?? const Uuid().v4(),
                        title: _titleController.text,
                        content: _contentController.text,
                        createdAt: widget.note?.createdAt ?? DateTime.now(),
                        modifiedAt: DateTime.now(),
                      ),
                      _shareKey,
                      context,
                    );
                  },
                  child: Text(AppLocalizations.of(context).share),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = _currentBackground ?? widget.note?.background;
    
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
            image: background.type == BackgroundType.preset
                ? AssetImage(background.assetPath!)
                : FileImage(File(background.customImagePath!)) as ImageProvider,
            fit: background.isTileable ? BoxFit.none : BoxFit.cover,  // 根据是否可平铺选择适配方式
            repeat: background.isTileable ? ImageRepeat.repeat : ImageRepeat.noRepeat,  // 可平铺时启用重复
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
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).title,
                        hintStyle: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[400],
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
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context).inputStartTyping,
                        hintStyle: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: Colors.grey[400],
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

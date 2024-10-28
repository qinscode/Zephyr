import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/note_background.dart';
import '../models/notes_model.dart';
import '../models/folder_model.dart';
import '../models/trash_model.dart';
import '../screens/note_editor_screen.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);  // 获取本地化实例
    return Consumer2<NotesModel, FolderModel>(
      builder: (context, notesModel, folderModel, child) {
        final selectedFolderId = folderModel.selectedFolderId;
        final notes = selectedFolderId == null
            ? notesModel.notes
            : notesModel.getNotesByFolder(selectedFolderId);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // 搜索栏
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBar(
                    hintText: l10n.searchNotes,  // 使用本地化文本
                    leading: const Icon(CupertinoIcons.search),
                    backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest),
                    elevation: WidgetStateProperty.all(0),
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              // 当前文件名称
              if (selectedFolderId != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      folderModel.folders
                          .firstWhere((f) => f.id == selectedFolderId)
                          .name,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              // 笔记网格
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: notes.isEmpty
                    ? SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            l10n.noNotes,  // 使用本地化文本
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    : SliverMasonryGrid.extent(
                        maxCrossAxisExtent: 200,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        itemBuilder: (context, index) {
                          return _buildNoteCard(context, notes[index]);
                        },
                        childCount: notes.length,
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Widget _buildNotesGrid(List<Note> notes) {
  //   if (notes.isEmpty) {
  //     return Center(
  //       child: Text(
  //         'No notes yet',
  //         style: TextStyle(
  //           color: Colors.grey[600],
  //           fontSize: 16,
  //         ),
  //       ),
  //     );
  //   }
  //
  //   return GridView.builder(
  //     shrinkWrap: true,
  //     physics: const NeverScrollableScrollPhysics(),
  //     padding: const EdgeInsets.all(16.0),
  //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //       crossAxisCount: 2,
  //       crossAxisSpacing: 8,
  //       mainAxisSpacing: 8,
  //       childAspectRatio: 0.85,
  //     ),
  //     itemCount: notes.length,
  //     itemBuilder: (context, index) {
  //       final note = notes[index];
  //       return _buildNoteCard(context, note);
  //     },
  //   );
  // }

  Widget _buildNoteCard(BuildContext context, Note note) {
    final l10n = AppLocalizations.of(context);  // 获取本地化实例
    // 处理标题和内容
    String displayTitle = '';
    String displayContent = '';
    
    if (note.title.isNotEmpty) {
      displayTitle = note.title;
      displayContent = note.plainText.isNotEmpty ? note.plainText : l10n.noText;
    } else if (note.plainText.isNotEmpty) {
      final lines = note.plainText.split('\n');
      displayTitle = lines[0];
      displayContent = lines.length > 1 ? lines.sublist(1).join('\n') : l10n.noText;
    } else {
      displayTitle = l10n.untitled;
      displayContent = l10n.noText;
    }

    // 格式化时间
    String formattedTime = _formatDateTime(note.modifiedAt);

    Widget buildBackgroundContainer(Widget child) {
      if (note.background == null || note.background!.type == BackgroundType.none) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16), // 增加圆角
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        );
      }

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // 增加圆角
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(note.background!.assetPath!),
            fit: note.background!.isTileable ? BoxFit.none : BoxFit.cover,
            repeat: note.background!.isTileable ? ImageRepeat.repeat : ImageRepeat.noRepeat,
            opacity: note.background!.opacity ?? 1.0,
          ),
        ),
        child: child,
      );
    }

    final textColor = note.background?.textColor ?? Colors.black;

    return GestureDetector(
      onTap: () => _openNote(context, note),
      onLongPress: () => _showNoteOptions(context, note),
      child: buildBackgroundContainer(
        Card(
          elevation: 0, // 移除卡片阴影
          color: Colors.transparent, // 使卡片背景透明
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // 增加圆角
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0), // 增加内边距
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 标题
                Text(
                  displayTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                // 内容
                Text(
                  displayContent,
                  maxLines: 8,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 14,
                    color: textColor.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                // 时间
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, Note note) {
    final l10n = AppLocalizations.of(context);  // 获取本地化实例
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(CupertinoIcons.folder),
                title: Text(l10n.moveToFolder),  // 使用本地化文本
                onTap: () {
                  Navigator.pop(context);
                  _showMoveToFolderDialog(context, note);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.share),
                title: Text(l10n.share),  // 使用本地化文本
                onTap: () {
                  Navigator.pop(context);
                  // Implement share functionality
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.delete),
                title: Text(l10n.moveToTrash),  // 使用本地化文本
                onTap: () {
                  final notesModel = Provider.of<NotesModel>(
                    context,
                    listen: false,
                  );
                  final trashModel = Provider.of<TrashModel>(
                    context,
                    listen: false,
                  );

                  trashModel.addToTrash(note);
                  notesModel.deleteNote(note.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoveToFolderDialog(
      BuildContext context,
      Note note,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        final folderModel = Provider.of<FolderModel>(context, listen: false);
        
        return AlertDialog(
          title: const Text('Move to folder'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(CupertinoIcons.folder),
                  title: const Text('Uncategorized'),
                  onTap: () {
                    final notesModel = Provider.of<NotesModel>(
                      context,
                      listen: false,
                    );
                    notesModel.moveNoteToFolder(note.id, null);
                    Navigator.pop(context);
                  },
                ),
                ...folderModel.folders.map(
                  (folder) => ListTile(
                    leading: const Icon(CupertinoIcons.folder),
                    title: Text(folder.name),
                    onTap: () {
                      final notesModel = Provider.of<NotesModel>(
                        context,
                        listen: false,
                      );
                      notesModel.moveNoteToFolder(note.id, folder.id);
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _openNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(
          note: note,
        ),
      ),
    );
  }

  // 添加时间格式化方法
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      // 今天 - 显示具体时间
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays == 1) {
      // 昨天 - 显示 "Yesterday HH:mm"
      return 'Yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      // 更早 - 显示完整日期
      return DateFormat('yyyy-MM-dd').format(dateTime);
    }
  }
}

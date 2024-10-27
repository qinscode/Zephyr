// lib/widgets/notes_view.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/notes_model.dart';
import '../models/folder_model.dart';
import '../models/trash_model.dart';
import '../screens/folders_screen.dart';
import '../screens/note_editor_screen.dart';
import '../screens/settings_screen.dart';
import 'base_view.dart';

class NotesView extends StatelessWidget {
  const NotesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesModel, FolderModel>(
      builder: (context, notesModel, folderModel, child) {
        final selectedFolderId = folderModel.selectedFolderId;
        final notes = selectedFolderId == null
            ? notesModel.notes
            : notesModel.getNotesByFolder(selectedFolderId);

        return BaseView(
          title: 'Notes',
          actions: [
            IconButton(
              icon: const Icon(CupertinoIcons.folder),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FoldersScreen(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.settings),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
          body: SliverList(
            delegate: SliverChildListDelegate([
              // 搜索栏
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SearchBar(
                  hintText: 'Search notes',
                  leading: const Icon(CupertinoIcons.search),
                  backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
                  elevation: MaterialStateProperty.all(0),
                  padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide.none,
                    ),
                  ),
                ),
              ),
              // 当前文件夹名称
              if (selectedFolderId != null)
                Padding(
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
              // 笔记网格
              _buildNotesGrid(notes),
            ]),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditorScreen(
                    initialFolderId: selectedFolderId,
                  ),
                ),
              );
            },
            child: const Icon(CupertinoIcons.add),
          ),
        );
      },
    );
  }

  Widget _buildNotesGrid(List<Note> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Text(
          'No notes yet',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(context, note);
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return GestureDetector(
      onTap: () => _openNote(context, note),
      onLongPress: () => _showNoteOptions(context, note),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  note.content,
                  maxLines: 6,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, Note note) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(CupertinoIcons.folder),
                title: const Text('Move to folder'),
                onTap: () {
                  Navigator.pop(context);
                  _showMoveToFolderDialog(context, note);
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.share),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement share functionality
                },
              ),
              ListTile(
                leading: const Icon(CupertinoIcons.delete),
                title: const Text('Move to trash'),
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
}

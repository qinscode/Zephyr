// lib/widgets/notes_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note.dart';
import '../models/notes_model.dart';
import '../models/folder_model.dart';
import '../models/trash_model.dart';
import '../screens/folders_screen.dart';
import '../screens/note_editor_screen.dart';
import '../screens/settings_screen.dart';

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

        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                backgroundColor: Colors.white,
                elevation: 0,
                title: const Text('Notes'),
                actions: [
                  // Folder button
                  IconButton(
                    icon: const Icon(Icons.folder_outlined),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FoldersScreen(),
                        ),
                      );
                    },
                  ),
                  // Settings button
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
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
              ),
              // Search bar
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SearchBar(
                    hintText: 'Search notes',
                    leading: const Icon(Icons.search),
                    padding: MaterialStateProperty.all(
                      const EdgeInsets.symmetric(horizontal: 16.0),
                    ),
                  ),
                ),
              ),
              // Current folder name
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
              // Notes grid
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: notes.isEmpty
                    ? SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'No notes yet',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
                    : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final note = notes[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NoteEditorScreen(
                                note: note,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showNoteOptions(context, note, folderModel);
                        },
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
                    },
                    childCount: notes.length,
                  ),
                ),
              ),
            ],
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
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }

  void _showNoteOptions(BuildContext context, Note note, FolderModel folderModel) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined),
                title: const Text('Move to folder'),
                onTap: () {
                  Navigator.pop(context);
                  _showMoveToFolderDialog(context, note, folderModel);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share'),
                onTap: () {
                  Navigator.pop(context);
                  // Implement share functionality
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
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
      FolderModel folderModel,
      ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Move to folder'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
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
                    leading: const Icon(Icons.folder_outlined),
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
}

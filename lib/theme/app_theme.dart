import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/folder_model.dart';

class FoldersScreen extends StatefulWidget {
  const FoldersScreen({super.key});

  @override
  State<FoldersScreen> createState() => _FoldersScreenState();
}

class _FoldersScreenState extends State<FoldersScreen> {
  final _folderNameController = TextEditingController();

  @override
  void dispose() {
    _folderNameController.dispose();
    super.dispose();
  }

  void _showCreateFolderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New folder'),
        content: TextField(
          controller: _folderNameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _folderNameController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_folderNameController.text.isNotEmpty) {
                final folderModel = Provider.of<FolderModel>(
                    context,
                    listen: false
                );
                folderModel.createFolder(_folderNameController.text);
                Navigator.pop(context);
                _folderNameController.clear();
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteFolderDialog(Folder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete folder?'),
        content: Text(
          'Are you sure you want to delete "${folder.name}"? '
              'All notes in this folder will be moved to Uncategorized.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final folderModel = Provider.of<FolderModel>(
                  context,
                  listen: false
              );
              folderModel.deleteFolder(folder.id);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameFolderDialog(Folder folder) {
    _folderNameController.text = folder.name;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename folder'),
        content: TextField(
          controller: _folderNameController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Folder name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _folderNameController.clear();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_folderNameController.text.isNotEmpty) {
                final folderModel = Provider.of<FolderModel>(
                    context,
                    listen: false
                );
                folderModel.renameFolder(folder.id, _folderNameController.text);
                Navigator.pop(context);
                _folderNameController.clear();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderModel>(
      builder: (context, folderModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Folders'),
            actions: const [
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: null,
              ),
            ],
          ),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.folder_outlined, color: Colors.orange),
                title: const Text('All'),
                trailing: Text(
                  folderModel.totalNoteCount.toString(),
                  style: TextStyle(color: Colors.grey[600]),
                ),
                selected: folderModel.selectedFolderId == null,
                onTap: () {
                  folderModel.selectFolder(null);
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              ...folderModel.folders.map((folder) {
                return ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: Text(folder.name),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        folder.noteCount.toString(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'rename',
                            child: Text('Rename'),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text(
                              'Delete',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'rename') {
                            _showRenameFolderDialog(folder);
                          } else if (value == 'delete') {
                            _showDeleteFolderDialog(folder);
                          }
                        },
                      ),
                    ],
                  ),
                  selected: folderModel.selectedFolderId == folder.id,
                  onTap: () {
                    folderModel.selectFolder(folder.id);
                    Navigator.pop(context);
                  },
                );
              }),
              ListTile(
                leading: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.orange[400],
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                title: const Text('New folder'),
                onTap: _showCreateFolderDialog,
              ),
            ],
          ),
        );
      },
    );
  }
}
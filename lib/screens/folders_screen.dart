// lib/screens/folders_screen.dart
import 'package:flutter/cupertino.dart';
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
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New folder'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: _folderNameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Folder name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a folder name';
              }

              final folderModel = Provider.of<FolderModel>(
                context,
                listen: false,
              );
              if (folderModel.folderExists(value.trim())) {
                return 'A folder with this name already exists';
              }
              return null;
            },
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
              if (formKey.currentState?.validate() ?? false) {
                final folderModel = Provider.of<FolderModel>(
                  context,
                  listen: false,
                );
                folderModel.createFolder(_folderNameController.text.trim());
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
    showDialog<void>(
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
                listen: false,
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
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename folder'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: _folderNameController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Folder name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter a folder name';
              }

              final folderModel = Provider.of<FolderModel>(
                context,
                listen: false,
              );
              final newName = value.trim();
              if (newName != folder.name && folderModel.folderExists(newName)) {
                return 'A folder with this name already exists';
              }
              return null;
            },
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
              if (formKey.currentState?.validate() ?? false) {
                final folderModel = Provider.of<FolderModel>(
                  context,
                  listen: false,
                );
                folderModel.renameFolder(folder.id, _folderNameController.text.trim());
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
              icon: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Folders'),
          ),
          body: Stack(
            children: [
              ListView(
                children: [
                  ListTile(
                    leading: const Icon(CupertinoIcons.folder, color: Colors.orange),
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
                  if (folderModel.folders.isNotEmpty) const Divider(height: 1),
                  ...folderModel.folders.map((folder) {
                    return ListTile(
                      leading: const Icon(CupertinoIcons.folder),
                      title: Text(folder.name),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            folder.noteCount.toString(),
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          PopupMenuButton<String>(
                            icon: const Icon(CupertinoIcons.ellipsis_vertical),
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
                  }).toList(),
                  if (folderModel.folders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'No folders yet',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ),
                ],
              ),
              if (folderModel.isLoading)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _showCreateFolderDialog,
            child: const Icon(CupertinoIcons.add),
          ),
        );
      },
    );
  }
}

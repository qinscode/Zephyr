// lib/screens/folders_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/folder_model.dart';
import '../l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context);

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newFolder),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: _folderNameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.folderName,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.folderName;
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
            child: Text(l10n.cancel),
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
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _showDeleteFolderDialog(Folder folder) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteFolder),
        content: Text(l10n.deleteFolderConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
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
            child: Text(
              l10n.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameFolderDialog(Folder folder) {
    final l10n = AppLocalizations.of(context);
    _folderNameController.text = folder.name;
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameFolder),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: _folderNameController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.folderName,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.folderName;
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
            child: Text(l10n.cancel),
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
            child: Text(l10n.rename),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
            title: Text(l10n.folders),
          ),
          body: Stack(
            children: [
              ListView(
                children: [
                  ListTile(
                    leading: const Icon(CupertinoIcons.folder, color: Colors.orange),
                    title: Text(l10n.all),
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
                              PopupMenuItem(
                                value: 'rename',
                                child: Text(l10n.rename),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  l10n.delete,
                                  style: const TextStyle(color: Colors.red),
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

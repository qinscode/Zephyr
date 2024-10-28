import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/folder_model.dart';
import '../models/notes_model.dart';
import '../l10n/app_localizations.dart';
import 'trash_screen.dart';

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
            actions: [
              IconButton(
                icon: const Icon(CupertinoIcons.trash),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TrashScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // All folder item
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 0,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: const Icon(
                        CupertinoIcons.checkmark_circle_fill,
                        color: Colors.orange,
                      ),
                      title: Text(
                        l10n.all,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: Consumer<NotesModel>(
                        builder: (context, notesModel, child) {
                          // 对于 All 选项，显示所有笔记的数量
                          return Text(
                            notesModel.notes.length.toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        folderModel.selectFolder(null);
                        Navigator.pop(context);
                      },
                    ),
                  ),

                  // Other folders list
                  if (folderModel.folders.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    ...folderModel.folders.map((folder) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 0,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          title: Text(
                            folder.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          trailing: Consumer<NotesModel>(
                            builder: (context, notesModel, child) {
                              final count = notesModel.getNotesByFolder(folder.id).length;
                              return Text(
                                count.toString(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              );
                            },
                          ),
                          onTap: () {
                            folderModel.selectFolder(folder.id);
                            Navigator.pop(context);
                          },
                        ),
                      );
                    }),
                  ],

                  // New folder button
                  const SizedBox(height: 32),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: const Icon(CupertinoIcons.plus),
                          color: Colors.white,
                          onPressed: _showCreateFolderDialog,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.newFolder,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
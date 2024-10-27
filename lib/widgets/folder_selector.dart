// lib/widgets/folder_selector.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/folder_model.dart';

class FolderSelector extends StatelessWidget {
  final String? currentFolderId;

  const FolderSelector({
    super.key,
    this.currentFolderId,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Folder'),
      contentPadding: const EdgeInsets.only(top: 16),
      content: Consumer<FolderModel>(
        builder: (context, folderModel, child) {
          return SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                // Uncategorized option
                ListTile(
                  leading: const Icon(Icons.folder_outlined),
                  title: const Text('Uncategorized'),
                  selected: currentFolderId == null,
                  onTap: () {
                    Navigator.pop<String?>(context, null);
                  },
                ),
                // Existing folders
                ...folderModel.folders.map(
                      (folder) => ListTile(
                    leading: const Icon(Icons.folder_outlined),
                    title: Text(folder.name),
                    selected: folder.id == currentFolderId,
                    onTap: () {
                      Navigator.pop<String?>(context, folder.id);
                    },
                  ),
                ),
                // Divider before create new folder option
                const Divider(height: 1),
                // Create new folder option
                ListTile(
                  leading: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.add,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: const Text('Create new folder'),
                  onTap: () => _showCreateFolderDialog(context),
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final textController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Folder'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: textController,
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
                dialogContext,
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
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState?.validate() ?? false) {
                final folderModel = Provider.of<FolderModel>(
                  dialogContext,
                  listen: false,
                );
                final newFolder = folderModel.createFolder(
                  textController.text.trim(),
                );
                Navigator.pop(dialogContext); // Close create folder dialog
                Navigator.pop<String>(context, newFolder.id); // Close folder selector
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }
}

// Folder selector button
class FolderSelectorButton extends StatelessWidget {
  final String? currentFolderId;
  final ValueChanged<String?> onFolderSelected;

  const FolderSelectorButton({
    super.key,
    this.currentFolderId,
    required this.onFolderSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FolderModel>(
      builder: (context, folderModel, child) {
        final folderName = currentFolderId != null
            ? folderModel.getFolderName(currentFolderId!)
            : 'Uncategorized';

        return InkWell(
          onTap: () async {
            final selectedFolderId = await showDialog<String?>(
              context: context,
              builder: (context) => FolderSelector(
                currentFolderId: currentFolderId,
              ),
            );

            if (selectedFolderId != currentFolderId) {
              onFolderSelected(selectedFolderId);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.folder_outlined,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  folderName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
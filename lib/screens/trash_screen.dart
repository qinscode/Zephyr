import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/trash_model.dart';
import '../models/note.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TrashModel>(
      builder: (context, trashModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Trash'),
            actions: [
              if (trashModel.trashedItems.isNotEmpty)
                TextButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Empty trash?'),
                        content: const Text(
                            'All items in trash will be permanently deleted.'
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              trashModel.emptyTrash();
                              Navigator.pop(context);
                            },
                            child: const Text(
                              'Empty',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  child: const Text(
                    'Empty',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: const Color(0xFFFFF9E6),
                child: const Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Items in the trash are kept for 30 days before being permanently deleted',
                        style: TextStyle(
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: trashModel.trashedItems.isEmpty
                    ? const Center(
                  child: Text(
                    'No items in trash',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: trashModel.trashedItems.length,
                  itemBuilder: (context, index) {
                    final item = trashModel.trashedItems[index];
                    return Dismissible(
                      key: Key(item.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(
                          Icons.delete_forever,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        trashModel.deletePermanently(item.id);
                      },
                      child: ListTile(
                        title: Text(
                          item.title.isEmpty ? 'No text' : item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          'Deleted ${_formatDate(item.deletedAt!)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        trailing: PopupMenuButton(
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'restore',
                              child: Text('Restore'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text(
                                'Delete permanently',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                          onSelected: (value) {
                            if (value == 'restore') {
                              trashModel.restoreItem(item.id);
                            } else if (value == 'delete') {
                              trashModel.deletePermanently(item.id);
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('h:mm a').format(date)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }
}
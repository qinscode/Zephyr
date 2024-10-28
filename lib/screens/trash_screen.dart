import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/trash_model.dart';
import '../l10n/app_localizations.dart';

class TrashScreen extends StatelessWidget {
  const TrashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<TrashModel>(
      builder: (context, trashModel, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Trash',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              // Warning banner
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Items are kept in the trash for 30 days before being permanently deleted',
                  style: TextStyle(
                    color: Colors.orange[700],
                    fontSize: 14,
                  ),
                ),
              ),

              // Trash items list
              Expanded(
                child: trashModel.trashedItems.isEmpty
                    ? Center(
                  child: Text(
                    l10n.alerts['noItemsInTrash']!,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: trashModel.trashedItems.length,
                  itemBuilder: (context, index) {
                    final item = trashModel.trashedItems[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          item.title.isEmpty ? 'ejernmtmmtmmttm' : item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'No text',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(item.deletedAt),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: const Icon(
                            CupertinoIcons.ellipsis_circle,
                            color: Colors.grey,
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              child: Text(l10n.restore),
                              onTap: () => trashModel.restoreItem(item.id),
                            ),
                            PopupMenuItem(
                              child: Text(
                                l10n.deletePermanently,
                                style: const TextStyle(color: Colors.red),
                              ),
                              onTap: () => trashModel.deletePermanently(item.id),
                            ),
                          ],
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
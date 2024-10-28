import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../l10n/app_localizations.dart';

class MoreOptions extends StatelessWidget {
  final VoidCallback onMoveToFolder;
  final VoidCallback onMoveToTrash;

  const MoreOptions({
    super.key,
    required this.onMoveToFolder,
    required this.onMoveToTrash,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(CupertinoIcons.folder),
            title: Text(l10n.moveToFolder),
            onTap: () {
              Navigator.pop(context);
              onMoveToFolder();
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.delete),
            title: Text(l10n.moveToTrash),
            onTap: () {
              Navigator.pop(context);
              onMoveToTrash();
            },
          ),
        ],
      ),
    );
  }
}

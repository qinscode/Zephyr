import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../models/folder_model.dart';

class FolderIndicator extends StatelessWidget {
  final String? folderId;
  final VoidCallback onTap;

  const FolderIndicator({
    super.key,
    required this.folderId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(CupertinoIcons.folder, size: 18),
                const SizedBox(width: 4),
                Consumer<FolderModel>(
                  builder: (context, folderModel, child) {
                    final folderName = folderId != null
                        ? folderModel.getFolderName(folderId!)
                        : 'Uncategorized';
                    return Text(folderName);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

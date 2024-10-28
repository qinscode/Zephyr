import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';

class EditorContent extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController contentController;
  final FocusNode titleFocusNode;
  final FocusNode contentFocusNode;
  final Color textColor;
  final int characterCount;
  final DateTime lastModified;

  const EditorContent({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.titleFocusNode,
    required this.contentFocusNode,
    required this.textColor,
    required this.characterCount,
    required this.lastModified,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: titleController,
          focusNode: titleFocusNode,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).title,
            hintStyle: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.4),
            ),
            border: InputBorder.none,
          ),
          onSubmitted: (_) {
            contentFocusNode.requestFocus();
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '$characterCount characters | ${DateFormat('yyyy-MM-dd HH:mm').format(lastModified)}',
            style: TextStyle(
              color: textColor.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ),
        TextField(
          controller: contentController,
          focusNode: contentFocusNode,
          maxLines: null,
          style: TextStyle(
            fontSize: 16,
            height: 1.5,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context).inputStartTyping,
            hintStyle: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: textColor.withOpacity(0.4),
            ),
            border: InputBorder.none,
          ),
        ),
      ],
    );
  }
}

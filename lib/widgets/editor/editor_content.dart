import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';

class EditorContent extends StatelessWidget {
  final QuillController titleController;
  final QuillController contentController;
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
        // 标题编辑器
        QuillEditor(
          controller: titleController,
          scrollController: ScrollController(),
          focusNode: titleFocusNode,
          configurations: QuillEditorConfigurations(
            scrollable: false,
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero,
            placeholder: 'Title',
            enableInteractiveSelection: true,
            enableSelectionToolbar: true,
            detectWordBoundary: true,
            showCursor: true,
            // 修改触控处理函数签名
            onTapUp: (details, getPosition) {
              titleFocusNode.requestFocus();
              return false;
            },
            onTapDown: (details, getPosition) {
              titleFocusNode.requestFocus();
              return false;
            },
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                  color: textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
            ),
          ),
        ),
        
        // 字数统计和时间
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

        // 内容编辑器
        QuillEditor(
          controller: contentController,
          scrollController: ScrollController(),
          focusNode: contentFocusNode,
          configurations: QuillEditorConfigurations(
            scrollable: true,
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero,
            placeholder: 'Start typing...',
            enableInteractiveSelection: true,
            enableSelectionToolbar: true,
            detectWordBoundary: true,
            showCursor: true,
            // 修改触控处理函数签名
            onTapUp: (details, getPosition) {
              contentFocusNode.requestFocus();
              return false;
            },
            onTapDown: (details, getPosition) {
              contentFocusNode.requestFocus();
              return false;
            },
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
              h1: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 32,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(16, 8),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
              h2: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 24,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(12, 8),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
              h3: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 20,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(8, 8),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
              bold: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              lists: DefaultListBlockStyle(
                TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
                null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

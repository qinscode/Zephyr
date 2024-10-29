// lib/services/share/widgets/rich_text_renderer.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../constants/share_constants.dart';
import 'share_image_embed_builder.dart';

class RichTextRenderer {
  static Widget build(List<dynamic>? deltaJson, String plainText, TextStyle style) {
    if (deltaJson != null) {
      try {
        final doc = Document.fromJson(deltaJson);
        final controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );

        return Container(
          constraints: BoxConstraints(
            maxWidth: ShareConstants.shareImageWidth - (ShareConstants.horizontalPadding * 2),
          ),
          child: QuillEditor(
            controller: controller,
            scrollController: ScrollController(),
            focusNode: FocusNode(),
            configurations: QuillEditorConfigurations(
              autoFocus: false,
              expands: false,
              scrollable: false,
              enableInteractiveSelection: false,
              showCursor: false,
              padding: EdgeInsets.zero,
              customStyles: DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  style,
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const BoxDecoration(),
                ),
              ),
              embedBuilders: [
                ShareImageEmbedBuilder(),
              ],
            ),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('Error rendering rich text: $e');
        debugPrint('Stack trace: $stackTrace');
      }
    }

    return Text(
      plainText,
      style: style,
    );
  }
}
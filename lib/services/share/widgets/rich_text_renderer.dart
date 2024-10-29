// lib/services/share/widgets/rich_text_renderer.dart
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../constants/share_constants.dart';
import 'share_image_embed_builder.dart';
import '../../../models/note_background.dart';

class RichTextRenderer {
  static Widget build(
    List<dynamic>? deltaJson, 
    String plainText, 
    TextStyle style,
    {NoteBackground? background}
  ) {
    final textColor = background?.textColor ?? style.color ?? Colors.black;
    
    if (deltaJson != null) {
      try {
        final doc = Document.fromJson(deltaJson);
        final controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );

        return Container(
          constraints: BoxConstraints(
            maxWidth: ShareConstants.dimensions.width - (ShareConstants.layout.horizontalPadding * 2),
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
                  style.copyWith(color: textColor),
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const BoxDecoration(),
                ),
                h1: DefaultTextBlockStyle(
                  TextStyle(
                    fontSize: ShareConstants.typography.h1FontSize,
                    fontWeight: FontWeight.bold,
                    height: ShareConstants.typography.contentLineHeight,
                    color: textColor,
                  ),
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const BoxDecoration(),
                ),
                h2: DefaultTextBlockStyle(
                  TextStyle(
                    fontSize: ShareConstants.typography.h2FontSize,
                    fontWeight: FontWeight.bold,
                    height: ShareConstants.typography.contentLineHeight,
                    color: textColor,
                  ),
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const BoxDecoration(),
                ),
                h3: DefaultTextBlockStyle(
                  TextStyle(
                    fontSize: ShareConstants.typography.h3FontSize,
                    fontWeight: FontWeight.bold,
                    height: ShareConstants.typography.contentLineHeight,
                    color: textColor,
                  ),
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const BoxDecoration(),
                ),
                lists: DefaultListBlockStyle(
                  TextStyle(
                    fontSize: ShareConstants.typography.listFontSize,
                    height: ShareConstants.typography.contentLineHeight,
                    color: textColor,
                  ),
                  const HorizontalSpacing(24, 0),
                  const VerticalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const BoxDecoration(),
                  null,
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
      style: style.copyWith(color: textColor),
    );
  }
}
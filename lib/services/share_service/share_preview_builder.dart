import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/note.dart';
import '../../models/note_background.dart';
import 'share_constants.dart';
import 'share_rich_text_builder.dart';

class SharePreviewBuilder {
  static Widget buildNotePreview(Note note) {
    return Container(
      width: ShareConstants.shareImageWidth,
      constraints: const BoxConstraints(
        minHeight: ShareConstants.shareImageMinHeight,
      ),
      decoration: _getBackgroundDecoration(note.background),
      child: Padding(
        padding: const EdgeInsets.only(
          left: ShareConstants.horizontalPadding,
          right: ShareConstants.horizontalPadding,
          top: ShareConstants.verticalPadding,
          bottom: ShareConstants.bottomPadding,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.title.isNotEmpty) ...[
              ShareRichTextBuilder.buildRichText(
                deltaJson: note.titleDeltaJson,
                plainText: note.title,
                baseStyle: TextStyle(
                  fontSize: ShareConstants.titleFontSize,
                  fontWeight: FontWeight.bold,
                  height: ShareConstants.contentLineHeight,
                  color: note.background?.textColor ?? Colors.black,
                ),
                textColor: note.background?.textColor ?? Colors.black,
              ),
              SizedBox(height: ShareConstants.titleBottomSpacing),
            ],
            if (note.content.isNotEmpty)
              ShareRichTextBuilder.buildRichText(
                deltaJson: note.content.first.deltaJson,
                plainText: note.content.first.text,
                baseStyle: TextStyle(
                  fontSize: ShareConstants.contentFontSize,
                  height: ShareConstants.contentLineHeight,
                  color: note.background?.textColor ?? Colors.black,
                ),
                textColor: note.background?.textColor ?? Colors.black,
              ),
            SizedBox(height: ShareConstants.contentBottomSpacing),
            Opacity(
              opacity: ShareConstants.dividerOpacity,
              child: Divider(
                height: ShareConstants.dividerHeight,
                thickness: ShareConstants.dividerHeight,
              ),
            ),
            SizedBox(height: ShareConstants.dividerBottomSpacing),
            SizedBox(
              height: ShareConstants.bottomAreaHeight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Created with Notes App',
                    style: TextStyle(
                      color: note.background?.textColor?.withOpacity(0.6) ?? Colors.grey,
                      fontSize: ShareConstants.watermarkFontSize,
                      letterSpacing: ShareConstants.watermarkLetterSpacing,
                    ),
                  ),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(note.createdAt),
                    style: TextStyle(
                      color: note.background?.textColor?.withOpacity(0.6) ?? Colors.grey,
                      fontSize: ShareConstants.watermarkFontSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static BoxDecoration _getBackgroundDecoration(NoteBackground? background) {
    if (background == null || background.type == BackgroundType.none) {
      return const BoxDecoration(color: Colors.white);
    }

    return BoxDecoration(
      color: Colors.white,
      image: DecorationImage(
        image: AssetImage(background.assetPath!),
        fit: background.isTileable ? BoxFit.none : BoxFit.cover,
        repeat: background.isTileable ? ImageRepeat.repeat : ImageRepeat.noRepeat,
        opacity: background.opacity ?? 1.0,
      ),
    );
  }
}
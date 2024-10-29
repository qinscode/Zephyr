// lib/services/share/widgets/preview_builder.dart
import 'package:flutter/material.dart';
import '../../../models/note_background.dart';
import '../constants/share_constants.dart';
import 'rich_text_renderer.dart';
import '../../../models/note.dart';

class PreviewBuilder {
  static Widget build(Note note) {
    return SingleChildScrollView(
      child: Container(
        width: ShareConstants.dimensions.width,
        constraints: BoxConstraints(
          minHeight: ShareConstants.dimensions.minHeight,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ShareConstants.layout.borderRadius),
        ),
        child: Stack(
          children: [
            _buildBackground(note),
            _buildContent(note),
            _buildFooter(note),
          ],
        ),
      ),
    );
  }

  static Widget _buildBackground(Note note) {
    if (note.background != null && note.background!.type != BackgroundType.none) {
      return Positioned.fill(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ShareConstants.layout.borderRadius),
            image: DecorationImage(
              image: AssetImage(note.background!.assetPath!),
              fit: note.background!.isTileable ? BoxFit.none : BoxFit.cover,
              repeat: note.background!.isTileable ? ImageRepeat.repeat : ImageRepeat.noRepeat,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  static Widget _buildContent(Note note) {
    return Padding(
      padding: EdgeInsets.only(
        left: ShareConstants.layout.horizontalPadding,
        right: ShareConstants.layout.horizontalPadding,
        top: ShareConstants.layout.verticalPadding,
        bottom: ShareConstants.bottomArea.height + ShareConstants.bottomArea.padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.title.isNotEmpty) ...[
            RichTextRenderer.build(
              note.titleDeltaJson,
              note.title,
              TextStyle(
                fontSize: ShareConstants.typography.titleFontSize,
                fontWeight: FontWeight.bold,
                height: ShareConstants.typography.contentLineHeight,
              ),
              background: note.background,
            ),
            SizedBox(height: ShareConstants.spacing.titleBottomSpacing),
          ],
          if (note.content.isNotEmpty)
            Flexible(
              child: RichTextRenderer.build(
                note.content.first.deltaJson,
                note.content.first.text,
                TextStyle(
                  fontSize: ShareConstants.typography.contentFontSize,
                  height: ShareConstants.typography.contentLineHeight,
                ),
                background: note.background,
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildFooter(Note note) {
    return Positioned(
      left: ShareConstants.layout.horizontalPadding,
      right: ShareConstants.layout.horizontalPadding,
      bottom: ShareConstants.bottomArea.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: ShareConstants.divider.height,
            color: Colors.grey.withOpacity(ShareConstants.divider.opacity),
          ),
          SizedBox(height: ShareConstants.spacing.dividerBottomSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created By Swift App',
                style: TextStyle(
                  fontSize: ShareConstants.typography.watermarkFontSize,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                  letterSpacing: ShareConstants.typography.watermarkLetterSpacing,
                ),
              ),
              Text(
                note.createdAt.toString().split('.')[0],
                style: TextStyle(
                  fontSize: ShareConstants.typography.watermarkFontSize,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
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
        width: ShareConstants.shareImageWidth,
        constraints: const BoxConstraints(
          minHeight: ShareConstants.shareImageMinHeight,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ShareConstants.borderRadius),
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
            borderRadius: BorderRadius.circular(ShareConstants.borderRadius),
            image: DecorationImage(
              image: AssetImage(note.background!.assetPath!),
              fit: note.background!.isTileable ? BoxFit.none : BoxFit.cover,
              repeat: note.background!.isTileable ? ImageRepeat.repeat : ImageRepeat.noRepeat,
              opacity: note.background!.opacity ?? 1.0,
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  static Widget _buildContent(Note note) {
    return Padding(
      padding: const EdgeInsets.only(
        left: ShareConstants.horizontalPadding,
        right: ShareConstants.horizontalPadding,
        top: ShareConstants.verticalPadding,
        bottom: ShareConstants.bottomAreaHeight + ShareConstants.bottomPadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (note.title.isNotEmpty) ...[
            RichTextRenderer.build(
              note.titleDeltaJson,
              note.title,
              const TextStyle(
                fontSize: ShareConstants.titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                height: ShareConstants.contentLineHeight,
              ),
            ),
            const SizedBox(height: ShareConstants.titleBottomSpacing),
          ],
          if (note.content.isNotEmpty)
            Flexible(
              child: RichTextRenderer.build(
                note.content.first.deltaJson,
                note.content.first.text,
                const TextStyle(
                  fontSize: ShareConstants.contentFontSize,
                  color: Colors.black87,
                  height: ShareConstants.contentLineHeight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  static Widget _buildFooter(Note note) {
    return Positioned(
      left: ShareConstants.horizontalPadding,
      right: ShareConstants.horizontalPadding,
      bottom: ShareConstants.bottomPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: ShareConstants.dividerHeight,
            color: Colors.grey.withOpacity(ShareConstants.dividerOpacity),
          ),
          const SizedBox(height: ShareConstants.dividerBottomSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Created with Notes App',
                style: TextStyle(
                  fontSize: ShareConstants.watermarkFontSize,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                  letterSpacing: ShareConstants.watermarkLetterSpacing,
                ),
              ),
              Text(
                note.createdAt.toString().split('.')[0],
                style: TextStyle(
                  fontSize: ShareConstants.watermarkFontSize,
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
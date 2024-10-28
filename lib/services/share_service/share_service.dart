import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/note.dart';
import 'share_constants.dart';
import 'share_preview_builder.dart';
import 'share_image_generator.dart';

class ShareService {
  static Future<void> shareNoteAsImage(Note note, BuildContext context) async {
    debugPrint('Starting shareNoteAsImage...');
    OverlayEntry? overlayEntry;
    OverlayEntry? previewOverlay;
    File? tempFile;

    try {
      final overlayState = Overlay.of(context);
      overlayEntry = OverlayEntry(
        builder: (context) => Container(
          color: Colors.black26,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );

      overlayState.insert(overlayEntry);

      final uniqueKey = GlobalKey();
      debugPrint('Creating preview widget...');

      final previewWidget = RepaintBoundary(
        key: uniqueKey,
        child: Material(
          child: SingleChildScrollView(
            child: Container(
              width: ShareConstants.shareImageWidth,
              child: SharePreviewBuilder.buildNotePreview(note),
            ),
          ),
        ),
      );

      previewOverlay = OverlayEntry(
        builder: (context) => Positioned(
          left: -9999,
          child: previewWidget,
        ),
      );
      overlayState.insert(previewOverlay);

      await Future.delayed(const Duration(seconds: 1));

      tempFile = await ShareImageGenerator.generateImage(
        uniqueKey: uniqueKey,
        note: note,
      );

      debugPrint('Sharing file...');
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Note: ${note.title}',
      );

      debugPrint('Share completed successfully');
    } catch (e, stackTrace) {
      debugPrint('Error in shareNoteAsImage: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share note as image: $e')),
        );
      }
      rethrow;
    } finally {
      previewOverlay?.remove();
      overlayEntry?.remove();
      if (tempFile != null) {
        try {
          await tempFile.delete();
        } catch (e) {
          debugPrint('Error deleting temp file: $e');
        }
      }
    }
  }
}
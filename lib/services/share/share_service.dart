// lib/services/share/share_service.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:notes_app/services/share/share/utils/image_compressor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/note.dart';
import 'widgets/preview_builder.dart';

class ShareService {
  static Future<void> shareNoteAsImage(
      Note note,
      GlobalKey repaintBoundaryKey,
      BuildContext context,
      ) async {
    debugPrint('Starting shareNoteAsImage...');
    try {
      final boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        throw Exception('Failed to generate image');
      }

      final bytes = byteData.buffer.asUint8List();
      debugPrint('Original size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');

      final compressedBytes = await ImageCompressor.compress(bytes);
      debugPrint('Final size: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB');

      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/note_${note.id}.jpg';
      final file = File(filePath);
      await file.writeAsBytes(compressedBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Note: ${note.title}');
      await file.delete();

    } catch (e, stackTrace) {
      debugPrint('Error in shareNoteAsImage: $e');
      debugPrint('Stack trace: $stackTrace');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share note as image: $e')),
        );
      }
      rethrow;
    }
  }

  static Widget buildNotePreviewWidget(Note note) {
    return PreviewBuilder.build(note);
  }
}
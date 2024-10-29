// lib/services/share/share_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import './share/utils/image_compressor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/note.dart';
import 'widgets/preview_builder.dart';

class ShareService {
  static const _kPixelRatio = 3.0;
  
  static Future<void> shareNoteAsImage(
    Note note,
    GlobalKey repaintBoundaryKey,
    BuildContext context,
  ) async {
    debugPrint('Starting shareNoteAsImage...');
    try {
      final bytes = await _captureNoteImage(repaintBoundaryKey);
      final compressedBytes = await _processImage(bytes);
      final filePath = await _saveTemporaryFile(note.id, compressedBytes);
      await _shareFile(filePath, note.title);
      await _cleanupTemporaryFile(filePath);
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, context);
      rethrow;
    }
  }

  static Future<Uint8List> _captureNoteImage(GlobalKey repaintBoundaryKey) async {
    final boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: _kPixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    
    if (byteData == null) {
      throw const ShareException('Failed to generate image');
    }
    
    return byteData.buffer.asUint8List();
  }

  static Future<Uint8List> _processImage(Uint8List bytes) async {
    debugPrint('Original size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
    final compressedBytes = await ImageCompressor.compress(bytes);
    debugPrint('Final size: ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB');
    return compressedBytes;
  }

  static Future<String> _saveTemporaryFile(String noteId, Uint8List bytes) async {
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/note_$noteId.jpg';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  static Future<void> _shareFile(String filePath, String noteTitle) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Note: $noteTitle',
    );
  }

  static Future<void> _cleanupTemporaryFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  static void _handleError(Object error, StackTrace stackTrace, BuildContext context) {
    debugPrint('Error in shareNoteAsImage: $error');
    debugPrint('Stack trace: $stackTrace');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share note as image: $error')),
      );
    }
  }

  static Widget buildNotePreviewWidget(Note note) => PreviewBuilder.build(note);
}

class ShareException implements Exception {
  final String message;
  const ShareException(this.message);
  
  @override
  String toString() => message;
}
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import '../../models/note.dart';

class ShareImageGenerator {
  static Future<File> generateImage({
    required GlobalKey uniqueKey,
    required Note note,
  }) async {
    debugPrint('Getting RenderRepaintBoundary...');
    final boundary = uniqueKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      throw Exception('Failed to find RenderRepaintBoundary');
    }

    final RenderBox renderBox = boundary.parent! as RenderBox;
    final size = renderBox.size;
    debugPrint('Current render size: ${size.width}x${size.height}');

    final double pixelRatio = 1.0;
    debugPrint('Using pixel ratio: $pixelRatio');

    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw Exception('Failed to generate image data');
    }

    debugPrint('Writing image file...');
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/note_${note.id}_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(byteData.buffer.asUint8List());

    debugPrint('Final image size: ${image.width}x${image.height}');
    debugPrint('Final file size: ${await file.length()} bytes');

    return file;
  }
}
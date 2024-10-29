// lib/services/share/utils/image_compressor.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;

class ImageCompressor {
  static Future<Uint8List> compress(Uint8List bytes) async {
    try {
      debugPrint('Original size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');

      final decodedImage = image.decodeImage(bytes);
      if (decodedImage == null) return bytes;

      debugPrint('Original dimensions: ${decodedImage.width}x${decodedImage.height}');

      if (bytes.length > 500 * 1024) {
        for (int quality = 80; quality >= 40; quality -= 10) {
          final compressedBytes = image.encodeJpg(
            decodedImage,
            quality: quality,
          );

          debugPrint('Compressed size (quality $quality): ${(compressedBytes.length / 1024).toStringAsFixed(2)} KB');

          if (compressedBytes.length < bytes.length * 0.5) {
            return Uint8List.fromList(compressedBytes);
          }
        }
      }

      return bytes;
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return bytes;
    }
  }
}
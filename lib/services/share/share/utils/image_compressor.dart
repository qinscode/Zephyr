// lib/services/share/utils/image_compressor.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image;

class ImageCompressor {
  static const _kMaxSizeKB = 500;
  static const _kInitialQuality = 80;
  static const _kMinQuality = 40;
  static const _kQualityStep = 10;
  static const _kTargetCompressionRatio = 0.5;

  static Future<Uint8List> compress(Uint8List bytes) async {
    try {
      _logImageInfo(bytes);
      
      final decodedImage = image.decodeImage(bytes);
      if (decodedImage == null) return bytes;
      
      if (!_needsCompression(bytes)) return bytes;
      
      return await _compressImage(decodedImage, bytes);
    } catch (e) {
      debugPrint('Error compressing image: $e');
      return bytes;
    }
  }

  static bool _needsCompression(Uint8List bytes) {
    return bytes.length > _kMaxSizeKB * 1024;
  }

  static void _logImageInfo(Uint8List bytes) {
    debugPrint('Original size: ${(bytes.length / 1024).toStringAsFixed(2)} KB');
  }

  static Future<Uint8List> _compressImage(
    image.Image decodedImage,
    Uint8List originalBytes,
  ) async {
    debugPrint('Original dimensions: ${decodedImage.width}x${decodedImage.height}');

    for (int quality = _kInitialQuality;
         quality >= _kMinQuality;
         quality -= _kQualityStep) {
      final compressedBytes = image.encodeJpg(
        decodedImage,
        quality: quality,
      );

      debugPrint('Compressed size (quality $quality): '
          '${(compressedBytes.length / 1024).toStringAsFixed(2)} KB');

      if (_isCompressionSufficient(compressedBytes, originalBytes)) {
        return Uint8List.fromList(compressedBytes);
      }
    }

    return originalBytes;
  }

  static bool _isCompressionSufficient(
    List<int> compressedBytes,
    List<int> originalBytes,
  ) {
    return compressedBytes.length < originalBytes.length * _kTargetCompressionRatio;
  }
}
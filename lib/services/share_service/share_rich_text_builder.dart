import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:image/image.dart' as image;
import 'share_constants.dart';

class ShareRichTextBuilder {
  static Widget buildRichText({
    required List<dynamic>? deltaJson,
    required String plainText,
    required TextStyle baseStyle,
    required Color textColor,
  }) {
    if (deltaJson == null) {
      return Text(plainText, style: baseStyle);
    }

    try {
      final doc = Document.fromJson(deltaJson);
      final delta = doc.toDelta();
      final widgets = <Widget>[];
      TextStyle currentStyle = baseStyle;
      StringBuffer currentText = StringBuffer();

      void addCurrentText() {
        if (currentText.isNotEmpty) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              currentText.toString(),
              style: currentStyle,
            ),
          ));
          currentText.clear();
        }
      }

      for (final op in delta.toList()) {
        if (op.data is String) {
          final attributes = op.attributes;
          if (attributes != null) {
            addCurrentText();
            currentStyle = baseStyle.merge(TextStyle(
              fontWeight: attributes.containsKey(Attribute.bold.key) ? FontWeight.bold : null,
              fontSize: _getFontSize(attributes, baseStyle.fontSize ?? ShareConstants.contentFontSize),
              backgroundColor: _getHighlightColor(attributes),
              color: textColor,
            ));
          }
          currentText.write(op.data as String);
        } else if (op.data is Map<String, dynamic>) {
          addCurrentText();
          final dataMap = op.data as Map<String, dynamic>;
          if (dataMap.containsKey('image')) {
            final imageWidget = _buildImageWidget(dataMap['image'] as String);
            if (imageWidget != null) {
              widgets.add(imageWidget);
            }
          }
        }
      }

      addCurrentText();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: widgets,
      );
    } catch (e, stack) {
      debugPrint('Error building rich text: $e');
      debugPrint('Stack trace: $stack');
      return Text(plainText, style: baseStyle);
    }
  }

  static Widget? _buildImageWidget(String imageUrl) {
    if (!imageUrl.startsWith('data:image')) {
      return null;
    }

    try {
      final base64Data = imageUrl.split(',')[1];
      final imageData = base64Decode(base64Data);

      final decodedImage = image.decodeImage(imageData);
      if (decodedImage == null) return null;

      double aspectRatio = decodedImage.width / decodedImage.height;
      int newWidth = decodedImage.width;
      int newHeight = decodedImage.height;

      if (newWidth > ShareConstants.maxEmbeddedImageWidth) {
        newWidth = ShareConstants.maxEmbeddedImageWidth;
        newHeight = (newWidth / aspectRatio).round();
      }

      debugPrint('Resizing image from ${decodedImage.width}x${decodedImage.height} to ${newWidth}x${newHeight}');

      final resizedImage = image.copyResize(
        decodedImage,
        width: newWidth,
        height: newHeight,
        interpolation: image.Interpolation.linear,
      );

      final compressedData = image.encodeJpg(resizedImage, quality: ShareConstants.imageQuality);
      debugPrint('Original size: ${imageData.length} bytes');
      debugPrint('Compressed size: ${compressedData.length} bytes');

      return Padding(
        padding: const EdgeInsets.only(
          top: ShareConstants.contentBottomSpacing / 2,
          bottom: ShareConstants.contentBottomSpacing,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ShareConstants.borderRadius),
          child: Image.memory(
            Uint8List.fromList(compressedData),
            fit: BoxFit.contain,
            width: newWidth.toDouble(),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error processing image: $e');
      return null;
    }
  }

  static double _getFontSize(Map<String, dynamic> attributes, double defaultSize) {
    if (attributes.containsKey(Attribute.header.key)) {
      final level = attributes[Attribute.header.key] as int;
      switch (level) {
        case 1:
          return ShareConstants.contentFontSize * 2.0;
        case 2:
          return ShareConstants.contentFontSize * 1.5;
        case 3:
          return ShareConstants.contentFontSize * 1.25;
      }
    }
    return defaultSize;
  }

  static Color? _getHighlightColor(Map<String, dynamic> attributes) {
    if (attributes.containsKey(Attribute.background.key)) {
      final colorStr = attributes[Attribute.background.key] as String;
      if (colorStr.startsWith('#')) {
        return Color(int.parse('FF${colorStr.substring(1)}', radix: 16));
      }
    }
    return null;
  }
}
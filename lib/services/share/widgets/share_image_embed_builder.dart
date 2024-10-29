// lib/services/share/widgets/share_image_embed_builder.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../constants/share_constants.dart';

class ShareImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, QuillController controller, Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final imageUrl = node.value.data as String;

    if (imageUrl.startsWith('data:image')) {
      try {
        final parts = imageUrl.split(',');
        final base64Data = parts[1];
        final imageData = base64Decode(base64Data);

        return Container(
          width: ShareConstants.shareImageWidth - (ShareConstants.horizontalPadding * 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(
            imageData,
            fit: BoxFit.fitWidth,
            width: ShareConstants.shareImageWidth - (ShareConstants.horizontalPadding * 2),
            gaplessPlayback: true,
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('Error processing image: $e');
        debugPrint('Stack trace: $stackTrace');
            return const SizedBox.shrink();
      }
    }
    return const SizedBox.shrink();
  }
}
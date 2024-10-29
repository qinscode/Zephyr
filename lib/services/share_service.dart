import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';
import '../models/note_background.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'dart:convert';
import 'dart:typed_data';

class ShareService {
  // 图片尺寸
  static const double shareImageWidth = 1200.0;
  static const double shareImageMinHeight = 700.0;

  // 布局尺寸
  static const double horizontalPadding = 80.0;
  static const double verticalPadding = 80.0;
  static const double borderRadius = 12.0;

  // 文字样式
  static const double titleFontSize = 48.0;
  static const double contentFontSize = 32.0;
  static const double watermarkFontSize = 24.0;
  static const double contentLineHeight = 1.6;
  static const double watermarkLetterSpacing = 0.3;

  // 间距
  static const double titleBottomSpacing = 40.0;
  static const double contentBottomSpacing = 40.0;
  static const double dividerBottomSpacing = 20.0;

  // 分割线
  static const double dividerHeight = 0.5;
  static const double dividerOpacity = 0.3;

  // 底部区域
  static const double bottomAreaHeight = 60.0;
  static const double bottomPadding = 60.0;

  // 将笔记转换为图片并分享
  static Future<void> shareNoteAsImage(
      Note note,
      GlobalKey repaintBoundaryKey,
      BuildContext context,
      ) async {
    debugPrint('Starting shareNoteAsImage...');
    try {
      debugPrint('Getting RenderRepaintBoundary...');
      final boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

      debugPrint('Converting to image...');
      final image = await boundary.toImage(pixelRatio: 3.0);
      debugPrint('Getting byte data...');
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        debugPrint('Error: byteData is null');
        throw Exception('Failed to generate image');
      }

      debugPrint('Converting to Uint8List...');
      final bytes = byteData.buffer.asUint8List();
      debugPrint('Bytes length: ${bytes.length}');

      debugPrint('Getting temp directory...');
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/note_${note.id}.png';
      debugPrint('Saving to file: $filePath');
      final file = File(filePath);
      await file.writeAsBytes(bytes);

      debugPrint('Sharing file...');
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Note: ${note.title}',
      ).then((_) {
        debugPrint('Share.shareXFiles completed successfully');
      }).catchError((error) {
        debugPrint('Share.shareXFiles failed: $error');
      });

      debugPrint('Deleting temp file...');
      await file.delete();
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
    }
  }

  // 生成笔记预览Widget
  static Widget buildNotePreviewWidget(Note note) {
    debugPrint('Building note preview widget...');
    return SingleChildScrollView(
      child: Container(
        width: shareImageWidth,
        constraints: const BoxConstraints(
          minHeight: shareImageMinHeight,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Stack(
          children: [
            // 背景层
            if (note.background != null && note.background!.type != BackgroundType.none)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    image: DecorationImage(
                      image: AssetImage(note.background!.assetPath!),
                      fit: note.background!.isTileable ? BoxFit.none : BoxFit.cover,
                      repeat: note.background!.isTileable ? ImageRepeat.repeat : ImageRepeat.noRepeat,
                      opacity: note.background!.opacity ?? 1.0,
                    ),
                  ),
                ),
              ),

            // 内容层
            Padding(
              padding: const EdgeInsets.only(
                left: horizontalPadding,
                right: horizontalPadding,
                top: verticalPadding,
                bottom: bottomAreaHeight + bottomPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (note.title.isNotEmpty) ...[
                    // 标题
                    _buildRichText(
                      note.titleDeltaJson,
                      note.title,
                      const TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: contentLineHeight,
                      ),
                    ),
                    const SizedBox(height: titleBottomSpacing),
                  ],

                  // 内容
                  if (note.content.isNotEmpty)
                    Flexible(
                      child: _buildRichText(
                        note.content.first.deltaJson,
                        note.content.first.text,
                        const TextStyle(
                          fontSize: contentFontSize,
                          color: Colors.black87,
                          height: contentLineHeight,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // 底部区域
            Positioned(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: bottomPadding,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: dividerHeight,
                    color: Colors.grey.withOpacity(dividerOpacity),
                  ),
                  const SizedBox(height: dividerBottomSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Created with Notes App',
                        style: TextStyle(
                          fontSize: watermarkFontSize,
                          color: Colors.grey[400],
                          fontWeight: FontWeight.w500,
                          letterSpacing: watermarkLetterSpacing,
                        ),
                      ),
                      Text(
                        note.createdAt.toString().split('.')[0],
                        style: TextStyle(
                          fontSize: watermarkFontSize,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 构建富文本
// 构建富文本
  static Widget _buildRichText(List<dynamic>? deltaJson, String plainText, TextStyle style) {
    if (deltaJson != null) {
      try {
        final doc = Document.fromJson(deltaJson);

        final controller = QuillController(
          document: doc,
          selection: const TextSelection.collapsed(offset: 0),
        );

        debugPrint('Creating QuillEditor...');
        return Container(
          constraints: BoxConstraints(
            maxWidth: shareImageWidth - (horizontalPadding * 2),
          ),
          child: QuillEditor(
            controller: controller,
            scrollController: ScrollController(),
            focusNode: FocusNode(),
            configurations: QuillEditorConfigurations(
              autoFocus: false,
              expands: false,
              scrollable: false,
              enableInteractiveSelection: false,
              showCursor: false,
              padding: EdgeInsets.zero,
              customStyles: DefaultStyles(
                paragraph: DefaultTextBlockStyle(
                  style,
                  const HorizontalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const VerticalSpacing(0, 0),
                  const BoxDecoration(),
                ),
              ),
              embedBuilders: [
                ShareImageEmbedBuilder(),
              ],
            ),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('Error rendering rich text: $e');
        debugPrint('Stack trace: $stackTrace');
        debugPrint('Falling back to plain text');
      }
    }

    return Text(
      plainText,
      style: style,
    );
  }}

class ShareImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, QuillController controller, Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final imageUrl = node.value.data as String;
    debugPrint('ShareImageEmbedBuilder.build called');

    if (imageUrl.startsWith('data:image')) {
      try {
        final parts = imageUrl.split(',');
        final base64Data = parts[1];
        final imageData = base64Decode(base64Data);

        return Container(
          width: ShareService.shareImageWidth - (ShareService.horizontalPadding * 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: Colors.white,
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.memory(
            imageData,
            fit: BoxFit.fitWidth,
            width: ShareService.shareImageWidth - (ShareService.horizontalPadding * 2),
            cacheWidth: 1200,
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
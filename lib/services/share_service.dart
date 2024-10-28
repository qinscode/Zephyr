import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' as math;  // 添加这个导入
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
    debugPrint('Note title: ${note.title}');
    debugPrint('Note content length: ${note.content.length}');
    if (note.content.isNotEmpty) {
      debugPrint('First content block length: ${note.content.first.text.length}');
      debugPrint('Has deltaJson: ${note.content.first.deltaJson != null}');
      if (note.content.first.deltaJson != null) {
        debugPrint('DeltaJson structure found');  // 不输出完整的 deltaJson
        final deltaList = note.content.first.deltaJson as List;
        for (var i = 0; i < deltaList.length; i++) {
          final op = deltaList[i];
          if (op['insert'] is Map && op['insert']['image'] != null) {
            debugPrint('Found image at index $i');
            debugPrint('Image data type: ${op['insert']['image'].runtimeType}');
            debugPrint('Found base64 image data');  // 不输出图片内容
          }
        }
      }
    }
    
    return SingleChildScrollView(  // 添加 SingleChildScrollView
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
                    Flexible(  // 添加 Flexible
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
  static Widget _buildRichText(List<dynamic>? deltaJson, String plainText, TextStyle style) {
    debugPrint('Building rich text...');
    debugPrint('Has deltaJson: ${deltaJson != null}');
    debugPrint('Text length: ${plainText.length}');
    
    if (deltaJson != null) {
      try {
        debugPrint('Creating Document from deltaJson...');
        final doc = Document.fromJson(deltaJson);
        debugPrint('Document created successfully');
        debugPrint('Document length: ${doc.length}');
        
        // 检查是否包含图片
        final delta = doc.toDelta();
        for (final op in delta.toList()) {
          if (op.data is Map && (op.data as Map).containsKey('image')) {
            debugPrint('Found image in delta');
          }
        }
        
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
                PreviewImageEmbedBuilder(),  // 使用专门的预览图片构建器
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
  }
}

// 添加自定义图片构建器
class ShareImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';  // 添加这一行

  @override
  Widget build(BuildContext context, QuillController controller, Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final imageUrl = node.value.data as String;
    debugPrint('ShareImageEmbedBuilder.build called');
    debugPrint('Processing image...');  // 不输出图片 URL
    
    if (imageUrl.startsWith('data:image')) {
      try {
        final parts = imageUrl.split(',');
        debugPrint('Image format: ${parts[0]}');  // 只输出格式信息
        final base64Data = parts[1];
        final imageData = base64Decode(base64Data);
        debugPrint('Image data size: ${imageData.length} bytes');
        
        return Container(
          constraints: BoxConstraints(
            maxWidth: ShareService.shareImageWidth - (ShareService.horizontalPadding * 2),
            maxHeight: ShareService.shareImageWidth * 0.75, // 限制最大高度
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.memory(
                imageData,
                fit: BoxFit.contain,
                width: ShareService.shareImageWidth - (ShareService.horizontalPadding * 2),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  debugPrint('Image frame loaded: $frame');
                  return child;
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Error building image: $error');
                  debugPrint('Stack trace: $stackTrace');
                  return const SizedBox.shrink();
                },
              ),
            ),
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

// 添加专门的预览图片构建器
class PreviewImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  @override
  Widget build(BuildContext context, QuillController controller, Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final imageUrl = node.value.data as String;
    debugPrint('PreviewImageEmbedBuilder.build called');
    debugPrint('Processing image...');
    
    if (imageUrl.startsWith('data:image')) {
      try {
        final parts = imageUrl.split(',');
        debugPrint('Image format: ${parts[0]}');
        final base64Data = parts[1];
        final imageData = base64Decode(base64Data);
        debugPrint('Original image data size: ${imageData.length} bytes');
        
        // 计算适当的显示尺寸
        final maxWidth = ShareService.shareImageWidth - (ShareService.horizontalPadding * 2);
        final maxHeight = maxWidth * 0.75;
        
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16.0),
          constraints: BoxConstraints(
            maxWidth: maxWidth,
            maxHeight: maxHeight,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.memory(
              imageData,
              fit: BoxFit.contain,
              width: maxWidth,
              height: maxHeight,
              cacheWidth: 1200,  // 固定缓存宽度
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Error building image: $error');
                debugPrint('Stack trace: $stackTrace');
                return Container(
                  height: 200,
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.error_outline, size: 48, color: Colors.grey),
                  ),
                );
              },
            ),
          ),
        );
      } catch (e, stackTrace) {
        debugPrint('Error processing image: $e');
        debugPrint('Stack trace: $stackTrace');
        return Container(
          height: 200,
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.error_outline, size: 48, color: Colors.grey),
          ),
        );
      }
    }
    return const SizedBox.shrink();
  }
}


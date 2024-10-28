import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';
import '../models/note_background.dart';

class ShareService {
  // 图片尺寸
  static const double shareImageWidth = 1200.0;
  static const double shareImageMinHeight = 700.0;
  
  // 布局尺寸
  static const double horizontalPadding = 80.0;
  static const double verticalPadding = 150.0;
  static const double borderRadius = 12.0;
  
  // 文字样式
  static const double titleFontSize = 65.0;
  static const double contentFontSize = 45.0;
  static const double watermarkFontSize = 30.0;
  static const double contentLineHeight = 1.6;
  static const double watermarkLetterSpacing = 0.3;
  
  // 间距
  static const double titleBottomSpacing = 50.0;
  static const double contentBottomSpacing = 40.0;
  static const double dividerBottomSpacing = 20.0;
  
  // 分割线
  static const double dividerHeight = 0.5;
  static const double dividerOpacity = 0.3;

  // 底部区域
  static const double bottomAreaHeight = 60.0;  // 底部区域高度
  static const double bottomPadding = 120.0;     // 底部区域距离底部的距离

  // 将笔记转换为图片并分享
  static Future<void> shareNoteAsImage(
    Note note,
    GlobalKey repaintBoundaryKey,
    BuildContext context,
  ) async {
    try {
      // 获取RenderRepaintBoundary
      final boundary = repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      
      // 将widget转换为图片
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      // 保存图片到临时目录
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/note_${note.id}.png');
      await file.writeAsBytes(bytes);

      // 分享图片
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Note: ${note.title}',
      );

      // 删除临时文件
      await file.delete();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share note as image: $e')),
        );
      }
    }
  }

  // 生成笔记预览Widget
  static Widget buildNotePreviewWidget(Note note) {
    return SizedBox(
      width: shareImageWidth,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: shareImageMinHeight,
        ),
        child: Container(
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
                      Text(
                        note.title,
                        style: const TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: titleBottomSpacing),
                    ],
                    
                    Text(
                      note.plainText,
                      style: const TextStyle(
                        fontSize: contentFontSize,
                        color: Colors.black87,
                        height: contentLineHeight,
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
                          'Created by Swift Note',
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
      ),
    );
  }
}

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/note.dart';

class ShareService {
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 标题
          if (note.title.isNotEmpty) ...[
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // 内容
          Text(
            note.content,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 底部信息
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                note.createdAt.toString().split('.')[0],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notes,
                      size: 14,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Notes App',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

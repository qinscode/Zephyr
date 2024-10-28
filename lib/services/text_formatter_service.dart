import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextFormatterService {
  static void applyHighlight(QuillController controller, Color color) {
    // 获取当前选中文本的样式
    final formats = controller.getSelectionStyle().attributes;
    // 检查当前是否已经有高亮
    final hasHighlight = formats[Attribute.background.key] != null;
    
    if (hasHighlight) {
      // 如果已经有高亮，则移除
      controller.formatSelection(Attribute.clone(Attribute.background, null));
    } else {
      // 如果没有高亮，则添加
      // 将颜色转换为十六进制字符串，并设置透明度为 0.5
      final colorHex = '#${(color.value & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}80';
      controller.formatSelection(BackgroundAttribute(colorHex));
    }
  }

  static void applyHeading(QuillController controller, int level) {
    controller.formatSelection(HeaderAttribute(level: level));
  }

  static void applyBold(QuillController controller) {
    controller.formatSelection(Attribute.bold);
  }
}

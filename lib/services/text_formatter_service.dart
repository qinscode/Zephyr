import 'package:flutter/material.dart';

class TextFormatterService {
  static void applyHighlight(TextEditingController controller, Color color) {
    final selection = controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final selectedText = controller.text.substring(selection.start, selection.end);
    // 实现高亮逻辑
  }

  static void applyHeading(TextEditingController controller, int level) {
    final selection = controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final selectedText = controller.text.substring(selection.start, selection.end);
    // 实现标题逻辑
  }

  static void applyBold(TextEditingController controller) {
    final selection = controller.selection;
    if (!selection.isValid || selection.isCollapsed) return;

    final selectedText = controller.text.substring(selection.start, selection.end);
    // 实现加粗逻辑
  }
}

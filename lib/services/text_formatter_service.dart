import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class TextFormatterService {
  static void applyHighlight(QuillController controller, Color color) {
    controller.formatSelection(const BackgroundAttribute('#FFFF00'));
  }

  static void applyHeading(QuillController controller, int level) {
    controller.formatSelection(HeaderAttribute(level: level));
  }

  static void applyBold(QuillController controller) {
    controller.formatSelection(Attribute.bold);
  }
}

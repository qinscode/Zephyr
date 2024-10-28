
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';
import 'dart:convert' as convert;
import 'dart:typed_data';  // 正确的导入

class CustomImageEmbedBuilder extends EmbedBuilder {
  @override
  String get key => 'image';

  // 添加图片缓存
  static final Map<String, Uint8List> _imageCache = <String, Uint8List>{};  // 明确指定类型

  @override
  Widget build(BuildContext context, QuillController controller, Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final imageUrl = node.value.data as String;
    if (imageUrl.startsWith('data:image')) {
      // 检查缓存
      final cacheKey = imageUrl.hashCode.toString();
      if (!_imageCache.containsKey(cacheKey)) {
        // 如果缓存中没有，则解码并存储
        final base64Data = imageUrl.split(',')[1];
        _imageCache[cacheKey] = convert.base64Decode(base64Data);
      }
      
      // 使用缓存的图片数据
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Image.memory(
          _imageCache[cacheKey]!,
          fit: BoxFit.contain,
          // 添加缓存配置
          cacheWidth: 1200,  // 限制缓存大小
          gaplessPlayback: true,  // 防止图片重载时闪烁
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          // 添加缓存配置
          cacheWidth: 1200,
          gaplessPlayback: true,
        ),
      );
    }
  }
}

class EditorContent extends StatefulWidget {
  final QuillController titleController;
  final QuillController contentController;
  final FocusNode titleFocusNode;
  final FocusNode contentFocusNode;
  final Color textColor;
  final int characterCount;
  final DateTime lastModified;

  const EditorContent({
    super.key,
    required this.titleController,
    required this.contentController,
    required this.titleFocusNode,
    required this.contentFocusNode,
    required this.textColor,
    required this.characterCount,
    required this.lastModified,
  });

  @override
  State<EditorContent> createState() => _EditorContentState();
}

class _EditorContentState extends State<EditorContent> {
  late final ScrollController mainScrollController;
  late final ScrollController contentScrollController;

  @override
  void initState() {
    super.initState();
    mainScrollController = ScrollController();
    contentScrollController = ScrollController();
  }

  @override
  void dispose() {
    mainScrollController.dispose();
    contentScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: mainScrollController,
      padding: const EdgeInsets.all(16),
      children: [
        // 标题编辑器
        QuillEditor(
          controller: widget.titleController,
          scrollController: ScrollController(),
          focusNode: widget.titleFocusNode,
          configurations: QuillEditorConfigurations(
            scrollable: false,
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero,
            placeholder: 'Title',
            enableInteractiveSelection: true,
            enableSelectionToolbar: true,
            detectWordBoundary: true,
            showCursor: true,
            onTapUp: (details, getPosition) {
              widget.titleFocusNode.requestFocus();
              return false;
            },
            onTapDown: (details, getPosition) {
              widget.titleFocusNode.requestFocus();
              return false;
            },
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                  color: widget.textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
            ),
          ),
        ),
        
        // 字数统计和时间
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            '${widget.characterCount} characters | ${DateFormat('yyyy-MM-dd HH:mm').format(widget.lastModified)}',
            style: TextStyle(
              color: widget.textColor.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ),

        // 内容编辑器
        QuillEditor(
          controller: widget.contentController,
          scrollController: contentScrollController,
          focusNode: widget.contentFocusNode,
          configurations: QuillEditorConfigurations(
            scrollable: true,
            autoFocus: false,
            expands: false,
            padding: EdgeInsets.zero,
            placeholder: 'Start typing...',
            enableInteractiveSelection: true,
            enableSelectionToolbar: true,
            detectWordBoundary: true,
            showCursor: true,
            onTapUp: (details, getPosition) {
              widget.contentFocusNode.requestFocus();
              return false;
            },
            onTapDown: (details, getPosition) {
              widget.contentFocusNode.requestFocus();
              return false;
            },
            customStyles: DefaultStyles(
              paragraph: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: widget.textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
              h1: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 32,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(16, 8),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
              h2: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 24,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(12, 8),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
              h3: DefaultTextBlockStyle(
                TextStyle(
                  fontSize: 20,
                  height: 1.5,
                  fontWeight: FontWeight.bold,
                  color: widget.textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(8, 8),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
              ),
              bold: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
              lists: DefaultListBlockStyle(
                TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: widget.textColor,
                ),
                const HorizontalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const VerticalSpacing(0, 0),
                const BoxDecoration(),
                null,
              ),
            ),
            embedBuilders: [
              CustomImageEmbedBuilder(),
            ],
          ),
        ),
      ],
    );
  }
}

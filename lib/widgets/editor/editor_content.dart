import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart';

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
    
    // 监听光标位置变化
    widget.contentController.addListener(_handleCursorChange);
  }

  @override
  void dispose() {
    mainScrollController.dispose();
    contentScrollController.dispose();
    widget.contentController.removeListener(_handleCursorChange);
    super.dispose();
  }

  void _handleCursorChange() {
    // 获取当前光标位置
    final selection = widget.contentController.selection;
    if (!selection.isValid) {
      debugPrint('Selection is not valid');
      return;
    }

    debugPrint('Selection: start=${selection.start}, end=${selection.end}');

    // 延迟执行以确保布局已完成
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!contentScrollController.hasClients) {
        debugPrint('ScrollController has no clients');
        return;
      }

      // 获取编辑器的渲染对象
      final renderObject = context.findRenderObject() as RenderBox?;
      if (renderObject == null) {
        debugPrint('RenderObject is null');
        return;
      }

      // 获取可见区域的高度（考虑输入法）
      final viewportHeight = MediaQuery.of(context).size.height -
          kToolbarHeight -  // AppBar 高度
          MediaQuery.of(context).padding.top -  // 状态栏高度
          MediaQuery.of(context).padding.bottom -  // 底部安全区域高度
          MediaQuery.of(context).viewInsets.bottom -  // 输入法高度
          100;  // 工具栏高度
      debugPrint('Viewport height: $viewportHeight');
      debugPrint('Keyboard height: ${MediaQuery.of(context).viewInsets.bottom}');

      // 获取当前滚动位置
      final currentOffset = contentScrollController.offset;
      debugPrint('Current scroll offset: $currentOffset');

      // 获取光标在编辑器中的位置
      final cursorIndex = selection.extentOffset;
      final text = widget.contentController.document.toPlainText();
      final textBeforeCursor = text.substring(0, cursorIndex);
      final linesBefore = textBeforeCursor.split('\n');
      
      // 计算光标所在行的位置
      const lineHeight = 24.0;  // 每行的估计高度
      final cursorY = linesBefore.length * lineHeight;
      debugPrint('Cursor Y position: $cursorY');

      // 计算光标在屏幕上的实际位置
      final editorPosition = renderObject.localToGlobal(Offset.zero);
      final cursorScreenPosition = editorPosition.dy + cursorY - currentOffset;
      debugPrint('Cursor screen position: $cursorScreenPosition');

      // 如果光标不在可见区域内，滚动到合适的位置
      final topThreshold = editorPosition.dy + 100;  // 上边界阈值
      final bottomThreshold = editorPosition.dy + viewportHeight - 100;  // 下边界阈值

      if (cursorScreenPosition < topThreshold) {
        // 如果光标在可见区域上方，向上滚动
        final targetOffset = currentOffset - (topThreshold - cursorScreenPosition);
        debugPrint('Scrolling up to: $targetOffset');
        contentScrollController.animateTo(
          targetOffset.clamp(0.0, contentScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } else if (cursorScreenPosition > bottomThreshold) {
        // 如果光标在可见区域下方，向下滚动
        final targetOffset = currentOffset + (cursorScreenPosition - bottomThreshold);
        debugPrint('Scrolling down to: $targetOffset');
        contentScrollController.animateTo(
          targetOffset.clamp(0.0, contentScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
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
              WidgetsBinding.instance.addPostFrameCallback((_) {
                mainScrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                );
              });
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
              _handleCursorChange();
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
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditorAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isEdited;
  final VoidCallback onBack;
  final VoidCallback onUndo;
  final VoidCallback onRedo;
  final VoidCallback onTheme;
  final VoidCallback onShare;
  final VoidCallback onMore;
  final bool canUndo;
  final bool canRedo;
  final Color? iconColor;       // 只保留图标颜色属性

  const EditorAppBar({
    super.key,
    required this.isEdited,
    required this.onBack,
    required this.onUndo,
    required this.onRedo,
    required this.onTheme,
    required this.onShare,
    required this.onMore,
    this.canUndo = false,
    this.canRedo = false,
    this.iconColor,       // 只保留这个参数
  });

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Colors.black;  // 默认使用黑色
    
    return AppBar(
      backgroundColor: Colors.transparent,  // 始终使用透明背景
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Icon(CupertinoIcons.back, color: effectiveIconColor),
        onPressed: onBack,
      ),
      actions: [
        if (canUndo)
          IconButton(
            icon: Icon(CupertinoIcons.arrow_counterclockwise, color: effectiveIconColor),
            onPressed: onUndo,
          ),
        if (canRedo)
          IconButton(
            icon: Icon(CupertinoIcons.arrow_clockwise, color: effectiveIconColor),
            onPressed: onRedo,
          ),
        IconButton(
          icon: Icon(FontAwesomeIcons.shirt, color: effectiveIconColor),
          onPressed: onTheme,
        ),
        IconButton(
          icon: Icon(CupertinoIcons.share, color: effectiveIconColor),
          onPressed: onShare,
        ),
        IconButton(
          icon: Icon(CupertinoIcons.ellipsis_vertical, color: effectiveIconColor),
          onPressed: onMore,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

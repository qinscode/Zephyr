import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';

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
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back),
        onPressed: onBack,
      ),
      actions: [
        if (canUndo)
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_counterclockwise),
            onPressed: onUndo,
          ),
        if (canRedo)
          IconButton(
            icon: const Icon(CupertinoIcons.arrow_clockwise),
            onPressed: onRedo,
          ),
        IconButton(
          icon: const Icon(FontAwesomeIcons.shirt),
          onPressed: onTheme,
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.share),
          onPressed: onShare,
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.ellipsis_vertical),
          onPressed: onMore,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

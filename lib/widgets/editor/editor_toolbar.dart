import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../l10n/app_localizations.dart';

class EditorToolbar extends StatelessWidget {
  final Color backgroundColor;
  final bool showFormatToolbar;
  final VoidCallback onFormatPressed;
  final VoidCallback onCloseFormat;
  final VoidCallback onHighlight;
  final VoidCallback onH1;
  final VoidCallback onH2;
  final VoidCallback onH3;
  final VoidCallback onBold;

  const EditorToolbar({
    super.key,
    required this.backgroundColor,
    required this.showFormatToolbar,
    required this.onFormatPressed,
    required this.onCloseFormat,
    required this.onHighlight,
    required this.onH1,
    required this.onH2,
    required this.onH3,
    required this.onBold,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border(
          top: BorderSide(
            color: Colors.grey[300]!,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.0, 1.0),
                end: Offset.zero,
              ).animate(animation),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: showFormatToolbar ? _buildFormatToolbar() : _buildMainToolbar(),
        ),
      ),
    );
  }

  Widget _buildMainToolbar() {
    return Row(
      key: const ValueKey<String>('mainToolbar'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(CupertinoIcons.list_bullet),
          onPressed: () {},
          color: Colors.grey[700],
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.photo),
          onPressed: () {},
          color: Colors.grey[700],
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.pencil),
          onPressed: () {},
          color: Colors.grey[700],
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.checkmark_square),
          onPressed: () {},
          color: Colors.grey[700],
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.textformat),
          onPressed: onFormatPressed,
          color: Colors.grey[700],
        ),
      ],
    );
  }

  Widget _buildFormatToolbar() {
    return Row(
      key: const ValueKey<String>('formatToolbar'),
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(FontAwesomeIcons.marker),
          onPressed: onHighlight,
          color: Colors.grey[700],
        ),
        TextButton(
          onPressed: onH1,
          child: const Text('H1', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          )),
        ),
        TextButton(
          onPressed: onH2,
          child: const Text('H2', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          )),
        ),
        TextButton(
          onPressed: onH3,
          child: const Text('H3', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          )),
        ),
        TextButton(
          onPressed: onBold,
          child: const Text('B', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          )),
        ),
        IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: onCloseFormat,
          color: Colors.grey[700],
        ),
      ],
    );
  }
}

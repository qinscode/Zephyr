import 'package:flutter/material.dart';

class ReorderableFolderList extends StatelessWidget {
  final List<Widget> children;
  final void Function(int oldIndex, int newIndex) onReorder;

  const ReorderableFolderList({
    super.key,
    required this.children,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        canvasColor: Colors.transparent,
      ),
      child: ReorderableListView(
        padding: EdgeInsets.zero,
        proxyDecorator: (child, index, animation) {
          return AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Material(
                elevation: 2 * animation.value,
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: child,
              );
            },
            child: child,
          );
        },
        onReorder: onReorder,
        children: children,
      ),
    );
  }
}
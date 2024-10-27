import 'package:flutter/material.dart';

import 'animated_list_item.dart';

class AnimatedGrid extends StatelessWidget {
  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;
  final double runSpacing;
  final EdgeInsets padding;

  const AnimatedGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 8,
    this.runSpacing = 8,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GridView.builder(
        key: ValueKey(children.length),
        padding: padding,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: runSpacing,
          childAspectRatio: 0.85,
        ),
        itemCount: children.length,
        itemBuilder: (context, index) {
          return AnimatedListItem(
            index: index,
            isEven: index.isEven,
            child: children[index],
          );
        },
      ),
    );
  }
}
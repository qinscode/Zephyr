import 'package:flutter/material.dart';

class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  final bool isEven;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.isEven = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOutQuad,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(
            0.0,
            20 * (1 - value),
          ),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
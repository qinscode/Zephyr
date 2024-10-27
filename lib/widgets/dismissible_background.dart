import 'package:flutter/material.dart';

class DismissibleBackground extends StatelessWidget {
  final DismissDirection direction;
  final Color color;
  final IconData icon;
  final String label;

  const DismissibleBackground({
    super.key,
    required this.direction,
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final alignment = direction == DismissDirection.endToStart
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
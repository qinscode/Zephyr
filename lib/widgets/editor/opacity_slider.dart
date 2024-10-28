import 'package:flutter/material.dart';

class OpacitySlider extends StatelessWidget {
  final double opacity;
  final ValueChanged<double> onChanged;

  const OpacitySlider({
    super.key,
    required this.opacity,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Opacity',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: opacity,
                  min: 0.1,
                  max: 1.0,
                  onChanged: onChanged,
                ),
              ),
              Text(
                '${(opacity * 100).round()}%',
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

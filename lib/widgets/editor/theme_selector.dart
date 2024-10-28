import 'package:flutter/material.dart';
import '../../models/note_background.dart';

class ThemeSelector extends StatelessWidget {
  final NoteBackground? currentBackground;
  final ValueChanged<NoteBackground> onBackgroundChanged;

  const ThemeSelector({
    super.key,
    this.currentBackground,
    required this.onBackgroundChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Choose Background',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildThemeOption(
                label: 'Default',
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onTap: () => onBackgroundChanged(NoteBackground.defaultBackground),
              ),
              _buildThemeOption(
                label: 'Cloud',
                child: _buildBackgroundPreview('assets/images/cloud_pattern.png'),
                onTap: () => onBackgroundChanged(NoteBackground.cloudBackground),
              ),
              _buildThemeOption(
                label: 'Snow',
                child: _buildBackgroundPreview('assets/images/snow_pattern.png'),
                onTap: () => onBackgroundChanged(NoteBackground.snowBackground),
              ),
              _buildThemeOption(
                label: 'Banana',
                child: _buildBackgroundPreview('assets/images/banana_pattern.png'),
                onTap: () => onBackgroundChanged(NoteBackground.bananaBackground),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required String label,
    required Widget child,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: child,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPreview(String assetPath) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage(assetPath),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}

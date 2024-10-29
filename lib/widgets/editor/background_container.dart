import 'package:flutter/material.dart';
import '../../models/note_background.dart';

class BackgroundContainer extends StatelessWidget {
  final NoteBackground? background;
  final Widget child;

  const BackgroundContainer({
    super.key,
    this.background,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (background == null || background!.type == BackgroundType.none) {
      return Container(
        color: Colors.white,
        child: child,
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        image: DecorationImage(
          image: AssetImage(background!.assetPath!),
          fit: background!.isTileable ? BoxFit.none : BoxFit.cover,
          repeat: background!.isTileable ? ImageRepeat.repeat : ImageRepeat.noRepeat,
        ),
      ),
      child: child,
    );
  }
}

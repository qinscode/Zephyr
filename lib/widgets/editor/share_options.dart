import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

class ShareOptions extends StatelessWidget {
  final VoidCallback onShareAsImage;
  final VoidCallback onShareAsText;
  final VoidCallback onShareNote;
  final VoidCallback onExportMarkdown;

  const ShareOptions({
    super.key,
    required this.onShareAsImage,
    required this.onShareAsText,
    required this.onShareNote,
    required this.onExportMarkdown,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l10n.getShareValue('shareNote')),
            onTap: () {
              Navigator.pop(context);
              onShareNote();
            },
          ),
          ListTile(
            title: Text(l10n.getShareValue('shareAsText')),
            onTap: () {
              Navigator.pop(context);
              onShareAsText();
            },
          ),
          ListTile(
            title: Text(l10n.getShareValue('shareAsImage')),
            leading: const Icon(Icons.image),
            onTap: () {
              Navigator.pop(context);
              onShareAsImage();
            },
          ),
          ListTile(
            title: Text(l10n.getShareValue('exportAsMarkdown')),
            onTap: () {
              Navigator.pop(context);
              onExportMarkdown();
            },
          ),
          ListTile(
            title: Text(l10n.cancel),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

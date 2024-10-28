// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/settings_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/custom_picker_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _fontSizeKey = GlobalKey();
  final _sortKey = GlobalKey();
  final _layoutKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<SettingsModel>(
      builder: (context, settings, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(CupertinoIcons.back),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(l10n.settings),
          ),
          body: ListView(
            children: [
              // Style section
              _SectionHeader(title: l10n.style),

              // Font Size
              _SettingsItem(
                key: _fontSizeKey,
                title: l10n.fontSize,
                value: l10n.getFontSizeOption(settings.fontSize.name),
                onTap: () => _showFontSizeDialog(context, settings),
              ),

              // Sort
              _SettingsItem(
                key: _sortKey,
                title: l10n.sort,
                value: settings.sortBy == SortBy.byCreationDate
                    ? l10n.getSettingsValue('sort', 'byCreationDate')
                    : l10n.getSettingsValue('sort', 'byModificationDate'),
                onTap: () => _showSortDialog(context, settings),
              ),

              // Layout
              _SettingsItem(
                key: _layoutKey,
                title: l10n.layout,
                value: settings.layout == NoteLayout.list
                    ? l10n.getSettingsValue('layout', 'list')
                    : l10n.getSettingsValue('layout', 'grid'),
                onTap: () => _showLayoutDialog(context, settings),
              ),

              const SizedBox(height: 20),

              // Quick features section
              _SectionHeader(title: l10n.settingsMap['quickFeatures'] as String),
              _SettingsItem(
                title: l10n.settingsMap['quickNotes'] as String,
                showChevron: true,
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // Reminders section
              _SectionHeader(title: l10n.settingsMap['reminders'] as String),
              SwitchListTile(
                title: Text(
                  l10n.settingsMap['highPriorityReminders'] as String,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(l10n.settingsMap['highPriorityRemindersDesc'] as String),
                value: settings.highPriorityReminders,
                onChanged: (value) => settings.setHighPriorityReminders(value),
              ),

              const SizedBox(height: 20),

              // Other section
              _SectionHeader(title: l10n.settingsMap['other'] as String),
              _SettingsItem(
                title: l10n.settingsMap['privacyPolicy'] as String,
                showChevron: true,
                onTap: () {},
              ),
              _SettingsItem(
                title: l10n.settingsMap['dataSharing'] as String,
                showChevron: true,
                onTap: () {},
              ),
              _SettingsItem(
                title: l10n.settingsMap['permissions'] as String,
                showChevron: true,
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeDialog(BuildContext context, SettingsModel settings) {
    final l10n = AppLocalizations.of(context);

    CustomPickerDialog.show(
      context: context,
      buttonKey: _fontSizeKey,
      options: [
        l10n.getSettingsValue('fontSize', 'small'),
        l10n.getSettingsValue('fontSize', 'medium'),
        l10n.getSettingsValue('fontSize', 'large'),
        l10n.getSettingsValue('fontSize', 'huge'),
      ],
      selectedValue: l10n.getFontSizeOption(settings.fontSize.name),
      onSelect: (value) {
        if (value == l10n.getSettingsValue('fontSize', 'small')) {
          settings.setFontSize(FontSize.small);
        } else if (value == l10n.getSettingsValue('fontSize', 'medium')) {
          settings.setFontSize(FontSize.medium);
        } else if (value == l10n.getSettingsValue('fontSize', 'large')) {
          settings.setFontSize(FontSize.large);
        } else {
          settings.setFontSize(FontSize.huge);
        }
      },
    );
  }

  void _showSortDialog(BuildContext context, SettingsModel settings) {
    final l10n = AppLocalizations.of(context);

    CustomPickerDialog.show(
      context: context,
      buttonKey: _sortKey,
      options: [
        l10n.getSettingsValue('sort', 'byCreationDate'),
        l10n.getSettingsValue('sort', 'byModificationDate'),
      ],
      selectedValue: settings.sortBy == SortBy.byCreationDate
          ? l10n.getSettingsValue('sort', 'byCreationDate')
          : l10n.getSettingsValue('sort', 'byModificationDate'),
      onSelect: (value) {
        if (value == l10n.getSettingsValue('sort', 'byCreationDate')) {
          settings.setSortBy(SortBy.byCreationDate);
        } else {
          settings.setSortBy(SortBy.byModificationDate);
        }
      },
    );
  }

  void _showLayoutDialog(BuildContext context, SettingsModel settings) {
    final l10n = AppLocalizations.of(context);

    CustomPickerDialog.show(
      context: context,
      buttonKey: _layoutKey,
      options: [
        l10n.getSettingsValue('layout', 'list'),
        l10n.getSettingsValue('layout', 'grid'),
      ],
      selectedValue: settings.layout == NoteLayout.list
          ? l10n.getSettingsValue('layout', 'list')
          : l10n.getSettingsValue('layout', 'grid'),
      onSelect: (value) {
        if (value == l10n.getSettingsValue('layout', 'list')) {
          settings.setLayout(NoteLayout.list);
        } else {
          settings.setLayout(NoteLayout.grid);
        }
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey[600],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final String? value;
  final VoidCallback onTap;
  final bool showChevron;

  const _SettingsItem({
    super.key,
    required this.title,
    this.value,
    required this.onTap,
    this.showChevron = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value!,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          if (value != null || showChevron)
            const Icon(CupertinoIcons.chevron_down, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}
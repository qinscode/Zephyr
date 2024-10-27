// lib/widgets/search/filter_bottom_sheet.dart
import 'package:flutter/material.dart';

class SearchFilter {
  final DateTime? startDate;
  final DateTime? endDate;
  final Set<String> folders;
  final bool includeNotes;
  final bool includeTasks;
  final bool includeCompleted;
  final String sortBy;

  SearchFilter({
    this.startDate,
    this.endDate,
    this.folders = const {},
    this.includeNotes = true,
    this.includeTasks = true,
    this.includeCompleted = true,
    this.sortBy = 'date',
  });

  SearchFilter copyWith({
    DateTime? startDate,
    DateTime? endDate,
    Set<String>? folders,
    bool? includeNotes,
    bool? includeTasks,
    bool? includeCompleted,
    String? sortBy,
  }) {
    return SearchFilter(
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      folders: folders ?? this.folders,
      includeNotes: includeNotes ?? this.includeNotes,
      includeTasks: includeTasks ?? this.includeTasks,
      includeCompleted: includeCompleted ?? this.includeCompleted,
      sortBy: sortBy ?? this.sortBy,
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final SearchFilter initialFilter;
  final List<String> availableFolders;
  final ValueChanged<SearchFilter> onFilterChanged;

  const FilterBottomSheet({
    super.key,
    required this.initialFilter,
    required this.availableFolders,
    required this.onFilterChanged,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.initialFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              'Filter',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Date Range',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _filter.startDate != null
                        ? _formatDate(_filter.startDate!)
                        : 'Start Date',
                  ),
                  onPressed: () => _selectDate(true),
                ),
              ),
              const Text('to'),
              Expanded(
                child: TextButton.icon(
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    _filter.endDate != null
                        ? _formatDate(_filter.endDate!)
                        : 'End Date',
                  ),
                  onPressed: () => _selectDate(false),
                ),
              ),
            ],
          ),
          const Divider(),
          const Text(
            'Include',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          CheckboxListTile(
            title: const Text('Notes'),
            value: _filter.includeNotes,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(includeNotes: value);
                widget.onFilterChanged(_filter);
              });
            },
          ),
          CheckboxListTile(
            title: const Text('Tasks'),
            value: _filter.includeTasks,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(includeTasks: value);
                widget.onFilterChanged(_filter);
              });
            },
          ),
          if (_filter.includeTasks)
            CheckboxListTile(
              title: const Text('Completed Tasks'),
              value: _filter.includeCompleted,
              onChanged: (value) {
                setState(() {
                  _filter = _filter.copyWith(includeCompleted: value);
                  widget.onFilterChanged(_filter);
                });
              },
            ),
          const Divider(),
          const Text(
            'Folders',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          Wrap(
            spacing: 8,
            children: widget.availableFolders.map((folder) {
              final isSelected = _filter.folders.contains(folder);
              return FilterChip(
                label: Text(folder),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    final newFolders = Set<String>.from(_filter.folders);
                    if (selected) {
                      newFolders.add(folder);
                    } else {
                      newFolders.remove(folder);
                    }
                    _filter = _filter.copyWith(folders: newFolders);
                    widget.onFilterChanged(_filter);
                  });
                },
              );
            }).toList(),
          ),
          const Divider(),
          const Text(
            'Sort By',
            style: TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          RadioListTile<String>(
            title: const Text('Date (Newest first)'),
            value: 'date',
            groupValue: _filter.sortBy,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(sortBy: value);
                widget.onFilterChanged(_filter);
              });
            },
          ),
          RadioListTile<String>(
            title: const Text('Title'),
            value: 'title',
            groupValue: _filter.sortBy,
            onChanged: (value) {
              setState(() {
                _filter = _filter.copyWith(sortBy: value);
                widget.onFilterChanged(_filter);
              });
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _filter = _filter.copyWith(
          startDate: isStartDate ? picked : _filter.startDate,
          endDate: isStartDate ? _filter.endDate : picked,
        );
        widget.onFilterChanged(_filter);
      });
    }
  }
}

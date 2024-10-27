import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/notes_model.dart';
import '../../models/tasks_model.dart';
import '../../models/folder_model.dart';
import '../../services/search_service.dart';
import '../note_card_gesture_detector.dart';
import '../../screens/note_editor_screen.dart';
import '../../screens/task_editor_screen.dart';
import 'filter_bottom_sheet.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final SearchService _searchService = SearchService();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  late SearchFilter _filter;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _filter = SearchFilter();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchController.text.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    _performSearch();
  }

  void _performSearch() {
    final notesModel = Provider.of<NotesModel>(context, listen: false);
    final tasksModel = Provider.of<TasksModel>(context, listen: false);

    final results = _searchService.advancedSearch(
      notes: notesModel.notes,
      tasks: tasksModel.tasks,
      query: _searchController.text,
      startDate: _filter.startDate,
      endDate: _filter.endDate,
      folders: _filter.folders,
      includeNotes: _filter.includeNotes,
      includeTasks: _filter.includeTasks,
      includeCompleted: _filter.includeCompleted,
      sortBy: _filter.sortBy,
    );

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        initialFilter: _filter,
        availableFolders: Provider.of<FolderModel>(context, listen: false)
            .folders
            .map((f) => f.name)
            .toList(),
        onFilterChanged: (newFilter) {
          setState(() {
            _filter = newFilter;
          });
          _performSearch();
        },
      ),
    );
  }

  void _openSearchResult(SearchResult result) {
    if (result.type == SearchResultType.note) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NoteEditorScreen(note: result.originalItem),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TaskEditorScreen(task: result.originalItem),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search notes and tasks',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(CupertinoIcons.clear),
              onPressed: () => _searchController.clear(),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          IconButton(
            icon: const Icon(CupertinoIcons.slider_horizontal_3),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: _buildSearchResults(),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_searchController.text.isEmpty) {
      return const Center(child: Text('Start typing to search'));
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.search,
              size: 48,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text('No results found for "${_searchController.text}"'),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return NoteCardGestureDetector(
          onTap: () => _openSearchResult(result),
          onLongPress: () {}, // TODO: Implement long press action if needed
          child: ListTile(
            leading: Icon(
              result.type == SearchResultType.note
                  ? CupertinoIcons.doc_text
                  : CupertinoIcons.checkmark_circle,
            ),
            title: Text(result.title),
            subtitle: Text(
              result.snippet,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}

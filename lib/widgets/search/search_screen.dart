import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../screens/note_editor_screen.dart';
import '../../screens/task_editor_screen.dart';
import '../../services/search_service.dart';
import '../../models/notes_model.dart';
import '../../models/tasks_model.dart';

// TODO: REFACTOR
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  final _searchService = SearchService();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final notesModel = Provider.of<NotesModel>(context, listen: false);
    final tasksModel = Provider.of<TasksModel>(context, listen: false);

    final noteResults = _searchService.searchNotes(notesModel.notes, query);
    final taskResults = _searchService.searchTasks(tasksModel.tasks, query);

    setState(() {
      _searchResults = [...noteResults, ...taskResults]
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _isSearching = false;
    });
  }

  void _openSearchResult(SearchResult result) {
    if (result.type == SearchService.SearchResultType.note) {
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
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search notes and tasks',
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
              },
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
      return const Center(
        child: Text('Start typing to search'),
      );
    }

    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found for "${_searchController.text}"',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return ListTile(
          leading: Icon(
            result.type == SearchService.SearchResultType.note
                ? Icons.note_outlined
                : Icons.check_circle_outline,
          ),
          title: Text(
            result.title.isEmpty ? 'Untitled' : result.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(
            result.snippet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () => _openSearchResult(result),
        );
      },
    );
  }
}
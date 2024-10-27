import 'package:flutter/material.dart';
import '../models/note.dart';
import '../widgets/note_card.dart';
import 'create_note_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // 模拟数据
  final List<Note> _notes = [
    Note.create(
      title: 'New Product',
      content: 'Create a mobile app UI Kit that provide a basic notes functionality',
      type: 'idea',
      isPinned: true,
      labels: const ['Important', 'Top Priority'],
    ),
    Note.create(
      title: 'Idea Design',
      content: 'Design the user interface for the new feature',
      type: 'idea',
      isPinned: true,
      labels: const ['Design'],
    ),
    Note.create(
      title: 'Shopping List',
      content: '1. Groceries\n2. Office supplies\n3. Home decor',
      type: 'shopping',
      labels: const ['Personal'],
    ),
    Note.create(
      title: 'Weekly Tasks',
      content: 'Plan the weekly schedule and set priorities',
      type: 'task',
      labels: const ['Work'],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildHomeTab(),
          _buildFinishedTab(),
          _buildSearchTab(),
          _buildSettingsTab(),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () => _createNewNote(),
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle),
            label: 'Finished',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),

    );
  }

  void _createNewNote() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateNoteScreen(),
      ),
    );
  }

  Widget _buildHomeTab() {
    final pinnedNotes = _notes.where((note) => note.isPinned).toList();
    final unpinnedNotes = _notes.where((note) => !note.isPinned).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Pinned Notes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (pinnedNotes.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) => NoteCard(note: pinnedNotes[index]),
                  childCount: pinnedNotes.length,
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Notes',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 查看所有笔记
                    },
                    child: const Text('View all'),
                  ),
                ],
              ),
            ),
          ),
          if (unpinnedNotes.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: NoteCard(
                      note: unpinnedNotes[index],
                      isListView: true,
                    ),
                  ),
                  childCount: unpinnedNotes.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFinishedTab() {
    return const Center(child: Text('Finished Notes'));
  }

  Widget _buildSearchTab() {
    return const Center(child: Text('Search'));
  }

  Widget _buildSettingsTab() {
    return const Center(child: Text('Settings'));
  }
}
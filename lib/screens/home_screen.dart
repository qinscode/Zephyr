import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/notes_view.dart';
import '../widgets/tasks_view.dart';
import '../screens/note_editor_screen.dart';
import '../screens/task_editor_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = const [
    NotesView(),
    TasksView(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final int currentIndex = _screens.indexOf(child as Widget);
          final bool isForward = currentIndex > _selectedIndex;
          
          final Offset beginOffset = isForward 
              ? const Offset(1.0, 0.0)
              : const Offset(-1.0, 0.0);

          return SlideTransition(
            position: Tween<Offset>(
              begin: beginOffset,
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            )),
            child: FadeTransition(
              opacity: animation,
              child: PageView(
                controller: _pageController,
                onPageChanged: _onPageChanged,
                children: _screens,
              ),
            ),
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
            // 添加页面动画切换
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(CupertinoIcons.doc_text),
            selectedIcon: Icon(CupertinoIcons.doc_text_fill),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(CupertinoIcons.checkmark_circle),
            selectedIcon: Icon(CupertinoIcons.checkmark_circle_fill),
            label: 'Tasks',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'home_fab',
        onPressed: () {
          if (_selectedIndex == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NoteEditorScreen(),
              ),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TaskEditorScreen(),
              ),
            );
          }
        },
        child: const Icon(CupertinoIcons.add),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes_app/screens/settings_screen.dart';
import 'package:provider/provider.dart';
import '../models/folder_model.dart';
import '../models/note.dart';
import '../models/notes_model.dart';
import '../models/task.dart';
import '../models/tasks_model.dart';
import '../widgets/notes_view.dart';
import '../widgets/tasks_view.dart';
import '../screens/note_editor_screen.dart';
import '../screens/task_editor_screen.dart';
import '../screens/folders_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  bool _isAnimating = false;

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
      _isAnimating = true;
      _selectedIndex = index;
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _isAnimating = false;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(_selectedIndex == 0 ? 'Notes' : 'Tasks'),
        actions: _selectedIndex == 0 
          ? [
              IconButton(
                icon: const Icon(CupertinoIcons.folder),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FoldersScreen(),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(CupertinoIcons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ]
          : [
              IconButton(
                icon: const Icon(CupertinoIcons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  );
                },
              ),
            ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _screens.map((screen) {
          return CustomScrollView(
            slivers: [
              if (screen is NotesView)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SearchBar(
                      hintText: 'Search notes',
                      leading: const Icon(CupertinoIcons.search),
                      backgroundColor: MaterialStateProperty.all(Colors.grey[100]),
                      elevation: MaterialStateProperty.all(0),
                      padding: MaterialStateProperty.all(
                        const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ),
              screen is NotesView
                  ? const NotesContentView()
                  : const TasksContentView(),
            ],
          );
        }).toList(),
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(  // 添加分隔线
            height: 1,
            thickness: 0.2,
            color: Colors.grey,
          ),
          NavigationBar(
            selectedIndex: _selectedIndex,
            backgroundColor: Colors.white,
            elevation: 0,
            indicatorColor: Colors.transparent,
            height: 65,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
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
        ],
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _isAnimating ? 0.0 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedScale(
          scale: _isAnimating ? 0.0 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: FloatingActionButton(
            heroTag: 'home_fab',
            shape: const CircleBorder(), // 添加这一行，使按钮变成圆形
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
        ),
      ),
    );
  }
}

class NotesContentView extends StatelessWidget {
  const NotesContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesModel, FolderModel>(
      builder: (context, notesModel, folderModel, child) {
        final selectedFolderId = folderModel.selectedFolderId;
        print('Current selectedFolderId: $selectedFolderId');
        print('Has folders: ${folderModel.folders.isNotEmpty}');

        final notes = selectedFolderId == null
            ? notesModel.notes
            : notesModel.getNotesByFolder(selectedFolderId);

        return SliverList(
          delegate: SliverChildListDelegate([
            // 文件夹选择器
            if (folderModel.folders.isNotEmpty)  // 只要有文件夹就显示标签栏
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    // "All" 标签
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: FilterChip(
                        label: const Text(
                          'All',
                          style: TextStyle(fontSize: 13),
                        ),
                        selected: selectedFolderId == null,
                        onSelected: (selected) {
                          print('All chip selected: $selected');
                          if (!selected) {  // 只在取消选择时设置为 null
                            folderModel.selectFolder(null);
                          }
                          print('After selecting All, selectedFolderId: ${folderModel.selectedFolderId}');
                        },
                        labelStyle: TextStyle(
                          color: selectedFolderId == null ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        backgroundColor: Colors.grey[100],
                        selectedColor: Colors.blue,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                    // 文件夹标签
                    ...folderModel.folders.map((folder) {
                      final isSelected = selectedFolderId == folder.id;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(
                            folder.name,
                            style: const TextStyle(fontSize: 13),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            print('Folder ${folder.name} selected: $selected');
                            if (selected) {
                              folderModel.selectFolder(folder.id);
                            } else {
                              folderModel.selectFolder(null);  // 取消选择时设置为 null
                            }
                            print('After selecting folder, selectedFolderId: ${folderModel.selectedFolderId}');
                          },
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.blue,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            if (folderModel.folders.isNotEmpty)
              const SizedBox(height: 8),
            // 笔记网格
            _buildNotesGrid(notes),
          ]),
        );
      },
    );
  }

  Widget _buildNotesGrid(List<Note> notes) {
    if (notes.isEmpty) {
      return Center(
        child: Text(
          'No notes yet',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.85,
      ),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        final note = notes[index];
        return _buildNoteCard(context, note);
      },
    );
  }

  Widget _buildNoteCard(BuildContext context, Note note) {
    return GestureDetector(
      onTap: () => _openNote(context, note),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    note.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 17,  // 增加字体大小
                      fontWeight: FontWeight.w700,  // 加粗字体
                      color: Colors.black,  // 确保标题颜色为黑色
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  note.content,
                  maxLines: 6,
                  overflow: TextOverflow.fade,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openNote(BuildContext context, Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
  }
}

class TasksContentView extends StatelessWidget {
  const TasksContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksModel>(
      builder: (context, tasksModel, child) {
        final tasks = tasksModel.tasks;

        if (tasks.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.checkmark_circle,
                    size: 48,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No tasks here yet',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildTaskItem(context, tasks[index], tasksModel),
            childCount: tasks.length,
          ),
        );
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task, TasksModel tasksModel) {
    return CheckboxListTile(
      value: task.isCompleted,
      onChanged: (value) {
        tasksModel.toggleTask(task.id);
      },
      title: Text(
        task.title,
        style: TextStyle(
          decoration: task.isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
      secondary: Icon(
        task.isCompleted
            ? CupertinoIcons.checkmark_circle_fill
            : CupertinoIcons.circle,
        color: task.isCompleted ? Colors.green : Colors.grey,
      ),
    );
  }
}

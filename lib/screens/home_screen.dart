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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';  // 添加这行


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

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
    final l10n = AppLocalizations.of(context);  // 获取本地化实例
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(_selectedIndex == 0 ? l10n.notes : l10n.tasks),  // 使用本地化文本
        actions: _selectedIndex == 0
            ? [
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.folder),
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
            icon: const FaIcon(FontAwesomeIcons.gear),
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
            icon: const FaIcon(FontAwesomeIcons.gear),
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
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 1,
            thickness: 0.2,
            color: Colors.grey,
          ),
          NavigationBar(
            selectedIndex: _selectedIndex,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
            destinations: [
              NavigationDestination(
                icon: const FaIcon(FontAwesomeIcons.noteSticky),
                selectedIcon: const FaIcon(FontAwesomeIcons.solidNoteSticky),
                label: l10n.notes,  // 使用本地化文本
              ),
              NavigationDestination(
                icon: const FaIcon(FontAwesomeIcons.circle),
                selectedIcon: const FaIcon(FontAwesomeIcons.circleCheck),
                label: l10n.tasks,  // 使用本地化文本
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
            child: const FaIcon(FontAwesomeIcons.plus),
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
    // final l10n = AppLocalizations.of(context);
    return Consumer2<NotesModel, FolderModel>(
      builder: (context, notesModel, folderModel, child) {
        final selectedFolderId = folderModel.selectedFolderId;

        // 修改这里的逻辑：当 selectedFolderId 为 'hide' 或 null 时显示所有笔记
        final notes = (selectedFolderId == null || selectedFolderId == 'hide')
            ? notesModel.notes
            : notesModel.getNotesByFolder(selectedFolderId);

        // 修改显示条件：只在 selectedFolderId 不是 'hide' 时显示标签栏
        final bool showTabs = folderModel.folders.isNotEmpty && selectedFolderId != 'hide';

        return SliverList(
          delegate: SliverChildListDelegate([
            // 文件夹选择器
            if (showTabs)
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
                          if (selectedFolderId == null && !selected) {
                            // 当前是 All 且是反选操作，隐藏标签栏
                            folderModel.selectFolder('hide');
                          } else {
                            // 其他情况，正常切换到 All
                            folderModel.selectFolder(null);
                          }
                        },
                        labelStyle: TextStyle(
                          color: selectedFolderId == null ? Colors.white : Colors.grey[800],
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        backgroundColor: Colors.grey[100],
                        selectedColor: Colors.orange,
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
                            if (selected) {
                              folderModel.selectFolder(folder.id);
                            } else {
                              folderModel.selectFolder(null);  // 取消选择时设置为 null
                            }
                          },
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey[800],
                            fontWeight: FontWeight.w500,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          backgroundColor: Colors.grey[100],
                          selectedColor: Colors.orange,
                          showCheckmark: false,
                          visualDensity: VisualDensity.compact,
                        ),
                      );
                    }),
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
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                ),
              Expanded(
                child: Text(
                  note.plainText,  // 使用 plainText getter
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
    // final l10n = AppLocalizations.of(context);
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
                    FontAwesomeIcons.circleCheck,
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
      secondary: FaIcon(
        task.isCompleted
            ? FontAwesomeIcons.circleCheck
            : FontAwesomeIcons.circle,
        color: task.isCompleted ? Colors.green : Colors.grey,
      ),
    );
  }
}



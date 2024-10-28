import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/tasks_model.dart';
import 'package:flutter/cupertino.dart';
import '../l10n/app_localizations.dart';

class TaskEditorScreen extends StatefulWidget {
  final Task? task;

  const TaskEditorScreen({
    super.key,
    this.task,
  });

  @override
  State<TaskEditorScreen> createState() => _TaskEditorScreenState();
}

class _TaskEditorScreenState extends State<TaskEditorScreen> {
  late TextEditingController _titleController;
  late FocusNode _titleFocusNode;
  bool _isCompleted = false;
  List<SubTask> _subtasks = [];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _titleFocusNode = FocusNode();
    _isCompleted = widget.task?.isCompleted ?? false;
    _subtasks = widget.task?.subtasks.toList() ?? [];

    // Auto focus on the title field when creating a new task
    if (widget.task == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _titleFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  void _saveTask() {
    // final l10n = AppLocalizations.of(context);  // 获取本地化实例
    if (_titleController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final tasksModel = Provider.of<TasksModel>(context, listen: false);
    final now = DateTime.now();

    if (widget.task == null) {
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text,
        isCompleted: _isCompleted,
        createdAt: now,
        subtasks: _subtasks,
      );
      tasksModel.addTask(newTask);
    } else {
      final updatedTask = Task(
        id: widget.task!.id,
        title: _titleController.text,
        isCompleted: _isCompleted,
        createdAt: widget.task!.createdAt,
        subtasks: _subtasks,
      );
      tasksModel.updateTask(updatedTask);
    }

    Navigator.pop(context);
  }

  void _addSubtask(String title) {
    setState(() {
      _subtasks.add(SubTask(
        id: const Uuid().v4(),
        title: title,
        isCompleted: false,
      ));
    });
  }

  void _toggleSubtask(String id) {
    setState(() {
      final index = _subtasks.indexWhere((subtask) => subtask.id == id);
      if (index != -1) {
        _subtasks[index] = _subtasks[index].copyWith(
          isCompleted: !_subtasks[index].isCompleted,
        );
      }
    });
  }

  void _removeSubtask(String id) {
    setState(() {
      _subtasks.removeWhere((subtask) => subtask.id == id);
    });
  }

  void _showSetReminderSheet() {
    final l10n = AppLocalizations.of(context);  // 获取本地化实例
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 4,
              width: 32,
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(CupertinoIcons.time),
              title: Text(l10n.setReminder),  // 使用本地化文本
              onTap: () async {
                Navigator.pop(context);
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (time != null && mounted) {
                  // Handle reminder time
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);  // 获取本地化实例
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.xmark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _saveTask,
            child: Text(
              l10n.done,  // 使用本地化文本
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _isCompleted,
                          onChanged: (value) {
                            setState(() {
                              _isCompleted = value ?? false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _titleController,
                          focusNode: _titleFocusNode,
                          style: const TextStyle(fontSize: 16),
                          decoration: InputDecoration(
                            hintText: l10n.addSubtask,  // 使用本地化文本
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 16,
                            ),
                            border: InputBorder.none,
                          ),
                          onSubmitted: (value) {
                            if (value.isNotEmpty) {
                              _addSubtask(value);
                              _titleController.clear();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                ..._buildSubtasks(),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(CupertinoIcons.time),
                  title: Text(l10n.setReminder),  // 使用本地化文本
                  onTap: _showSetReminderSheet,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSubtasks() {
    return List.generate(_subtasks.length, (index) {
      final subtask = _subtasks[index];
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 36),
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: subtask.isCompleted,
                onChanged: (value) => _toggleSubtask(subtask.id),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subtask.title,
                style: TextStyle(
                  decoration: subtask.isCompleted
                      ? TextDecoration.lineThrough
                      : null,
                  color: subtask.isCompleted
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(CupertinoIcons.xmark, size: 16),
              onPressed: () => _removeSubtask(subtask.id),
              color: Colors.grey,
            ),
          ],
        ),
      );
    });
  }
}

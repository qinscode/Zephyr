// lib/screens/task_editor_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/tasks_model.dart';
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
    final l10n = AppLocalizations.of(context);
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
    if (title.isNotEmpty) {
      setState(() {
        _subtasks.add(SubTask(
          id: const Uuid().v4(),
          title: title,
          isCompleted: false,
        ));
      });
      _titleController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              focusNode: _titleFocusNode,
              style: const TextStyle(fontSize: 17),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: l10n.addSubtask,
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 17,
                ),
                prefixIcon: Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: _isCompleted,
                    onChanged: (value) {
                      setState(() {
                        _isCompleted = value ?? false;
                      });
                    },
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    side: BorderSide(
                      color: Colors.grey[300]!,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              onSubmitted: _addSubtask,
            ),
            if (_subtasks.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (var subtask in _subtasks)
                Padding(
                  padding: const EdgeInsets.only(left: 36),
                  child: Row(
                    children: [
                      Transform.scale(
                        scale: 1.1,
                        child: Checkbox(
                          value: subtask.isCompleted,
                          onChanged: (value) {
                            setState(() {
                              final index = _subtasks.indexWhere(
                                      (st) => st.id == subtask.id);
                              if (index != -1) {
                                _subtasks[index] = subtask.copyWith(
                                  isCompleted: value ?? false,
                                );
                              }
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          side: BorderSide(
                            color: Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          subtask.title,
                          style: TextStyle(
                            fontSize: 15,
                            color: subtask.isCompleted ? Colors.grey : Colors.black,
                            decoration: subtask.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          CupertinoIcons.xmark,
                          size: 16,
                          color: Colors.grey[400],
                        ),
                        onPressed: () {
                          setState(() {
                            _subtasks.removeWhere((st) => st.id == subtask.id);
                          });
                        },
                      ),
                    ],
                  ),
                ),
            ],
            const Divider(height: 32),
            ListTile(
              leading: const Icon(CupertinoIcons.time),
              title: Text(l10n.setReminder),
              onTap: () {
                // TODO: 实现提醒功能
              },
            ),
          ],
        ),
      ),
    );
  }
}
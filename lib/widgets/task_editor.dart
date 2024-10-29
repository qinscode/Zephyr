// lib/widgets/task_editor.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/tasks_model.dart';
import '../l10n/app_localizations.dart';

class TaskEditor extends StatefulWidget {
  final Task? task;

  const TaskEditor({
    super.key,
    this.task,
  });

  static Future<void> show(BuildContext context, {Task? task}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TaskEditor(task: task),
    );
  }

  @override
  State<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<TaskEditor> {
  late TextEditingController _titleController;
  late List<TextEditingController> _subtaskControllers;
  DateTime? _reminder;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _subtaskControllers = [TextEditingController()];
    _reminder = widget.task?.reminder;
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _saveTask() {
    if (_titleController.text.isEmpty &&
        _subtaskControllers.every((c) => c.text.isEmpty)) {
      Navigator.pop(context);
      return;
    }

    final tasksModel = Provider.of<TasksModel>(context, listen: false);
    final now = DateTime.now();

    // 过滤掉空的子任务
    final subtasks = _subtaskControllers
        .where((c) => c.text.isNotEmpty)
        .map((c) => SubTask(
      id: const Uuid().v4(),
      title: c.text.trim(),
      isCompleted: false,
    ))
        .toList();

    if (widget.task == null) {
      final newTask = Task(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        createdAt: now,
        reminder: _reminder,
        subtasks: subtasks,
      );
      tasksModel.addTask(newTask);
    } else {
      final updatedTask = widget.task!.copyWith(
        title: _titleController.text.trim(),
        reminder: _reminder,
        subtasks: subtasks,
      );
      tasksModel.updateTask(updatedTask);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final mediaQuery = MediaQuery.of(context);
    final bottomPadding = mediaQuery.viewInsets.bottom + mediaQuery.padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, bottomPadding + 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 标题输入
          if (_titleController.text.isEmpty && widget.task == null)
            const Text(
              'Title',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),

          // 子任务列表
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subtaskControllers.length,
            itemBuilder: (context, index) {
              final isLast = index == _subtaskControllers.length - 1;
              return Row(
                children: [
                  Transform.scale(
                    scale: 1.1,
                    child: Checkbox(
                      value: false,
                      onChanged: null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      side: BorderSide(
                        color: Colors.grey[300]!,
                        width: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _subtaskControllers[index],
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: isLast ? l10n.addSubtask : null,
                        hintStyle: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 17,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.isNotEmpty && isLast) {
                          _addNewSubtaskField();
                        }
                      },
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 16),

          // 底部按钮
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.grey[100],
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                icon: const Icon(CupertinoIcons.alarm, size: 20),
                label: Text(l10n.setReminder),
                onPressed: () {
                  // TODO: 实现设置提醒功能
                },
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
                onPressed: _saveTask,
                child: Text(l10n.done),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
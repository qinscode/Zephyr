// lib/widgets/tasks_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/tasks_model.dart';
import '../l10n/app_localizations.dart';
import '../widgets/task_editor.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<TasksModel>(
      builder: (context, tasksModel, child) {
        final tasks = tasksModel.tasks;

        return tasks.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  CupertinoIcons.checkmark_circle,
                  size: 40,
                  color: Colors.orange[300],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noTasks,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ],
          ),
        )
            : ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: tasks.length,
          itemBuilder: (context, index) =>
              _buildTaskCard(context, tasks[index], tasksModel),
        );
      },
    );
  }
  Widget _buildTaskCard(
      BuildContext context,
      Task task,
      TasksModel tasksModel,
      ) {
    final completedSubtasks = task.subtasks.where((st) => st.isCompleted).length;
    final totalSubtasks = task.subtasks.length;

    // 处理标题显示逻辑
    String displayTitle;
    bool isSingleSubtask = totalSubtasks == 1;
    if (isSingleSubtask) {
      // 如果只有一个子任务，使用子任务作为标题
      displayTitle = task.subtasks.first.title;
    } else if (task.title.isEmpty) {
      // 如果没有标题且有多个子任务，显示默认标题
      displayTitle = 'Checklist of subtasks';
    } else {
      // 其他情况显示正常标题
      displayTitle = task.title;
    }

    return Dismissible(
      key: Key(task.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task?'),
            content: const Text('This task will be deleted permanently.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (direction) {
        tasksModel.deleteTask(task.id);
      },
      child: InkWell(
        onTap: () => TaskEditor.show(context, task: task),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // 主任务
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Transform.scale(
                      scale: 1.1,
                      child: Checkbox(
                        value: isSingleSubtask
                            ? task.subtasks.first.isCompleted
                            : task.isCompleted,
                        onChanged: (value) {
                          if (isSingleSubtask) {
                            tasksModel.toggleSubtask(task.id, task.subtasks.first.id);
                          } else {
                            tasksModel.toggleTask(task.id);
                          }
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
                    Expanded(
                      child: Text(
                        displayTitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: (isSingleSubtask
                              ? task.subtasks.first.isCompleted
                              : task.isCompleted)
                              ? Colors.grey
                              : Colors.black,
                          decoration: (isSingleSubtask
                              ? task.subtasks.first.isCompleted
                              : task.isCompleted)
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    if (totalSubtasks > 1) ...[  // 只在多个子任务时显示计数和展开按钮
                      Text(
                        '$completedSubtasks/$totalSubtasks',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        width: 25,
                        height: 25,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          iconSize: 16,
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            task.expanded
                                ? CupertinoIcons.chevron_up
                                : CupertinoIcons.chevron_down,
                            color: Colors.grey[400],
                          ),
                          onPressed: () => tasksModel.toggleTaskExpanded(task.id),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // 子任务 - 只在有多个子任务且展开时显示
              if (task.expanded && totalSubtasks > 1)
                Padding(
                  padding: const EdgeInsets.only(
                      left: 44,
                      right: 16,
                      bottom: 8
                  ),
                  child: Column(
                    children: task.subtasks.map((subtask) => Row(
                      children: [
                        Transform.scale(
                          scale: 1.1,
                          child: Checkbox(
                            value: subtask.isCompleted,
                            onChanged: (value) {
                              tasksModel.toggleSubtask(task.id, subtask.id);
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
                      ],
                    )).toList(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
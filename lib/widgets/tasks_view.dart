import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../models/tasks_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../l10n/app_localizations.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Consumer<TasksModel>(
      builder: (context, tasksModel, child) {
        final tasks = tasksModel.tasks;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              if (tasks.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            CupertinoIcons.checkmark_circle,
                            size: 40,
                            color: Colors.orange.shade300,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noTasks,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTaskItem(
                      context,
                      tasks[index],
                      tasksModel,
                    ),
                    childCount: tasks.length,
                  ),
                ),
            ],
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

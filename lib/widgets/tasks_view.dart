import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../screens/settings_screen.dart';
import '../models/tasks_model.dart';
import 'base_view.dart';

class TasksView extends StatelessWidget {
  const TasksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TasksModel>(
      builder: (context, tasksModel, child) {
        final tasks = tasksModel.tasks;

        return BaseView(
          title: 'Tasks',
          actions: [
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
          body: tasks.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
                          'No tasks here yet',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTaskItem(context, tasks[index], tasksModel),
                    childCount: tasks.length,
                  ),
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

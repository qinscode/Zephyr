// lib/models/tasks_model.dart
import 'package:flutter/foundation.dart';
import '../services/storage_service.dart';
import 'task.dart';

class TasksModel extends ChangeNotifier {
  final StorageService _storage;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  TasksModel(this._storage) {
    _loadTasks();
  }

  // Getters
  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get incompleteTasks => _tasks.where((task) => !task.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get error => _error;

  // 加载任务
  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _storage.loadTasks();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 保存任务
  Future<void> _saveTasks() async {
    try {
      await _storage.saveTasks(_tasks);
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // 添加新任务
  Future<void> addTask(Task task) async {
    try {
      _tasks.insert(0, task);
      await _saveTasks();
      notifyListeners();
    } catch (e) {
      _tasks.removeWhere((t) => t.id == task.id);
      rethrow;
    }
  }

  // 更新任务
  Future<void> updateTask(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final oldTask = _tasks[index];
      try {
        _tasks[index] = task;
        await _saveTasks();
        notifyListeners();
      } catch (e) {
        _tasks[index] = oldTask;
        rethrow;
      }
    }
  }

  // 删除任务
  Future<void> deleteTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final deletedTask = _tasks[index];
      try {
        _tasks.removeAt(index);
        await _saveTasks();
        notifyListeners();
      } catch (e) {
        _tasks.insert(index, deletedTask);
        rethrow;
      }
    }
  }

  // 切换任务完成状态
  Future<void> toggleTask(String id) async {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      final oldTask = _tasks[index];
      try {
        _tasks[index] = oldTask.copyWith(
          isCompleted: !oldTask.isCompleted,
        );
        await _saveTasks();
        notifyListeners();
      } catch (e) {
        _tasks[index] = oldTask;
        rethrow;
      }
    }
  }

  // 添加子任务
  Future<void> addSubTask(String taskId, SubTask subTask) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final oldTask = _tasks[index];
      try {
        _tasks[index] = oldTask.copyWith(
          subtasks: [...oldTask.subtasks, subTask],
        );
        await _saveTasks();
        notifyListeners();
      } catch (e) {
        _tasks[index] = oldTask;
        rethrow;
      }
    }
  }

  // 更新子任务
  Future<void> updateSubTask(String taskId, SubTask subTask) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final oldTask = _tasks[taskIndex];
      final subTaskIndex = oldTask.subtasks.indexWhere((st) => st.id == subTask.id);

      if (subTaskIndex != -1) {
        try {
          final newSubTasks = List<SubTask>.from(oldTask.subtasks);
          newSubTasks[subTaskIndex] = subTask;
          _tasks[taskIndex] = oldTask.copyWith(subtasks: newSubTasks);
          await _saveTasks();
          notifyListeners();
        } catch (e) {
          _tasks[taskIndex] = oldTask;
          rethrow;
        }
      }
    }
  }

  // 删除子任务
  Future<void> deleteSubTask(String taskId, String subTaskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      final oldTask = _tasks[taskIndex];
      try {
        _tasks[taskIndex] = oldTask.copyWith(
          subtasks: oldTask.subtasks.where((st) => st.id != subTaskId).toList(),
        );
        await _saveTasks();
        notifyListeners();
      } catch (e) {
        _tasks[taskIndex] = oldTask;
        rethrow;
      }
    }
  }

  // 设置任务提醒
  Future<void> setTaskReminder(String taskId, DateTime? reminder) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final oldTask = _tasks[index];
      try {
        _tasks[index] = oldTask.copyWith(reminder: reminder);
        await _saveTasks();
        notifyListeners();
      } catch (e) {
        _tasks[index] = oldTask;
        rethrow;
      }
    }
  }

  // 批量操作
  Future<void> toggleMultipleTasks(List<String> ids) async {
    final originalTasks = Map<int, Task>.fromEntries(
      _tasks.asMap().entries.where((e) => ids.contains(e.value.id)),
    );

    try {
      for (final id in ids) {
        final index = _tasks.indexWhere((task) => task.id == id);
        if (index != -1) {
          _tasks[index] = _tasks[index].copyWith(
            isCompleted: !_tasks[index].isCompleted,
          );
        }
      }
      await _saveTasks();
      notifyListeners();
    } catch (e) {
      // 恢复原始状态
      originalTasks.forEach((index, task) {
        _tasks[index] = task;
      });
      rethrow;
    }
  }

  Future<void> deleteMultipleTasks(List<String> ids) async {
    final deletedTasks = <int, Task>{};
    for (final id in ids) {
      final index = _tasks.indexWhere((task) => task.id == id);
      if (index != -1) {
        deletedTasks[index] = _tasks[index];
        _tasks.removeAt(index);
      }
    }

    if (deletedTasks.isNotEmpty) {
      try {
        await _saveTasks();
        notifyListeners();
      } catch (e) {
        // 恢复原始状态
        deletedTasks.forEach((index, task) {
          _tasks.insert(index, task);
        });
        rethrow;
      }
    }
  }

  // 获取带有提醒的任务
  List<Task> getTasksWithReminders() {
    return _tasks.where((task) => task.reminder != null).toList();
  }

  // 根据日期获取任务
  List<Task> getTasksByDate(DateTime date) {
    return _tasks.where((task) {
      final taskDate = task.reminder ?? task.createdAt;
      return taskDate.year == date.year &&
          taskDate.month == date.month &&
          taskDate.day == date.day;
    }).toList();
  }

  // 获取今天的任务
  List<Task> get todayTasks {
    final now = DateTime.now();
    return getTasksByDate(now);
  }

  // 获取即将到期的任务
  List<Task> getUpcomingTasks({int days = 7}) {
    final now = DateTime.now();
    final future = now.add(Duration(days: days));
    return _tasks.where((task) {
      if (task.reminder == null) return false;
      return task.reminder!.isAfter(now) && task.reminder!.isBefore(future);
    }).toList();
  }

  // 刷新数据
  Future<void> refresh() async {
    await _loadTasks();
  }

  // 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
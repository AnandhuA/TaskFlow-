import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_flow/models/task_model.dart';

class HiveRepo {
  final Box<TaskPlan> _taskBox = Hive.box<TaskPlan>('taskPlans');

  Future<void> reorderTasks(List<TaskPlan> reorderedTasks) async {
    final box = Hive.box<TaskPlan>('taskPlans');
    await box.clear();
    for (var task in reorderedTasks) {
      await box.put(task.id, task);
    }
  }

  Future<void> saveTask(TaskPlan taskPlan) async {
    await _taskBox.put(taskPlan.id, taskPlan);
  }

  List<TaskPlan> getAllTasks() {
    return _taskBox.values.toList();
  }

  TaskPlan? getTaskById(String id) {
    return _taskBox.get(id);
  }

  Future<void> updateTask(String id, TaskPlan updatedTask) async {
    await _taskBox.put(id, updatedTask);
  }

  Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  Future<void> clearAll() async {
    await _taskBox.clear();
  }
}

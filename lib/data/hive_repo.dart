import 'package:hive_flutter/hive_flutter.dart';
import 'package:task_flow/models/task_model.dart';

class HiveRepo {
  final Box<TaskPlan> _taskBox = Hive.box<TaskPlan>('taskPlans');

  Future<void> saveTask(TaskPlan taskPlan) async {
    await _taskBox.add(taskPlan);
  }

  List<TaskPlan> getAllTasks() {
    return _taskBox.values.toList();
  }

  Future<void> deleteTask(int index) async {
    await _taskBox.deleteAt(index);
  }

  Future<void> clearAll() async {
    await _taskBox.clear();
  }
}

import 'package:hive_flutter/adapters.dart';
import 'package:uuid/uuid.dart';

part 'task_model.g.dart';

class ResultModel {
  final  List<TaskPlan>? taskList;
  final String message;

  ResultModel({this.taskList, required this.message});
}

@HiveType(typeId: 0)
class TaskPlan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final List<SubTask> subtasks;

  @HiveField(3)
  final DateTime? createdAt;

  TaskPlan({
    required this.id,
    required this.title,
    required this.subtasks,
    this.createdAt,
  });

  factory TaskPlan.create({
    required String title,
    required List<SubTask> subtasks,
  }) {
    return TaskPlan(
      id: const Uuid().v4(),
      title: title,
      subtasks: subtasks,
      createdAt: DateTime.now(),
    );
  }
}

@HiveType(typeId: 1)
class SubTask {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String priority;

  @HiveField(2)
  final List<String> steps;

  @HiveField(3)
  bool completed;

  SubTask({
    required this.title,
    required this.priority,
    required this.steps,
    this.completed = false,
  });
}
class SubTaskWrapper {
  final SubTask subtask;
  bool selected;

  SubTaskWrapper({required this.subtask, this.selected = false});
}

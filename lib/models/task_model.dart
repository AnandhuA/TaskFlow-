import 'package:hive_flutter/adapters.dart';
part 'task_model.g.dart';

class ResultModel {
  final TaskPlan? taskPlan;
  final String errorMessage;

  ResultModel({this.taskPlan, required this.errorMessage});
}

@HiveType(typeId: 0)
class TaskPlan {
  @HiveField(0)
  final String title;
  @HiveField(1)
  final List<SubTask> subtasks;
  @HiveField(2)
  final DateTime? createdAt;

  TaskPlan({
    required this.title,
    required this.subtasks,
     this.createdAt,
  });
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

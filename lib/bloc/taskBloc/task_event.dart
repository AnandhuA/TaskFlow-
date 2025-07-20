part of 'task_bloc.dart';

@immutable
sealed class TaskEvent {}


class InitialEventEvent extends TaskEvent{}

class AddNewTaskEvent extends TaskEvent {
  final TaskPlan newTask;

  AddNewTaskEvent({required this.newTask});
}

class UpdateTaskEvent extends TaskEvent {
  final String taskId;
  final TaskPlan updatedTask;

  UpdateTaskEvent({required this.updatedTask, required this.taskId});
}

class AddTaskUseAiEvent extends TaskEvent {
  final  String task;

  AddTaskUseAiEvent({required this.task});
}

class DeleteTaskEvent extends TaskEvent {
  final String taskId;

  DeleteTaskEvent({required this.taskId});
}

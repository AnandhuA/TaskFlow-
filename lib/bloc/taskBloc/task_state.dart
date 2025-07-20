part of 'task_bloc.dart';

@immutable
sealed class TaskState {}

final class TaskInitial extends TaskState {}

//----- loading --------
final class TaskLoadingState extends TaskState {}

//------- success --------
final class TaskSuccessState extends TaskState {
  final ResultModel resultModel;

  TaskSuccessState({required this.resultModel});
}

// ------ error ---------
final class TaskErrorState extends TaskState {
  final String error;

  TaskErrorState({required this.error});
}
//------- Task Editing ------

final class TaskEditingState extends TaskState {}

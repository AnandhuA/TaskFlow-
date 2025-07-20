import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/data/hive_repo.dart';
import 'package:task_flow/models/task_model.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final hiveRepo = HiveRepo();
  List<TaskPlan> taskList = [];

  //-------- TaskIntial ------
  TaskBloc() : super(TaskInitial()) {
    on<InitialEventEvent>(_initialEvent);

    on<AddNewTaskEvent>(_onAddNewTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<DeleteTaskEvent>(_onDeleteTask);
    on<AddTaskUseAiEvent>(_onAddTaskUseAi);
  }

  //---------- initialEvent ------
  void _initialEvent(TaskEvent event, Emitter<TaskState> emit) {
    emit(TaskLoadingState());
    taskList = hiveRepo.getAllTasks().reversed.toList();
    return emit(
      TaskSuccessState(
        resultModel: ResultModel(message: "Success", taskList: taskList),
      ),
    );
  }
  //------- add task --------

  void _onAddNewTask(AddNewTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    taskList = await hiveRepo.saveTask(event.newTask);
    return emit(
      TaskSuccessState(
        resultModel: ResultModel(message: "Success", taskList: taskList),
      ),
    );
  }

  //---- update task --------

  void _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    taskList = await hiveRepo.updateTask(event.taskId, event.updatedTask);
    return emit(
      TaskSuccessState(
        resultModel: ResultModel(message: "Success", taskList: taskList),
      ),
    );
  }

  //--------- delete task -----------
  void _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoadingState());
    taskList = await hiveRepo.deleteTask(event.taskId);
    return emit(
      TaskSuccessState(
        resultModel: ResultModel(message: "Success", taskList: taskList),
      ),
    );
  }

  // ------  add task use ai ---------
  void _onAddTaskUseAi(AddTaskUseAiEvent event, Emitter<TaskState> emit) {}
}

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/data/chat_repo.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/utils/parser.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(ChatInitial());

  final ChatRepo _repo = ChatRepo();

  void chatButtonClick({required String task}) async {
    emit(ChatLoadingState());
    try {
      final result = await _repo.generateSubTasks(task);
      log(result);
      final TaskPlan taskPlan = parseAiResponse(result);
      return emit(
        ChatLoadedState(
          resultModel: ResultModel(taskPlan: taskPlan, errorMessage: "Success"),
        ),
      );
    } catch (e) {
      log(e.toString());
      return emit(ChatErrorState(resultModel: ResultModel(errorMessage: "$e")));
    }
  }
}

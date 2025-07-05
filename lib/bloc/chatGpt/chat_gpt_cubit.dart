import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_flow/data/chat_gpt_repo.dart';
import 'package:task_flow/models/task_model.dart';
import 'package:task_flow/utils/parser.dart';

part 'chat_gpt_state.dart';

class ChatGptCubit extends Cubit<ChatGptState> {
  ChatGptCubit() : super(ChatGptInitial());

  final ChatGptRepo _repo = ChatGptRepo();

  void chatButtonClick({required String task}) async {
    emit(ChatGptLoadingState());
    try {
      final result = await _repo.generateSubTasks(task);
      log(result);
      final TaskPlan taskPlan = parseAiResponse(result);
      return emit(
        ChatGptLoadedState(
          resultModel: ResultModel(taskPlan: taskPlan, errorMessage: "Success"),
        ),
      );
    } catch (e) {
      log(e.toString());
      return emit(ChatGptErrorState(resultModel: ResultModel(errorMessage: "$e")));
    }
  }
}

part of 'chat_gpt_cubit.dart';


@immutable
sealed class ChatGptState {}

final class ChatGptInitial extends ChatGptState {}

final class ChatGptLoadingState extends ChatGptState {}

final class ChatGptLoadedState extends ChatGptState {
  final ResultModel resultModel;

  ChatGptLoadedState({required this.resultModel});
}

final class ChatGptErrorState extends ChatGptState {
  final ResultModel resultModel;

  ChatGptErrorState({required this.resultModel});
}

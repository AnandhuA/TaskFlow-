part of 'chat_cubit.dart';

@immutable
sealed class ChatState {}

final class ChatInitial extends ChatState {}

final class ChatLoadingState extends ChatState {}

final class ChatLoadedState extends ChatState {
  final ResultModel resultModel;

  ChatLoadedState({required this.resultModel});
}

final class ChatErrorState extends ChatState {
  final ResultModel resultModel;

  ChatErrorState({required this.resultModel});
}

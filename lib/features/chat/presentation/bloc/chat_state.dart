import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {
  final List<Map<String, dynamic>> messages;

  const ChatInitial({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatUpdated extends ChatState {
  final List<Map<String, dynamic>> messages;

  const ChatUpdated({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatLoading extends ChatState {
  final List<Map<String, dynamic>> messages;

  const ChatLoading({required this.messages});

  @override
  List<Object?> get props => [messages];
}

class ChatError extends ChatState {
  final List<Map<String, dynamic>> messages;
  final String error;

  const ChatError({required this.messages, required this.error});

  @override
  List<Object?> get props => [messages, error];
}

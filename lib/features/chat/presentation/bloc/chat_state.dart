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

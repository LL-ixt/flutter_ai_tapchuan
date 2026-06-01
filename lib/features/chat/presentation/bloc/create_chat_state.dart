import 'package:equatable/equatable.dart';

abstract class CreateChatState extends Equatable {
  const CreateChatState();
  @override
  List<Object?> get props => [];
}

class CreateChatInitial extends CreateChatState {}
class CreateChatLoading extends CreateChatState {}

// Trạng thái tìm thấy User thành công để chuẩn bị mở phòng chat
class CreateChatSuccess extends CreateChatState {
  final Map<String, dynamic> partnerInfo;
  const CreateChatSuccess(this.partnerInfo);

  @override
  List<Object?> get props => [partnerInfo];
}

class CreateChatFailure extends CreateChatState {
  final String message;
  const CreateChatFailure(this.message);

  @override
  List<Object?> get props => [message];
}
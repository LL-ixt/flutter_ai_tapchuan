import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../services/api_service.dart';
import 'create_chat_state.dart';

class CreateChatCubit extends Cubit<CreateChatState> {
  CreateChatCubit() : super(CreateChatInitial());

  // Tìm thông tin đối phương thông qua API get_user_info giống slide tuần 10/11 yêu cầu
  void findUserToChat({required String token, required String userId}) async {
    if (userId.isEmpty) {
      emit(const CreateChatFailure("Vui lòng nhập ID người dùng"));
      return;
    }

    emit(CreateChatLoading());
    try {
      final result = await ApiService.getUserInfo(token: token, userId: userId);

      if (result['code'] == '1000') {
        // Lấy được data gốc chứa id, username, avatar từ server
        emit(CreateChatSuccess(result['data']));
      } else {
        emit(CreateChatFailure(result['message'] ?? 'Tài khoản không tồn tại trên hệ thống'));
      }
    } catch (e) {
      emit(CreateChatFailure('Lỗi hệ thống: $e'));
    }
  }

  void reset() => emit(CreateChatInitial());
}
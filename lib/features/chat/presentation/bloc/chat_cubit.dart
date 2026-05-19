import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/chat_remote_data_source.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRemoteDataSource _chatRemoteDataSource;
  List<Map<String, dynamic>> _messages = [];

  ChatCubit(this._chatRemoteDataSource) : super(const ChatInitial(messages: []));

  // Tạm thời chưa dùng ở UI nhưng có thể gọi khi mở màn hình inbox
  void fetchConversations() async {
    try {
      await _chatRemoteDataSource.getConversations(0, 20);
      // Xử lý conversations nếu UI hỗ trợ
    } catch (e) {
      // Bỏ qua lỗi hoặc xử lý
    }
  }

  void fetchMessages(String partnerId) async {
    emit(const ChatLoading(messages: []));
    try {
      final messageModels = await _chatRemoteDataSource.getMessages(partnerId, 0, 50);
      _messages = messageModels.map((m) {
        return {
          "text": m.message,
          "isMe": m.isMe,
        };
      }).toList();
      emit(ChatUpdated(messages: List.from(_messages)));
    } catch (e) {
      emit(ChatError(messages: _messages, error: e.toString()));
    }
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Thêm tin nhắn của mình
    _messages.insert(0, {
      "text": text,
      "isMe": true,
    });
    emit(ChatUpdated(messages: List.from(_messages)));

    // Hiện tại Backend chưa có API send_message theo file docs nên chỉ mock response hoặc đợi làm API sau
    await Future.delayed(const Duration(seconds: 2));
    _messages.insert(0, {
      "text": "Tin nhắn tự động (Chưa có API send_message)",
      "isMe": false,
    });
    emit(ChatUpdated(messages: List.from(_messages)));
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  // Mock data ban đầu
  final List<Map<String, dynamic>> _messages = [
    {
      "text": "Tuyệt vời, cảm ơn cậu nhiều nhé!",
      "isMe": true,
    },
    {
      "text": "Tớ gửi tài liệu qua mail rồi đó, cậu check xem nhận được chưa.",
      "isMe": false,
    },
    {
      "text": "Ok cậu, mai tớ qua.",
      "isMe": true,
    },
    {
      "text": "Mai rảnh qua thư viện mượn sách không?",
      "isMe": false,
    },
    {
      "text": "Chào cậu!",
      "isMe": true,
    },
    {
      "text": "Chào bạn, mình học chung lớp lập trình nè.",
      "isMe": false,
    },
  ];

  ChatCubit() : super(const ChatInitial(messages: [])) {
    emit(ChatUpdated(messages: List.from(_messages)));
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Thêm tin nhắn của mình
    _messages.insert(0, {
      "text": text,
      "isMe": true,
    });
    emit(ChatUpdated(messages: List.from(_messages)));

    // 2. Giả lập độ trễ 2 giây
    await Future.delayed(const Duration(seconds: 2));

    // 3. Thêm tin nhắn tự động phản hồi
    _messages.insert(0, {
      "text": "Đây là tin nhắn trả lời tự động!",
      "isMe": false,
    });
    emit(ChatUpdated(messages: List.from(_messages)));
  }
}

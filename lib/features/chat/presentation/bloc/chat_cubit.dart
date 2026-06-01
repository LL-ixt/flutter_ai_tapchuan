import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  IO.Socket? socket;
  Timer? _availableTimer; // Timer xử lý sự kiện định kỳ 1s
  Map<String, dynamic>? _myInfo; // Lưu thông tin của chính mình để sử dụng trong sendMessage
  String? _conversationId; // Lưu conversationId để sử dụng khi gửi tin nhắn

  ChatCubit() : super(const ChatState.initial());

  // HÀM KÍCH HOẠT KHI VÀO PHÒNG CHAT
  void joinChatRoom({
    required String token,
    required Map<String, dynamic> myInfo,       // Thông tin của chính bạn {id, avatar, name}
    required Map<String, dynamic> partnerInfo,  // Thông tin đối phương lấy từ get_user_info
    String? conversationId,
  }) {
    // Lưu thông tin của chính mình và conversationId để sử dụng trong sendMessage
    _myInfo = myInfo;
    _conversationId = conversationId ?? partnerInfo['conversationId']?.toString();
    
    // Chỉ emit loading state nếu chưa có tin nhắn (lần đầu tiên join)
    if (state.messages.isEmpty) {
      emit(const ChatState.loading());
    }
    
    final myRealID = myInfo['id'] ?? '';
    // 1. Cấu hình và kết nối Socket (giữ cấu hình của nhóm bạn)
    socket ??= IO.io('https://group1.it4788.sukkaito.id.vn', IO.OptionBuilder()
    .setTransports(['websocket']) // Bắt buộc dùng giao thức websocket
    // BỎ hoàn toàn dòng .setPath('/it4788/socket.io') đi vì server chạy ở root
    .setQuery({'userId': myRealID})     // Truyền token xác thực của bạn vào đây
    .enableForceNew()              // Tạo kết nối mới sạch sẽ
    .build());

    if (socket!.disconnected) {
      socket!.connect();
    }

    // 2. Đóng gói dữ liệu JSON biến đổi từ lớp Message đúng chuẩn Slide 
    final Map<String, dynamic> messagePayload = {
      'sender': {
        'id': myInfo['id'],
        'avatar': myInfo['avatar'] ?? '',
        'name': myInfo['username'] ?? myInfo['name'] ?? 'Tôi',
      },
      'receiver': {
        'id': partnerInfo['id'],
        'avatar': partnerInfo['avatar'] ?? '',
        'name': partnerInfo['username'] ?? partnerInfo['name'] ?? 'Đối phương',
      },
      'created': DateTime.now().toIso8601String(),
      'content': '', // Vào phòng chat nên content để rỗng [cite: 88]
    };

    // 3. ĐÓN ĐẦU SỰ KIỆN KẾT NỐI THÀNH CÔNG (QUAN TRỌNG)
    socket!.onConnect((_) {
      debugPrint("=== [Socket.IO] Kết nối thành công tới Server trường! ===");
      
      // Chỉ khi Server xác nhận ONLINE hoàn toàn, mới bắn 'joinchat'
      socket!.emit('joinchat', {
        'conversationId': _conversationId ?? partnerInfo['conversationId'] ?? '' // Hoặc ID phòng chat nếu có
      });

      // Chạy heartbeat 'available' định kỳ 10-20 giây một lần để server cập nhật thời gian sống
      Timer.periodic(const Duration(seconds: 15), (timer) {
        if (socket != null && socket!.connected) {
          debugPrint("=== [Socket.IO] Gửi sự kiện 'available' định kỳ để giữ kết nối sống ===");
          socket!.emit('available', {});
        } else {
          timer.cancel();
        }
      });
      
      // Mở cổng luôn luôn lắng nghe tin nhắn mới đập nhả từ Server
      listenToIncomingMessages();

      // Đẩy trạng thái thành công lên UI
      emit(ChatState.success(
        partnerInfo: partnerInfo,
        isConnected: true,
        messages: state.messages, // Giữ lại tin nhắn cũ nếu có
      ));
    });

    // Lắng nghe lỗi kết nối để debug nếu Server chặn hoặc sai Path
    socket!.onConnectError((data) {
      debugPrint("=== [Socket.IO] Lỗi kết nối: $data ===");
      emit(ChatState.failure("Lỗi kết nối máy chủ chat. Vui lòng kiểm tra kết nối mạng"));
    });

    // Lắng nghe sự kiện disconnect
    socket!.onDisconnect((_) {
      debugPrint("=== [Socket.IO] Ngắt kết nối từ server ===");
    });

    // Lắng nghe sự kiện reconnect_attempt
    socket!.on('reconnect_attempt', (_) {
      debugPrint("=== [Socket.IO] Đang thử kết nối lại... ===");
    });

    // Lắng nghe sự kiện connection_timeout (Hết thời gian đợi - timeout 200s)
    socket!.on('connection_timeout', (data) {
      debugPrint("=== [Socket.IO] Hết thời gian đợi kết nối: $data ===");
      emit(ChatState.failure("Hết thời gian kết nối. Vui lòng thử lại"));
    });

    // Lắng nghe sự kiện connection_error (Không thể kết nối với phía bên kia)
    socket!.on('connection_error', (data) {
      debugPrint("=== [Socket.IO] Lỗi kết nối với phía bên kia: $data ===");
      emit(ChatState.failure("Không thể kết nối với phía bên kia. Vui lòng thử lại"));
    });

    // Lắng nghe tin nhắn mới sau khi cấu hình
    listenToIncomingMessages();
  }
  // HÀM CHẠY NGẦM ĐỊNH KỲ CHO BIẾN AVAILABLE 

  // HÀM GỬI TIN NHẮN MỚI LÊN SERVER VIA SOCKET
  void sendMessage({required String content, required String partnerId, String? conversationId}) {
    if (socket == null || !socket!.connected) {
      debugPrint("Không thể gửi tin nhắn vì Socket chưa kết nối!");
      return;
    }

    if (content.trim().isEmpty) return;

    // Ưu tiên conversationId từ parameter, nếu không có thì dùng từ _conversationId
    final finalConversationId = conversationId ?? _conversationId;

    // ĐÓNG GÓI PAYLOAD THEO ĐÚNG ĐÒI HỎI CỦA BACKEND NESTJS
    final Map<String, dynamic> nestPayload = {
      'message': content.trim(),        // Server đọc: data?.message
      'partnerId': partnerId,           // Server đọc: data?.partnerId
      if (finalConversationId != null) 'conversationId': finalConversationId, // Server đọc: data?.conversationId
    };

    // BẮN LÊN CỔNG 'send'
    socket!.emit('send', nestPayload);
    debugPrint("=== Đã emit sự kiện 'send' bản mới: $nestPayload ===");

    // Để giao diện của bạn hiển thị mượt mà ngay lập tức (Xử lý UI cục bộ)
    final localMessagePayload = {
      'messageId': 'temp_${DateTime.now().millisecondsSinceEpoch}', // Tạm ID cho tới khi server phản hồi
      'content': content.trim(),
      'created': DateTime.now().toIso8601String(),
      'sender': {
        'id': _myInfo?['id'] ?? '',
        'name': _myInfo?['username'] ?? _myInfo?['name'] ?? 'Tôi',
        'avatar': _myInfo?['avatar'] ?? '',
      },
      'receiver': {
        'id': partnerId,
        'name': state.partnerInfo?['username'] ?? state.partnerInfo?['name'] ?? '',
        'avatar': state.partnerInfo?['avatar'] ?? '',
      }
    };
    final currentMessages = List<Map<String, dynamic>>.from(state.messages);
    currentMessages.add(localMessagePayload);
    emit(state.copyWith(messages: currentMessages));
  }

  // HÀM LẮNG NGHE TIN NHẮN TỪ SERVER BẮN VỀ (GỌI TRONG HÀM JOIN_CHAT_ROOM)
  void listenToIncomingMessages() {
    if (socket == null) return;

    socket!.on('onmessage', (data) {
      debugPrint("=== Nhận tin nhắn thực tế từ Server: $data ===");
      final Map<String, dynamic> incomingData = Map<String, dynamic>.from(data);
      
      // Nếu server trả về conversationId, lưu lại để sử dụng sau này
      if (incomingData['conversationId'] != null) {
        _conversationId = incomingData['conversationId'].toString();
      } else if (incomingData['conversation_id'] != null) {
        _conversationId = incomingData['conversation_id'].toString();
      }
      
      // Đồng bộ cấu trúc thô thành Map<String, dynamic> sạch để add vào danh sách chat
      final Map<String, dynamic> formattedMessage = {
        'messageId': incomingData['message_id'] ?? incomingData['messageId'] ?? '',
        'content': incomingData['content'] ?? '',
        'created': incomingData['created'] ?? DateTime.now().toIso8601String(),
        'sender': Map<String, dynamic>.from(incomingData['sender'] ?? {}),
        'receiver': Map<String, dynamic>.from(incomingData['receiver'] ?? {}),
      };

      final currentMessages = List<Map<String, dynamic>>.from(state.messages);
      
      // Kiểm tra tránh trùng lặp tin nhắn (Do UI local đã chèn trước đó)
      final isExist = currentMessages.any((m) => 
        m['content'] == formattedMessage['content'] && 
        m['sender']?['id'] == formattedMessage['sender']?['id']
      );
      
      if (!isExist) {
        currentMessages.add(formattedMessage);
        emit(state.copyWith(messages: currentMessages));
      }
    });

    // Lắng nghe sự kiện deletemessage - Server báo khi có yêu cầu thu hồi tin nhắn
    socket!.on('deletemessage', (data) {
      debugPrint("=== [Socket.IO] Có yêu cầu xóa tin nhắn: $data ===");
      
      // Xóa tin nhắn khỏi danh sách dựa trên message_id
      final Map<String, dynamic> deleteData = Map<String, dynamic>.from(data);
      final String? messageId = deleteData['message_id']?.toString();
      
      if (messageId != null) {
        final currentMessages = List<Map<String, dynamic>>.from(state.messages);
        currentMessages.removeWhere((msg) => msg['message_id']?.toString() == messageId);
        emit(state.copyWith(messages: currentMessages));
        debugPrint("=== Đã xóa tin nhắn có ID: $messageId ===");
      }
    });
  }

  // Hàm này lôi ra dùng khi người dùng bấm nút back thoát khỏi cửa sổ chat [cite: 60]
  void leaveChatRoom() {
    _availableTimer?.cancel(); // Tắt ngay lập tức Timer định kỳ 
    
    if (socket != null && socket!.connected) {
      // Bắn sự kiện ngắt kết nối riêng cho phòng chat này theo slide [cite: 59, 61]
      socket!.emit('disconnect'); 
    }
  }

  // Hàm này cập nhật state với tin nhắn quá khứ từ API
  void updateHistoricalMessages({
    required Map<String, dynamic> partnerInfo,
    required List<Map<String, dynamic>> messages,
  }) {
    emit(ChatState.success(
      partnerInfo: partnerInfo,
      messages: messages,
      isConnected: false,
    ));
  }

  @override
  Future<void> close() {
    _availableTimer?.cancel();
    socket?.disconnect();
    return super.close();
  }
}
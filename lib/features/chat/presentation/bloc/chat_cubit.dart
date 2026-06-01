import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  IO.Socket? socket;
  Timer? _availableTimer; // Timer xử lý sự kiện định kỳ 1s
  Map<String, dynamic>? _myInfo; // Lưu thông tin của chính mình để sử dụng trong sendMessage

  ChatCubit() : super(const ChatState.initial());

  // HÀM KÍCH HOẠT KHI VÀO PHÒNG CHAT
  void joinChatRoom({
    required String token,
    required Map<String, dynamic> myInfo,       // Thông tin của chính bạn {id, avatar, name}
    required Map<String, dynamic> partnerInfo,  // Thông tin đối phương lấy từ get_user_info
  }) {
    // Lưu thông tin của chính mình để sử dụng trong sendMessage
    _myInfo = myInfo;
    emit(const ChatState.loading());
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

    // 2. Đóng gói dữ liệu JSON biến đổi từ lớp Message đúng chuẩn Slide [cite: 71, 83]
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
      socket!.emit('joinchat', messagePayload);
      debugPrint("=== Đã emit 'joinchat' sau khi kết nối ổn định: $messagePayload ===");

      // Bắt đầu chạy ngầm định kỳ báo cáo available mỗi 1 giây
      _startAvailableHeartbeat(messagePayload);
      
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
  void _startAvailableHeartbeat(Map<String, dynamic> basePayload) {
    _availableTimer?.cancel(); // Hủy timer cũ nếu có để tránh trùng lặp
    
    _availableTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (socket != null && socket!.connected) {
        
        // Tạo gói dữ liệu available (cập nhật lại thời gian hiện tại)
        final Map<String, dynamic> availablePayload = Map.from(basePayload);
        availablePayload['created'] = DateTime.now().toIso8601String();

        // Bắn sự kiện 'available' lên server [cite: 56, 74]
        socket!.emit('available', availablePayload);
        debugPrint("=== [Heartbeat] Đã emit 'available' ===");
      }
    });
  }

  // HÀM GỬI TIN NHẮN MỚI LÊN SERVER VIA SOCKET
  void sendMessage({required String content}) {
    if (socket == null || !socket!.connected) {
      debugPrint("Không thể gửi tin nhắn vì Socket chưa kết nối!");
      return;
    }

    if (content.trim().isEmpty) return;

    if (state.partnerInfo == null || _myInfo == null) return;
    final Map<String, dynamic> partnerInfo = Map<String, dynamic>.from(state.partnerInfo!);

    // Sử dụng myInfo được lưu từ joinChatRoom để lấy sender ID chính xác
    final String myId = _myInfo!['id']?.toString() ?? 'my_id_001'; 

    // Đóng gói gói tin JSON biến đổi từ lớp Message đúng chuẩn đặc tả:
    final Map<String, dynamic> messagePayload = {
      'sender': {
        'id': myId,
        'avatar': '', // Điền nếu có
        'name': 'Tôi', // Điền nếu có
      },
      'receiver': {
        'id': partnerInfo['id'],
        'avatar': partnerInfo['avatar'] ?? '',
        'name': partnerInfo['username'] ?? partnerInfo['name'] ?? '',
      },
      // KHÔNG CÓ trường message_id khi gửi tin nhắn mới
      'created': DateTime.now().toIso8601String(),
      'content': content.trim(),
    };

    // BẮN SỰ KIỆN 'send' LÊN SERVER
    socket!.emit('send', messagePayload);
    debugPrint("=== Đã emit sự kiện 'send' với data: $messagePayload ===");

    // TÙY CHỌN: Cập nhật tin nhắn tạm thời lên UI của chính mình ngay lập tức để tạo cảm giác mượt mà (Optimistic UI)
    // Hoặc bạn có thể đợi server trả về sự kiện rồi mới add vào. Dưới đây là cách add luôn trên UI client:
    final currentMessages = List<Map<String, dynamic>>.from(state.messages);
    currentMessages.add(messagePayload);
    emit(state.copyWith(messages: currentMessages));
  }

  // HÀM LẮNG NGHE TIN NHẮN TỪ SERVER BẮN VỀ (GỌI TRONG HÀM JOIN_CHAT_ROOM)
  void listenToIncomingMessages() {
    if (socket == null) return;

    // Lắng nghe sự kiện new_message - Server báo có tin nhắn mới từ một trong hai người
    socket!.on('new_message', (data) {
      debugPrint("=== Nhận tin nhắn thực từ NestJS: $data ===");
      final Map<String, dynamic> nestMessage = Map<String, dynamic>.from(data);
      
      // Convert cấu trúc dữ liệu từ NestJS về cấu trúc hiển thị của giao diện Flutter
      final Map<String, dynamic> formattedMessage = {
        'messageId': nestMessage['messageId'],
        'content': nestMessage['message'], // NestJS gửi trường 'message' thay vì 'content'
        'senderId': nestMessage['senderId'],
        'created': nestMessage['createdAt'], // NestJS gửi trường 'createdAt' thay vì 'created'
        'sender': {
          'id': nestMessage['senderId'],
          'name': '',
          'avatar': '',
        }
      };
      
      final currentMessages = List<Map<String, dynamic>>.from(state.messages);
      currentMessages.add(formattedMessage);
      emit(state.copyWith(messages: currentMessages));
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

  @override
  Future<void> close() {
    _availableTimer?.cancel();
    socket?.disconnect();
    return super.close();
  }
}
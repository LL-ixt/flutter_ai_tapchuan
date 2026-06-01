import 'package:equatable/equatable.dart';

class ChatState extends Equatable {
  final bool isLoading;
  final bool isConnected; // Trạng thái kết nối Socket (True/False)
  final String? error;
  
  // Lưu thông tin đối phương (name, avatar, id) nhận từ CreateChatCubit truyền sang
  final Map<String, dynamic>? partnerInfo;
  
  // Danh sách các tin nhắn hiển thị trong phòng chat chi tiết
  final List<Map<String, dynamic>> messages;

  const ChatState._({
    this.isLoading = false,
    this.isConnected = false,
    this.error,
    this.partnerInfo,
    this.messages = const [],
  });

  // 1. Trạng thái khởi tạo ban đầu khi chưa vào phòng
  const ChatState.initial() : this._();

  // 2. Trạng thái đang tải dữ liệu / kết nối socket
  const ChatState.loading() : this._(isLoading: true);

  // 3. Trạng thái joinchat thành công, sẵn sàng nhận/gửi tin nhắn
  const ChatState.success({
    required Map<String, dynamic> partnerInfo,
    List<Map<String, dynamic>> messages = const [],
    bool isConnected = true,
  }) : this._(
          isConnected: isConnected,
          partnerInfo: partnerInfo,
          messages: messages,
        );

  // 4. Trạng thái xảy ra lỗi kết nối hoặc không tìm thấy phòng
  const ChatState.failure(String error) : this._(error: error);

  // Hàm copyWith giúp cập nhật danh sách tin nhắn mới mà không làm mất thông tin cũ
  ChatState copyWith({
    bool? isLoading,
    bool? isConnected,
    String? error,
    Map<String, dynamic>? partnerInfo,
    List<Map<String, dynamic>>? messages,
  }) {
    return ChatState._(
      isLoading: isLoading ?? this.isLoading,
      isConnected: isConnected ?? this.isConnected,
      error: error ?? this.error,
      partnerInfo: partnerInfo ?? this.partnerInfo,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [isLoading, isConnected, error, partnerInfo, messages];
}
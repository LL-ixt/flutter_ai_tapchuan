import 'package:dio/dio.dart';
import '../../../../core/network/base_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';

abstract class ChatRemoteDataSource {
  Future<List<ConversationModel>> getConversations(int index, int count);
  Future<List<MessageModel>> getMessages(String partnerId, int index, int count);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final DioClient _dioClient;

  ChatRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ConversationModel>> getConversations(int index, int count) async {
    try {
      final response = await _dioClient.dio.post(
        'get_list_conversation',
        data: {'index': index, 'count': count},
      );

      final baseResponse = BaseResponse<List<ConversationModel>>.fromJson(
        response.data is String ? {} : response.data,
        (data) {
          if (data is List) {
            return data.map((item) => ConversationModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      if (baseResponse.code == '1000') {
        return baseResponse.data ?? [];
      } else {
        throw ServerException(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lỗi tải danh sách hội thoại');
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối mạng: ${e.message}');
    }
  }

  @override
  Future<List<MessageModel>> getMessages(String partnerId, int index, int count) async {
    try {
      final response = await _dioClient.dio.post(
        'get_conversation',
        data: {'partner_id': partnerId, 'index': index, 'count': count},
      );

      // Lấy ID người dùng hiện tại từ Secure Storage để so sánh xem tin nhắn là của ai
      // Giả sử API lưu my_id hoặc chúng ta lấy tạm my_id giả định
      // final myUserId = await SecureStorageHelper.getUserId() ?? '';
      const myUserId = "mock_my_user_id"; // TODO: Lấy ID thật khi Auth tích hợp xong

      final baseResponse = BaseResponse<List<MessageModel>>.fromJson(
        response.data is String ? {} : response.data,
        (data) {
          // API có thể trả về List trực tiếp hoặc gói trong object { conversation: [...] }
          if (data is List) {
            return data.map((item) => MessageModel.fromJson(item as Map<String, dynamic>, myUserId)).toList();
          } else if (data is Map && data['conversation'] is List) {
            return (data['conversation'] as List).map((item) => MessageModel.fromJson(item as Map<String, dynamic>, myUserId)).toList();
          }
          return [];
        },
      );

      if (baseResponse.code == '1000') {
        return baseResponse.data ?? [];
      } else {
        throw ServerException(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lỗi tải chi tiết cuộc trò chuyện');
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối mạng: ${e.message}');
    }
  }
}

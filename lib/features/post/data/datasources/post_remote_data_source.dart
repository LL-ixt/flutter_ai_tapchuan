import 'package:dio/dio.dart';
import '../../../../core/network/base_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';

abstract class PostRemoteDataSource {
  Future<bool> addProducts({
    required String described,
    required String leftVideoPath,
    required String rightVideoPath,
  });
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  final DioClient _dioClient;

  PostRemoteDataSourceImpl(this._dioClient);

  @override
  Future<bool> addProducts({
    required String described,
    required String leftVideoPath,
    required String rightVideoPath,
  }) async {
    try {
      // Bắt buộc dùng FormData cho Upload File (Multipart)
      final formData = FormData.fromMap({
        'described': described,
        'left_video': await MultipartFile.fromFile(
          leftVideoPath,
          filename: leftVideoPath.split('/').last,
        ),
        'right_video': await MultipartFile.fromFile(
          rightVideoPath,
          filename: rightVideoPath.split('/').last,
        ),
      });

      final response = await _dioClient.dio.post(
        'add_products',
        data: formData,
      );

      final baseResponse = BaseResponse<dynamic>.fromJson(
        response.data is String ? {} : response.data,
        (data) => data,
      );

      // Trả về true nếu thành công
      if (baseResponse.code == '1000' || response.statusCode == 200) {
        return true;
      } else {
        throw ServerException(baseResponse.message.isNotEmpty ? baseResponse.message : 'Lỗi từ Server');
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối mạng khi tải video lên: ${e.message}');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException('Lỗi không xác định: $e');
    }
  }
}

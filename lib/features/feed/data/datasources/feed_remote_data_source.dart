import 'package:dio/dio.dart';
import '../../../../core/network/base_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/error/exceptions.dart';
import '../models/post_model.dart';

abstract class FeedRemoteDataSource {
  Future<List<PostModel>> getListProducts();
}

class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final DioClient _dioClient;

  FeedRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<PostModel>> getListProducts() async {
    try {
      final response = await _dioClient.dio.post(
        'get_list_products',
      );

      final baseResponse = BaseResponse<List<PostModel>>.fromJson(
        response.data,
        (data) {
          if (data is List) {
            return data.map((item) => PostModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      if (baseResponse.code == '1000') {
        return baseResponse.data ?? [];
      } else {
        throw ServerException(baseResponse.message);
      }
    } on DioException catch (e) {
      throw ServerException('Lỗi kết nối mạng: ${e.message}');
    }
  }
}

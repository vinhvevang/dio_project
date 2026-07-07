import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';

class AuthService {
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final Response response = await ApiClient.dio.post(
        '/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final String? token =
          response.data['data']['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Không lấy được token từ response');
      }

      return token;
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Đăng nhập thất bại'));
    }
  }
}

import 'package:dio/dio.dart';
import '../../core/api_client.dart';

class AuthService {
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await ApiClient.dio.post(
        '/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      final token = response.data['data']['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw Exception('Không lấy được token từ response');
      }

      return token;
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ?? 'Login failed',
      );
    }
  }
}
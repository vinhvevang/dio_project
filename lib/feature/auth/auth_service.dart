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

      final token = response.data['data']?['access_token'];

      if (token == null || token.toString().isEmpty) {
        throw Exception('Không lấy được token từ backend');
      }

      return token.toString();
    } on DioException catch (e) {
      final message =
          e.response?.data?['message']?.toString() ?? 'Đăng nhập thất bại';
      throw Exception(message);
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }
}
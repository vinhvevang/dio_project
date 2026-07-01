import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';

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
      throw Exception(_dioErrorMessage(e, 'Đăng nhập thất bại'));
    }
  }

  // Lấy message lỗi an toàn, không giả định cứng error body là Map
  String _dioErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    final status = e.response?.statusCode;
    // ignore: avoid_print
    print('DioException(login) status=$status data=$data');

    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    if (data is List && data.isNotEmpty) {
      return data.first.toString();
    }
    if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    if (status != null) {
      return '$fallback (HTTP $status)';
    }
    return fallback;
  }
}

import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_constants.dart';
import 'package:dio_complete/core/storage/token_storage.dart';

class AuthRetryManager {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  static Future<String?> relogin() async {
    final credentials = TokenStorage.getCredentials();
    if (credentials == null) return null;

    final username = credentials['username']?.trim() ?? '';
    final password = credentials['password']?.trim() ?? '';
    if (username.isEmpty || password.isEmpty) return null;

    final response = await _dio.post(
      '/login',
      data: {'username': username, 'password': password},
    );

    final data = response.data;
    final token = data is Map && data['data'] is Map
        ? data['data']['access_token']?.toString()
        : null;

    if (token == null || token.isEmpty) {
      return null;
    }

    await TokenStorage.saveToken(token);
    return token;
  }
}
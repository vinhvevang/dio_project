import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';
import 'package:dio_complete/features/login/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  @override
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

      final data = response.data;
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw Exception(_loginErrorMessage(data));
      }

      if (data is Map) {
        final success = data['success'];
        if (success is bool && !success) {
          throw Exception(_loginErrorMessage(data));
        }

        final responseMessage = data['message']?.toString();
        if (responseMessage != null && responseMessage.isNotEmpty) {
          final lowerMessage = responseMessage.toLowerCase();
          if (lowerMessage.contains('invalid') ||
              lowerMessage.contains('fail') ||
              lowerMessage.contains('sai') ||
              lowerMessage.contains('incorrect') ||
              lowerMessage.contains('wrong')) {
            throw Exception(responseMessage);
          }
        }

        final nestedData = data['data'];
        final token = nestedData is Map ? nestedData['access_token']?.toString() : null;
        if (token == null || token.isEmpty) {
          throw Exception('Sai tên đăng nhập hoặc mật khẩu');
        }

        return token;
      }

      throw Exception('Sai tên đăng nhập hoặc mật khẩu');

    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Đăng nhập thất bại'));
    }
  }

  String _loginErrorMessage(dynamic data) {
    if (data is Map) {
      final message = data['message']?.toString();
      if (message != null && message.isNotEmpty) return message;
      final error = data['error']?.toString();
      if (error != null && error.isNotEmpty) return error;
    }
    return 'Sai tên đăng nhập hoặc mật khẩu';
  }
}

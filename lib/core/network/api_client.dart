import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_constants.dart';
import 'package:dio_complete/core/network/auth_retry_manager.dart';
import 'package:dio_complete/core/storage/token_storage.dart';

class ApiClient {
  static const String baseUrl = ApiConstants.baseUrl;

  static final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {},
      ),
    )
    ..interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = TokenStorage.getToken(); 

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (error, handler) async {
          final statusCode = error.response?.statusCode;
          final alreadyRetried = error.requestOptions.extra['authRetried'] == true;

          if (statusCode == 401 && !alreadyRetried) {
            try {
              final newToken = await AuthRetryManager.relogin();
              if (newToken != null && newToken.isNotEmpty) {
                final requestOptions = error.requestOptions;
                final headers = Map<String, dynamic>.from(requestOptions.headers);
                headers['Authorization'] = 'Bearer $newToken';

                final response = await dio.request(
                  requestOptions.path,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                  options: Options(
                    method: requestOptions.method,
                    headers: headers,
                    contentType: requestOptions.contentType,
                    responseType: requestOptions.responseType,
                    followRedirects: requestOptions.followRedirects,
                    receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
                    extra: {
                      ...requestOptions.extra,
                      'authRetried': true,
                    },
                  ),
                  cancelToken: requestOptions.cancelToken,
                  onReceiveProgress: requestOptions.onReceiveProgress,
                  onSendProgress: requestOptions.onSendProgress,
                );
                return handler.resolve(response);
              }
            } catch (_) {
              await TokenStorage.clearAll();
            }
          }

          handler.next(error);
        },
      ),
    );
}

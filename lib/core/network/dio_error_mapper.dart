import 'package:dio/dio.dart';

/// Lấy message lỗi an toàn từ DioException, không giả định cứng error body
/// luôn là { "message": "..." } - dùng chung cho mọi service (auth, product,
/// category...) thay vì mỗi service tự chép lại 1 bản giống hệt nhau.
String dioErrorMessage(DioException e, String fallback) {
  final data = e.response?.data;
  final status = e.response?.statusCode;
  // ignore: avoid_print
  print('DioException status=$status data=$data');

  if (data is Map && data['message'] != null) {
    return data['message'].toString();
  }
  if (data is Map && data['error'] != null) {
    return data['error'].toString();
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

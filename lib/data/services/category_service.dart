import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';
import 'package:dio_complete/data/models/category_model.dart';

class CategoryService {
  Future<List<Category>> getCategories() async {
    try {
      final response = await ApiClient.dio.get('/categories');
      dynamic node = response.data;
      if (node is Map && node.containsKey('data')) {
        node = node['data'];
      }
      if (node is! List) return <Category>[];

      return node
          .whereType<Map>()
          .map((item) => Category.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Tải danh mục thất bại'));
    }
  }

  /// Trả về id của danh mục vừa tạo - API chỉ trả { "data": <id> }, không trả
  /// nguyên object, nên phần gọi hàm này sẽ tự dựng Category cục bộ từ id này
  /// + name vừa nhập để cập nhật UI ngay, không cần gọi lại getCategories().
  Future<int> createCategory({required String name}) async {
    try {
      final response = await ApiClient.dio.post(
        '/categories',
        data: {'name': name},
      );
      dynamic node = response.data;
      if (node is Map && node.containsKey('data')) {
        node = node['data'];
      }

      if (node is num) return node.toInt();
      if (node is Map && node['id'] != null) {
        return (node['id'] as num).toInt();
      }

      throw Exception('Không lấy được id danh mục vừa tạo');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Tạo danh mục thất bại'));
    }
  }

  Future<void> updateCategory({required int id, required String name}) async {
    try {
      await ApiClient.dio.put('/categories/$id', data: {'name': name});
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Cập nhật danh mục thất bại'));
    }
  }

  Future<void> deleteCategory(int id) async {
    try {
      await ApiClient.dio.delete('/categories/$id');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Xóa danh mục thất bại'));
    }
  }
}

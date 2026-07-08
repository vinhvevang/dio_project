import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';
import 'package:dio_complete/core/network/dio_error_mapper.dart';
import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/domain/entities/product_result.dart';
import 'package:dio_complete/features/product/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    throw Exception('Dữ liệu sản phẩm trả về không đúng định dạng');
  }

  List<Product> _extractProducts(dynamic raw) {
    dynamic node = raw;

    if (node is Map && node.containsKey('data')) {
      node = node['data'];
    }

    if (node == null) return <Product>[];
    if (node is! List) {
      node = [node];
    }

    return node.whereType<Map>().map((item) => Product.fromJson(_asMap(item))).toList();
  }

  Map<String, dynamic> _extractSingleProductMap(dynamic raw) {
    dynamic node = raw;

    if (node is Map && node.containsKey('data')) {
      node = node['data'];
    }

    if (node is List) {
      if (node.isEmpty) {
        throw Exception('Server không trả về dữ liệu sản phẩm');
      }
      node = node.first;
    }

    return _asMap(node);
  }

  Product _buildLocalProduct({
    required int id,
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  }) {
    final now = DateTime.now().toIso8601String();
    return Product(
      id: id,
      status: 1,
      createdAt: now,
      updatedAt: now,
      name: name,
      code: code,
      price: price,
      stock: stock,
      description: description,
      image: image,
      category: category,
    );
  }

  Future<Product> _findProductById(int id) async {
    final result = await getProducts(page: 1, limit: 1000);
    for (final product in result.products) {
      if (product.id == id) return product;
    }
    throw Exception('Không tìm thấy sản phẩm');
  }

  @override
  Future<ProductResult> getProducts({required int page, int limit = 10}) async {
    try {
      final response = await ApiClient.dio.get(
        '/products',
        queryParameters: {'page': page, 'limit': limit},
      );
      final products = _extractProducts(response.data);
      final paging = response.data is Map ? response.data['paging'] : null;
      final pagingMap = paging is Map ? paging : <String, dynamic>{};
      final rawCount = pagingMap['count'];
      final int? count = rawCount is num && rawCount > 0 ? rawCount.toInt() : null;
      return ProductResult(
        products: products,
        page: pagingMap['page'] is int ? pagingMap['page'] as int : page,
        limit: pagingMap['limit'] is int ? pagingMap['limit'] as int : limit,
        count: count,
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Tải danh sách sản phẩm thất bại'));
    }
  }

  @override
  Future<Product> getProductDetail(int id) async {
    try {
      final response = await ApiClient.dio.get('/products/$id');
      return Product.fromJson(_extractSingleProductMap(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _findProductById(id);
      }
      throw Exception(dioErrorMessage(e, 'Tải chi tiết sản phẩm thất bại'));
    } catch (e) {
      return _findProductById(id);
    }
  }

  @override
  Future<Product> createProduct({
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  }) async {
    try {
      final response = await ApiClient.dio.post('/products', data: {
        'name': name,
        'code': code,
        'price': price,
        'stock': stock,
        'description': description,
        'image': image,
        // Ghi (POST/PUT) dùng category_id (số) - khác với đọc (GET) trả về
        // object "category" lồng đầy đủ. Xác nhận từ dữ liệu JSON thật lấy
        // về: sản phẩm đã gán danh mục qua field này thành công ở backend.
        'category_id': category.id,
      });
      dynamic node = response.data;
      if (node is Map && node.containsKey('data')) {
        node = node['data'];
      }

      if (node is Map || node is List) {
        // Đảm bảo category luôn đúng như vừa chọn, phòng khi response backend
        // không echo lại object category đầy đủ (client vẫn nhất quán với ý
        // định của người dùng).
        return Product.fromJson(_extractSingleProductMap(node))
            .copyWith(category: category);
      }

      final int createdId = node is int ? node : DateTime.now().millisecondsSinceEpoch;
      return _buildLocalProduct(
        id: createdId,
        name: name,
        code: code,
        price: price,
        stock: stock,
        description: description,
        image: image,
        category: category,
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Tạo sản phẩm thất bại'));
    } catch (e) {
      throw Exception('Lỗi xử lý dữ liệu sản phẩm: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  }) async {
    try {
      final response = await ApiClient.dio.put('/products/$id', data: {
        'name': name,
        'code': code,
        'price': price,
        'stock': stock,
        'description': description,
        'image': image,
        'category_id': category.id,
      });
      dynamic node = response.data;
      if (node is Map && node.containsKey('data')) {
        node = node['data'];
      }

      if (node is Map || node is List) {
        return Product.fromJson(_extractSingleProductMap(node))
            .copyWith(category: category);
      }

      return _buildLocalProduct(
        id: id,
        name: name,
        code: code,
        price: price,
        stock: stock,
        description: description,
        image: image,
        category: category,
      );
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Cập nhật sản phẩm thất bại'));
    } catch (e) {
      throw Exception('Lỗi xử lý dữ liệu sản phẩm: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await ApiClient.dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Xóa sản phẩm thất bại'));
    }
  }

  @override
  Future<void> resetData() async {
    try {
      await ApiClient.dio.get('/reset');
    } on DioException catch (e) {
      throw Exception(dioErrorMessage(e, 'Reset dữ liệu thất bại'));
    }
  }
}

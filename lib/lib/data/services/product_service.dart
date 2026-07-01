import 'package:dio/dio.dart';
import 'package:dio_complete/core/network/api_client.dart';
import 'package:dio_complete/data/models/product_model.dart';

class ProductResult {
  final List<Product> products;
  final int page;
  final int limit;
  final int? count;

  ProductResult({
    required this.products,
    required this.page,
    required this.limit,
    required this.count,
  });
}

class ProductService {
  /// Lấy message lỗi từ DioException một cách an toàn, không giả định cứng
  /// error body luôn là { "message": "..." } — đây chính là chỗ bị crash
  /// thật sự (server trả lỗi, body không phải Map, index ['message'] vỡ).
  String _dioErrorMessage(DioException e, String fallback) {
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
    );
  }

  Future<Product> _findProductById(int id) async {
    final result = await getProducts(page: 1, limit: 1000);
    for (final product in result.products) {
      if (product.id == id) return product;
    }
    throw Exception('Không tìm thấy sản phẩm');
  }

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
      throw Exception(_dioErrorMessage(e, 'Tải danh sách sản phẩm thất bại'));
    }
  }

  Future<Product> getProductDetail(int id) async {
    try {
      final response = await ApiClient.dio.get('/products/$id');
      return Product.fromJson(_extractSingleProductMap(response.data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return _findProductById(id);
      }
      throw Exception(_dioErrorMessage(e, 'Tải chi tiết sản phẩm thất bại'));
    } catch (e) {
      return _findProductById(id);
    }
  }

  Future<Product> createProduct({
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
  }) async {
    try {
      final response = await ApiClient.dio.post('/products', data: {
        'name': name,
        'code': code,
        'price': price,
        'stock': stock,
        'description': description,
        'image': image,
      });
      dynamic node = response.data;
      if (node is Map && node.containsKey('data')) {
        node = node['data'];
      }

      if (node is Map || node is List) {
        return Product.fromJson(_extractSingleProductMap(node));
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
      );
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e, 'Tạo sản phẩm thất bại'));
    } catch (e) {
      throw Exception('Lỗi xử lý dữ liệu sản phẩm: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<Product> updateProduct({
    required int id,
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
  }) async {
    try {
      final response = await ApiClient.dio.put('/products/$id', data: {
        'name': name,
        'code': code,
        'price': price,
        'stock': stock,
        'description': description,
        'image': image,
      });
      dynamic node = response.data;
      if (node is Map && node.containsKey('data')) {
        node = node['data'];
      }

      if (node is Map || node is List) {
        return Product.fromJson(_extractSingleProductMap(node));
      }

      return _buildLocalProduct(
        id: id,
        name: name,
        code: code,
        price: price,
        stock: stock,
        description: description,
        image: image,
      );
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e, 'Cập nhật sản phẩm thất bại'));
    } catch (e) {
      throw Exception('Lỗi xử lý dữ liệu sản phẩm: ${e.toString().replaceAll('Exception: ', '')}');
    }
  }

  Future<void> deleteProduct(int id) async {
    try {
      await ApiClient.dio.delete('/products/$id');
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e, 'Xóa sản phẩm thất bại'));
    }
  }

  Future<void> resetData() async {
    try {
      await ApiClient.dio.get('/reset');
    } on DioException catch (e) {
      throw Exception(_dioErrorMessage(e, 'Reset dữ liệu thất bại'));
    }
  }
}

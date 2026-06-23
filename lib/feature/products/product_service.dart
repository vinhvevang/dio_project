import 'package:dio/dio.dart';
import '../../core/api_client.dart';
import 'product_model.dart';

class ProductResult {
  final List<ProductModel> products;
  final int page;
  final int limit;
  final int count;

  ProductResult({
    required this.products,
    required this.page,
    required this.limit,
    required this.count,
  });
}

class ProductService {
  Future<ProductResult> getProducts({
    required int page,
    int limit = 10,
  }) async {
    try {
      final response = await ApiClient.dio.get(
        '/products',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      final List data = (response.data['data'] as List?) ?? [];
      final paging = response.data['paging'] ?? {};

      final products = data
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();

      return ProductResult(
        products: products,
        page: paging['page'] ?? page,
        limit: paging['limit'] ?? limit,
        count: paging['count'] ?? products.length,
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['message']?.toString() ?? 'Load products failed',
      );
    }
  }
}
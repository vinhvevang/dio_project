import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/domain/entities/product_result.dart';

abstract class ProductRepository {
  Future<ProductResult> getProducts({required int page, int limit = 10});
  Future<Product> getProductDetail(int id);
  Future<Product> createProduct({
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  });
  Future<Product> updateProduct({
    required int id,
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  });
  Future<void> deleteProduct(int id);
  Future<void> resetData();
}
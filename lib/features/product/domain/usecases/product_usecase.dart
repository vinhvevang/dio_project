import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/domain/entities/product_result.dart';
import 'package:dio_complete/features/product/domain/repositories/product_repository.dart';

class ProductUseCase {
  final ProductRepository _repository;

  ProductUseCase(this._repository);

  Future<ProductResult> getProducts({required int page, int limit = 10}) {
    return _repository.getProducts(page: page, limit: limit);
  }

  Future<Product> getProductDetail(int id) => _repository.getProductDetail(id);

  Future<Product> createProduct({
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  }) {
    return _repository.createProduct(
      name: name,
      code: code,
      price: price,
      stock: stock,
      description: description,
      image: image,
      category: category,
    );
  }

  Future<Product> updateProduct({
    required int id,
    required String name,
    required String code,
    required double price,
    required int stock,
    required String description,
    required String image,
    required Category category,
  }) {
    return _repository.updateProduct(
      id: id,
      name: name,
      code: code,
      price: price,
      stock: stock,
      description: description,
      image: image,
      category: category,
    );
  }

  Future<void> deleteProduct(int id) => _repository.deleteProduct(id);

  Future<void> resetData() => _repository.resetData();
}
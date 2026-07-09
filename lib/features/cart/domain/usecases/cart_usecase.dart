import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/cart/domain/repositories/cart_repository.dart';

class CartUseCase {
  final CartRepository _repository;

  CartUseCase(this._repository);

  List<CartItem> loadItems() => _repository.loadItems();

  Future<void> addItem(Product product, {int quantity = 1}) =>
      _repository.addItem(product, quantity: quantity);

  Future<void> increaseQuantity(int productId) =>
      _repository.increaseQuantity(productId);

  Future<void> decreaseQuantity(int productId) =>
      _repository.decreaseQuantity(productId);

  Future<void> removeItem(int productId) => _repository.removeItem(productId);

  Future<void> updateProduct(Product updated) =>
      _repository.updateProduct(updated);

  Future<void> clearAll() => _repository.clearAll();

  int get count => _repository.count;
}
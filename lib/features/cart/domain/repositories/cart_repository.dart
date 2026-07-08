import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  List<CartItem> loadItems();
  Future<void> addItem(Product product, {int quantity = 1});
  Future<void> increaseQuantity(int productId);
  Future<void> decreaseQuantity(int productId);
  Future<void> removeItem(int productId);
  Future<void> clearAll();
  int get count;
}
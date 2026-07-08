import 'package:dio_complete/features/product/data/models/product_model.dart';

class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  CartItem copyWithQty(int qty) => CartItem(product: product, quantity: qty);
}
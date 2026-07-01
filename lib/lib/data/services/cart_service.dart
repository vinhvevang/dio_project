import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:dio_complete/data/models/product_model.dart';

// Mỗi item trong giỏ hàng lưu sản phẩm + số lượng
class CartItem {
  final Product product;
  final int quantity;

  CartItem({required this.product, required this.quantity});

  Map<String, dynamic> toJson() => {
        'product': {
          ...product.toJson(),
          'id': product.id,
          'status': product.status,
          'created_at': product.createdAt,
          'updated_at': product.updatedAt,
        },
        'quantity': quantity,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(json['product']),
        quantity: json['quantity'] ?? 1,
      );

  // Tạo bản sao với quantity mới
  CartItem copyWithQty(int qty) =>
      CartItem(product: product, quantity: qty);
}

class CartService {
  static const _boxName = 'cartBox';
  static const _key = 'items';

  Box get _box => Hive.box(_boxName);

  // Đọc danh sách giỏ hàng từ Hive
  List<CartItem> getItems() {
    final raw = _box.get(_key);
    if (raw == null) return [];
    final List decoded = jsonDecode(raw as String);
    return decoded.map((e) => CartItem.fromJson(e)).toList();
  }

  // Thêm 1 sản phẩm vào giỏ (nếu đã có thì tăng số lượng)
  Future<void> addItem(Product product) async {
    final items = getItems();
    final idx = items.indexWhere((e) => e.product.id == product.id);

    if (idx >= 0) {
      // Đã có trong giỏ → tăng số lượng
      items[idx] = items[idx].copyWithQty(items[idx].quantity + 1);
    } else {
      // Chưa có → thêm mới với quantity = 1
      items.add(CartItem(product: product, quantity: 1));
    }

    await _save(items);
  }

  // Xóa 1 sản phẩm khỏi giỏ
  Future<void> removeItem(int productId) async {
    final items = getItems();
    items.removeWhere((e) => e.product.id == productId);
    await _save(items);
  }

  // Xóa toàn bộ giỏ hàng
  Future<void> clearAll() async {
    await _box.delete(_key);
  }

  // Số loại sản phẩm trong giỏ (để hiện badge)
  int get count => getItems().length;

  // Lưu vào Hive dưới dạng JSON string
  Future<void> _save(List<CartItem> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await _box.put(_key, encoded);
  }
}

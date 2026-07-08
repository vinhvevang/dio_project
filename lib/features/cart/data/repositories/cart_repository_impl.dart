import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/cart/domain/repositories/cart_repository.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';

/// Chuyển đổi CartItem <-> Map để lưu xuống Hive. Đây là chi tiết định dạng
/// lưu trữ (data layer), không phải khái niệm domain, nên đặt cạnh
/// CartRepositoryImpl thay vì trong entity CartItem (giữ entity thuần).
extension CartItemMapping on CartItem {
  Map<String, dynamic> toMap() => {
        'product': {
          'id': product.id,
          'status': product.status,
          'created_at': product.createdAt,
          'updated_at': product.updatedAt,
          'name': product.name,
          'code': product.code,
          'price': product.price,
          'stock': product.stock,
          'description': product.description,
          'image': product.image,
          if (product.category != null)
            'category': {
              'id': product.category!.id,
              'status': product.category!.status,
              'created_at': product.category!.createdAt,
              'updated_at': product.category!.updatedAt,
              'name': product.category!.name,
            },
        },
        'quantity': quantity,
      };

  static CartItem fromMap(Map<String, dynamic> json) => CartItem(
        product: Product.fromJson(Map<String, dynamic>.from(json['product'] as Map)),
        quantity: json['quantity'] ?? 1,
      );
}

class CartRepositoryImpl implements CartRepository {
  static const _boxName = 'cartBox';
  static const _key = 'items';

  Box get _box => Hive.box(_boxName);

  @override
  List<CartItem> loadItems() {
    final raw = _box.get(_key);
    if (raw == null) return [];
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((e) => CartItemMapping.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (raw is String && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map>()
          .map((e) => CartItemMapping.fromMap(Map<String, dynamic>.from(e)))
          .toList();
    }
    return [];
  }

  @override
  Future<void> addItem(Product product, {int quantity = 1}) async {
    final items = loadItems();
    final idx = items.indexWhere((e) => e.product.id == product.id);

    if (idx >= 0) {
      items[idx] = items[idx].copyWithQty(items[idx].quantity + quantity);
    } else {
      items.add(CartItem(product: product, quantity: quantity));
    }

    await _save(items);
  }

  @override
  Future<void> increaseQuantity(int productId) async {
    final items = loadItems();
    final idx = items.indexWhere((e) => e.product.id == productId);
    if (idx < 0) return;
    items[idx] = items[idx].copyWithQty(items[idx].quantity + 1);
    await _save(items);
  }

  @override
  Future<void> decreaseQuantity(int productId) async {
    final items = loadItems();
    final idx = items.indexWhere((e) => e.product.id == productId);
    if (idx < 0) return;

    final current = items[idx].quantity;
    if (current <= 1) {
      items.removeAt(idx);
    } else {
      items[idx] = items[idx].copyWithQty(current - 1);
    }
    await _save(items);
  }

  @override
  Future<void> removeItem(int productId) async {
    final items = loadItems();
    items.removeWhere((e) => e.product.id == productId);
    await _save(items);
  }

  @override
  Future<void> clearAll() async {
    await _box.delete(_key);
  }

  @override
  int get count => loadItems().length;

  Future<void> _save(List<CartItem> items) async {
    await _box.put(_key, items.map((e) => e.toMap()).toList());
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/data/services/cart_service.dart';

class CartController extends GetxController {
  final _cartService = CartService();

  final items = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  void _loadCart() {
    items.assignAll(_cartService.getItems());
  }

  // Tổng tiền giỏ hàng
  double get totalPrice => items.fold(
      0, (sum, item) => sum + item.product.price * item.quantity);

  // Số loại sản phẩm
  int get itemCount => items.length;

  // Xóa 1 sản phẩm khỏi giỏ
  Future<void> removeItem(int productId) async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
      title: const Text('Xóa khỏi giỏ'),
      content: const Text('Bạn có muốn xóa sản phẩm này khỏi giỏ hàng?'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Xóa', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));

    if (confirmed != true) return;

    await _cartService.removeItem(productId);
    _loadCart();
    Get.snackbar('Đã xóa', 'Đã xóa sản phẩm khỏi giỏ hàng',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100);
  }

  // Xóa toàn bộ giỏ
  Future<void> clearCart() async {
    final confirmed = await Get.dialog<bool>(AlertDialog(
      title: const Text('Xóa tất cả'),
      content: const Text('Xóa tất cả sản phẩm trong giỏ hàng?'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Hủy')),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Xóa hết',
              style: TextStyle(color: Colors.white)),
        ),
      ],
    ));

    if (confirmed != true) return;

    await _cartService.clearAll();
    _loadCart();
  }
}

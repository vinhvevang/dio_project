import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/cart/domain/usecases/cart_usecase.dart';
import 'package:dio_complete/routes/app_routes.dart';

class CartController extends GetxController {
  final _cartUseCase = Get.find<CartUseCase>();

  final items = <CartItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadCart();
  }

  void _loadCart() {
    items.assignAll(_cartUseCase.loadItems());
  }

  // Tổng tiền giỏ hàng
  double get totalPrice => items.fold(0, (sum, item) => sum + item.product.price * item.quantity);

  // Số loại sản phẩm
  int get itemCount => items.length;
  int get totalQuantity => items.fold(0, (sum, item) => sum + item.quantity);

  int _quantityFor(int productId) {
    final item = items.cast<CartItem?>().firstWhere(
      (entry) => entry?.product.id == productId,
      orElse: () => null,
    );
    return item?.quantity ?? 0;
  }

  // Xóa 1 sản phẩm khỏi giỏ
  Future<void> removeItem(int productId) async {
    final confirmed = await showConfirmDialog(
      title: 'Xóa khỏi giỏ',
      message: 'Bạn có muốn xóa sản phẩm này khỏi giỏ hàng?',
      confirmLabel: 'Xóa',
    );

    if (!confirmed) return;

    await _cartUseCase.removeItem(productId);
    _loadCart();
  }

  Future<void> increaseQuantity(int productId) async {
    await _cartUseCase.increaseQuantity(productId);
    _loadCart();
  }

  Future<void> requestDecreaseQuantity(int productId) async {
    final quantity = _quantityFor(productId);
    if (quantity <= 1) {
      final confirmed = await showConfirmDialog(
        title: 'Bỏ sản phẩm khỏi giỏ',
        message: 'Bạn có chắc muốn bỏ sản phẩm này khỏi giỏ hàng?',
        confirmLabel: 'Đồng ý',
        cancelLabel: 'Không',
      );

      if (!confirmed) return;
    }

    await decreaseQuantity(productId);
  }

  Future<void> decreaseQuantity(int productId) async {
    await _cartUseCase.decreaseQuantity(productId);
    _loadCart();
  }

  void goToDetail(CartItem item) {
    Get.toNamed(
      AppRoutes.productDetail,
      arguments: {'product': item.product, 'quantity': item.quantity},
    );
  }

  // Xóa toàn bộ giỏ
  Future<void> clearCart() async {
    final confirmed = await showConfirmDialog(
      title: 'Xóa tất cả',
      message: 'Xóa tất cả sản phẩm trong giỏ hàng?',
      confirmLabel: 'Xóa hết',
    );

    if (!confirmed) return;

    await _cartUseCase.clearAll();
    _loadCart();
  }
}

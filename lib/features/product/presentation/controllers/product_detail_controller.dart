import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/core/widgets/app_message_dialog.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';
import 'package:dio_complete/features/cart/domain/usecases/cart_usecase.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/domain/usecases/product_usecase.dart';
import 'package:dio_complete/features/product/presentation/controllers/home_controller.dart';
import 'package:dio_complete/features/cart/presentation/controllers/cart_controller.dart';
import 'package:dio_complete/routes/app_routes.dart';

class ProductDetailController extends GetxController {
  final _useCase = Get.find<ProductUseCase>();
  final _cartUseCase = Get.find<CartUseCase>();

  final product = Rxn<Product>(); // null khi đang load
  final isLoading = false.obs;
  final cartQuantity = 0.obs;

  late int _productId;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Product) {
      product.value = arguments;
      _productId = arguments.id;
    } else if (arguments is Map) {
      final rawProduct = arguments['product'];
      if (rawProduct is Product) {
        product.value = rawProduct;
        _productId = rawProduct.id;
      } else {
        _productId = 0;
      }
    } else {
      _productId = arguments is int ? arguments : 0;
    }
    _fetchDetail();
    _loadCartQuantity();
  }

  // ─── Tải chi tiết sản phẩm từ API ────────────────────────────
  Future<void> _fetchDetail() async {
    isLoading.value = true;
    try {
      product.value = await _useCase.getProductDetail(_productId);
    } catch (e, st) {
      print('=== LỖI CHI TIẾT SP ===');
      print(e);
      print(st);
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadCartQuantity() {
    final items = _cartUseCase.loadItems();
    final item = items.cast<CartItem?>().firstWhere(
      (entry) => entry?.product.id == _productId,
      orElse: () => null,
    );
    cartQuantity.value = item?.quantity ?? 0;
  }

  // ─── Sang màn edit, truyền Product hiện tại vào form ─────────
  void goToEdit() async {
    final updated = await Get.toNamed(
      AppRoutes.productForm,
      arguments: product.value, // form nhận Product này để điền sẵn
    );

    if (updated is Product) {
      product.value = updated;
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().updateProductInList(updated);
      }
      // Giỏ hàng lưu snapshot Product riêng trong Hive nên cần đồng bộ lại.
      // Nếu CartController đang sống (đã từng mở màn Giỏ hàng trong phiên
      // này) thì gọi qua nó để danh sách đang hiển thị được làm mới NGAY.
      // Nếu chưa (chưa đăng ký), vẫn phải ghi thẳng qua _cartUseCase (đăng ký
      // global, luôn tồn tại) để dữ liệu lưu trong Hive đúng ngay từ bây giờ
      // - nếu không, lần đầu mở màn Giỏ hàng sau đó vẫn sẽ đọc ra bản cũ.
      if (Get.isRegistered<CartController>()) {
        await Get.find<CartController>().updateProductInList(updated);
      } else {
        await _cartUseCase.updateProduct(updated);
      }
    } else if (updated == true) {
      // Reload lại thông tin sau khi sửa
      await _fetchDetail();
    }
  }

  // ─── Xóa sản phẩm (có dialog xác nhận) ───────────────────────
  Future<void> deleteProduct() async {
    final confirmed = await showConfirmDialog(
      title: 'Xóa sản phẩm',
      message: 'Xóa "${product.value?.name}"?\nThao tác này không thể hoàn tác.',
      confirmLabel: 'Xóa',
    );

    if (!confirmed) return;

    isLoading.value = true;
    try {
      await _useCase.deleteProduct(_productId);
      // Quay về list, báo list tự reload
      Get.back(result: true);
      await showAppMessageDialog(
        title: 'Thành công',
        message: 'Đã xóa sản phẩm',
        isSuccess: true,
      );
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

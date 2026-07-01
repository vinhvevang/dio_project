import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/data/models/product_model.dart';
import 'package:dio_complete/data/services/product_service.dart';
import 'package:dio_complete/presentation/home/home_controller.dart';
import 'package:dio_complete/routes/app_routes.dart';

class ProductDetailController extends GetxController {
  final _service = ProductService();

  final product = Rxn<Product>(); // null khi đang load
  final isLoading = false.obs;

  late int _productId;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    if (arguments is Product) {
      product.value = arguments;
      _productId = arguments.id;
    } else {
      _productId = arguments is int ? arguments : 0;
    }
    _fetchDetail();
  }

  // ─── Tải chi tiết sản phẩm từ API ────────────────────────────
  Future<void> _fetchDetail() async {
    isLoading.value = true;
    try {
      product.value = await _service.getProductDetail(_productId);
    } catch (e, st) {
      print('=== LỖI CHI TIẾT SP ===');
      print(e);
      print(st);
      Get.snackbar(
        'Lỗi',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
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
    } else if (updated == true) {
      // Reload lại thông tin sau khi sửa
      await _fetchDetail();
    }
  }

  // ─── Xóa sản phẩm (có dialog xác nhận) ───────────────────────
  Future<void> deleteProduct() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Xóa sản phẩm'),
        content: Text(
            'Xóa "${product.value?.name}"?\nThao tác này không thể hoàn tác.'),
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
      ),
    );

    if (confirmed != true) return;

    isLoading.value = true;
    try {
      await _service.deleteProduct(_productId);
      // Quay về list, báo list tự reload
      Get.back(result: true);
      Get.snackbar(
        'Thành công',
        'Đã xóa sản phẩm',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

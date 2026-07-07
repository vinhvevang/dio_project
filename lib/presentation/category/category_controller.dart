import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/data/models/category_model.dart';
import 'package:dio_complete/data/services/category_service.dart';
import 'package:dio_complete/data/services/product_service.dart';
import 'package:dio_complete/presentation/category/category_form_controller.dart';
import 'package:dio_complete/presentation/category/widgets/category_form_dialog.dart';
import 'package:dio_complete/presentation/home/home_controller.dart';

class CategoryController extends GetxController {
  final _service = CategoryService();
  final _productService = ProductService();

  final categories = <Category>[].obs;

  /// null nghĩa là "Tất cả sản phẩm" (không lọc theo danh mục nào).
  final selectedCategory = Rx<Category?>(null);

  final isLoading = false.obs;
  final isDistributing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    try {
      categories.assignAll(await _service.getCategories());
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

  /// Chọn danh mục để lọc sản phẩm ở Home, rồi đóng Drawer lại.
  void selectCategory(Category? category) {
    selectedCategory.value = category;
    Get.back();
  }

  Future<void> openAddDialog() async {
    final formController = CategoryFormController();

    final name = await Get.dialog<String>(
      CategoryFormDialog(controller: formController),
    );

    if (name == null) return;

    try {
      final id = await _service.createCategory(name: name);
      // API tạo danh mục chỉ trả về id (data: 5), không trả nguyên object,
      // nên tự dựng Category cục bộ để cập nhật danh sách ngay, không cần
      // gọi lại loadCategories().
      final now = DateTime.now().toIso8601String();
      categories.add(
        Category(id: id, status: 1, createdAt: now, updatedAt: now, name: name),
      );
      Get.snackbar(
        'Thành công',
        'Đã thêm danh mục "$name"',
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
    }
  }

  Future<void> openEditDialog(Category category) async {
    final formController = CategoryFormController(initial: category);

    final name = await Get.dialog<String>(
      CategoryFormDialog(controller: formController),
    );

    if (name == null) return;

    try {
      await _service.updateCategory(id: category.id, name: name);

      final updated = category.copyWith(
        name: name,
        updatedAt: DateTime.now().toIso8601String(),
      );
      final index = categories.indexWhere((c) => c.id == category.id);
      if (index >= 0) categories[index] = updated;

      // Nếu đang lọc theo đúng danh mục vừa sửa, cập nhật luôn tên hiển thị.
      if (selectedCategory.value?.id == category.id) {
        selectedCategory.value = updated;
      }

      Get.snackbar(
        'Thành công',
        'Đã cập nhật danh mục',
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
    }
  }

  Future<void> confirmAndDelete(Category category) async {
    final confirmed = await showConfirmDialog(
      title: 'Xóa danh mục',
      message: 'Xóa danh mục "${category.name}"? Thao tác này không thể hoàn tác.',
      confirmLabel: 'Xóa',
    );

    if (!confirmed) return;

    try {
      await _service.deleteCategory(category.id);
      categories.removeWhere((c) => c.id == category.id);

      // Đang lọc theo đúng danh mục vừa xóa -> quay về "Tất cả".
      if (selectedCategory.value?.id == category.id) {
        selectedCategory.value = null;
      }

      Get.snackbar(
        'Thành công',
        'Đã xóa danh mục',
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
    }
  }

  /// Giải pháp tạm thời: backend chưa có sẵn category_id cho các sản phẩm đã
  /// tồn tại từ trước, nên chia đều (round-robin) toàn bộ sản phẩm hiện có
  /// vào các danh mục đã tạo, gọi PUT /products/:id thật cho từng sản phẩm để
  /// lưu lại trên backend - không phải chỉ hiển thị giả ở client.
  Future<void> distributeProductsIntoCategories() async {
    if (categories.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Chưa có danh mục nào để phân bổ - tạo danh mục trước đã',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    final confirmed = await showConfirmDialog(
      title: 'Phân bổ sản phẩm vào danh mục',
      message:
          'Thao tác này sẽ gán lại danh mục cho TẤT CẢ sản phẩm hiện có, '
          'chia đều vào ${categories.length} danh mục đã tạo. Chỉ nên dùng '
          'tạm thời cho sản phẩm cũ chưa có danh mục. Tiếp tục?',
      confirmLabel: 'Phân bổ',
      isDestructive: false,
    );

    if (!confirmed) return;

    isDistributing.value = true;
    try {
      final result = await _productService.getProducts(page: 1, limit: 1000);
      final products = result.products;

      for (var i = 0; i < products.length; i++) {
        final product = products[i];
        final category = categories[i % categories.length];

        await _productService.updateProduct(
          id: product.id,
          name: product.name,
          code: product.code,
          price: product.price,
          stock: product.stock,
          description: product.description,
          image: product.image,
          category: category,
        );
      }

      Get.snackbar(
        'Thành công',
        'Đã phân bổ ${products.length} sản phẩm vào ${categories.length} danh mục',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );

      // Home đang mở thì tải lại danh sách để thấy category_id mới ngay.
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().refresh();
      }
    } catch (e) {
      Get.snackbar(
        'Lỗi',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isDistributing.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/confirm_dialog.dart';
import 'package:dio_complete/core/widgets/app_message_dialog.dart';
import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/category/domain/usecases/category_usecase.dart';
import 'package:dio_complete/features/product/domain/usecases/product_usecase.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_form_controller.dart';
import 'package:dio_complete/features/category/presentation/widgets/category_form_dialog.dart';
import 'package:dio_complete/features/product/presentation/controllers/home_controller.dart';

class CategoryController extends GetxController {
  final _categoryUseCase = Get.find<CategoryUseCase>();
  final _productUseCase = Get.find<ProductUseCase>();

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
      categories.assignAll(await _categoryUseCase.loadCategories());
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
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
      final id = await _categoryUseCase.createCategory(name: name);
      // API tạo danh mục chỉ trả về id (data: 5), không trả nguyên object,
      // nên tự dựng Category cục bộ để cập nhật danh sách ngay, không cần
      // gọi lại loadCategories().
      final now = DateTime.now().toIso8601String();
      categories.add(
        Category(id: id, status: 1, createdAt: now, updatedAt: now, name: name),
      );
      await showAppMessageDialog(
        title: 'Thành công',
        message: 'Đã thêm danh mục "$name"',
        isSuccess: true,
      );
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
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
      await _categoryUseCase.updateCategory(id: category.id, name: name);

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

      await showAppMessageDialog(
        title: 'Thành công',
        message: 'Đã cập nhật danh mục',
        isSuccess: true,
      );
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
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
      await _categoryUseCase.deleteCategory(category.id);
      categories.removeWhere((c) => c.id == category.id);

      // Đang lọc theo đúng danh mục vừa xóa -> quay về "Tất cả".
      if (selectedCategory.value?.id == category.id) {
        selectedCategory.value = null;
      }

      await showAppMessageDialog(
        title: 'Thành công',
        message: 'Đã xóa danh mục',
        isSuccess: true,
      );
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  /// Giải pháp tạm thời: backend chưa có sẵn category_id cho các sản phẩm đã
  /// tồn tại từ trước, nên chia đều (round-robin) toàn bộ sản phẩm hiện có
  /// vào các danh mục đã tạo, gọi PUT /products/:id thật cho từng sản phẩm để
  /// lưu lại trên backend - không phải chỉ hiển thị giả ở client.
  Future<void> distributeProductsIntoCategories() async {
    if (categories.isEmpty) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: 'Chưa có danh mục nào để phân bổ - tạo danh mục trước đã',
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
      final result = await _productUseCase.getProducts(page: 1, limit: 1000);
      final products = result.products;

      for (var i = 0; i < products.length; i++) {
        final product = products[i];
        final category = categories[i % categories.length];

        await _productUseCase.updateProduct(
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

      await showAppMessageDialog(
        title: 'Thành công',
        message: 'Đã phân bổ ${products.length} sản phẩm vào ${categories.length} danh mục',
        isSuccess: true,
      );

      // Home đang mở thì tải lại danh sách để thấy category_id mới ngay.
      if (Get.isRegistered<HomeController>()) {
        await Get.find<HomeController>().refresh();
      }
    } catch (e) {
      await showAppMessageDialog(
        title: 'Lỗi',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      isDistributing.value = false;
    }
  }
}

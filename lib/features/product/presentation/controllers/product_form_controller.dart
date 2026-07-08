import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_message_dialog.dart';
import 'package:dio_complete/features/category/data/models/category_model.dart';
import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/product/domain/usecases/product_usecase.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_controller.dart';

class ProductFormController extends GetxController {
  final _useCase = Get.find<ProductUseCase>();
  final categoryController = Get.find<CategoryController>();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();

  final nameFocusNode = FocusNode();
  final codeFocusNode = FocusNode();
  final priceFocusNode = FocusNode();
  final stockFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final imageFocusNode = FocusNode();

  // Observable riêng để preview ảnh
  final imageUrl = ''.obs;

  // Danh mục đang chọn cho sản phẩm - bắt buộc phải có khi thêm/sửa.
  final selectedCategory = Rx<Category?>(null);

  final isLoading = false.obs;
  final fieldError = ''.obs;
  final hasSubmittedOnce = false.obs;

  Product? _existingProduct;
  bool get isEditMode => _existingProduct != null;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Product) {
      _existingProduct = Get.arguments as Product;
      _prefillForm(_existingProduct!);
    }
    // Sync imageUrl observable khi text thay đổi
    imageController.addListener(() {
      imageUrl.value = imageController.text.trim();
    });
  }

  @override
  void onClose() {
    nameController.dispose();
    codeController.dispose();
    priceController.dispose();
    stockController.dispose();
    descriptionController.dispose();
    imageController.dispose();

    nameFocusNode.dispose();
    codeFocusNode.dispose();
    priceFocusNode.dispose();
    stockFocusNode.dispose();
    descriptionFocusNode.dispose();
    imageFocusNode.dispose();
    super.onClose();
  }

  void _prefillForm(Product p) {
    nameController.text = p.name;
    codeController.text = p.code;
    priceController.text = p.price.toStringAsFixed(0);
    stockController.text = p.stock.toString();
    descriptionController.text = p.description;
    imageController.text = p.image;
    imageUrl.value = p.image;
    // Product giờ mang sẵn object category đầy đủ (backend trả object lồng
    // "category": {...}), không cần tra cứu qua danh sách categoryController
    // nữa. Vẫn khớp lại với đúng instance trong categories (nếu có) để dropdown
    // hiển thị đúng, tránh 2 object khác instance nhưng cùng id gây lệch UI.
    selectedCategory.value = _matchInCategoryList(p.category);
  }

  Category? _matchInCategoryList(Category? category) {
    if (category == null) return null;
    for (final c in categoryController.categories) {
      if (c.id == category.id) return c;
    }
    // Không tìm thấy trong danh sách (danh mục đã bị xóa, hoặc chưa tải xong)
    // -> PHẢI trả null chứ không trả object của sản phẩm, vì
    // DropdownButtonFormField sẽ crash nếu value không trùng identity với
    // bất kỳ item nào trong items (items lấy từ categoryController.categories).
    return null;
  }

  void selectCategory(Category? category) => selectedCategory.value = category;

  void clearFieldError() {
    if (fieldError.value.isNotEmpty) {
      fieldError.value = '';
    }
  }

  String? validateCategory(Category? value) {
    return value == null ? 'Vui lòng chọn danh mục' : null;
  }

  Future<void> submit() async {
    if (isLoading.value) return; // chặn bấm liên tiếp khi đang xử lý
    hasSubmittedOnce.value = true;
    if (!formKey.currentState!.validate()) return;
    if (selectedCategory.value == null) {
      fieldError.value = 'Vui lòng chọn danh mục cho sản phẩm';
      return;
    }

    fieldError.value = '';

    isLoading.value = true;
    try {
      final name = nameController.text.trim();
      final code = codeController.text.trim();
      final price = double.parse(priceController.text.trim());
      final stock = int.tryParse(stockController.text.trim()) ?? 0;
      final description = descriptionController.text.trim();
      final image = imageController.text.trim();
      final category = selectedCategory.value!;

      if (isEditMode) {
        final updatedProduct = await _useCase.updateProduct(
          id: _existingProduct!.id,
          name: name,
          code: code,
          price: price,
          stock: stock,
          description: description,
          image: image,
          category: category,
        );
        Get.back(result: updatedProduct);
        await showAppMessageDialog(
          title: 'Thành công',
          message: 'Đã cập nhật sản phẩm',
          isSuccess: true,
        );
      } else {
        final createdProduct = await _useCase.createProduct(
          name: name,
          code: code,
          price: price,
          stock: stock,
          description: description,
          image: image,
          category: category,
        );
        Get.back(result: createdProduct);
        await showAppMessageDialog(
          title: 'Thành công',
          message: 'Đã tạo sản phẩm mới',
          isSuccess: true,
        );
      }
    } catch (e, st) {
      print('=== LỖI TẠO/SỬA SP ===');
      print(e);
      print(st);
      fieldError.value = e.toString().replaceAll('Exception: ', '');
      await showAppMessageDialog(
        title: 'Lỗi',
        message: fieldError.value,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

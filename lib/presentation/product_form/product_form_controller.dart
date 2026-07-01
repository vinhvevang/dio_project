import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/data/models/product_model.dart';
import 'package:dio_complete/data/services/product_service.dart';

class ProductFormController extends GetxController {
  final _service = ProductService();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final codeController = TextEditingController();
  final priceController = TextEditingController();
  final stockController = TextEditingController();
  final descriptionController = TextEditingController();
  final imageController = TextEditingController();

  // Observable riêng để preview ảnh
  final imageUrl = ''.obs;

  final isLoading = false.obs;

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
  }

  Future<void> submit() async {
    if (isLoading.value) return; // chặn bấm liên tiếp khi đang xử lý
    if (!formKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      final name = nameController.text.trim();
      final code = codeController.text.trim();
      final price = double.parse(priceController.text.trim());
      final stock = int.tryParse(stockController.text.trim()) ?? 0;
      final description = descriptionController.text.trim();
      final image = imageController.text.trim();

      if (isEditMode) {
        final updatedProduct = await _service.updateProduct(
          id: _existingProduct!.id,
          name: name,
          code: code,
          price: price,
          stock: stock,
          description: description,
          image: image,
        );
        Get.back(result: updatedProduct);
        Get.snackbar('Thành công', 'Đã cập nhật sản phẩm',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100);
      } else {
        final createdProduct = await _service.createProduct(
          name: name,
          code: code,
          price: price,
          stock: stock,
          description: description,
          image: image,
        );
        Get.back(result: createdProduct);
        Get.snackbar('Thành công', 'Đã tạo sản phẩm mới',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.shade100);
      }
    } catch (e, st) {
      print('=== LỖI TẠO/SỬA SP ===');
      print(e);
      print(st);
      Get.snackbar('Lỗi', e.toString().replaceAll('Exception: ', ''),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100);
    } finally {
      isLoading.value = false;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/features/category/data/models/category_model.dart';

/// Điều khiển form Thêm/Sửa danh mục. Là object Dart thường (không qua
/// Get.put/Get.find, không tự dispose FocusNode/TextEditingController) -
/// tránh đúng lỗi "used after disposed" đã từng gặp với pattern Get.put +
/// dispose theo thời điểm đoán được cho các control tạm thời trong dialog.
class CategoryFormController {
  CategoryFormController({Category? initial}) : isEditing = initial != null {
    if (initial != null) {
      nameController.text = initial.name;
    }
  }

  final bool isEditing;

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final nameFocusNode = FocusNode();
  final fieldError = ''.obs;

  /// Validate và trả về tên đã nhập nếu hợp lệ, null nếu chưa (để dialog biết
  /// không nên đóng).
  String? submit() {
    if (!formKey.currentState!.validate()) return null;
    return nameController.text.trim();
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/presentation/category/category_form_controller.dart';

/// Dialog Thêm/Sửa danh mục dùng chung. Nhận [controller] qua constructor
/// (không qua Get.find) để không lệ thuộc GetX DI cho object tạm thời này.
class CategoryFormDialog extends StatelessWidget {
  final CategoryFormController controller;

  const CategoryFormDialog({super.key, required this.controller});

  void _handleSubmit() {
    final name = controller.submit();
    if (name != null) {
      Get.back<String>(result: name);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(controller.isEditing ? 'Sửa danh mục' : 'Thêm danh mục'),
      content: Form(
        key: controller.formKey,
        child: TextFormField(
          controller: controller.nameController,
          focusNode: controller.nameFocusNode,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Tên danh mục',
            hintText: 'VD: Đồ uống',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Tên danh mục không được để trống';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => _handleSubmit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: null),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          onPressed: _handleSubmit,
          child: Text(controller.isEditing ? 'Lưu' : 'Thêm'),
        ),
      ],
    );
  }
}

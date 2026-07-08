import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_text_field.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_form_controller.dart';

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
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: AppTextFormField(
          controller: controller.nameController,
          focusNode: controller.nameFocusNode,
          autofocus: true,
          label: 'Tên danh mục',
          hintText: 'VD: Đồ uống',
          onChanged: (_) => controller.fieldError.value = '',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Tên danh mục không được để trống';
            }
            return null;
          },
          textInputAction: TextInputAction.done,
          onSubmit: _handleSubmit,
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

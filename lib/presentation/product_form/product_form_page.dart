import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_text_field.dart';
import 'package:dio_complete/data/models/category_model.dart';
import 'package:dio_complete/presentation/product_form/product_form_controller.dart';

class ProductFormPage extends GetView<ProductFormController> {
  const ProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditMode ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        backgroundColor: Color(0xFFF24E1E),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Preview ảnh (reactive theo imageUrl observable) ──
              Obx(() {
                final url = controller.imageUrl.value;
                if (url.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        url,
                        height: 160,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 60,
                          color: Colors.grey.shade200,
                          child: const Center(
                              child: Text('URL ảnh không hợp lệ',
                                  style: TextStyle(color: Colors.grey))),
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // ── Tên sản phẩm ────────────────────────────────────
              AppTextFormField(
                controller: controller.nameController,
                focusNode: controller.nameFocusNode,
                nextFocus: controller.codeFocusNode,
                label: 'Tên sản phẩm *',
                hintText: 'Nhập tên sản phẩm',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Tên không được để trống'
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Mã sản phẩm ─────────────────────────────────────
              AppTextFormField(
                controller: controller.codeController,
                focusNode: controller.codeFocusNode,
                nextFocus: controller.priceFocusNode,
                label: 'Mã sản phẩm *',
                hintText: 'VD: DHN-001',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Mã không được để trống'
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Giá ─────────────────────────────────────────────
              AppTextFormField(
                controller: controller.priceController,
                focusNode: controller.priceFocusNode,
                nextFocus: controller.stockFocusNode,
                label: 'Giá (đ) *',
                hintText: 'VD: 120000',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Giá không được để trống';
                  }
                  final val = int.tryParse(v.trim());
                  if (val == null) return 'Giá phải là số nguyên';
                  if (val < 0) return 'Giá không được âm';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ── Số lượng ─────────────────────────────────────────
              // Field cuối trước Danh mục (Dropdown không nằm trong chuỗi
              // focus vì nó không phải bàn phím) - nên Enter ở đây chuyển
              // luôn tới URL ảnh (field văn bản tiếp theo sau Dropdown).
              AppTextFormField(
                controller: controller.stockController,
                focusNode: controller.stockFocusNode,
                nextFocus: controller.imageFocusNode,
                label: 'Số lượng *',
                hintText: 'VD: 10',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Số lượng không được để trống';
                  }
                  final val = int.tryParse(v.trim());
                  if (val == null) return 'Số lượng phải là số nguyên';
                  if (val < 0) return 'Số lượng không được âm';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ── Danh mục ─────────────────────────────────────────
              Obx(() {
                final categories = controller.categoryController.categories;

                if (controller.categoryController.isLoading.value &&
                    categories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (categories.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 18, color: Colors.orange.shade800),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Chưa có danh mục nào. Mở menu bên trái (kéo từ mép trái) để tạo danh mục trước.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.orange.shade800),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return DropdownButtonFormField<Category>(
                  value: controller.selectedCategory.value,
                  hint: const Text('Chọn danh mục'),
                  decoration: InputDecoration(
                    labelText: 'Danh mục *',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: controller.selectCategory,
                  validator: controller.validateCategory,
                );
              }),
              const SizedBox(height: 12),

              // ── URL ảnh ──────────────────────────────────────────
              AppTextFormField(
                controller: controller.imageController,
                focusNode: controller.imageFocusNode,
                nextFocus: controller.descriptionFocusNode,
                label: 'URL ảnh *',
                hintText: 'https://...',
                prefixIcon: const Icon(Icons.image_outlined),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'URL ảnh không được để trống';
                  }
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme) return 'URL không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ── Mô tả ────────────────────────────────────────────
              // Field cuối cùng: nhấn Enter/Done coi như bấm nút submit.
              AppTextFormField(
                controller: controller.descriptionController,
                focusNode: controller.descriptionFocusNode,
                onSubmit: controller.submit,
                maxLines: 4,
                label: 'Mô tả',
                hintText: 'Nhập mô tả sản phẩm...',
              ),
              const SizedBox(height: 24),

              // ── Nút submit ───────────────────────────────────────
              Obx(() => SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                          controller.isLoading.value ? null : controller.submit,
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Icon(controller.isEditMode
                              ? Icons.save
                              : Icons.add_circle_outline),
                      label: Text(controller.isLoading.value
                          ? 'Đang xử lý...'
                          : (controller.isEditMode
                              ? 'Lưu thay đổi'
                              : 'Tạo sản phẩm')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFF24E1E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  )),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

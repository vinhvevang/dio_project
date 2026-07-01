import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/presentation/product_form/product_form_controller.dart';

class ProductFormPage extends GetView<ProductFormController> {
  const ProductFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditMode ? 'Sửa sản phẩm' : 'Thêm sản phẩm'),
        backgroundColor: Colors.blue,
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
              _buildField(
                ctrl: controller.nameController,
                label: 'Tên sản phẩm *',
                hint: 'Nhập tên sản phẩm',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Tên không được để trống'
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Mã sản phẩm ─────────────────────────────────────
              _buildField(
                ctrl: controller.codeController,
                label: 'Mã sản phẩm *',
                hint: 'VD: DHN-001',
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Mã không được để trống'
                    : null,
              ),
              const SizedBox(height: 12),

              // ── Giá ─────────────────────────────────────────────
              _buildField(
                ctrl: controller.priceController,
                label: 'Giá (đ) *',
                hint: 'VD: 120000',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Giá không được để trống';
                  final val = int.tryParse(v.trim());
                  if (val == null) return 'Giá phải là số nguyên';
                  if (val < 0) return 'Giá không được âm';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ── Số lượng ─────────────────────────────────────────
              _buildField(
                ctrl: controller.stockController,
                label: 'Số lượng *',
                hint: 'VD: 10',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Số lượng không được để trống';
                  final val = int.tryParse(v.trim());
                  if (val == null) return 'Số lượng phải là số nguyên';
                  if (val < 0) return 'Số lượng không được âm';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ── URL ảnh ──────────────────────────────────────────
              TextFormField(
                controller: controller.imageController,
                decoration: InputDecoration(
                  labelText: 'URL ảnh *',
                  hintText: 'https://...',
                  prefixIcon: const Icon(Icons.image_outlined),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'URL ảnh không được để trống';
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || !uri.hasScheme) return 'URL không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // ── Mô tả ────────────────────────────────────────────
              TextFormField(
                controller: controller.descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Mô tả',
                  hintText: 'Nhập mô tả sản phẩm...',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
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
                        backgroundColor: Colors.blue,
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

  Widget _buildField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

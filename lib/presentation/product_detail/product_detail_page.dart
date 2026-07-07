import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/presentation/product_detail/product_detail_controller.dart';

class ProductDetailPage extends GetView<ProductDetailController> {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết sản phẩm'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          // Nút sửa
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Sửa sản phẩm',
            onPressed: controller.goToEdit,
          ),
          // Nút xóa
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Xóa sản phẩm',
            onPressed: controller.deleteProduct,
          ),
        ],
      ),
      body: Obx(() {
        // Đang tải lần đầu
        if (controller.isLoading.value && controller.product.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final p = controller.product.value;
        if (p == null) {
          return const Center(child: Text('Không tìm thấy sản phẩm'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Ảnh sản phẩm ──────────────────────────────────
              if (p.image.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  height: 240,
                  child: Image.network(
                    p.image,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image,
                          size: 60, color: Colors.grey),
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  height: 180,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.image, size: 60, color: Colors.grey),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Tên & trạng thái ─────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: p.status == 1
                                ? Colors.green.shade100
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            p.status == 1 ? 'Còn bán' : 'Ngừng bán',
                            style: TextStyle(
                              fontSize: 12,
                              color: p.status == 1
                                  ? Colors.green.shade700
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Mã sản phẩm ───────────────────────────────
                    Text('Mã SP: ${p.code}',
                        style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 4),

                    // ── Danh mục ──────────────────────────────────
                    Row(
                      children: [
                        Icon(Icons.category_outlined,
                            size: 14, color: Colors.grey.shade600),
                        const SizedBox(width: 4),
                        Text(
                          p.category?.name ?? 'Chưa phân loại',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Giá & Tồn kho ─────────────────────────────
                    Row(
                      children: [
                        _infoBox(
                          label: 'Giá bán',
                          value: '${p.price.toStringAsFixed(0)}đ',
                          color: Colors.blue.shade50,
                          textColor: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        _infoBox(
                          label: 'Tồn kho',
                          value: '${p.stock} cái',
                          color: Colors.orange.shade50,
                          textColor: Colors.orange.shade700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Mô tả ─────────────────────────────────────
                    if (p.description.isNotEmpty) ...[
                      const Text('Mô tả',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 14)),
                      const SizedBox(height: 6),
                      Text(p.description,
                          style: const TextStyle(
                              height: 1.5, color: Colors.black87)),
                      const SizedBox(height: 16),
                    ],

                    // ── Ngày tạo / cập nhật ───────────────────────
                    const Divider(),
                    const SizedBox(height: 8),
                    _metaRow('Ngày tạo', p.createdAt),
                    const SizedBox(height: 4),
                    _metaRow('Cập nhật', p.updatedAt),
                    const SizedBox(height: 24),

                    // ── Nút sửa & xóa ────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: controller.goToEdit,
                            icon: const Icon(Icons.edit),
                            label: const Text('Sửa thông tin'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                              side: const BorderSide(color: Colors.blue),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: controller.deleteProduct,
                            icon: const Icon(Icons.delete),
                            label: const Text('Xóa sản phẩm'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Widget ô thông tin ────────────────────────────────────────
  Widget _infoBox({
    required String label,
    required String value,
    required Color color,
    required Color textColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: textColor)),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor)),
          ],
        ),
      ),
    );
  }

  Widget _metaRow(String label, String value) => Row(
        children: [
          Text('$label: ',
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
        ],
      );
}

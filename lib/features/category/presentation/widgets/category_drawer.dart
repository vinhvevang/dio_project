import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/features/category/presentation/controllers/category_controller.dart';

/// Drawer kéo từ mép trái (tự động nhờ Scaffold.drawer) để chọn danh mục lọc
/// sản phẩm ở Home, kèm thêm/sửa/xóa danh mục ngay tại đây.
class CategoryDrawer extends StatelessWidget {
  const CategoryDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CategoryController>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Color(0xFFF24E1E),
              child: const Row(
                children: [
                  Icon(Icons.category_outlined, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    'Danh mục',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value && controller.categories.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.apps),
                      title: const Text('Tất cả sản phẩm'),
                      selected: controller.selectedCategory.value == null,
                      selectedTileColor: Colors.blue.shade50,
                      onTap: () => controller.selectCategory(null),
                    ),
                    const Divider(height: 1),
                    if (controller.categories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text(
                          'Chưa có danh mục nào',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ...controller.categories.map((category) {
                      final isSelected =
                          controller.selectedCategory.value?.id == category.id;

                      return ListTile(
                        leading: const Icon(Icons.label_outline),
                        title: Text(category.name),
                        selected: isSelected,
                        selectedTileColor: Colors.blue.shade50,
                        onTap: () => controller.selectCategory(category),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 20),
                              tooltip: 'Sửa danh mục',
                              onPressed: () => controller.openEditDialog(category),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red),
                              tooltip: 'Xóa danh mục',
                              onPressed: () => controller.confirmAndDelete(category),
                            ),
                          ],
                        ),
                      );
                    }),
                    // Loading khi đang tạo danh mục mới - đặt TRONG ListView,
                    // ngay sau danh mục cuối cùng, thay vì sau Expanded (chỗ
                    // đó bị đẩy xuống tận đáy Drawer vì Expanded chiếm hết
                    // khoảng trống còn thừa). Đặt ở đây thì nó luôn bám sát
                    // ngay dưới danh sách dù danh sách dài hay ngắn.
                    if (controller.isSubmittingCategory.value)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5),
                          ),
                        ),
                      ),
                  ],
                );
              }),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: SizedBox(
                width: double.infinity,
                height: 44,
                child: Obx(
                  () => OutlinedButton.icon(
                    // Disable trong lúc đang submit để tránh bấm thêm lần nữa
                    // khi danh mục trước đó còn chưa tạo xong.
                    onPressed: controller.isSubmittingCategory.value
                        ? null
                        : controller.openAddDialog,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm danh mục'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
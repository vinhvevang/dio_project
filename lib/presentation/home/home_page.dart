import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/presentation/category/category_controller.dart';
import 'package:dio_complete/presentation/category/widgets/category_drawer.dart';
import 'package:dio_complete/presentation/home/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const CategoryDrawer(),
      appBar: AppBar(
        title: Center(child: const Text('Sản phẩm')),
        backgroundColor: Color(0xFFF24E1E),
        foregroundColor: Colors.white,
        actions: [
          Obx(
            () => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined),
                  onPressed: controller.goToCart,
                  tooltip: 'Giỏ hàng',
                ),
                if (controller.cartCount.value > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${controller.cartCount.value}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
            tooltip: 'Đăng xuất',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm theo tên...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: Obx(
                        () =>
                            controller.searchText.value.isNotEmpty
                                ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    controller.searchController.clear();
                                    controller.onSearchChanged('');
                                  },
                                )
                                : const SizedBox.shrink(),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune),
                        tooltip: 'Lọc theo giá',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              controller.isFilterActive
                                  ? Colors.blue.shade50
                                  : null,
                        ),
                        onPressed: () => _showPriceFilter(context),
                      ),
                      if (controller.isFilterActive)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            final category =
                Get.find<CategoryController>().selectedCategory.value;
            if (category == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Row(
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 14,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Danh mục: ${category.name}',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap:
                        () =>
                            Get.find<CategoryController>()
                                .selectedCategory
                                .value = null,
                    child: const Text(
                      'Bỏ lọc',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Obx(() {
            if (!controller.isFilterActive) {
              return const SizedBox.shrink();
            }

            return Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
              child: Row(
                children: [
                  Icon(Icons.filter_alt, size: 14, color: Colors.blue.shade600),
                  const SizedBox(width: 4),
                  Text(
                    'Sắp xếp gần giá: ${controller.targetPrice.value.toStringAsFixed(0)}đ',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: controller.clearPriceFilter,
                    child: const Text(
                      'Xóa lọc',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value &&
                  controller.shownProducts.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.shownProducts.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Không tìm thấy sản phẩm',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: GridView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 90),
                  itemCount:
                      controller.shownProducts.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    if (index >= controller.shownProducts.length) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final product = controller.shownProducts[index];

                    return Card(
                      margin: EdgeInsets.zero,
                      elevation: 1,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: InkWell(
                        onTap: () => controller.goToDetail(product),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Ảnh vuông full-width, nút giỏ hàng nổi góc dưới-phải -
                            // chuẩn cho card lưới 2 cột, thay vì Row ngang bị nhồi ép.
                            AspectRatio(
                              aspectRatio: 1,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  product.image.isNotEmpty
                                      ? Image.network(
                                        product.image,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (_, __, ___) => _placeholder(),
                                      )
                                      : _placeholder(),
                                  Positioned(
                                    right: 6,
                                    bottom: 6,
                                    child: Material(
                                      color: Colors.white,
                                      shape: const CircleBorder(),
                                      elevation: 2,
                                      child: InkWell(
                                        customBorder: const CircleBorder(),
                                        onTap:
                                            () => controller.addToCart(product),
                                        child: const Padding(
                                          padding: EdgeInsets.all(7),
                                          child: Icon(
                                            Icons.add_shopping_cart,
                                            size: 18,
                                            color: Color(0xFFF24E1E),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Thông tin bên dưới ảnh
                            Padding(
                              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (product.category != null) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        product.category!.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.blue.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Text(
                                    'Mã: ${product.code}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${product.price.toStringAsFixed(0)}đ',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Color(0xFFF24E1E),
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Kho: ${product.stock}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          product.stock <= 5
                                              ? Colors.red
                                              : Colors.grey,
                                      fontWeight:
                                          product.stock <= 5
                                              ? FontWeight.w600
                                              : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.goToAddProduct,
        icon: const Icon(Icons.add),
        label: const Text('Thêm SP'),
        backgroundColor: Color(0xFFF24E1E),
        foregroundColor: Colors.white,
      ),
    );
  }

  void _showPriceFilter(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Lọc theo giá',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    controller.clearPriceFilter();
                    Get.back();
                  },
                  child: const Text(
                    'Xóa lọc',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text(
              'Nhập giá mục tiêu. Danh sách sẽ sắp xếp sản phẩm có giá gần nhất lên đầu.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.priceFilterController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Giá mục tiêu (đ)',
                hintText: 'VD: 500000',
                prefixIcon: const Icon(Icons.attach_money),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: controller.applyPriceFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF24E1E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Áp dụng'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _placeholder() => Container(
    width: 65,
    height: 65,
    color: Colors.grey.shade200,
    child: const Icon(Icons.image, color: Colors.grey),
  );
}

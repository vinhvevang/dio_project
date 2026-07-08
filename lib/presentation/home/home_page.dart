import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/data/models/category_model.dart';
import 'package:dio_complete/data/models/product_model.dart';
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
                  child: _ProductSearchBar(controller: controller),
                ),
                const SizedBox(width: 8),
                Obx(
                  () => Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.tune),
                        tooltip: 'Bộ lọc',
                        style: IconButton.styleFrom(
                          backgroundColor:
                              controller.isFilterActive
                                  ? Colors.blue.shade50
                                  : null,
                        ),
                        onPressed: () => _showFilterSheet(context),
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
                child: CustomScrollView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
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
                          childCount: controller.shownProducts.length,
                        ),
                      ),
                    ),
                    // Spinner load-thêm: sliver RIÊNG, full-width màn hình -
                    // trước đây "+1" vào itemCount của GridView nên spinner bị
                    // kẹt gọn trong đúng 1 ô lưới (nửa trái/phải), không phải
                    // giữa màn hình. Tách sliver thế này thì Center bên trong
                    // mới thật sự căn giữa theo chiều ngang toàn màn hình, và
                    // luôn nằm ngay dưới hàng sản phẩm cuối cùng.
                    if (controller.isLoadingMore.value)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    // Chừa khoảng trống cuối cùng để FAB không đè lên sản phẩm.
                    const SliverToBoxAdapter(child: SizedBox(height: 80)),
                  ],
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

  void _showFilterSheet(BuildContext context) {
    final categoryController = Get.find<CategoryController>();

    // Danh mục NHÁP: chỉ ghi vào categoryController.selectedCategory (state
    // thật, cái HomeController đang lắng nghe để lọc danh sách) khi bấm
    // "Áp dụng" - giống hệt cách priceFilterController/targetPrice đã làm
    // cho giá (gõ giá không lọc ngay, phải bấm Áp dụng). Trước đây chip chọn
    // xong là ghi thẳng vào state thật nên danh sách cập nhật ngay lập tức,
    // không đúng ý muốn "chỉ cập nhật khi bấm Áp dụng".
    final draftCategory = Rx<Category?>(categoryController.selectedCategory.value);

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
                  'Bộ lọc',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    controller.clearPriceFilter();
                    categoryController.selectedCategory.value = null;
                    Get.back();
                  },
                  child: const Text(
                    'Xóa lọc',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Danh mục: chip tick ngay khi chạm (Rx), showCheckmark:
            // false để chip không đổi kích thước lúc chọn (mặc định
            // ChoiceChip hiện dấu tick làm phình to, khiến cả hàng bị
            // "nhảy" layout) - đồng bộ trực tiếp với CategoryController
            // nên chọn ở đây hay ở Drawer bên trái đều khớp nhau.
            const Text(
              'Danh mục',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final categories = categoryController.categories;
              final selected = draftCategory.value;

              Widget buildChip({required String label, required bool isSelected, required VoidCallback onTap}) {
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (_) => onTap(),
                  showCheckmark: false,
                  selectedColor: Color(0xFFF24E1E),
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? Color(0xFFF24E1E) : Colors.grey.shade300,
                  ),
                );
              }

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  buildChip(
                    label: 'Tất cả',
                    isSelected: selected == null,
                    onTap: () => draftCategory.value = null,
                  ),
                  ...categories.map((c) => buildChip(
                        label: c.name,
                        isSelected: selected?.id == c.id,
                        onTap: () => draftCategory.value = c,
                      )),
                ],
              );
            }),

            const SizedBox(height: 16),
            const Text(
              'Giá mục tiêu',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
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
                onPressed: () {
                  // Chỉ tới đây (bấm Áp dụng) danh mục nháp mới được ghi vào
                  // state thật -> HomeController mới lọc lại danh sách.
                  categoryController.selectedCategory.value = draftCategory.value;
                  controller.applyPriceFilter(); // hàm này đã tự Get.back()
                },
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

/// Ô tìm kiếm dùng SearchAnchor.bar (Material 3) - bấm vào mở rộng thành
/// overlay. Khi ô đang rỗng, overlay hiện LỊCH SỬ TÌM KIẾM GẦN ĐÂY; khi đã
/// gõ từ khóa, overlay đổi sang gợi ý TÊN SẢN PHẨM khớp từ khóa đó.
class _ProductSearchBar extends StatelessWidget {
  final HomeController controller;

  const _ProductSearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      searchController: controller.searchController,
      barHintText: 'Tìm kiếm theo tên...',
      barLeading: const Icon(Icons.search),
      viewHintText: 'Tìm kiếm theo tên...',
      // SearchAnchor có bug đã biết: gọi closeView() để điền gợi ý không tự
      // kích hoạt lại logic lọc, nên onSearchChanged/commitSearch còn được
      // gọi thủ công ngay trong onTap của từng gợi ý, không chỉ trông vào
      // onChanged.
      onChanged: controller.onSearchChanged,
      onSubmitted: (value) {
        controller.searchController.closeView(value);
        controller.onSearchChanged(value);
        controller.commitSearch(value);
      },
      suggestionsBuilder: (context, searchController) {
        final query = searchController.text.trim().toLowerCase();

        // Ô đang rỗng (vừa bấm vào, chưa gõ gì) -> hiện lịch sử tìm kiếm gần
        // đây thay vì gợi ý sản phẩm.
        if (query.isEmpty) {
          return [
            // Bọc trong Obx để khi bấm "x" xóa 1 mục, chính widget này tự
            // rebuild lại - không phụ thuộc việc SearchAnchor có gọi lại
            // suggestionsBuilder hay không (né bug ở trên).
            Obx(() {
              if (controller.recentSearches.isEmpty) {
                return const ListTile(
                  leading: Icon(Icons.history),
                  title: Text('Chưa có tìm kiếm gần đây'),
                );
              }

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: controller.recentSearches.map((term) {
                  return ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(term),
                    trailing: IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      tooltip: 'Xóa khỏi lịch sử',
                      onPressed: () => controller.removeRecentSearch(term),
                    ),
                    onTap: () {
                      searchController.closeView(term);
                      controller.onSearchChanged(term);
                      controller.commitSearch(term);
                    },
                  );
                }).toList(),
              );
            }),
          ];
        }

        // Đã có từ khóa -> hiện gợi ý tên sản phẩm khớp.
        final matches = controller.allProducts
            .where((p) => p.name.toLowerCase().contains(query))
            .take(6)
            .toList();

        if (matches.isEmpty) {
          return const [
            ListTile(
              leading: Icon(Icons.search_off),
              title: Text('Không có sản phẩm phù hợp'),
            ),
          ];
        }

        return matches.map((Product p) {
          return ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: Text(p.name),
            subtitle: Text('${p.price.toStringAsFixed(0)}đ'),
            onTap: () {
              searchController.closeView(p.name);
              controller.onSearchChanged(p.name);
              controller.commitSearch(p.name);
            },
          );
        }).toList();
      },
    );
  }
}

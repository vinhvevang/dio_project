import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/widgets/app_formatter.dart';
import 'package:dio_complete/features/cart/presentation/controllers/cart_controller.dart';

class CartPage extends GetView<CartController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ hàng'),
        backgroundColor: Color(0xFFF24E1E),
        foregroundColor: Colors.white,
        actions: [
          Obx(() => controller.items.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: 'Xóa tất cả',
                  onPressed: controller.clearCart,
                )
              : const SizedBox.shrink()),
        ],
      ),
      body: Obx(() {
        if (controller.items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 80, color: Colors.grey.shade300),
                const SizedBox(height: 12),
                const Text('Giỏ hàng trống',
                    style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 8),
                const Text('Thêm sản phẩm từ trang chủ',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Danh sách sản phẩm trong giỏ ──────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 8),
                itemCount: controller.items.length,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  final p = item.product;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 5),
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        children: [
                          // Ảnh nhỏ
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: p.image.isNotEmpty
                                ? Image.network(
                                    p.image,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        _placeholder(),
                                  )
                                : _placeholder(),
                          ),
                          const SizedBox(width: 10),

                          // Thông tin
                          Expanded(
                            child: InkWell(
                              onTap: () => controller.goToDetail(item),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(p.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(AppFormatter.currency(p.price),
                                      style: const TextStyle(
                                          color: Colors.blue, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _quantityButton(
                                        icon: Icons.remove,
                                        onTap: () => controller.requestDecreaseQuantity(p.id),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                      _quantityButton(
                                        icon: Icons.add,
                                        onTap: () => controller.increaseQuantity(p.id),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Tổng giá item + nút xóa
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                AppFormatter.currency(p.price * item.quantity),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue),
                              ),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () =>
                                    controller.removeItem(p.id),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Icon(Icons.delete_outline,
                                      color: Colors.red, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // ── Thanh tổng tiền ───────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 8,
                      offset: const Offset(0, -2))
                ],
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Text('${controller.totalQuantity} sản phẩm',
                          style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        'Tổng: ${AppFormatter.currency(controller.totalPrice)}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _placeholder() => Container(
        width: 60,
        height: 60,
        color: Colors.grey.shade200,
        child: const Icon(Icons.image, color: Colors.grey),
      );

  Widget _quantityButton({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.blue.shade50,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 16, color: Colors.blue),
        ),
      ),
    );
  }
}

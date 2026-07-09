import 'package:dio_complete/features/product/data/models/product_model.dart';
import 'package:dio_complete/features/cart/domain/entities/cart_item.dart';

abstract class CartRepository {
  List<CartItem> loadItems();
  Future<void> addItem(Product product, {int quantity = 1});
  Future<void> increaseQuantity(int productId);
  Future<void> decreaseQuantity(int productId);
  Future<void> removeItem(int productId);
  Future<void> clearAll();

  /// Cập nhật lại thông tin sản phẩm (tên/giá/...) cho item ĐÃ CÓ trong giỏ,
  /// giữ nguyên số lượng - dùng khi sản phẩm được sửa ở nơi khác để giỏ hàng
  /// không hiển thị dữ liệu cũ.
  Future<void> updateProduct(Product updated);

  int get count;
}
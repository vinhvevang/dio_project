import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Hộp thoại xác nhận dùng chung (đăng xuất, xóa sản phẩm, xóa giỏ hàng, xóa
/// danh mục...). Trả về true nếu người dùng bấm nút xác nhận, false nếu hủy
/// hoặc đóng dialog bằng cách khác.
Future<bool> showConfirmDialog({
  required String title,
  required String message,
  String confirmLabel = 'Xác nhận',
  String cancelLabel = 'Hủy',
  bool isDestructive = true,
}) async {
  final confirmed = await Get.dialog<bool>(
    AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? Colors.red : Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}

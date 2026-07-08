import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showAppMessageDialog({
  required String title,
  required String message,
  bool isSuccess = false,
}) async {
  await Get.dialog(
    AlertDialog(
      title: Row(
        children: [
          Icon(
            isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: isSuccess ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title)),
        ],
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () => Get.back(),
          style: ElevatedButton.styleFrom(
            backgroundColor: isSuccess ? Colors.green : Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
}
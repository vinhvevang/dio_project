import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/storage/token_storage.dart';
import 'package:dio_complete/data/services/auth_service.dart';
import 'package:dio_complete/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthService _authService = AuthService();

  final usernameController = TextEditingController(text: 'cuongpc10');
  final passwordController = TextEditingController(text: '123456');

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Lỗi',
        'Vui lòng nhập đầy đủ thông tin',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return;
    }

    isLoading.value = true;

    try {
      final token = await _authService.login(
        username: username,
        password: password,
      );

      await TokenStorage.saveToken(token);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Đăng nhập thất bại',
        e.toString().replaceAll('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
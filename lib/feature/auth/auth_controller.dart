import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/token_storage.dart';
import 'auth_service.dart';
import '../home/empty_page.dart';

class AuthController extends GetxController {
  AuthController(this._authService);

  final AuthService _authService;

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Lỗi', 'Nhập username và password');
      return;
    }

    isLoading.value = true;
    try {
      final token = await _authService.login(
        username: username,
        password: password,
      );

      TokenStorage.saveToken(token);
      Get.offAll(() => const EmptyPage());
    } catch (e) {
      Get.snackbar('Login failed', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/core/storage/token_storage.dart';
import 'package:dio_complete/features/login/domain/usecases/auth_usecase.dart';
import 'package:dio_complete/routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthUseCase _authUseCase = Get.find<AuthUseCase>();
  final formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final usernameFocusNode = FocusNode();
  final passwordFocusNode = FocusNode();

  final isLoading = false.obs;
  final obscurePassword = true.obs;
  final authError = ''.obs;
  final hasSubmittedOnce = false.obs;

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    usernameFocusNode.dispose();
    passwordFocusNode.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void clearAuthError() {
    if (authError.value.isNotEmpty) {
      authError.value = '';
    }
  }

  Future<void> login() async {
    authError.value = '';
    hasSubmittedOnce.value = true;
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    isLoading.value = true;

    try {
      final token = await _authUseCase.login(
        username: username,
        password: password,
      );

      await TokenStorage.saveToken(token);
      await TokenStorage.saveCredentials(username: username, password: password);
      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      authError.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
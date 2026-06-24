import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'feature/auth/auth_controller.dart';
import 'feature/auth/auth_service.dart';
import 'feature/auth/login_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(AuthService());
  Get.put(AuthController(Get.find<AuthService>()));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
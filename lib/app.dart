import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio_complete/routes/app_pages.dart';
import 'package:dio_complete/routes/app_routes.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SDS Mobile',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      initialRoute: AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
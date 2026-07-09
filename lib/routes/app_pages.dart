import 'package:get/get.dart';
import 'package:dio_complete/features/login/presentation/bindings/login_binding.dart';
import 'package:dio_complete/features/login/presentation/pages/login_page.dart';
import 'package:dio_complete/features/product/presentation/bindings/home_binding.dart';
import 'package:dio_complete/features/product/presentation/pages/home_page.dart';
import 'package:dio_complete/features/product/presentation/bindings/product_detail_binding.dart';
import 'package:dio_complete/features/product/presentation/pages/product_detail_page.dart';
import 'package:dio_complete/features/product/presentation/bindings/product_form_binding.dart';
import 'package:dio_complete/features/product/presentation/pages/product_form_page.dart';
import 'package:dio_complete/features/cart/presentation/bindings/cart_binding.dart';
import 'package:dio_complete/features/cart/presentation/pages/cart_page.dart';
import 'package:dio_complete/routes/app_routes.dart';

abstract class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.productDetail,
      page: () => const ProductDetailPage(),
      binding: ProductDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.productForm,
      page: () => const ProductFormPage(),
      binding: ProductFormBinding(),
    ),
    GetPage(
      name: AppRoutes.cart,
      page: () => const CartPage(),
      binding: CartBinding(),
    ),
  ];
}
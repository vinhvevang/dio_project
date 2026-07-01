import 'package:get/get.dart';
import 'package:dio_complete/presentation/home/home_controller.dart';
import 'package:dio_complete/presentation/cart/cart_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    // CartController đặt ở đây để badge giỏ hàng hoạt động đúng
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}

import 'package:get/get.dart';
import 'package:dio_complete/presentation/home/home_controller.dart';
import 'package:dio_complete/presentation/cart/cart_controller.dart';
import 'package:dio_complete/presentation/category/category_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // CategoryController đặt trước HomeController vì HomeController cần đọc
    // danh mục đang chọn ngay từ onInit (để nghe selectedCategory.listen).
    Get.lazyPut<CategoryController>(() => CategoryController(), fenix: true);
    Get.lazyPut<HomeController>(() => HomeController());
    // CartController đặt ở đây để badge giỏ hàng hoạt động đúng
    Get.lazyPut<CartController>(() => CartController(), fenix: true);
  }
}

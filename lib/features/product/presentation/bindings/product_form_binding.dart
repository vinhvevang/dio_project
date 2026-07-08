import 'package:get/get.dart';
import 'package:dio_complete/features/product/presentation/controllers/product_form_controller.dart';

class ProductFormBinding extends Bindings {
  @override
  void dependencies() {
    // fenix: true để controller tạo lại mỗi lần mở form
    Get.lazyPut<ProductFormController>(() => ProductFormController(),
        fenix: true);
  }
}

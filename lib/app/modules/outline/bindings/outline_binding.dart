import 'package:get/get.dart';
import '../controllers/outline_controller.dart';

class OutlineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OutlineController>(
      () => OutlineController(),
      fenix: true,
    );
  }
}

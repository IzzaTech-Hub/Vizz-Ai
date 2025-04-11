import 'package:get/get.dart';

import '../controllers/ai_responce_controller.dart';

class AiResponceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AiResponceController>(
      () => AiResponceController(),
    );
  }
}

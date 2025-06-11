import 'package:get/get.dart';
import 'package:napkin/app/services/ai_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AiService());
  }
}

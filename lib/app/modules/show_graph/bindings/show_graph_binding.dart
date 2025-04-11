import 'package:get/get.dart';

import '../controllers/show_graph_controller.dart';

class ShowGraphBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShowGraphController>(
      () => ShowGraphController(),
    );
  }
}

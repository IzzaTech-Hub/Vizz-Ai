import 'package:get/get.dart';
import 'package:napkin/app/data/models/presentation_settings.dart';

class PresentationSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresentationSettingsController>(
      () => PresentationSettingsController(),
      fenix: true,
    );
  }
}

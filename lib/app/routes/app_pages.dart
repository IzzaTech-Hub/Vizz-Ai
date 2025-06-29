import 'package:get/get.dart';
import 'package:napkin/app/modules/splash/binding/splash_screen_binding.dart';
import 'package:napkin/app/modules/splash/view/splash_screen_view.dart';
import 'package:napkin/app/modules/presentation_setup/bindings/presentation_setup_binding.dart';
import 'package:napkin/app/modules/presentation_setup/views/presentation_setup_view.dart';

import '../modules/ai_responce/bindings/ai_responce_binding.dart';
import '../modules/ai_responce/views/ai_responce_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/show_graph/bindings/show_graph_binding.dart';
import '../modules/show_graph/views/show_graph_view.dart';
import '../modules/outline/bindings/outline_binding.dart';
import '../modules/outline/views/outline_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASHVIEW;

  static final routes = [
    GetPage(
      name: _Paths.SPLASHVIEW,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.PRESENTATION_SETUP,
      page: () => PresentationSetupView(),
      binding: PresentationSetupBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.OUTLINE,
      page: () => OutlineView(),
      binding: OutlineBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 250),
    ),
    GetPage(
      name: _Paths.AI_RESPONCE,
      page: () => AiResponceView(),
      binding: AiResponceBinding(),
    ),
    GetPage(
      name: _Paths.SHOW_GRAPH,
      page: () => const ShowGraphView(),
      binding: ShowGraphBinding(),
    ),
  ];
}

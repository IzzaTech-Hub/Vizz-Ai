import 'package:get/get.dart';

import '../modules/ai_responce/bindings/ai_responce_binding.dart';
import '../modules/ai_responce/views/ai_responce_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/show_graph/bindings/show_graph_binding.dart';
import '../modules/show_graph/views/show_graph_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.AI_RESPONCE,
      page: () => const AiResponceView(),
      binding: AiResponceBinding(),
    ),
    GetPage(
      name: _Paths.SHOW_GRAPH,
      page: () => const ShowGraphView(),
      binding: ShowGraphBinding(),
    ),
  ];
}

import 'dart:convert';

import 'package:get/get.dart';
import 'package:napkin/app/data/model_classes/comparison.dart';
import 'package:napkin/app/data/model_classes/graph_class.dart';
import 'package:napkin/app/data/model_classes/hierarchy.dart';
import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/model_classes/sbs.dart';

class ShowGraphController extends GetxController {
  //TODO: Implement ShowGraphController
  HierarchyModel? hierarchy;
  KeyPoints? keyPoints;
  GraphModel? graph;
  ComparisonModel? comparison;
  StepByStepModel? sbs;
  String? heading;
  String type = '';
  String? jsonString;

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    var args = Get.arguments;
    type = args[0];
    jsonString = args[1].toString();
    print('type is = $type');
    Map<String, dynamic> jsonData = args[1];
    // print(jsonstring);
    // final Map<String, dynamic> jsonData = jsonDecode(jsonstring);
    // try {
    //   final Map<String, dynamic> jsonData = json.decode(args[1]);
    // } catch (e) {
    //   print(e);
    //   Get.back();
    // }
    // keyPoints = KeyPoints.fromJson(jsonData);
    switch (type) {
      case 'hierarchy':
        print('parsing by heirarchy');
        hierarchy = HierarchyModel.fromJson(jsonData);
        heading = hierarchy!.heading;
        // Do something with the model
        break;

      case 'key_points':
        print('parsing by kp');
        keyPoints = KeyPoints.fromJson(jsonData);
        heading = keyPoints!.heading;
        // Do something with the model
        break;

      case 'graph':
        print('parsing by graph');
        graph = GraphModel.fromJson(jsonData);
        heading = graph!.heading;
        // Do something with the model
        break;

      case 'comparison':
      case 'comparison/differentiate':
        print('parsing by diff');
        comparison = ComparisonModel.fromJson(jsonData);
        heading = comparison!.heading;
        // Do something with the model
        break;

      case 'step_by_step':
        sbs = StepByStepModel.fromJson(jsonData);
        print('parsing by sbs');
        // Do something with the model
        heading = sbs!.heading;
        break;

      default:
        // Handle unknown or unsupported type
        print('Unsupported type: $type');
        break;
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;
}

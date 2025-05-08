import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pptx/flutter_pptx.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/model_classes/comparison.dart';
import 'package:napkin/app/data/model_classes/graph_class.dart';
import 'package:napkin/app/data/model_classes/hierarchy.dart';
import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/model_classes/sbs.dart';
import 'package:napkin/app/data/model_classes/slideData.dart';
import 'package:napkin/app/data/model_classes/slidePart.dart';
import 'package:napkin/app/widgets/touch_guide_animation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

class AiResponceController extends GetxController {
  //TODO: Implement AiResponceController
  // Map<String,dynamic>? allcontentString;
  // List<String>? contentList;
  // List<String> slideContentList = <String>[];
  String mainTitle = "";
  Rx<SlideData> slideData =
      SlideData(mainTitle: '', slidePart: <Rx<SlidePart>>[].obs).obs;
  List<Widget> slides = [];
  var isAllowBackButton = true.obs;

  List<String> typesList = [];
  final count = 0.obs;
  @override
  void onInit() async {
    super.onInit();
    // allcontentString = Get.arguments[0];
    slideData.value =
        SlideData.fromMap(Get.arguments[0] as Map<String, dynamic>);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showGuideDialog();
    // });
    // showGuideDialog();
    // parseParagraphs(allcontentString!);
  }

  void showGuideDialog() {
    Get.dialog(Dialog(
      backgroundColor: Colors.black54,
      surfaceTintColor: Colors.black54,
      child: TouchToSplitBox(),
    ));
  }

  Future<String> generatePPTX(BuildContext context, {String? mainTitle}) async {
    try {
      final pres = FlutterPowerPoint();

      for (Widget slide in slides) {
        await pres.addWidgetSlide((size) => slide,
            pixelRatio: 6.0, context: context);
      }

      final bytes = await pres.save();
      if (bytes == null || bytes.isEmpty) {
        throw Exception("Failed to generate PowerPoint content.");
      }

      Directory appDocDir = await getApplicationDocumentsDirectory();

      /// Sanitize the title to prevent double dots and invalid characters.
      String safeTitle = (slideData.value.mainTitle?.trim().isNotEmpty ?? false)
          ? slideData.value.mainTitle!
              .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
              .replaceAll(RegExp(r'\.+'), '.')
          : 'presentation';

      /// Ensure the filename ends with `.pptx`
      if (!safeTitle.endsWith('.pptx')) {
        safeTitle = '$safeTitle.pptx';
      }

      String filePath = '${appDocDir.path}/$safeTitle';
      final file = File(filePath);

      await file.writeAsBytes(bytes, flush: true);

      print('PPT generated at: $filePath');
      Get.snackbar("File Saved", "Slide has been saved as $safeTitle");

      return filePath;
    } catch (e) {
      print('Error generating PPTX: $e');
      Get.snackbar("Error", "Failed to save the PowerPoint file.");
      return '';
    }
  }

  Future<bool> isBackAllowed() async {
    return isAllowBackButton.value;
  }

  void shareFile(String filePath) async {
    final params = ShareParams(
      text: 'Great picture',
      files: [XFile(filePath)],
    );

    final result = await SharePlus.instance.share(params);

    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
    }
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Loading...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  void setGraph(int index, Map<String, dynamic> jsonData, String type) {
    HierarchyModel? hierarchy;
    KeyPoints? keyPoints;
    GraphModel? graph;
    ComparisonModel? comparison;
    StepByStepModel? sbs;
    String? heading;
    switch (type) {
      case 'hierarchy':
        print('parsing by heirarchy');
        hierarchy = HierarchyModel.fromJson(jsonData);
        heading = hierarchy!.heading;
        slideData.value.slidePart[index].value.hierarchy = hierarchy;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        // Do something with the model
        break;

      case 'key_points':
        print('parsing by kp');
        keyPoints = KeyPoints.fromJson(jsonData);
        heading = keyPoints!.heading;
        slideData.value.slidePart[index].value.keyPoints = keyPoints;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        // Do something with the model
        break;

      case 'graph':
        print('parsing by graph');
        graph = GraphModel.fromJson(jsonData);
        heading = graph!.heading;
        slideData.value.slidePart[index].value.graph = graph;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        // Do something with the model
        break;

      case 'comparison':
      case 'comparison/differentiate':
        print('parsing by diff');
        comparison = ComparisonModel.fromJson(jsonData);
        heading = comparison!.heading;
        slideData.value.slidePart[index].value.comparison = comparison;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        // Do something with the model
        break;

      case 'step_by_step':
        sbs = StepByStepModel.fromJson(jsonData);
        print('parsing by sbs');
        // Do something with the model
        heading = sbs!.heading;
        slideData.value.slidePart[index].value.sbs = sbs;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        break;

      default:
        // Handle unknown or unsupported type
        print('Unsupported type: $type');
        break;
    }
    print(
        "is show graph : ${slideData.value.slidePart[index].value.isShowGraph.value}");
  }

  void parseParagraphs(String jsonString) {
    try {
      // Decode JSON string
      // Map<String, dynamic> decodedJson = jsonDecode(jsonString);
      slideData.value = SlideData.fromMap(jsonDecode(jsonString));
      print("slideData: ${slideData.value.toMap()}");

      // Clear previous data
      // slideContentList.clear();
      // typesList.clear();

      // // Extract paragraphs if they exist and are a list
      // if (decodedJson.containsKey("slidePart") &&
      //     decodedJson["slidePart"] is List) {
      //   mainTitle = decodedJson["mainTitle"] ??
      //       ""; // Default to empty string if missing
      //   print("mainTitle: $mainTitle");
      //   for (var item in decodedJson["slidePart"]) {
      //     // Extract and assign values
      //     String type = item["type"] ?? "none"; // Default to 'none' if missing

      //     String slideContent =
      //         item["slideContent"] ?? ""; // Default to empty string if missing

      //     // Add to respective lists
      //     typesList.add(type);
      //     slideContentList.add(slideContent);
      //   }
      // }
    } catch (e) {
      print("Error parsing JSON: $e");
      // Ensure lists reset on failure
      // slideContentList = [];
      // typesList = [];
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

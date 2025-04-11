import 'dart:convert';

import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';

class AiResponceController extends GetxController {
  //TODO: Implement AiResponceController
  String? allcontentString;
  // List<String>? contentList;
  List<String> paragraphsList = [];
List<String> typesList = [];
  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
    allcontentString = Get.arguments[0];
   parseParagraphs(allcontentString!);
  }

void parseParagraphs(String jsonString) {
  try {
    // Decode JSON string
    Map<String, dynamic> decodedJson = jsonDecode(jsonString);

    // Clear previous data
    paragraphsList.clear();
    typesList.clear();

    // Extract paragraphs if they exist and are a list
    if (decodedJson.containsKey("paragraphs") && decodedJson["paragraphs"] is List) {
      for (var item in decodedJson["paragraphs"]) {
        // Extract and assign values
        String type = item["type"] ?? "none"; // Default to 'none' if missing
        String paragraph = item["paragraph"] ?? ""; // Default to empty string if missing

        // Add to respective lists
        typesList.add(type);
        paragraphsList.add(paragraph);
      }
    }
  } catch (e) {
    print("Error parsing JSON: $e");
    // Ensure lists reset on failure
    paragraphsList = [];
    typesList = [];
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


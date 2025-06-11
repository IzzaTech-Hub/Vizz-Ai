import 'dart:convert';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/models/presentation_outline.dart';
import 'package:napkin/app/data/gemini_ai/slide_types.dart';
import 'package:napkin/app/data/gemini_ai/ai_prompts.dart';
import 'package:napkin/app/data/gemini_ai/ai_schema.dart';
import 'package:napkin/app/data/rc_variables.dart';
import 'package:napkin/app/routes/app_pages.dart';
import 'package:napkin/app/services/ads/adshandler.dart';
import 'package:napkin/app/services/ai_service.dart';
import 'package:napkin/app/data/gemini_prompts.dart';

class OutlineController extends GetxController {
  final AiService aiService = Get.find<AiService>();
  final isLoading = false.obs;
  final Rx<PresentationOutline?> outline = Rx<PresentationOutline?>(null);

  @override
  void onInit() {
    super.onInit();
    print('OutlineController onInit with arguments: ${Get.arguments}');
    if (Get.arguments != null) {
      if (Get.arguments is PresentationOutline) {
        outline.value = Get.arguments as PresentationOutline;
      } else if (Get.arguments is String) {
        _generateOutlineDelayed(Get.arguments as String);
      }
    }
  }

  // Using a delayed call to ensure the view is built before showing loading state
  void _generateOutlineDelayed(String topic) {
    Future.delayed(Duration(milliseconds: 100), () {
      generateOutline(topic);
    });
  }

  // This will be called when entering the outline view
  Future<void> generateOutline(String topic) async {
    print('Generating outline for topic: $topic');
    isLoading.value = true;

    try {
      final prompt = GeminiPrompts.generateTitlesPrompt(topic);
      final response = await aiService.generateContent(prompt);

      if (response != null) {
        final jsonResponse = json.decode(response);
        final generatedOutline = PresentationOutline.fromJson(jsonResponse);

        // Convert first slide to titleOnly and remove its key points
        if (generatedOutline.slides.isNotEmpty) {
          generatedOutline.slides[0].type = 'titleOnly';
          generatedOutline.slides[0].keyPoints = [];
        }

        outline.value = generatedOutline;
      }
    } catch (e) {
      print('Error generating outline: $e');
      Get.snackbar(
        'Error',
        'Failed to generate outline: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void proceedToSlideGeneration() {
    AdsHandler().getAd();
    if (outline.value == null) {
      Get.snackbar(
        'Error',
        'No outlines generated',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Navigate to the AI response view with the outline data
    Get.toNamed(Routes.AI_RESPONCE, arguments: outline.value);
  }
}

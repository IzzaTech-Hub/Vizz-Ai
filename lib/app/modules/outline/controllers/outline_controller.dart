import 'dart:convert';
import 'package:api_key_pool/api_key_pool.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/models/presentation_outline.dart';
import 'package:napkin/app/data/models/presentation_settings.dart';
import 'package:napkin/app/data/gemini_ai/slide_types.dart';
import 'package:napkin/app/data/gemini_ai/ai_prompts.dart';
import 'package:napkin/app/data/gemini_ai/ai_schema.dart';
import 'package:napkin/app/data/rc_variables.dart';
import 'package:napkin/app/routes/app_pages.dart';
import 'package:napkin/app/services/ads/adshandler.dart';
import 'package:napkin/app/data/gemini_prompts.dart';

class OutlineController extends GetxController {
  final isLoading = false.obs;
  final Rx<PresentationOutline?> outline = Rx<PresentationOutline?>(null);
  final isEditing = false.obs;
  final Rx<PresentationSettings?> settings = Rx<PresentationSettings?>(null);

  @override
  void onInit() {
    super.onInit();
    print('OutlineController onInit with arguments: ${Get.arguments}');
    if (Get.arguments != null) {
      if (Get.arguments is PresentationSettings) {
        settings.value = Get.arguments as PresentationSettings;
        generateOutline(settings.value!.topic);
      } else if (Get.arguments is String) {
        settings.value = PresentationSettings(
          topic: Get.arguments as String,
          purpose: 'Informative',
          style: 'Professional',
          includeImages: true,
          numberOfSlides: 7,
          detailLevel: DetailLevel.medium,
        );
        generateOutline(settings.value!.topic);
      }
    }
  }

  Future<void> generateOutline(String topic) async {
    print('DEBUG: Starting to generate outline for topic: $topic');
    isLoading.value = true;

    try {
      final prompt = _generatePromptWithSettings(topic);
      print('DEBUG: Prompt generated successfully');

      // Call the API directly instead of using the service
      try {
        print('DEBUG: Initializing GenerativeModel...');
        final model = GenerativeModel(
          model: RcVariables.geminiAiModel,
          apiKey: ApiKeyPool.getKey(),
          // apiKey: RcVariables.apikey,
          generationConfig: GenerationConfig(
            temperature: 0.2,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
            responseMimeType: 'application/json',
          ),
        );

        print('DEBUG: Sending content generation request...');
        final response = await model.generateContent([Content.text(prompt)]);
        print('DEBUG: Response received from API');

        if (response.text != null) {
          print('DEBUG: Response text length: ${response.text!.length}');

          // Clean the response text
          String cleanJson = response.text!.trim();
          cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');

          try {
            print('DEBUG: Attempting to parse JSON...');
            final jsonResponse = json.decode(cleanJson);
            print(
                'DEBUG: JSON parsed successfully with keys: ${jsonResponse.keys.join(", ")}');

            print('DEBUG: Creating PresentationOutline from JSON');
            final generatedOutline = PresentationOutline.fromJson(jsonResponse);
            print(
                'DEBUG: Outline generated with ${generatedOutline.slides.length} slides');

            // Convert first slide to titleOnly and remove its key points
            if (generatedOutline.slides.isNotEmpty) {
              generatedOutline.slides[0].type = 'titleOnly';
              generatedOutline.slides[0].keyPoints = [];
              print('DEBUG: Converted first slide to titleOnly');
            }

            print('DEBUG: Setting outline value...');
            outline.value = generatedOutline;
            print('DEBUG: Outline set successfully');
          } catch (parseError) {
            print('DEBUG: JSON parsing error: $parseError');
            print(
                'DEBUG: Raw JSON first 200 chars: ${cleanJson.substring(0, cleanJson.length > 200 ? 200 : cleanJson.length)}');
            Get.snackbar(
              'JSON Error',
              'Failed to parse the AI response. Using fallback outline.',
              snackPosition: SnackPosition.BOTTOM,
            );
            _generateFallbackOutline(topic);
          }
        } else {
          print('DEBUG: API returned null response text');
          Get.snackbar(
            'Service Error',
            'No response from AI service. Using fallback outline.',
            snackPosition: SnackPosition.BOTTOM,
          );
          _generateFallbackOutline(topic);
        }
      } catch (apiError) {
        print('DEBUG: API call error: $apiError');
        Get.snackbar(
          'API Error',
          'Error calling the AI service. Using fallback outline.',
          snackPosition: SnackPosition.BOTTOM,
        );
        _generateFallbackOutline(topic);
      }
    } catch (e) {
      print('DEBUG: Error generating outline: $e');
      Get.snackbar(
        'Error',
        'Failed to generate outline. Using fallback outline.',
        snackPosition: SnackPosition.BOTTOM,
      );
      _generateFallbackOutline(topic);
    } finally {
      print('DEBUG: Setting isLoading to false');
      isLoading.value = false;
    }
  }

  void _generateFallbackOutline(String topic) {
    print('DEBUG: Generating fallback outline for topic: $topic');

    final numSlides = settings.value?.numberOfSlides ?? 7;

    // Create a basic outline structure
    final slides = <SlideOutline>[];

    // Add introduction slide
    slides.add(SlideOutline(
      slideTitle: 'Introduction to $topic',
      type: 'titleOnly',
      keyPoints: [],
    ));

    // Add content slides
    final contentSlidesCount = numSlides - 2; // Minus intro and conclusion
    for (int i = 0; i < contentSlidesCount; i++) {
      slides.add(SlideOutline(
        slideTitle: 'Key Aspect ${i + 1} of $topic',
        type: 'titleOneParagraph',
        keyPoints: [
          'Important point about this aspect',
          'Relevant information to consider',
          'Practical application or example',
        ],
      ));
    }

    // Add conclusion slide
    slides.add(SlideOutline(
      slideTitle: 'Conclusion',
      type: 'titleOneParagraph',
      keyPoints: [
        'Summary of key points',
        'Final thoughts on $topic',
        'Next steps or recommendations',
      ],
    ));

    // Set the outline
    outline.value = PresentationOutline(
      title: 'Presentation on $topic',
      slides: slides,
    );

    print('DEBUG: Fallback outline generated with ${slides.length} slides');
  }

  String _generatePromptWithSettings(String topic) {
    if (settings.value == null) {
      print("DEBUG: Using default prompt because settings is null");
      return GeminiPrompts.generateTitlesPrompt(topic);
    }

    final s = settings.value!;
    print(
        "DEBUG: Using custom prompt with settings: ${s.detailLevel}, ${s.numberOfSlides}, ${s.purpose}, ${s.style}");

    // Ultra simplified prompt for gemini-2.0-flash-lite
    return '''
Create a presentation outline about "${topic}" with ${s.numberOfSlides} slides.
The presentation should be ${s.purpose} in style and ${s.style} in tone.

Format your response as JSON with this exact structure:
{
  "title": "Main Title",
  "slides": [
    {
      "slideTitle": "Slide Title",
      "type": "titleOneParagraph",
      "keyPoints": ["Point 1", "Point 2", "Point 3"]
    }
  ]
}
''';
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

    // Navigate to the AI response view with both outline and settings
    Get.toNamed(Routes.AI_RESPONCE, arguments: [outline.value, settings.value]);
  }

  // Toggle editing mode
  void toggleEditing() {
    isEditing.value = !isEditing.value;
  }

  void updateSlideTitle(int index, String newTitle) {
    if (outline.value == null) return;

    final slides = List<SlideOutline>.from(outline.value!.slides);
    slides[index] = slides[index].copyWith(slideTitle: newTitle);

    outline.value = PresentationOutline(
      title: outline.value!.title,
      slides: slides,
    );
  }

  void updateKeyPoint(int slideIndex, int pointIndex, String newPoint) {
    if (outline.value == null) return;

    final slides = List<SlideOutline>.from(outline.value!.slides);
    final keyPoints = List<String>.from(slides[slideIndex].keyPoints);
    keyPoints[pointIndex] = newPoint;

    slides[slideIndex] = slides[slideIndex].copyWith(keyPoints: keyPoints);

    outline.value = PresentationOutline(
      title: outline.value!.title,
      slides: slides,
    );
  }

  void addKeyPoint(int slideIndex, String newPoint) {
    if (outline.value == null) return;

    final slides = List<SlideOutline>.from(outline.value!.slides);
    final keyPoints = List<String>.from(slides[slideIndex].keyPoints)
      ..add(newPoint);

    slides[slideIndex] = slides[slideIndex].copyWith(keyPoints: keyPoints);

    outline.value = PresentationOutline(
      title: outline.value!.title,
      slides: slides,
    );
  }

  void removeKeyPoint(int slideIndex, int pointIndex) {
    if (outline.value == null) return;

    final slides = List<SlideOutline>.from(outline.value!.slides);
    final keyPoints = List<String>.from(slides[slideIndex].keyPoints)
      ..removeAt(pointIndex);

    slides[slideIndex] = slides[slideIndex].copyWith(keyPoints: keyPoints);

    outline.value = PresentationOutline(
      title: outline.value!.title,
      slides: slides,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/rc_variables.dart';

class HomeController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  //TODO: Implement HomeController
  final promptText = ''.obs;
  final isLoading = false.obs;
  final List<String> allPrompts = [
    "Futuristic city",
    "Coffee logo",
    "Weather flowchart",
    "Space station",
    "AI assistant UI",
    "Pet shop logo",
    "Travel poster",
    "Smart home app",
    "Fitness dashboard",
    "Eco-friendly house",
    "Vintage car sketch",
    "E-learning layout",
    "Music player UI",
    "Food delivery map",
    "Tech startup logo",
  ];

  final RxList<String> examplePrompts = <String>[].obs;

  void initPrompts() {
    allPrompts.shuffle();
    examplePrompts.value = allPrompts.take(3).toList();
  }

  void setPrompt(String text) {
    promptText.value = text;
    textEditingController.text = text;
  }

  void generateVisualization() async {
    isLoading.value = true;
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    isLoading.value = false;
    Get.snackbar('Success', 'Visualization generated!');
  }

  final count = 0.obs;
  @override
  void onInit() {
    initPrompts();
    super.onInit();
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

// Hide the loading dialog
  void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  Future<String> generateContent(String prompt) async {
    String sysinstructionprompt =
        // '''Generate a complete presentation on given topic, make a list of paragraphs. in paragraph also tell the best type of paragraph to explain from 'hierarchy','key_points','graph','comparison/differentiate','step_by_step' to tell me in which form i should visualize it.
        // - 'hierarchy' (tree structure)

        '''Generate a complete presentation on given topic, make a list of paragraphs. in paragraphs also tell the best type of paragraph to explain from 'key_points','graph','comparison/differentiate','step_by_step' to tell me in which form i should visualize it.
        - 'key_points' (bullet points/unordered list)
        - 'graph' (data in values/also in unordered list)
        - 'comparison/differentiate' (tables/relationship)
        - 'step_by_step' (ordered lists/process flow/algorithms).
    - Content should be wrapped in normal markdown syntax. Keep sentences concise and properly formatted.
    - Headings (H1-H3) should follow standard markdown syntax (# H1, ## H2, ### H3). Use them to structure the content logically.
    - Bold (**text**) and Italic (*text*) should be used where necessary to emphasize key points.
    - Links ([text](URL)) should be clearly structured, using simple URLs.
    - Lists should be formatted correctly:
    - Ordered lists (1. Item) should contain at least three points.
    - Unordered lists (- Item) should use dashes (-) and maintain uniform indentation.
    - Code Blocks should be enclosed with triple backticks (```) and specify the programming language (e.g., ```dart for Dart code). Keep indentation clean and consistent.
    - Blockquotes (> Text) should be used for important notes or callouts.
    - Tables should be formatted using | Column 1 | Column 2 | syntax, with proper alignment.
    - Make sure the output is structured, readable, and follows best markdown practices. Format everything cleanly, keeping it simple yet visually appealing."

    Make at least 10 paragraphs but a paragraph should only contain a particular topic with several types of markdown content.
    Maximum of 2 rows are allowed for a table. 
    Table should be used only when necessary without any following paragraph.
    make sure you use all the paragraph types in appropriate place like: 'hierarchy','key_points','graph','comparison/differentiate','step_by_step' .
    Each list must contain heading at top with content below it, not a single paragraph should be without a heading.
    The content below the heading should not exceed limit of 3 lines.

    ''';
    // Each paragraph should contain only on one type.

    final model = GenerativeModel(
      model: RcVariables.geminiAiModel,
      // model: 'gemini-2.0-flash-lite',
      // model: 'gemini-1.5-pro',
      // model: 'gemini-1.5-flash-8b',
      // model: 'gemini-1.5-flash',
      // apiKey: 'AIzaSyCj-pkjlMrppk-ZNsPlkFq5U9t9jeUahr8',
      apiKey: RcVariables.apikey,
      generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
          responseSchema: Schema(SchemaType.object, requiredProperties: [
            "slidePart",
            "mainTitle"
          ], properties: {
            "slidePart": Schema(
              SchemaType.array,
              items: Schema(SchemaType.object, requiredProperties: [
                "type",
                "slideContent",
              ], properties: {
                "type": Schema(SchemaType.string, enumValues: [
                  // 'hierarchy',
                  'key_points',
                  'graph',
                  'comparison/differentiate',
                  'step_by_step'
                ]),
                "slideContent": Schema(
                  SchemaType.string,
                ),
              }),
            ),
            "mainTitle": Schema(SchemaType.string),
          })),
      systemInstruction: Content.system(sysinstructionprompt),
    );

    final content = [
      // Content.multi([TextPart("Generate json")]),
      Content.text(
          // "Make The course content devided into 4 or more stages. each stage contains 2 to 5 chapter and each chapter covers 3 to 6 subtopics."
          prompt),
    ];

    try {
      final response = await model.generateContent(content);
      // print(response);
      // myresponce.value = response.text!;

      print('Respons: ${response.text}');
      return response.text!;
      // print('Respons: ${myresponce.value}');
    } catch (e) {
      print('failed');
      print(e.toString());
      // hasError.value = true;
      return '';
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

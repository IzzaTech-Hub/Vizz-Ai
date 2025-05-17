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

        '''Generate a complete presentation on the given topic. The presentation must consist of exactly 10 paragraphs, each focusing on a distinct subtopic with a specific visualization type from the following options:

- **'paragraph'** - A brief, well-structured text paragraph that introduces or elaborates on a concept.  
- **'key_points'** - Use bullet points/unordered lists to present concise key points.  
- **'graph'** - Include data values formatted as an unordered list. Data must be presented clearly for graphical representation.  
- **'comparison/differentiate'** - Use a table with a maximum of 4 rows to present comparisons or relationships.  
- **'step_by_step'** - Provide an ordered list that illustrates a process, algorithm, or sequence clearly.  

**Content Formatting Rules:**  

1. **Paragraph Structure:**  
   - Each paragraph must focus on only one visualization type.  
   - Each paragraph must not exceed **5 lines of content**, including headings, lists, and tables.  
   - Headings and their associated content must remain within the same paragraph.  
   - Lists, tables, and blockquotes must not be divided across multiple paragraphs.  
   - The content must adhere to the specified visualization type strictly without mixing types.  

2. **Markdown Syntax:**  
   - Use appropriate headings (`#`, `##`, `###`) for each paragraph.  
   - Apply bold (`**text**`) and italic (`*text*`) styles for emphasis where necessary.  
   - Hyperlinks must follow the format `[text](URL)` and must be used sparingly.  
   - Code blocks, if included, should be enclosed within triple backticks (```) and specify the language.  

3. **Content Clarity:**  
   - Keep sentences concise, informative, and grammatically correct.  
   - Ensure that content remains structured, readable, and visually appealing.  
   - Maintain logical flow and coherence across paragraphs, aligning with the overall topic.  

4. **Strict Adherence:**  
   - Do **not exceed 5 lines per paragraph**, including lists and tables.  
   - Ensure each paragraph adheres to its designated visualization type without mixing multiple types.  
   - Every paragraph must clearly specify its type (`paragraph`, `key_points`, `graph`, `comparison/differentiate`, `step_by_step`).  

Format all content clearly, adhering to the above instructions strictly.


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

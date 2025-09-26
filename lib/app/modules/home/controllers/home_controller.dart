import 'dart:convert';
import 'dart:math';

import 'package:api_key_pool/api_key_pool.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/model_classes/slideData.dart';
import 'package:napkin/app/data/models/presentation_outline.dart';
import 'package:napkin/app/data/gemini_prompts.dart';
import 'package:napkin/app/data/rc_variables.dart';
import 'package:napkin/app/routes/app_pages.dart';
import 'package:napkin/app/services/ads/admob_ads_prvider.dart';

class HomeController extends GetxController {
  final TextEditingController textEditingController = TextEditingController();
  //TODO: Implement HomeController
  final promptText = ''.obs;
  final isLoading = false.obs;

  List<String> premoptList1 = [];
  List<String> premoptList2 = [];
  List<String> premoptList3 = [];
  final List<String> fullList = [
    "Machine Learning",
    "Cardio Exercises",
    "Reptile Pets",
    "Cultural Dress",
    "Career Growth",
    "Digital Marketing",
    "Music Genres",
    "Augmented Reality",
    "Student Life",
    "Life Hacks",
    "Plant-Based Diet",
    "World History",
    "Animal Behavior",
    "Fan Pages",
    "Marketing Strategy",
    "Blockchain Basics",
    "Career Paths",
    "Brand Building",
    "Coding Games",
    "Virtual Pets",
    "Crafting Ideas",
    "Job Ethics",
    "Cooking Tips",
    "Freelancing Tips",
    "Graphic Design",
    "Language Skills",
    "Holiday Traditions",
    "Virtual Reality",
    "Workout Plans",
    "Solar Power",
    "Pet Grooming",
    "Minimal Living",
    "Investing 101",
    "Dance Styles",
    "Study Tips",
    "Electric Cars",
    "Pet Food",
    "Meal Prep",
    "Artificial Intelligence",
    "Mental Health",
    "Climate Change",
    "Dog Breeds",
    "Home Decor",
    "Startup Ideas",
    "Smart Watches",
    "Cyber Security",
    "Healthy Snacks",
    "Math Tricks",
    "Green Energy",
    "Fish Tanks",
    "Team Building",
    "Art Therapy",
    "Note Taking",
    "Rainwater Harvesting",
    "Zoo Facts",
    "Ecommerce Tips",
    "Memory Games",
    "Photography Tips",
    "Online Learning",
    "5G Technology",
    "Mobile Apps",
    "Yoga Benefits",
    "Heart Health",
    "Language Learning",
    "Goal Setting",
    "Aquatic Pets",
    "Calligraphy Art",
    "Global Warming",
    "Critical Thinking",
    "House Plants",
    "Recycling Ideas",
    "Job Interviews",
    "Weight Training",
    "Movie Making",
    "Homework Help",
    "Sleep Importance",
    "Web Development",
    "Interior Design",
    "Pet Training",
    "Time Management",
    "Cultural Festivals",
    "Open Source",
    "Wild Animals",
    "Street Art",
    "Remote Work",
    "Public Speaking",
    "Pet Safety",
    "Plant Trees",
    "Resume Tips",
    "Reading Habits",
    "Pet Health",
    "Skin Care",
    "Office Culture",
    "Book Genres",
    "Daily Routine",
    "Budget Travel",
    "Painting Styles",
    "DIY Crafts",
    "Zero Waste",
    "Science Facts",
    "Cloud Storage",
    "Weekend Plans",
    "Public Issues",
    "Math Games",
    "Poetry Forms",
    "Vegan Diet",
    "Smart Homes",
    "Dramatic Arts",
    "Stress Relief",
    "Wildlife Protection",
    "Dog Adoption",
    "Fashion Design",
    "Healthy Eating",
    "Sustainable Life",
    "Comic Books",
    "Education Apps",
    "Small Business",
    "Work Ethics",
    "Clean Oceans",
    "Fan Theories",
    "Pet Toys",
    "Smart Kitchen"
        "Scent Psychology",
    "Freedom Struggles",
    "Seasonal Foods",
    "Breaking News",
    "Educational Games",
    "Child Psychology",
    "City Gardening",
    "Quantum Computing",
    "Immune System",
    "Farm Animals",
    "Community Life",
    "Family Culture",
    "Online Forums",
    "Budget Trips",
    "Music History",
    "Tech Startups",
    "Goal Tracking",
    "Interior Trends",
    "Startup Planning",
    "Language Practice",
    "Pet Fashion",
    "Online Portfolios",
    "Resume Builder",
    "Confidence Boost",
    "Mobile Photography",
    "Healthy Mindset",
    "E-Waste Disposal",
    "Creative Projects",
    "Plant Health",
    "Historic Monuments",
    "Fitness Goals",
    "Pet Products",
    "Cultural Values",
    "Mental Strength",
    "Gadget Reviews",
    "Wildlife Cameras",
    "Civic Duties",
    "Digital Footprint",
    "Handmade Soap",
    "Local Travel",
    "Zoo Conservation",
    "Positive Habits",
    "Toy Trends",
    "Sustainable Fashion",
    "Public Safety",
    "Craft Tutorials",
    "Virtual Tours",
    "Pet Feeding",
    "Presentation Tips",
    "Baking Tips",
    "Learning Plans",
    "Digital Art",
    "Social Ethics",
    "Learning Languages",
    "Holiday Shopping",
    "Digital Journaling",
    "Chore Lists",
    "Smart Accessories",
    "Drawing Styles",
    "Earning Online",
    "Online Courses",
    "Remote Jobs",
    "Urban Farming",
    "Mindful Eating",
    "Education Systems",
    "Home Office",
    "Handmade Jewelry",
    "Energy Efficiency",
    "Inspiring Quotes",
    "Public Transport",
    "Positive Thinking",
    "Animal Habitats",
    "Podcast Tips",
    "Animation Basics",
    "Parenting Skills",
    "Smart Clothing",
    "Daily Affirmations",
    "Dance Moves",
    "Natural Living",
    "Safety Measures",
    "Local Businesses",
    "Eco Projects",
    "Food Budgeting",
    "Home Gadgets",
    "Quiet Living",
    "Micro Habits",
    "Recycling Rules",
    "Dream Journals",
    "Wild Parks",
    "Design Trends"
        "Sugar Effects",
    "Bird Watching",
    "Resume Tips",
    "Creative Writing",
    "Digital Payments",
    "Peace Talks",
    "Interior Plants",
    "Global News",
    "Virtual Classes",
    "DIY Projects",
    "Public Events",
    "Smart Furniture",
    "Office Hacks",
    "Body Posture",
    "Population Growth",
    "Comic Creation",
    "Food Storage",
    "Hobby Ideas",
    "E-learning Tools",
    "Pet Rescue",
    "Space Travel",
    "Ethnic Foods",
    "Pet Adoption",
    "Online Safety",
    "Coding Basics",
    "Scented Candles",
    "Budget Planning",
    "Pet Accessories",
    "Ocean Cleanup",
    "Green Lifestyle",
    "Study Apps",
    "Eco-Friendly Tips",
    "Bird Rescue",
    "Cultural Dance",
    "Remote Learning",
    "Urban Life",
    "Nature Photography",
    "Brain Exercises",
    "Local Cuisine",
    "Wild Adventures",
    "Budget Saving",
    "Voice Assistants",
    "Job Hunting",
    "Music Instruments",
    "Drama Class",
    "Robot Helpers",
    "Smart Lighting",
    "Family Values",
    "Trash Sorting",
    "Creative Crafts",
    "Travel Diaries",
    "Animal Rights",
    "Essay Writing",
    "Pet Sitting",
    "Zoo Habits",
    "School Projects",
    "Home Renovation",
    "Cooking Classes",
    "Resume Hacks",
    "Digital Life",
    "Traffic Problems",
    "Fitness Gadgets",
    "Learning Methods",
    "Speech Practice",
    "Ethical Hacking",
    "Freelance Work",
    "Toy Reviews",
    "Life Balance",
    "Waste Reduction",
    "Doodle Art",
    "3D Printing",
    "School Subjects",
    "Chore Charts",
    "Fun Science",
    "Pet Training",
    "Online Security",
    "Energy Saving",
    "Stress Control",
    "Time Blocking",
    "Book Reviews",
    "Financial Tips",
    "Clean Energy",
    "Budget Meals",
    "Handmade Gifts",
    "Recycling Crafts",
    "Fun Facts",
    "Smart Wearables",
    "Exercise Routines"
  ];
  Future<void> startGenerating(BuildContext context) async {
    final topic = textEditingController.text.trim();
    if (topic.isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a topic',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        Get.snackbar(
          'No Internet Connection',
          'Please check your internet and try again',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Navigate to presentation setup instead of outline
      Get.toNamed(Routes.PRESENTATION_SETUP, arguments: topic);
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<PresentationOutline?> generateOutline(String topic) async {
    final systemInstructions = '''
You are a professional presentation outline generator.
Your task is to create well-structured presentation outlines.
Always respond with valid JSON that follows the exact schema provided.
Each response must include a title and 5-7 slides with 3-4 key points each.
Do not include any explanatory text, only output the JSON structure.
''';

    final model = GenerativeModel(
      model: RcVariables.geminiAiModel,
      apiKey: ApiKeyPool.getKey(),
      // apiKey: RcVariables.apikey,
      generationConfig: GenerationConfig(
        temperature: 0.9,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
        responseMimeType: 'application/json',
        responseSchema: Schema(
          SchemaType.object,
          properties: {
            'title': Schema(SchemaType.string),
            'slides': Schema(
              SchemaType.array,
              items: Schema(
                SchemaType.object,
                properties: {
                  'slideTitle': Schema(SchemaType.string),
                  'keyPoints': Schema(
                    SchemaType.array,
                    items: Schema(SchemaType.string),
                  ),
                },
                requiredProperties: ['slideTitle', 'keyPoints'],
              ),
            ),
          },
          requiredProperties: ['title', 'slides'],
        ),
      ),
      systemInstruction: Content.system(systemInstructions),
    );

    try {
      final prompt = GeminiPrompts.generateTitlesPrompt(topic);
      final response = await model.generateContent([Content.text(prompt)]);
      print('Raw response: ${response.text}');

      if (response.text == null) {
        print('Null response from Gemini');
        return null;
      }

      try {
        // Clean the response text to ensure it's valid JSON
        String cleanJson = response.text!.trim();
        // Remove any potential markdown code block markers
        cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');

        print('Cleaned JSON: $cleanJson');

        final Map<String, dynamic> jsonResponse = jsonDecode(cleanJson);
        print('Parsed JSON: $jsonResponse');

        final outline = PresentationOutline.fromJson(jsonResponse);
        print('Successfully created outline object');
        return outline;
      } catch (parseError) {
        print('JSON parsing error: $parseError');
        return null;
      }
    } catch (e) {
      print('Error generating outline: $e');
      return null;
    }
  }

  final RxList<String> examplePrompts = <String>[].obs;

  void initPrompts() {
    final random = Random();

    final original = fullList; // Make a copy to avoid mutation

    List<String> getRandomItems() {
      final result = <String>[];
      for (int i = 0; i < 10 && original.isNotEmpty; i++) {
        final index = random.nextInt(original.length);
        result.add(original.removeAt(index));
      }
      return result;
    }

    final l1 = (getRandomItems());
    final l2 = (getRandomItems());
    final l3 = (getRandomItems());
    final l4 = (getRandomItems());
    final l5 = (getRandomItems());
    final l6 = (getRandomItems());
    final l7 = (getRandomItems());
    final l8 = (getRandomItems());
    final l9 = (getRandomItems());

    premoptList1 = l1 + l2 + l3;
    premoptList2 = l4 + l5 + l6;
    premoptList3 = l7 + l8 + l9;

    premoptList1.shuffle();
    premoptList2.shuffle();
    premoptList3.shuffle();
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
    AdMobAdsProvider.instance.initialize();
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
      apiKey: ApiKeyPool.getKey(),
      // apiKey: RcVariables.apikey,
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
    textEditingController.dispose();
    super.onClose();
  }

  void increment() => count.value++;
}

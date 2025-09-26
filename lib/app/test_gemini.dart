import 'package:api_key_pool/api_key_pool.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'data/rc_variables.dart';

Future<void> testGenerateOutline() async {
  try {
    print("=== GEMINI API TEST ===");
    print("Testing with a simple outline generation prompt...");

    // Use a very simple, direct prompt
    final prompt = '''
Create a presentation outline about "Flutter Development" with 5 slides.
Format your response as JSON with this structure:
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

    // print("Prompt: $prompt");
    // print(
    //     "Model: ${RcVariables.geminiAiModel}, API Key: ${RcVariables.apikey.substring(0, 5)}...");

    final response = await model.generateContent([Content.text(prompt)]);

    if (response.text == null) {
      print("Error: No response text received");
      return;
    }

    print("Response received: ${response.text!.substring(0, 100)}...");

    // Clean JSON
    final cleanJson =
        response.text!.trim().replaceAll('```json', '').replaceAll('```', '');

    try {
      final jsonData = json.decode(cleanJson);
      print("Successfully parsed JSON: ${jsonData.keys.join(', ')}");

      if (jsonData.containsKey('title') && jsonData.containsKey('slides')) {
        print("Found expected keys in response");
        print("Title: ${jsonData['title']}");
        print("Number of slides: ${(jsonData['slides'] as List).length}");
      } else {
        print("JSON missing expected keys");
      }
    } catch (e) {
      print("Failed to parse JSON: $e");
      print("Raw JSON: $cleanJson");
    }
  } catch (e) {
    print("Test failed with error: $e");
  }
}

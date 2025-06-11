import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/rc_variables.dart';

class AiService {
  Future<String?> generateContent(String prompt) async {
    try {
      final model = GenerativeModel(
        model: RcVariables.geminiAiModel,
        apiKey: RcVariables.apikey,
        generationConfig: GenerationConfig(
          temperature: 0.9,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
          responseMimeType: 'application/json',
        ),
      );

      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw 'No response received from AI';
      }

      // Clean and parse the JSON response
      String cleanJson = response.text!.trim();
      cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');

      return cleanJson;
    } catch (e) {
      print('Error in AI service: $e');
      return null;
    }
  }
}

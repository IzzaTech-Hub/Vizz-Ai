import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/rc_variables.dart';

class AiService {
  final int maxRetries = 2;
  final Duration timeout = Duration(seconds: 60);

  Future<String?> generateContent(String prompt) async {
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        print('AI Service: Attempt ${retryCount + 1}/${maxRetries + 1}');

        final model = GenerativeModel(
          model: RcVariables.geminiAiModel,
          apiKey: RcVariables.apikey,
          generationConfig: GenerationConfig(
            temperature:
                0.7, // Lowered temperature for more predictable outputs
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 2048,
            responseMimeType: 'application/json',
          ),
          safetySettings: [
            SafetySetting(
                HarmCategory.dangerousContent, HarmBlockThreshold.none),
            SafetySetting(HarmCategory.harassment, HarmBlockThreshold.none),
          ],
        );

        print(
            'AI Service: Model initialized (${RcVariables.geminiAiModel}), sending request');

        try {
          final response = await model
              .generateContent([Content.text(prompt)]).timeout(timeout);
          print('AI Service: Response received');

          if (response.text == null) {
            print('AI Service: Empty response received');
            throw 'No response received from AI';
          }

          // Clean and parse the JSON response
          String cleanJson = response.text!.trim();
          cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');

          print('AI Service: Response processed successfully');
          return cleanJson;
        } catch (apiError) {
          print('AI Service: API error: $apiError');
          throw apiError;
        }
      } catch (e) {
        retryCount++;
        print('AI Service Error (attempt $retryCount/$maxRetries): $e');

        if (e is TimeoutException) {
          print('AI Service: Request timed out');
        }

        if (retryCount <= maxRetries) {
          print('AI Service: Retrying in 2 seconds...');
          await Future.delayed(Duration(seconds: 2));
        } else {
          print('AI Service: Max retries reached, giving up');
          return null;
        }
      }
    }

    return null;
  }
}

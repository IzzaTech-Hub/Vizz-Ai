import 'dart:convert';
import 'dart:typed_data';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

class GeminiImageService {
  static String? _apiKey;
  void initilize(String apikey) {
    _apiKey = apikey;
  }

  Future<GeminiImageResponse> generateGeminiImage({
    required String prompt,
    List<Uint8List>? images,
  }) async {
    String? message;
    Uint8List? imagebytes;
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-preview-image-generation:generateContent?key=$_apiKey',
    );

    final headers = {'Content-Type': 'application/json'};

    // Build the parts array
    final parts = <Map<String, dynamic>>[];
    parts.add({"text": prompt});

    if (images != null && images.isNotEmpty) {
      for (final image in images) {
        parts.add({
          "inlineData": {
            "mimeType": "image/jpeg", // adjust based on actual format
            "data": base64Encode(image),
          }
        });
      }
    }

    final body = jsonEncode({
      "contents": [
        {"parts": parts}
      ],
      "generationConfig": {
        "responseModalities": ["TEXT", "IMAGE"]
      }
    });

    try {
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity[0] == ConnectivityResult.none) {
        throw ('no internet connection');
      }

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode != 200) {
        throw ('no response found, status code = ${response.statusCode}');
      }
      final decoded = json.decode(response.body);
      if (decoded['candidates'][0]['finishReason'] == 'IMAGE_SAFETY' ||
          (decoded['candidates'][0]['safetyRatings'] != null &&
              decoded['candidates'][0]['safetyRatings'][0]['blocked'] ==
                  true)) {
        throw ('Image generation blocked due to safety filters.');
      }
      if (((decoded['candidates'][0]['content']['parts']).length) < 2) {
        if (decoded['candidates'][0]['content']['parts'][0]['inlineData'] ==
            null) {
          throw ('Bad input request, Image generation blocked due to safety filters.');
        } else {
          final base64Image = decoded['candidates'][0]['content']['parts'][0]
              ['inlineData']['data'];
          imagebytes = base64Decode(base64Image);
          message = 'result image generated';
        }
      } else {
        final base64Image = decoded['candidates'][0]['content']['parts'][1]
            ['inlineData']['data'];
        imagebytes = base64Decode(base64Image);
        message = decoded['candidates'][0]['content']['parts'][0]['text'];
      }

      return GeminiImageResponse(
          success: true, imageBytes: imagebytes, message: message);
    } catch (e) {
      return GeminiImageResponse(
        success: false,
        error: "$e",
      );
    }
  }
}

class GeminiImageResponse {
  final bool success;
  final String? message;
  final String? error;
  final Uint8List? imageBytes;

  GeminiImageResponse({
    required this.success,
    this.message,
    this.error,
    this.imageBytes,
  });
}

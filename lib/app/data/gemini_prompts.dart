class GeminiPrompts {
  static String generateTitlesPrompt(String topic) {
    return '''
Create a presentation outline for: "$topic"

IMPORTANT: Respond ONLY with a JSON object. Do not include any other text, markdown, or explanations.
The JSON must exactly follow this structure:

{
  "title": "Clear and engaging main title",
  "slides": [
    {
      "slideTitle": "Specific and descriptive slide title",
      "type": "One of: titleOneParagraph, titleTwoParagraphs, titleParaImage, titleTwoParaOneImage",
      "keyPoints": [
        "Clear and actionable key point 1",
        "Clear and actionable key point 2",
        "Clear and actionable key point 3"
      ]
    }
  ]
}

Requirements:
1. Generate 7-10 slides
2. Each slide must have exactly 3-4 key points
3. First slide must be an introduction
4. Last slide must be a conclusion/summary
5. Key points must be clear and specific
6. No placeholder text
7. No explanatory comments
8. Pure JSON only
9. Each slide must have one of these types:
   - titleOneParagraph: Title with one paragraph
   - titleTwoParagraphs: Title with two paragraphs
   - titleParaImage: Title with paragraph and image
   - titleTwoParaOneImage: Title with two paragraphs and one image
''';
  }

  static Map<String, dynamic> outlineResponseSchema = {
    "type": "object",
    "required": ["title", "slides"],
    "properties": {
      "title": {"type": "string"},
      "slides": {
        "type": "array",
        "items": {
          "type": "object",
          "required": ["slideTitle", "keyPoints", "type"],
          "properties": {
            "slideTitle": {"type": "string"},
            "type": {"type": "string"},
            "keyPoints": {
              "type": "array",
              "items": {"type": "string"}
            }
          }
        }
      }
    }
  };

  static String generateSlideContentPrompt(
      String slideTitle, List<String> keyPoints) {
    return '''
Create a detailed slide content for a presentation slide with:
Title: "$slideTitle"
Key Points: ${keyPoints.join(", ")}

Return ONLY a JSON object in this exact format:
{
  "slideTitle": "Slide title",
  "content": {
    "mainPoints": ["Detailed point 1", "Detailed point 2"],
    "subPoints": ["Sub point 1", "Sub point 2"],
    "visualSuggestion": "Suggestion for visual element or diagram"
  }
}
''';
  }

  static const String systemInstructions = '''
You are a professional presentation outline generator.
Your task is to create well-structured, engaging presentation outlines.
Always respond with valid JSON that follows the exact schema provided.
Each response must include:
1. A clear, concise title
2. 5-7 slides that flow logically
3. Each slide must have 2-3 key points only
4. First slide MUST be titleOnly type (introduction)
5. Last slide MUST be titleOneParagraph type (conclusion)
6. Middle slides should use a mix of other types
7. Keep all content extremely concise and to-the-point
8. Each paragraph should be maximum 2-3 sentences

Do not include any explanatory text, only output the JSON structure.
''';

  static String generateDetailedContentPrompt(String presentationOutline) {
    return '''
Convert this presentation outline into detailed slide content.

Original Outline:
$presentationOutline

IMPORTANT: Respond ONLY with a JSON object. Do not include any other text or explanations.
The JSON must follow this exact structure:

{
  "title": "Main presentation title",
  "slides": [
    {
      "title": "Slide title",
      "type": "One of: titleOneParagraph, titleTwoParagraphs, titleParaImage, titleTwoParaOneImage",
      "paragraphs": ["Detailed paragraph 1", "Detailed paragraph 2"],
      "imagePrompt": "Detailed image generation prompt (only for slides with images)"
    }
  ]
}

Requirements:
1. Use appropriate slide types:
   - titleOneParagraph: For simple points
   - titleTwoParagraphs: For detailed explanations
   - titleParaImage: For visual concepts
   - titleTwoParaOneImage: For complex topics with visuals
2. Keep paragraphs concise (2-3 sentences max)
3. Use markdown formatting:
   - # for main points (red)
   - ## for sub-points (maroon)
   - **bold** for emphasis
   - *italic* for secondary emphasis
   - Bullet points for lists
4. Image prompts should be detailed and specific
5. Maintain logical flow between slides
6. Each slide should focus on one key concept
''';
  }
}

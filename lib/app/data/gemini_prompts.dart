class GeminiPrompts {
  static String generateTitlesPrompt(String topic) {
    return '''
Create a presentation outline for: "$topic"

Format your response as a JSON object with this structure:
{
  "title": "Clear and engaging main title",
  "slides": [
    {
      "slideTitle": "Specific slide title",
      "type": "titleOneParagraph",
      "keyPoints": [
        "Key point 1",
        "Key point 2",
        "Key point 3"
      ]
    }
  ]
}

Each slide should have 3-4 key points.
Generate 7-10 slides total.
First slide should be an introduction.
Last slide should be a conclusion.
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

  static String generateDetailedContentPrompt(
    String presentationOutline, {
    String purpose = 'Informative',
    String style = 'Professional',
    String detailLevel = 'medium',
    bool includeImages = true,
  }) {
    return '''
Convert this presentation outline into detailed slide content.

Original Outline:
$presentationOutline

Presentation Settings:
- Purpose: $purpose
- Style: $style
- Detail Level: $detailLevel
- Include Images: $includeImages

IMPORTANT: Respond ONLY with a JSON object. Do not include any other text or explanations.
The JSON must follow this EXACT structure:

{
  "title": "Main presentation title",
  "slides": [
    {
      "title": "Slide title",
      "type": "titleOneParagraph",
      "paragraphs": [
        "First paragraph with detailed content. Use markdown formatting like **bold** and *italic*.",
        "Second paragraph if needed. Keep paragraphs concise (2-3 sentences)."
      ],
      "imagePrompt": "Optional: Detailed description for generating an image"
    }
  ]
}

Requirements:
1. Use ONLY these slide types:
   - titleOneParagraph: For simple points (1-2 paragraphs)
   - titleTwoParagraphs: For detailed explanations (2 paragraphs)
   - titleParaImage: For visual concepts (1 paragraph + image)
   - titleTwoParaOneImage: For complex topics (2 paragraphs + image)

2. Image Usage Guidelines:
   ${includeImages ? '''
   - When images are enabled (current setting), use image types for:
     * Visual concepts that benefit from illustration
     * Complex processes that need visual representation
     * Data visualization opportunities
     * Key concepts that would be clearer with visual aids
   - Include at least 2-3 slides with images in the presentation
   - For image slides, provide a detailed imagePrompt that describes what to generate
   ''' : '''
   - Images are disabled (current setting)
   - Do NOT use titleParaImage or titleTwoParaOneImage types
   - Convert any visual concepts to text-based explanations
   '''}

3. Each slide MUST have:
   - A clear title
   - One of the allowed types
   - Appropriate content based on its type
   - For image types: A detailed imagePrompt that describes what to generate

4. Content Guidelines:
   - Keep paragraphs concise (2-3 sentences)
   - Use markdown formatting for emphasis
   - Ensure logical flow between slides
   - Maintain consistent style throughout
''';
  }
}

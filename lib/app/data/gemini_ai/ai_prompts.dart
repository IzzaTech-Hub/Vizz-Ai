class AiPrompts {
  static const String systemInstructions = '''
You are a professional presentation outline generator.
Your task is to create well-structured, engaging presentation outlines.
Always respond with valid JSON that follows the exact schema provided.
Each response must include:
1. A clear, concise title
2. 5-7 slides that flow logically
3. Each slide must have 3-4 key points
4. Use appropriate slide types based on content
5. Ensure content is engaging and professional

Do not include any explanatory text, only output the JSON structure.
''';

  static String generatePresentationPrompt(String topic) {
    return '''
Create a professional presentation outline about "$topic".

Guidelines:
1. Start with an engaging title slide
2. Include an introduction that hooks the audience
3. Present key concepts in a logical flow
4. Use varied slide types for different content:
   - Use titleBulletPoints for lists and key points
   - Use titleComparisonTable for comparisons
   - Use titleStatistics for data and metrics
   - Use titleProcessSteps for procedures
   - Use titleParagraphImage for complex concepts
5. End with a strong conclusion
6. Each slide should have 3-4 clear, concise key points
7. Ensure content is informative and engaging

Please generate a complete presentation outline following these guidelines.
''';
  }

  static String generateImagePrompt(String description) => '''
Create a detailed image generation prompt for: "$description"

Requirements:
1. Make it detailed and specific
2. Include style suggestions (e.g., "minimalist", "photorealistic", "isometric")
3. Specify colors or mood if relevant
4. Include composition details
5. Keep it under 100 words
6. Focus on visual elements
7. Avoid any inappropriate or controversial content
8. Make it suitable for professional presentations

Return ONLY the prompt text, no explanations or additional formatting.
''';

  static String get slideTypeExamples => '''
Examples for each slide type:

titleOnly:
{
  "title": "The Future of Artificial Intelligence",
  "type": "titleOnly"
}

titleSubtitle:
{
  "title": "Understanding Machine Learning",
  "type": "titleSubtitle",
  "subtitle": "A Comprehensive Overview of Modern AI Technologies"
}

titleParagraph:
{
  "title": "Neural Networks Explained",
  "type": "titleParagraph",
  "paragraph1": "Neural networks are computing systems inspired by biological neural networks. They learn to perform tasks by considering examples, generally without being programmed with task-specific rules."
}

[Continue with examples for other types...]
''';
}

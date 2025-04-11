class AiPrompt {
  String getSystemInstructions(String type) {
    switch (type) {
      case 'hierarchy':
        return '''
Analyze the content and organize it into a hierarchical structure.
Each point should contain a Flutter icon, a short title (1–2 words), a brief description, and optional nested sub-points under a "children" field.
Make sure each point has a unique and relevant Flutter icon. Include at least 3 top-level points, and add sub-children wherever logical.
''';

      case 'key_points':
        return '''
Analyze the given content and convert it into a list key points containg an icon from flutter icons, title of one or two words and a very short description.
there should be more than 3 key points. and flutter icon of every other point should be different.
''';

      case 'graph':
        return '''
Analyze the content and convert it into graph-style data with at least 3 points.
Each point should contain a label, a short description, a numeric value (for visual graphing), and a relevant Flutter icon.
Make sure values are realistic and icons are not repeated too frequently.
''';

      case 'comparison':
      case 'comparison/differentiate':
        return '''
Analyze the content and create a comparison table with at least 3 items (columns) and 3 or more features (rows).
Each item should have a title and Flutter icon.
Each row should compare all items under a specific feature or characteristic.
Ensure clarity and avoid repetition of icons within the same row.
''';

      case 'step_by_step':
        return '''
Analyze the content and break it down into a clear step-by-step process (like a tutorial or guide).
Each step should have a step number, a short title (1–2 words), a description, and a relevant Flutter icon.
There should be at least 3 steps, and the icons should not repeat often.
''';

      default:
        return '''
Analyze the given content and convert it into a list of key points with more than 3 entries.
Each point should include a Flutter icon, a short title (1–2 words), and a brief description.
Icons should vary and match the meaning of each point.
''';
    }
  }
}

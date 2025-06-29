import 'package:google_generative_ai/google_generative_ai.dart';
import 'slide_types.dart';

class AiSchema {
  Schema getJsonSchema(String type) {
    switch (type) {
      case 'hierarchy':
        return hierarchySchema;
      case 'key_points':
        return keywordsSchema;
      case 'graph':
        return graphSchema;
      case 'comparison/differentiate':
        return comparisonSchema;
      case 'step_by_step':
        return sbsSchema;

      default:
        return keywordsSchema;
    }
  }

  Schema hierarchySchema = Schema(
    SchemaType.object,
    requiredProperties: ["heading", "nodes"],
    properties: {
      "heading": Schema(SchemaType.string),
      "nodes": Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          requiredProperties: [
            "title",
            "flutter_icon_name",
            "description",
            "children"
          ],
          properties: {
            "title": Schema(SchemaType.string),
            "flutter_icon_name": Schema(SchemaType.string),
            "description": Schema(SchemaType.string),
            "children": Schema(
              SchemaType.array,
              items: Schema(SchemaType.object),
            ),
          },
        ),
      ),
    },
  );

  Schema keywordsSchema = Schema(
    SchemaType.object,
    requiredProperties: ["heading", "keypoints"],
    properties: {
      "heading": Schema(
        SchemaType.string,
      ),
      "keypoints": Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          requiredProperties: [
            "title",
            "flutter_icon_name",
            "short_description"
          ],
          properties: {
            "title": Schema(
              SchemaType.string,
            ),
            "flutter_icon_name": Schema(
              SchemaType.string,
            ),
            "short_description": Schema(
              SchemaType.string,
            ),
          },
        ),
      ),
    },
  );
  // Schema keywordsSchema = Schema(
  //   SchemaType.object,
  //   requiredProperties: ["heading", "keypoints"],
  //   properties: {
  //     "heading": Schema(
  //       SchemaType.string,
  //     ),
  //     "keypoints": Schema(
  //       SchemaType.array,
  //       items: Schema(
  //         SchemaType.object,
  //         requiredProperties: [
  //           "title",
  //           "flutter_icon_name",
  //           "short_description"
  //         ],
  //         properties: {
  //           "title": Schema(
  //             SchemaType.string,
  //           ),
  //           "flutter_icon_name": Schema(
  //             SchemaType.string,
  //           ),
  //           "short_description": Schema(
  //             SchemaType.string,
  //           ),
  //         },
  //       ),
  //     ),
  //   },
  // );

  Schema graphSchema = Schema(
    SchemaType.object,
    requiredProperties: ["heading", "data_points"],
    properties: {
      "heading": Schema(SchemaType.string),
      "data_points": Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          requiredProperties: [
            "label",
            "flutter_icon_name",
            "value",
            "description"
          ],
          properties: {
            "label": Schema(SchemaType.string),
            "flutter_icon_name": Schema(SchemaType.string),
            "value": Schema(SchemaType.number),
            "description": Schema(SchemaType.string),
          },
        ),
      ),
    },
  );

  Schema comparisonSchema = Schema(
    SchemaType.object,
    requiredProperties: ["heading", "columns", "rows"],
    properties: {
      "heading": Schema(SchemaType.string),
      "columns": Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          requiredProperties: ["title", "flutter_icon_name"],
          properties: {
            "title": Schema(SchemaType.string),
            "flutter_icon_name": Schema(SchemaType.string),
          },
        ),
      ),
      "rows": Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          requiredProperties: ["feature", "values"],
          properties: {
            "feature": Schema(SchemaType.string),
            "values": Schema(
              SchemaType.array,
              items: Schema(
                  SchemaType.string), // each value corresponds to a column
            ),
          },
        ),
      ),
    },
  );

  Schema sbsSchema = Schema(
    SchemaType.object,
    requiredProperties: ["heading", "steps"],
    properties: {
      "heading": Schema(SchemaType.string),
      "steps": Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          requiredProperties: [
            "step_number",
            "title",
            "flutter_icon_name",
            "description"
          ],
          properties: {
            "step_number": Schema(SchemaType.integer),
            "title": Schema(SchemaType.string),
            "flutter_icon_name": Schema(SchemaType.string),
            "description": Schema(SchemaType.string),
          },
        ),
      ),
    },
  );

  static final Schema presentationSchema = Schema(
    SchemaType.object,
    properties: {
      'title': Schema(SchemaType.string),
      'slides': Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          properties: {
            'type': Schema(
              SchemaType.string,
              enumValues: [
                // 'titleOnly',
                'titleOneParagraph',
                'titleTwoParagraphs',
                'titleParaImage',
                'titleTwoParaOneImage'
              ],
            ),
            'slideTitle': Schema(SchemaType.string),
            'keyPoints': Schema(
              SchemaType.array,
              items: Schema(SchemaType.string),
            ),
          },
          requiredProperties: ['type', 'slideTitle', 'keyPoints'],
        ),
      ),
    },
    requiredProperties: ['title', 'slides'],
  );

  static Schema get slideContentSchema => Schema(
        SchemaType.object,
        properties: {
          'title': Schema(SchemaType.string),
          'type': Schema(
            SchemaType.string,
            enumValues: SlideType.values
                .map((e) => e.toString().split('.').last)
                .toList(),
          ),
          'subtitle': Schema(SchemaType.string),
          'paragraph1': Schema(SchemaType.string),
          'paragraph2': Schema(SchemaType.string),
          'bulletPoints': Schema(
            SchemaType.array,
            items: Schema(SchemaType.string),
          ),
          'image1': imagePromptSchema,
          'image2': imagePromptSchema,
          'quote': Schema(SchemaType.string),
          'quoteAuthor': Schema(SchemaType.string),
          'comparisonItems': Schema(
            SchemaType.array,
            items: comparisonItemSchema,
          ),
          'timelineItems': Schema(
            SchemaType.array,
            items: timelineItemSchema,
          ),
          'statistics': Schema(
            SchemaType.array,
            items: statItemSchema,
          ),
          'processSteps': Schema(
            SchemaType.array,
            items: processStepSchema,
          ),
        },
        requiredProperties: ['title', 'type'],
      );

  static Schema get imagePromptSchema => Schema(
        SchemaType.object,
        properties: {
          'description': Schema(SchemaType.string),
          'generatedUrl': Schema(SchemaType.string),
        },
        requiredProperties: ['description'],
      );

  static Schema get comparisonItemSchema => Schema(
        SchemaType.object,
        properties: {
          'aspect': Schema(SchemaType.string),
          'side1': Schema(SchemaType.string),
          'side2': Schema(SchemaType.string),
        },
        requiredProperties: ['aspect', 'side1', 'side2'],
      );

  static Schema get timelineItemSchema => Schema(
        SchemaType.object,
        properties: {
          'date': Schema(SchemaType.string),
          'event': Schema(SchemaType.string),
          'description': Schema(SchemaType.string),
        },
        requiredProperties: ['date', 'event'],
      );

  static Schema get statItemSchema => Schema(
        SchemaType.object,
        properties: {
          'value': Schema(SchemaType.string),
          'label': Schema(SchemaType.string),
          'description': Schema(SchemaType.string),
        },
        requiredProperties: ['value', 'label'],
      );

  static Schema get processStepSchema => Schema(
        SchemaType.object,
        properties: {
          'stepNumber': Schema(SchemaType.integer),
          'title': Schema(SchemaType.string),
          'description': Schema(SchemaType.string),
        },
        requiredProperties: ['stepNumber', 'title', 'description'],
      );

  static final Schema presentationContentSchema = Schema(
    SchemaType.object,
    properties: {
      'title': Schema(SchemaType.string),
      'slides': Schema(
        SchemaType.array,
        items: Schema(
          SchemaType.object,
          properties: {
            'title': Schema(SchemaType.string),
            'type': Schema(
              SchemaType.string,
              enumValues: [
                'titleOneParagraph',
                'titleTwoParagraphs',
                'titleParaImage',
                'titleTwoParaOneImage'
              ],
            ),
            'paragraphs': Schema(
              SchemaType.array,
              items: Schema(SchemaType.string),
            ),
            'imagePrompt': Schema(SchemaType.string),
          },
          requiredProperties: ['title', 'type', 'paragraphs'],
        ),
      ),
    },
    requiredProperties: ['title', 'slides'],
  );

  static void printSchema() {
    print('DEBUG: Presentation Content Schema:');
    print('''
{
  "type": "object",
  "required": ["title", "slides"],
  "properties": {
    "title": {"type": "string"},
    "slides": {
      "type": "array",
      "items": {
        "type": "object",
        "required": ["title", "type", "paragraphs"],
        "properties": {
          "title": {"type": "string"},
          "type": {
            "type": "string",
            "enum": ["titleOneParagraph", "titleTwoParagraphs", "titleParaImage", "titleTwoParaOneImage"]
          },
          "paragraphs": {
            "type": "array",
            "items": {"type": "string"}
          },
          "imagePrompt": {"type": "string"}
        }
      }
    }
  }
}
''');
  }
}

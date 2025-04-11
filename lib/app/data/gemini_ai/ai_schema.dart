import 'package:google_generative_ai/google_generative_ai.dart';

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
              items: Schema(SchemaType.object
              ),
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
        requiredProperties: ["step_number", "title", "flutter_icon_name", "description"],
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


}

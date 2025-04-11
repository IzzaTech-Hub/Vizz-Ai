import 'dart:convert';

/// Model class for `Keypoint`
class KeyPoint {
  final String title;
  final String flutterIconName;
  final String shortDescription;

  KeyPoint({
    required this.title,
    required this.flutterIconName,
    required this.shortDescription,
  });

  /// Factory method to create `Keypoint` from JSON
  factory KeyPoint.fromJson(Map<String, dynamic> json) {
    return KeyPoint(
      title: json["title"] ?? "",
      flutterIconName: json["flutter_icon_name"] ?? "",
      shortDescription: json["short_description"] ?? "",
    );
  }

  /// Converts `Keypoint` object to JSON
  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "flutter_icon_name": flutterIconName,
      "short_description": shortDescription,
    };
  }
}

/// Model class for `SchemaData`
class KeyPoints {
  final String heading;
  final List<KeyPoint> keypoints;

  KeyPoints({
    required this.heading,
    required this.keypoints,
  });

  /// Factory method to create `SchemaData` from JSON
  factory KeyPoints.fromJson(Map<String, dynamic> json) {
  // factory KeyPoints.fromJson(String jsonString) {
    // Map<String, dynamic> json = jsonDecode(jsonString);

    return KeyPoints(
      heading: json["heading"] ?? "",
      keypoints: (json["keypoints"] as List<dynamic>)
          .map((item) => KeyPoint.fromJson(item))
          .toList(),
    );
  }

  /// Converts `SchemaData` object to JSON
  Map<String, dynamic> toJson() {
    return {
      "heading": heading,
      "keypoints": keypoints.map((kp) => kp.toJson()).toList(),
    };
  }
}

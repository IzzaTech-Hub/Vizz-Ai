class GraphPoint {
  final String label;
  final String flutterIconName;
  final String description;
  final num value;

  GraphPoint({
    required this.label,
    required this.flutterIconName,
    required this.description,
    required this.value,
  });

  factory GraphPoint.fromJson(Map<String, dynamic> json) => GraphPoint(
        label: json['label'],
        flutterIconName: json['flutter_icon_name'],
        description: json['description'],
        value: json['value'],
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'flutter_icon_name': flutterIconName,
        'description': description,
        'value': value,
      };
}

class GraphModel {
  final String heading;
  final List<GraphPoint> dataPoints;

  GraphModel({required this.heading, required this.dataPoints});

  factory GraphModel.fromJson(Map<String, dynamic> json) => GraphModel(
        heading: json['heading'],
        dataPoints: (json['data_points'] as List<dynamic>)
            .map((e) => GraphPoint.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'data_points': dataPoints.map((e) => e.toJson()).toList(),
      };
}

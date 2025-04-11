class ComparisonColumn {
  final String title;
  final String flutterIconName;

  ComparisonColumn({
    required this.title,
    required this.flutterIconName,
  });

  factory ComparisonColumn.fromJson(Map<String, dynamic> json) =>
      ComparisonColumn(
        title: json['title'],
        flutterIconName: json['flutter_icon_name'],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'flutter_icon_name': flutterIconName,
      };
}

class ComparisonRow {
  final String feature;
  final List<String> values;

  ComparisonRow({
    required this.feature,
    required this.values,
  });

  factory ComparisonRow.fromJson(Map<String, dynamic> json) => ComparisonRow(
        feature: json['feature'],
        values: List<String>.from(json['values']),
      );

  Map<String, dynamic> toJson() => {
        'feature': feature,
        'values': values,
      };
}

class ComparisonModel {
  final String heading;
  final List<ComparisonColumn> columns;
  final List<ComparisonRow> rows;

  ComparisonModel({
    required this.heading,
    required this.columns,
    required this.rows,
  });

  factory ComparisonModel.fromJson(Map<String, dynamic> json) =>
      ComparisonModel(
        heading: json['heading'],
        columns: (json['columns'] as List<dynamic>)
            .map((e) => ComparisonColumn.fromJson(e))
            .toList(),
        rows: (json['rows'] as List<dynamic>)
            .map((e) => ComparisonRow.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'columns': columns.map((e) => e.toJson()).toList(),
        'rows': rows.map((e) => e.toJson()).toList(),
      };
}

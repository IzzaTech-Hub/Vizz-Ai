class StepItem {
  final int stepNumber;
  final String title;
  final String flutterIconName;
  final String description;

  StepItem({
    required this.stepNumber,
    required this.title,
    required this.flutterIconName,
    required this.description,
  });

  factory StepItem.fromJson(Map<String, dynamic> json) => StepItem(
        stepNumber: json['step_number'],
        title: json['title'],
        flutterIconName: json['flutter_icon_name'],
        description: json['description'],
      );

  Map<String, dynamic> toJson() => {
        'step_number': stepNumber,
        'title': title,
        'flutter_icon_name': flutterIconName,
        'description': description,
      };
}

class StepByStepModel {
  final String heading;
  final List<StepItem> steps;

  StepByStepModel({required this.heading, required this.steps});

  factory StepByStepModel.fromJson(Map<String, dynamic> json) =>
      StepByStepModel(
        heading: json['heading'],
        steps: (json['steps'] as List<dynamic>)
            .map((e) => StepItem.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'steps': steps.map((e) => e.toJson()).toList(),
      };
}

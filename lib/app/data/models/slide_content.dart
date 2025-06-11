import '../gemini_ai/slide_types.dart';

class SlideContent {
  final String title;
  final SlideType type;
  final String? subtitle;
  final String? paragraph1;
  final String? paragraph2;
  final List<String>? bulletPoints;
  final ImagePrompt? image1;
  final ImagePrompt? image2;
  final String? quote;
  final String? quoteAuthor;
  final List<ComparisonItem>? comparisonItems;
  final List<TimelineItem>? timelineItems;
  final List<StatItem>? statistics;
  final List<ProcessStep>? processSteps;

  SlideContent({
    required this.title,
    required this.type,
    this.subtitle,
    this.paragraph1,
    this.paragraph2,
    this.bulletPoints,
    this.image1,
    this.image2,
    this.quote,
    this.quoteAuthor,
    this.comparisonItems,
    this.timelineItems,
    this.statistics,
    this.processSteps,
  });

  factory SlideContent.fromJson(Map<String, dynamic> json) {
    return SlideContent(
      title: json['title'],
      type: SlideType.fromString(json['type']),
      subtitle: json['subtitle'],
      paragraph1: json['paragraph1'],
      paragraph2: json['paragraph2'],
      bulletPoints: json['bulletPoints']?.cast<String>(),
      image1:
          json['image1'] != null ? ImagePrompt.fromJson(json['image1']) : null,
      image2:
          json['image2'] != null ? ImagePrompt.fromJson(json['image2']) : null,
      quote: json['quote'],
      quoteAuthor: json['quoteAuthor'],
      comparisonItems: json['comparisonItems']
          ?.map<ComparisonItem>((item) => ComparisonItem.fromJson(item))
          ?.toList(),
      timelineItems: json['timelineItems']
          ?.map<TimelineItem>((item) => TimelineItem.fromJson(item))
          ?.toList(),
      statistics: json['statistics']
          ?.map<StatItem>((item) => StatItem.fromJson(item))
          ?.toList(),
      processSteps: json['processSteps']
          ?.map<ProcessStep>((item) => ProcessStep.fromJson(item))
          ?.toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type.toString().split('.').last,
        'subtitle': subtitle,
        'paragraph1': paragraph1,
        'paragraph2': paragraph2,
        'bulletPoints': bulletPoints,
        'image1': image1?.toJson(),
        'image2': image2?.toJson(),
        'quote': quote,
        'quoteAuthor': quoteAuthor,
        'comparisonItems':
            comparisonItems?.map((item) => item.toJson())?.toList(),
        'timelineItems': timelineItems?.map((item) => item.toJson())?.toList(),
        'statistics': statistics?.map((item) => item.toJson())?.toList(),
        'processSteps': processSteps?.map((item) => item.toJson())?.toList(),
      };
}

class ImagePrompt {
  final String description;
  final String? generatedUrl;

  ImagePrompt({
    required this.description,
    this.generatedUrl,
  });

  factory ImagePrompt.fromJson(Map<String, dynamic> json) {
    return ImagePrompt(
      description: json['description'],
      generatedUrl: json['generatedUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'description': description,
        'generatedUrl': generatedUrl,
      };
}

class ComparisonItem {
  final String aspect;
  final String side1;
  final String side2;

  ComparisonItem({
    required this.aspect,
    required this.side1,
    required this.side2,
  });

  factory ComparisonItem.fromJson(Map<String, dynamic> json) {
    return ComparisonItem(
      aspect: json['aspect'],
      side1: json['side1'],
      side2: json['side2'],
    );
  }

  Map<String, dynamic> toJson() => {
        'aspect': aspect,
        'side1': side1,
        'side2': side2,
      };
}

class TimelineItem {
  final String date;
  final String event;
  final String? description;

  TimelineItem({
    required this.date,
    required this.event,
    this.description,
  });

  factory TimelineItem.fromJson(Map<String, dynamic> json) {
    return TimelineItem(
      date: json['date'],
      event: json['event'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'event': event,
        'description': description,
      };
}

class StatItem {
  final String value;
  final String label;
  final String? description;

  StatItem({
    required this.value,
    required this.label,
    this.description,
  });

  factory StatItem.fromJson(Map<String, dynamic> json) {
    return StatItem(
      value: json['value'],
      label: json['label'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'value': value,
        'label': label,
        'description': description,
      };
}

class ProcessStep {
  final int stepNumber;
  final String title;
  final String description;

  ProcessStep({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  factory ProcessStep.fromJson(Map<String, dynamic> json) {
    return ProcessStep(
      stepNumber: json['stepNumber'],
      title: json['title'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() => {
        'stepNumber': stepNumber,
        'title': title,
        'description': description,
      };
}

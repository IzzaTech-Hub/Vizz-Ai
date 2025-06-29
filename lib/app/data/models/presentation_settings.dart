import 'package:get/get.dart';

enum DetailLevel { short, medium, detailed }

class PresentationSettings {
  final String topic;
  final String purpose;
  final String style;
  final bool includeImages;
  final int numberOfSlides;
  final DetailLevel detailLevel;

  PresentationSettings({
    required this.topic,
    required this.purpose,
    required this.style,
    required this.includeImages,
    required this.numberOfSlides,
    required this.detailLevel,
  });

  factory PresentationSettings.initial() {
    return PresentationSettings(
      topic: '',
      purpose: 'Informative',
      style: 'Professional',
      includeImages: true,
      numberOfSlides: 7,
      detailLevel: DetailLevel.medium,
    );
  }

  PresentationSettings copyWith({
    String? topic,
    String? purpose,
    String? style,
    bool? includeImages,
    int? numberOfSlides,
    DetailLevel? detailLevel,
  }) {
    return PresentationSettings(
      topic: topic ?? this.topic,
      purpose: purpose ?? this.purpose,
      style: style ?? this.style,
      includeImages: includeImages ?? this.includeImages,
      numberOfSlides: numberOfSlides ?? this.numberOfSlides,
      detailLevel: detailLevel ?? this.detailLevel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'topic': topic,
      'purpose': purpose,
      'style': style,
      'includeImages': includeImages,
      'numberOfSlides': numberOfSlides,
      'detailLevel': detailLevel.toString().split('.').last,
    };
  }

  factory PresentationSettings.fromJson(Map<String, dynamic> json) {
    return PresentationSettings(
      topic: json['topic'] as String,
      purpose: json['purpose'] as String,
      style: json['style'] as String,
      includeImages: json['includeImages'] as bool,
      numberOfSlides: json['numberOfSlides'] as int,
      detailLevel: DetailLevel.values.firstWhere(
        (e) => e.toString().split('.').last == json['detailLevel'],
        orElse: () => DetailLevel.medium,
      ),
    );
  }
}

class PresentationSettingsController extends GetxController {
  final Rx<PresentationSettings> settings = PresentationSettings.initial().obs;

  static final List<String> purposes = [
    'Informative',
    'Persuasive',
    'Educational',
    'Business',
    'Technical',
    'Sales',
    'Training',
  ];

  static final List<String> styles = [
    'Professional',
    'Creative',
    'Minimalist',
    'Modern',
    'Classic',
    'Dynamic',
    'Academic',
  ];

  void updateSettings(PresentationSettings newSettings) {
    settings.value = newSettings;
  }

  void updateTopic(String topic) {
    settings.value = settings.value.copyWith(topic: topic);
  }

  void updatePurpose(String purpose) {
    settings.value = settings.value.copyWith(purpose: purpose);
  }

  void updateStyle(String style) {
    settings.value = settings.value.copyWith(style: style);
  }

  void updateIncludeImages(bool includeImages) {
    settings.value = settings.value.copyWith(includeImages: includeImages);
  }

  void updateNumberOfSlides(int numberOfSlides) {
    settings.value = settings.value.copyWith(numberOfSlides: numberOfSlides);
  }

  void updateDetailLevel(DetailLevel detailLevel) {
    settings.value = settings.value.copyWith(detailLevel: detailLevel);
  }
}

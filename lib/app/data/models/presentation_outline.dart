import 'dart:convert';
import '../gemini_ai/slide_types.dart';

class PresentationOutline {
  final String title;
  final List<SlideOutline> slides;

  PresentationOutline({
    required this.title,
    required this.slides,
  });

  factory PresentationOutline.fromJson(Map<String, dynamic> json) {
    return PresentationOutline(
      title: json['title'] as String,
      slides: (json['slides'] as List)
          .map((slide) => SlideOutline.fromJson(slide))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'slides': slides.map((slide) => slide.toJson()).toList(),
    };
  }
}

class SlideOutline {
  final String slideTitle;
  String type; // Made mutable
  List<String> keyPoints; // Made mutable

  SlideOutline({
    required this.slideTitle,
    required this.type,
    required this.keyPoints,
  });

  factory SlideOutline.fromJson(Map<String, dynamic> json) {
    return SlideOutline(
      slideTitle: json['slideTitle'] as String,
      type: json['type'] as String,
      keyPoints: (json['keyPoints'] as List).map((e) => e as String).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'slideTitle': slideTitle,
      'type': type,
      'keyPoints': keyPoints,
    };
  }
}

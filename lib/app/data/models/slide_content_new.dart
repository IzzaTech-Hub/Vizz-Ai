import 'package:napkin/app/data/gemini_ai/slide_types.dart';

class PresentationContent {
  final String title;
  final List<SlideContentNew> slides;

  PresentationContent({
    required this.title,
    required this.slides,
  });

  factory PresentationContent.fromJson(Map<String, dynamic> json) {
    return PresentationContent(
      title: json['title'] as String,
      slides: (json['slides'] as List)
          .map((slide) => SlideContentNew.fromJson(slide))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'slides': slides.map((slide) => slide.toJson()).toList(),
      };
}

class SlideContentNew {
  final String title;
  final List<String> paragraphs;
  final String? imagePrompt;
  final SlideType type;

  SlideContentNew({
    required this.title,
    required this.paragraphs,
    this.imagePrompt,
    required this.type,
  });

  factory SlideContentNew.fromJson(Map<String, dynamic> json) {
    return SlideContentNew(
      title: json['title'] as String,
      paragraphs: (json['paragraphs'] as List).cast<String>(),
      imagePrompt: json['imagePrompt'] as String?,
      type: SlideType.fromString(json['type'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'paragraphs': paragraphs,
        'imagePrompt': imagePrompt,
        'type': type.toString().split('.').last,
      };
}

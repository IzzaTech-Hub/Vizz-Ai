import 'dart:typed_data';
import 'dart:ui';

class Templete {
  final String id;
  final String name;
  final String previewImageUrl;
  final List<String> imageUrls; // Remote URLs from Firebase
  final List<String> localImagePaths; // Local file paths after download
  final String titleColorHex;
  final String textColorHex;

  Templete({
    required this.id,
    required this.name,
    required this.previewImageUrl,
    required this.imageUrls,
    required this.localImagePaths,
    required this.titleColorHex,
    required this.textColorHex,
  });

  factory Templete.fromJson(Map<String, dynamic> json) {
    return Templete(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      previewImageUrl: json['previewImageUrl'] ?? '',
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      localImagePaths: List<String>.from(json['localImagePaths'] ?? []),
      titleColorHex: json['titleColor'] ?? '#000000',
      textColorHex: json['textColor'] ?? '#FFFFFF',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'previewImageUrl': previewImageUrl,
      'imageUrls': imageUrls,
      'localImagePaths': localImagePaths,
      'titleColor': titleColorHex,
      'textColor': textColorHex,
    };
  }
}

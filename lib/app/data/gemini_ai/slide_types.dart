enum SlideType {
  titleOnly, // Just a title slide
  titleOneParagraph, // Title with one paragraph
  titleTwoParagraphs, // Title with two paragraphs
  titleParaImage, // Title with paragraph and image
  titleTwoParaOneImage; // Title with two paragraphs and one image

  factory SlideType.fromString(String type) {
    return SlideType.values.firstWhere(
      (e) => e.toString().split('.').last == type,
      orElse: () => SlideType.titleOneParagraph,
    );
  }

  String get displayName {
    switch (this) {
      case SlideType.titleOnly:
        return "Title Only";
      case SlideType.titleOneParagraph:
        return "Title with One Paragraph";
      case SlideType.titleTwoParagraphs:
        return "Title with Two Paragraphs";
      case SlideType.titleParaImage:
        return "Title with Paragraph and Image";
      case SlideType.titleTwoParaOneImage:
        return "Title with Two Paragraphs and Image";
    }
  }
}

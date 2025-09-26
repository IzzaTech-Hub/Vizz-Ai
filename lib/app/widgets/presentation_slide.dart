import 'dart:io';
import 'package:flutter/material.dart';
import 'package:napkin/app/utills/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';

class PresentationSlide extends StatefulWidget {
  final String title;
  final List<String> paragraphs;
  final String? imagePrompt;
  final Function(File) onImageSelected;
  final Function() onGenerateImage;
  final File? selectedImage;
  final bool isGenerating;
  final bool isEditing;
  final Function(String) onTitleChanged;
  final Function(int, String) onParagraphChanged;
  final Function(String) onAddParagraph;
  final Function(int) onRemoveParagraph;
  final Color? titleColor;
  final Color? textColor;

  // Constants for text constraints
  static const double TITLE_MAX_CHARS = 40; // Maximum characters for title
  static const double PARAGRAPH_LINE_HEIGHT = 1.5;
  static const int LINES_PER_SLIDE_WITH_IMAGE = 6; // Maximum lines with image
  static const int LINES_PER_SLIDE_NO_IMAGE = 8; // Maximum lines without image
  static const int WORDS_PER_LINE = 8; // Target words per line for readability
  static const int MAX_PARAGRAPHS = 2; // Maximum number of paragraphs per slide

  // Guidelines for AI content generation
  static const String AI_CONTENT_GUIDELINES = 'Presentation Guidelines:\n'
      '1. Format:\n'
      '   - Use markdown for clear visual hierarchy:\n'
      '     * `# ` for main point (stands out in red)\n'
      '     * `## ` for sub-points (stands out in maroon)\n'
      '     * `**bold**` for key terms (red)\n'
      '     * `*italic*` for supporting points (maroon)\n'
      '     * `- ` for bullet points\n'
      '     * `` `highlighted` `` for technical terms\n'
      '2. Content Style:\n'
      '   - Keep title short and impactful\n'
      '   - One key idea per slide\n'
      '   - Use bullet points for clarity\n'
      '   - Be extremely concise\n'
      '   - Prioritize key information only';

  // Calculate maximum characters per line based on slide width
  static int getMaxCharsPerLine(double slideWidth) {
    final baseFontSize = slideWidth * 0.022; // Our paragraph font size
    return (slideWidth / (baseFontSize * 0.65))
        .round(); // Slightly tighter character spacing
  }

  // Calculate maximum characters for the entire content
  static int getMaxContentChars(double slideWidth, bool hasImage) {
    final charsPerLine = getMaxCharsPerLine(slideWidth);
    final maxLines =
        hasImage ? LINES_PER_SLIDE_WITH_IMAGE : LINES_PER_SLIDE_NO_IMAGE;
    return (charsPerLine * maxLines * 0.8)
        .round(); // 80% of theoretical maximum for better readability
  }

  // Helper method to check if content fits
  static bool doesContentFit(
      String title, List<String> paragraphs, double slideWidth, bool hasImage) {
    if (title.length > TITLE_MAX_CHARS) return false;
    if (paragraphs.length > MAX_PARAGRAPHS) return false;

    final maxContentChars = getMaxContentChars(slideWidth, hasImage);
    final totalChars = paragraphs.join(' ').length;

    // Check both total characters and line count
    bool fitsChars = totalChars <= maxContentChars;
    bool fitsLines = paragraphs.join('\n').split('\n').length <=
        (hasImage ? LINES_PER_SLIDE_WITH_IMAGE : LINES_PER_SLIDE_NO_IMAGE);

    return fitsChars && fitsLines;
  }

  // Get formatted content constraints for AI prompt
  static String getAiPromptConstraints(double slideWidth, bool hasImage) {
    final maxChars = getMaxContentChars(slideWidth, hasImage);
    final maxLines =
        hasImage ? LINES_PER_SLIDE_WITH_IMAGE : LINES_PER_SLIDE_NO_IMAGE;

    return '''
    Content Constraints:
    - Title: Maximum 40 characters
    - Total Content: Maximum ${maxChars} characters
    - Maximum Lines: $maxLines
    - Maximum Paragraphs: $MAX_PARAGRAPHS
    - Words per Line: Target $WORDS_PER_LINE words
    
    Format:
    - Use concise, impactful statements
    - Focus on key points only
    - Avoid detailed explanations
    - Use active voice
    ''';
  }

  PresentationSlide({
    Key? key,
    required this.title,
    required this.paragraphs,
    this.imagePrompt,
    required this.onImageSelected,
    required this.onGenerateImage,
    this.selectedImage,
    this.isGenerating = false,
    this.isEditing = false,
    required this.onTitleChanged,
    required this.onParagraphChanged,
    required this.onAddParagraph,
    required this.onRemoveParagraph,
    this.titleColor,
    this.textColor,
  }) : super(key: key);

  @override
  State<PresentationSlide> createState() => _PresentationSlideState();
}

class _PresentationSlideState extends State<PresentationSlide> {
  late TextEditingController _titleController;
  late List<TextEditingController> _paragraphControllers;
  String _tempTitle = '';
  List<String> _tempParagraphs = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void didUpdateWidget(PresentationSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title ||
        oldWidget.paragraphs != widget.paragraphs ||
        oldWidget.isEditing != widget.isEditing) {
      _initializeControllers();
    }
  }

  void _initializeControllers() {
    _titleController = TextEditingController(text: widget.title);
    _tempTitle = widget.title;
    _paragraphControllers =
        widget.paragraphs.map((p) => TextEditingController(text: p)).toList();
    _tempParagraphs = List.from(widget.paragraphs);
  }

  @override
  void dispose() {
    _titleController.dispose();
    for (var controller in _paragraphControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _showEditDialog(
    BuildContext context, {
    required String title,
    required bool isTitle,
    required Function(String) onSave,
  }) {
    final TextEditingController controller = TextEditingController(text: title);
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isTitle ? 'Edit Slide Title' : 'Edit Paragraph',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: MyAppColors.color2,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                maxLines: isTitle ? 2 : 5,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (controller.text.trim().isNotEmpty) {
                        onSave(controller.text.trim());
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: MyAppColors.color2,
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: Text('Done'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate dimensions based on 16:9 ratio
    final screenWidth = MediaQuery.of(context).size.width;
    final slideWidth = screenWidth - 32; // Account for padding
    final slideHeight = slideWidth * 9 / 16;

    // For debugging purposes - print available space metrics
    assert(() {
      final maxCharsPerLine = PresentationSlide.getMaxCharsPerLine(slideWidth);
      final maxContentChars = PresentationSlide.getMaxContentChars(
          slideWidth, widget.imagePrompt != null);
      // print('Slide Metrics:');
      // print('Max chars per line: $maxCharsPerLine');
      // print('Max total chars: $maxContentChars');
      // print('Current content length: ${widget.paragraphs.join(' ').length}');
      return true;
    }());

    // Create markdown style sheet with responsive sizes
    final markdownStyle = MarkdownStyleSheet(
      h1: TextStyle(
        fontSize: slideWidth * 0.028,
        color: widget.titleColor ?? MyAppColors.color1,
        fontWeight: FontWeight.bold,
        height: 1.3,
      ),
      h2: TextStyle(
        fontSize: slideWidth * 0.025,
        color: MyAppColors.color2,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      p: TextStyle(
        fontSize: slideWidth * 0.022,
        color: widget.textColor ?? Colors.black87,
        height: PresentationSlide.PARAGRAPH_LINE_HEIGHT,
      ),
      listBullet: TextStyle(
        color: MyAppColors.color2,
      ),
      strong: TextStyle(
        color: MyAppColors.color1,
        fontWeight: FontWeight.bold,
      ),
      em: TextStyle(
        color: MyAppColors.color2,
        fontStyle: FontStyle.italic,
      ),
      code: TextStyle(
        backgroundColor: MyAppColors.color2.withOpacity(0.1),
        color: MyAppColors.color2,
        fontSize: slideWidth * 0.022,
      ),
      blockquote: TextStyle(
        color: MyAppColors.color2,
        fontSize: slideWidth * 0.022,
        fontStyle: FontStyle.italic,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: MyAppColors.color2,
            width: 4,
          ),
        ),
      ),
      listBulletPadding: EdgeInsets.only(right: 8),
      listIndent: 24,
      blockSpacing: slideHeight * 0.02,
      unorderedListAlign: WrapAlignment.start,
    );

    return Container(
      width: slideWidth,
      height: slideHeight,
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.isEditing
                      ? GestureDetector(
                          onTap: () => _showEditDialog(
                            context,
                            title: widget.title,
                            isTitle: true,
                            onSave: (value) => widget.onTitleChanged(value),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    widget.title,
                                    style: TextStyle(
                                      fontSize: slideWidth * 0.035,
                                      fontWeight: FontWeight.bold,
                                      color: widget.titleColor ??
                                          MyAppColors.color2,
                                    ),
                                  ),
                                ),
                                Icon(Icons.edit, size: 20, color: Colors.grey),
                              ],
                            ),
                          ),
                        )
                      : Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: slideWidth * 0.035,
                            fontWeight: FontWeight.bold,
                            color: widget.titleColor ?? MyAppColors.color2,
                          ),
                        ),
                  SizedBox(height: slideHeight * 0.04),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.only(
                        right: widget.imagePrompt != null
                            ? slideHeight * 0.5 + 8
                            : 0,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ...widget.paragraphs.asMap().entries.map((entry) {
                              final index = entry.key;
                              return Padding(
                                padding:
                                    EdgeInsets.only(bottom: slideHeight * 0.02),
                                child: widget.isEditing
                                    ? GestureDetector(
                                        onTap: () => _showEditDialog(
                                          context,
                                          title: entry.value,
                                          isTitle: false,
                                          onSave: (value) => widget
                                              .onParagraphChanged(index, value),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: MarkdownBody(
                                                        data: entry.value,
                                                        styleSheet:
                                                            markdownStyle,
                                                        softLineBreak: true,
                                                        selectable: false,
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(Icons.edit,
                                                            size: 16,
                                                            color: Colors.grey),
                                                        SizedBox(width: 8),
                                                        IconButton(
                                                          icon: Icon(
                                                              Icons.delete,
                                                              size: 16),
                                                          color: Colors.red,
                                                          padding:
                                                              EdgeInsets.zero,
                                                          constraints:
                                                              BoxConstraints(),
                                                          onPressed: () => widget
                                                              .onRemoveParagraph(
                                                                  index),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : MarkdownBody(
                                        data: entry.value,
                                        styleSheet: markdownStyle,
                                        softLineBreak: true,
                                        selectable: false,
                                      ),
                              );
                            }).toList(),
                            if (widget.isEditing)
                              Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: ElevatedButton.icon(
                                  onPressed: () =>
                                      widget.onAddParagraph("New paragraph"),
                                  icon: Icon(Icons.add, size: 20),
                                  label: Text("Add Paragraph"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: MyAppColors.color2,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Image section
            if (widget.imagePrompt != null)
              Positioned(
                right: 24,
                bottom: 24,
                child: Container(
                  width: slideHeight * 0.5,
                  height: slideHeight * 0.5,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (widget.selectedImage != null)
                        GestureDetector(
                          onTap: () => _showImageOptionsDialog(context),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.file(
                                widget.selectedImage!,
                                fit: BoxFit.cover,
                              ),
                              Container(
                                color: Colors.black.withOpacity(0.1),
                              ),
                            ],
                          ),
                        )
                      else if (!widget.isGenerating)
                        Stack(
                          fit: StackFit.expand,
                          children: [
                            // Placeholder image
                            Image.asset(
                              'assets/images/image_placeholder.png',
                              fit: BoxFit.cover,
                            ),
                            Positioned.fill(
                              child: Container(
                                color: Colors.black38,
                              ),
                            ),
                            // Semi-transparent shimmer overlay
                            Shimmer.fromColors(
                              baseColor: Colors.transparent,
                              // baseColor: Colors.grey[300]!.withOpacity(0.7),
                              highlightColor: Colors.white.withOpacity(0.4),
                              // highlightColor:
                              //     Colors.grey[100]!.withOpacity(0.9),
                              child: Container(
                                // color: Colors.transparent,
                                color: Colors.white.withOpacity(0.4),
                                // color: Colors.white,
                              ),
                            ),
                          ],
                        ),

                      // Loading indicator overlay
                      if (widget.isGenerating)
                        Container(
                          color: Colors.black.withOpacity(0.1),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      MyAppColors.color2),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Generating...',
                                  style: TextStyle(
                                    color: MyAppColors.color2,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Control overlay
                      if (!widget.isGenerating && widget.selectedImage == null)
                        Container(
                          // height: 40,
                          // width: 40,
                          decoration: BoxDecoration(
                            // color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      iconSize: 20,
                                      icon: Icon(Icons.photo_camera),
                                      onPressed: () =>
                                          _pickImage(ImageSource.camera),
                                      color: Colors.white,
                                      // color: MyAppColors.color2,
                                    ),
                                    // SizedBox(width: 8),
                                    IconButton(
                                      iconSize: 20,
                                      icon: Icon(Icons.photo_library),
                                      onPressed: () =>
                                          _pickImage(ImageSource.gallery),
                                      color: Colors.white,
                                      // color: MyAppColors.color2,
                                    ),
                                  ],
                                ),
                                // SizedBox(height: 8),
                                IconButton(
                                  iconSize: 20,
                                  icon: Icon(Icons.auto_awesome),
                                  onPressed: widget.onGenerateImage,
                                  color: Colors.white,
                                  // color: MyAppColors.color2,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      widget.onImageSelected(File(pickedFile.path));
    }
  }

  void _showImageOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Change Image',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: MyAppColors.color2,
                  ),
                ),
                SizedBox(height: 16),
                _buildOptionButton(
                  context,
                  Icons.photo_camera,
                  'Camera',
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                SizedBox(height: 8),
                _buildOptionButton(
                  context,
                  Icons.photo_library,
                  'Gallery',
                  () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                SizedBox(height: 8),
                _buildOptionButton(
                  context,
                  Icons.auto_awesome,
                  'Generate',
                  () {
                    Navigator.pop(context);
                    widget.onGenerateImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(
              color: MyAppColors.color2.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(
                icon,
                color: MyAppColors.color2,
                size: 24,
              ),
              SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

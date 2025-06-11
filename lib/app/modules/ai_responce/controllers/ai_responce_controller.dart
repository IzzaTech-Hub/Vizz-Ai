import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_pptx/flutter_pptx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/model_classes/comparison.dart';
import 'package:napkin/app/data/model_classes/graph_class.dart';
import 'package:napkin/app/data/model_classes/hierarchy.dart';
import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/model_classes/sbs.dart';
import 'package:napkin/app/data/model_classes/slideData.dart';
import 'package:napkin/app/data/model_classes/slidePart.dart';
import 'package:napkin/app/data/models/presentation_outline.dart';
import 'package:napkin/app/data/models/slide_content_new.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/services/ads/admob_ads_prvider.dart';
import 'package:napkin/app/services/rate_us_service.dart';
import 'package:napkin/app/widgets/touch_guide_animation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:napkin/app/data/gemini_ai/ai_schema.dart';
import 'package:napkin/app/data/gemini_prompts.dart';
import 'package:napkin/app/data/rc_variables.dart';
import 'package:napkin/app/services/gemini_image_service.dart';

class AiResponceController extends GetxController {
  String mainTitle = "";
  RxBool isEditable = false.obs;
  Rx<SlideData> slideData =
      SlideData(mainTitle: '', slidePart: <Rx<SlidePart>>[].obs).obs;
  // List<Widget> slides = [];
  var isAllowBackButton = true.obs;

  List<String> typesList = [];
  final count = 0.obs;
  final isLoading = true.obs;
  final Rx<PresentationContent?> presentationContent =
      Rx<PresentationContent?>(null);
  final RxMap<int, File> selectedImages = RxMap<int, File>();
  final RxMap<int, bool> imageGenerating = RxMap<int, bool>();

  @override
  void onInit() async {
    super.onInit();
    // allcontentString = Get.arguments[0];
    if (Get.arguments != null) {
      generateDetailedContent(Get.arguments as PresentationOutline);
    }
  }

  void showGuideDialog() {
    Get.dialog(Dialog(
      backgroundColor: Colors.black54,
      surfaceTintColor: Colors.black54,
      child: TouchToSplitBox(),
    ));
  }

  Future<String> generatePPTX(BuildContext context, {String? mainTitle}) async {
    var slideHeight = SizeConfig.screenWidth * 9 / 16;
    var slideWidth = SizeConfig.screenWidth;
    try {
      if (presentationContent.value == null) {
        throw Exception("No presentation content available.");
      }

      final pres = FlutterPowerPoint();

      // Title slide
      List<Widget> slides = [
        Container(
          height: slideHeight,
          width: slideWidth,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
          ),
          child: Center(
            child: Text(
              presentationContent.value!.title,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.red[900],
                  fontWeight: FontWeight.w900),
            ),
          ),
        ),
      ];

      // Content slides
      for (int i = 1; i < presentationContent.value!.slides.length; i++) {
        final slide = presentationContent.value!.slides[i];
        final hasImage =
            selectedImages[i] != null && selectedImages[i]!.existsSync();

        slides.add(
          Container(
            height: slideHeight,
            width: slideWidth,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
            ),
            padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  slide.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[900],
                  ),
                ),
                SizedBox(height: 12),
                // Paragraphs with markdown
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Text content
                      Expanded(
                        flex: hasImage ? 7 : 10,
                        child: MarkdownBody(
                          data: slide.paragraphs.join('\n\n'),
                          styleSheet: MarkdownStyleSheet(
                            p: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                            strong: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900],
                            ),
                            em: TextStyle(
                              fontSize: 10,
                              fontStyle: FontStyle.italic,
                              color: Colors.purple[900],
                            ),
                            h1: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.red[900],
                            ),
                            h2: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                            listBullet: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                            listIndent: 16.0,
                          ),
                        ),
                      ),
                      // Image if available
                      if (hasImage) ...[
                        SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(selectedImages[i]!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Add all slides to the presentation
      for (Widget slide in slides) {
        await pres.addWidgetSlide((size) => slide,
            pixelRatio: 6.0, context: context);
      }

      final bytes = await pres.save();
      if (bytes == null || bytes.isEmpty) {
        throw Exception("Failed to generate PowerPoint content.");
      }

      Directory appDocDir = await getApplicationDocumentsDirectory();

      // Sanitize the title
      String safeTitle = (presentationContent.value!.title.trim().isNotEmpty)
          ? presentationContent.value!.title
              .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
              .replaceAll(RegExp(r'\.+'), '.')
          : 'presentation';

      if (!safeTitle.endsWith('.pptx')) {
        safeTitle = '$safeTitle.pptx';
      }

      String filePath = '${appDocDir.path}/$safeTitle';
      final file = File(filePath);

      await file.writeAsBytes(bytes, flush: true);

      print('PPT generated at: $filePath');
      Get.snackbar("File Saved", "Slide has been saved as $safeTitle");

      return filePath;
    } catch (e) {
      print('Error generating PPTX: $e');
      Get.snackbar("Error", "Failed to save the PowerPoint file: $e");
      return '';
    }
  }

  Future<bool> isBackAllowed() async {
    return isAllowBackButton.value;
  }

  void shareFile(String filePath) async {
    try {
      print('start sharing');
      final params = ShareParams(
        text: 'Great picture',
        files: [XFile(filePath)],
      );

      final result = await SharePlus.instance.share(params);

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing the picture!');
      }
    } catch (e) {
      print(e);
    }
  }

  void showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text("Loading...", style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        );
      },
    );
  }

  void setGraph(int index, Map<String, dynamic> jsonData, String type) {
    HierarchyModel? hierarchy;
    KeyPoints? keyPoints;
    GraphModel? graph;
    ComparisonModel? comparison;
    StepByStepModel? sbs;
    String? heading;
    switch (type) {
      case 'hierarchy':
        print('parsing by heirarchy');
        hierarchy = HierarchyModel.fromJson(jsonData);
        heading = hierarchy!.heading;
        slideData.value.slidePart[index].value.hierarchy = hierarchy;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        // Do something with the model
        break;

      case 'key_points':
        print('parsing by kp');
        keyPoints = KeyPoints.fromJson(jsonData);
        heading = keyPoints!.heading;
        slideData.value.slidePart[index].value.keyPoints = keyPoints;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        // Do something with the model
        break;

      case 'graph':
        print('parsing by graph');
        graph = GraphModel.fromJson(jsonData);
        heading = graph!.heading;
        slideData.value.slidePart[index].value.graph = graph;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        // Do something with the model
        break;

      case 'comparison':
      case 'comparison/differentiate':
        print('parsing by diff');
        comparison = ComparisonModel.fromJson(jsonData);
        heading = comparison!.heading;
        slideData.value.slidePart[index].value.comparison = comparison;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        // Do something with the model
        break;

      case 'step_by_step':
        sbs = StepByStepModel.fromJson(jsonData);
        print('parsing by sbs');
        // Do something with the model
        heading = sbs!.heading;
        slideData.value.slidePart[index].value.sbs = sbs;
        slideData.value.slidePart[index].value.heading = heading;
        slideData.value.slidePart[index].value.isShowGraph.value = true;
        break;

      default:
        // Handle unknown or unsupported type
        print('Unsupported type: $type');
        break;
    }
    print(
        "is show graph : ${slideData.value.slidePart[index].value.isShowGraph.value}");
  }

  void parseParagraphs(String jsonString) {
    try {
      // Decode JSON string
      // Map<String, dynamic> decodedJson = jsonDecode(jsonString);
      slideData.value = SlideData.fromMap(jsonDecode(jsonString));
      print("slideData: ${slideData.value.toMap()}");

      // Clear previous data
      // slideContentList.clear();
      // typesList.clear();

      // // Extract paragraphs if they exist and are a list
      // if (decodedJson.containsKey("slidePart") &&
      //     decodedJson["slidePart"] is List) {
      //   mainTitle = decodedJson["mainTitle"] ??
      //       ""; // Default to empty string if missing
      //   print("mainTitle: $mainTitle");
      //   for (var item in decodedJson["slidePart"]) {
      //     // Extract and assign values
      //     String type = item["type"] ?? "none"; // Default to 'none' if missing

      //     String slideContent =
      //         item["slideContent"] ?? ""; // Default to empty string if missing

      //     // Add to respective lists
      //     typesList.add(type);
      //     slideContentList.add(slideContent);
      //   }
      // }
    } catch (e) {
      print("Error parsing JSON: $e");
      // Ensure lists reset on failure
      // slideContentList = [];
      // typesList = [];
    }
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  void handleImageSelected(int slideIndex, File image) {
    selectedImages[slideIndex] = image;
  }

  Future<void> generateImage(int slideIndex) async {
    bool isAdShown = await Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(FontAwesomeIcons.gift, color: Colors.orange), // Ad icon
            SizedBox(width: 10),
            Text("Generate Image"),
          ],
        ),
        // content: Text("To generate the image, you'll watch a short reward ad."),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(result: false);
              // return false;
            }, // Close dialog
            child: Text("Cancel", style: TextStyle(color: Colors.black)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Get.back(result: true); // Close dialog before showing ad

              AdMobAdsProvider.instance.ShowRewardedAd(() {
                // Your logic after ad is completed
                print("Ad finished. Proceed with image generation.");
              });
            },
            icon: Icon(Icons.play_circle_fill),
            label: Text(
              "Generate",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    if (!isAdShown) return;
    // Get.dialog(Column(
    //   children: [
    //     Text("Generat Image"),
    //   ]
    // ));
    // AdMobAdsProvider.instance.showRewardedInterGame(() {});
    try {
      if (presentationContent.value == null) return;

      final slide = presentationContent.value!.slides[slideIndex];
      if (slide.imagePrompt == null) {
        Get.snackbar(
          'Error',
          'No image prompt available for this slide',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      imageGenerating[slideIndex] = true;

      // Remove existing image for this slide if any
      if (selectedImages.containsKey(slideIndex)) {
        final existingFile = selectedImages[slideIndex];
        if (existingFile != null && await existingFile.exists()) {
          await existingFile.delete();
        }
        selectedImages.remove(slideIndex);
      }

      final geminiImageService = GeminiImageService();
      geminiImageService.initilize(RcVariables.apikey);

      final response = await geminiImageService.generateGeminiImage(
        prompt: slide.imagePrompt!,
      );

      if (!response.success) {
        throw response.error ?? 'Failed to generate image';
      }

      if (response.imageBytes == null) {
        throw 'No image data received';
      }

      // Create a temporary file to store the image
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
          '${tempDir.path}/slide_${slideIndex}_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(response.imageBytes!);

      // Update the selected image
      selectedImages[slideIndex] = tempFile;

      Get.snackbar(
        'Success',
        'Image generated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error generating image: $e');
      Get.snackbar(
        'Error',
        'Failed to generate image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      imageGenerating[slideIndex] = false;
    }
  }

  Future<void> generateDetailedContent(PresentationOutline outline) async {
    try {
      isLoading.value = true;

      // Clear existing images and generation states
      selectedImages.clear();
      imageGenerating.clear();

      // Convert outline to JSON string for the prompt
      final outlineJson = jsonEncode(outline.toJson());

      // Initialize Gemini model
      final model = GenerativeModel(
        model: RcVariables.geminiAiModel,
        apiKey: RcVariables.apikey,
        generationConfig: GenerationConfig(
          temperature: 0.9,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 2048,
          responseMimeType: 'application/json',
          responseSchema: AiSchema.presentationContentSchema,
        ),
      );

      // Generate detailed content
      final prompt = GeminiPrompts.generateDetailedContentPrompt(outlineJson);
      final response = await model.generateContent([Content.text(prompt)]);

      if (response.text == null) {
        throw 'No response received from AI';
      }

      // Clean and parse the response
      String cleanJson = response.text!.trim();
      cleanJson = cleanJson.replaceAll('```json', '').replaceAll('```', '');

      final Map<String, dynamic> jsonResponse = jsonDecode(cleanJson);
      final content = PresentationContent.fromJson(jsonResponse);

      presentationContent.value = content;
    } catch (e) {
      print('Error generating detailed content: $e');
      Get.snackbar(
        'Error',
        'Failed to generate detailed content: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}

class EditableMarkdown extends StatefulWidget {
  final int index;

  const EditableMarkdown({
    Key? key,
    required this.index,
  }) : super(key: key);

  @override
  _EditableMarkdownState createState() => _EditableMarkdownState();
}

class _EditableMarkdownState extends State<EditableMarkdown> {
  late AiResponceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AiResponceController>();
  }

  void _editText(String original, String tag) async {
    TextEditingController textController =
        TextEditingController(text: original);

    await Get.dialog(
      AlertDialog(
        title: Text('Edit $tag'),
        content: TextField(
          controller: textController,
          maxLines: null,
          decoration: const InputDecoration(hintText: 'Enter new text'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final updatedText = textController.text;
              if (updatedText.trim().isNotEmpty) {
                final currentContent = controller
                    .slideData.value.slidePart[widget.index].value.slideContent;
                final newContent =
                    currentContent.replaceFirst(original, updatedText);

                controller.slideData.update((val) {
                  val?.slidePart[widget.index].value.slideContent = newContent;
                });
              }
              Get.back();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stylesheet = MarkdownStyleSheet(
      p: const TextStyle(fontSize: 10.58, color: Color(0xFF333333)),
      strong: const TextStyle(
          fontSize: 10.08, fontWeight: FontWeight.bold, color: Colors.blue),
      em: const TextStyle(
          fontSize: 10.08, fontStyle: FontStyle.italic, color: Colors.black),
      a: const TextStyle(
          fontSize: 8.06,
          color: Color(0xFF007AFF),
          decoration: TextDecoration.underline),
      code: const TextStyle(
        fontSize: 8.06,
        fontFamily: 'monospace',
        fontStyle: FontStyle.italic,
        backgroundColor: Color.fromARGB(255, 255, 242, 217),
        color: Color.fromARGB(255, 255, 95, 95),
      ),
      h1: TextStyle(
          fontSize: 14.11, fontWeight: FontWeight.w900, color: Colors.red[900]),
      h2: TextStyle(
          fontSize: 13.10,
          fontWeight: FontWeight.bold,
          color: Colors.purple[600]),
      h3: const TextStyle(
          fontSize: 12.10, fontWeight: FontWeight.bold, color: Colors.red),
      blockquoteDecoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(left: BorderSide(color: Color(0xFFCCCCCC), width: 4)),
      ),
      listBullet: const TextStyle(fontSize: 10.08, color: Colors.black),
      tableHead: const TextStyle(
          fontSize: 11.09,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333)),
      tableBody: const TextStyle(fontSize: 8.06, color: Color(0xFF333333)),
      listBulletPadding: EdgeInsets.zero,
      listIndent: 32,
      tableCellsPadding: const EdgeInsets.all(4.2),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xff23241f),
        borderRadius: BorderRadius.circular(6.72),
      ),
    );

    final builderMap = {
      'p': _InteractiveBuilder(tag: 'p', onTap: _editText),
      'em': _InteractiveBuilder(tag: 'em', onTap: _editText),
      'code': _InteractiveBuilder(tag: 'code', onTap: _editText),
      'h1': _InteractiveBuilder(tag: 'h1', onTap: _editText),
      'h2': _InteractiveBuilder(tag: 'h2', onTap: _editText),
      'h3': _InteractiveBuilder(tag: 'h3', onTap: _editText),
      'a': _InteractiveBuilder(tag: 'a', onTap: _editText),
      'li': _InteractiveBuilder(tag: 'li', onTap: _editText),
      'strong': _InteractiveBuilder(tag: 'strong', onTap: _editText),
    };

    final markdownData =
        controller.slideData.value.slidePart[widget.index].value.slideContent;

    return MarkdownBody(
      data: markdownData,
      selectable: true,
      styleSheet: stylesheet,
      builders: builderMap,
    );
  }
}

class _InteractiveBuilder extends MarkdownElementBuilder {
  final String tag;
  final void Function(String original, String tag) onTap;

  _InteractiveBuilder({
    required this.tag,
    required this.onTap,
  });

  @override
  Widget visitText(md.Text text, TextStyle? preferredStyle) {
    final styleSheet = MarkdownStyleSheet(
      p: const TextStyle(fontSize: 10.58, color: Color(0xFF333333)),
      strong: const TextStyle(
          fontSize: 10.08, fontWeight: FontWeight.bold, color: Colors.blue),
      em: const TextStyle(
          fontSize: 10.08, fontStyle: FontStyle.italic, color: Colors.black),
      a: const TextStyle(
          fontSize: 8.06,
          color: Color(0xFF007AFF),
          decoration: TextDecoration.underline),
      code: const TextStyle(
        fontSize: 8.06,
        fontFamily: 'monospace',
        fontStyle: FontStyle.italic,
        backgroundColor: Color(0xFFFFF2D9),
        color: Color(0xFFFF5F5F),
      ),
      h1: TextStyle(
          fontSize: 14.11, fontWeight: FontWeight.w900, color: Colors.red[900]),
      h2: TextStyle(
          fontSize: 13.10,
          fontWeight: FontWeight.bold,
          color: Colors.purple[600]),
      h3: const TextStyle(
          fontSize: 12.10, fontWeight: FontWeight.bold, color: Colors.red),
      listBullet: const TextStyle(fontSize: 10.08, color: Colors.black),
      tableHead: const TextStyle(
          fontSize: 11.09,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333)),
      tableBody: const TextStyle(fontSize: 8.06, color: Color(0xFF333333)),
      tableCellsPadding: const EdgeInsets.all(4.2),
      codeblockDecoration: BoxDecoration(
        color: const Color(0xff23241f),
        borderRadius: BorderRadius.circular(6.72),
      ),
      blockquoteDecoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(left: BorderSide(color: Color(0xFFCCCCCC), width: 4)),
      ),
    );
    TextStyle getStyleByTag() {
      switch (tag) {
        case 'p':
          return styleSheet.p!;
        case 'strong':
          return styleSheet.strong!;
        case 'em':
          return styleSheet.em!;
        case 'code':
          return styleSheet.code!;
        case 'a':
          return styleSheet.a!;
        case 'h1':
          return styleSheet.h1!;
        case 'h2':
          return styleSheet.h2!;
        case 'h3':
          return styleSheet.h3!;
        case 'li':
          // You can use styleSheet.p or create a custom style for list items
          return styleSheet.p!;
        case 'th':
          return styleSheet.tableHead!;
        case 'td':
          return styleSheet.tableBody!;
        default:
          return const TextStyle(); // fallback
      }
    }

    return GestureDetector(
      onTap: () => onTap(text.text, tag),
      child:
          //  MyMarkDownBuilder().getit(text.text)
          Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey, // You can change this color
            width: 1,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          text.text,
          style: getStyleByTag(),
        ),
      ),
    );
  }
}

class simpleMarkDown extends StatelessWidget {
  int index;
  simpleMarkDown({required this.index, super.key});

  @override
  Widget build(BuildContext context) {
    AiResponceController controller = Get.find();

    String markdownData =
        controller.slideData.value.slidePart[index].value.slideContent;
    final stylesheet = MarkdownStyleSheet(
      p: const TextStyle(
        fontSize: 10.58, // Increased by 20%
        color: Color(0xFF333333),
      ),
      strong: const TextStyle(
        fontSize: 10.08, // Increased by 20%
        fontWeight: FontWeight.bold,
        color: Colors.blue,
      ),
      em: const TextStyle(
        fontSize: 10.08, // Increased by 20%
        fontStyle: FontStyle.italic,
        color: Colors.black,
      ),
      a: const TextStyle(
        fontSize: 8.06, // Increased by 20%
        color: Color(0xFF007AFF),
        decoration: TextDecoration.underline,
      ),
      code: const TextStyle(
        fontSize: 8.06, // Increased by 20%
        fontFamily: 'monospace',
        fontStyle: FontStyle.italic,
        backgroundColor: Color.fromARGB(255, 255, 242, 217),
        color: Color.fromARGB(255, 255, 95, 95),
      ),
      h1: TextStyle(
        fontSize: 14.11, // Increased by 20%
        fontWeight: FontWeight.w900,
        color: Colors.red[900],
      ),
      h2: TextStyle(
        fontSize: 13.10, // Increased by 20%
        fontWeight: FontWeight.bold,
        color: Colors.purple[600],
      ),
      h3: const TextStyle(
        fontSize: 12.10, // Increased by 20%
        fontWeight: FontWeight.bold,
        color: Colors.red,
      ),
      blockquoteDecoration: const BoxDecoration(
        color: Color(0xFFF5F5F5),
        border: Border(
          left: BorderSide(
            color: Color(0xFFCCCCCC),
            width: 4,
          ),
        ),
      ),
      listBullet: const TextStyle(
        fontSize: 10.08, // Increased by 20%
        color: Colors.black,
      ),
      tableHead: const TextStyle(
        fontSize: 11.09, // Increased by 20%
        fontWeight: FontWeight.bold,
        color: Color(0xFF333333),
      ),
      tableBody: const TextStyle(
        fontSize: 8.06, // Increased by 20%
        color: Color(0xFF333333),
      ),
      listBulletPadding: EdgeInsets.all(0),
      listIndent: 32,

      tableCellsPadding: const EdgeInsets.all(4.2), // Increased by 20%
      codeblockDecoration: BoxDecoration(
        color: const Color(0xff23241f),
        borderRadius: BorderRadius.circular(6.72), // Increased by 20%
      ),
    );

    return MarkdownBody(
      data: markdownData,
      selectable: true,
      styleSheet: stylesheet,
    );
  }
}

class GetSlideView extends StatelessWidget {
  int index;
  double slideHeight;
  double slideWidth;

  GetSlideView(
      {super.key,
      required this.index,
      required this.slideHeight,
      required this.slideWidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: slideHeight,
      width: slideWidth,
      decoration: BoxDecoration(
        color: Colors.red.shade50, // Red background
        // borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
      child: simpleMarkDown(index: index),
    );
  }
}

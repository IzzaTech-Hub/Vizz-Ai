import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_pptx/flutter_pptx.dart';
import 'package:get/get.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/model_classes/comparison.dart';
import 'package:napkin/app/data/model_classes/graph_class.dart';
import 'package:napkin/app/data/model_classes/hierarchy.dart';
import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/model_classes/sbs.dart';
import 'package:napkin/app/data/model_classes/slideData.dart';
import 'package:napkin/app/data/model_classes/slidePart.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/services/rate_us_service.dart';
import 'package:napkin/app/widgets/touch_guide_animation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:markdown/markdown.dart' as md;
// import 'package:markdown/markdown.dart';

// import 'package:google_generative_ai/google_generative_ai.dart';

class AiResponceController extends GetxController {
  String mainTitle = "";
  RxBool isEditable = false.obs;
  Rx<SlideData> slideData =
      SlideData(mainTitle: '', slidePart: <Rx<SlidePart>>[].obs).obs;
  // List<Widget> slides = [];
  var isAllowBackButton = true.obs;

  List<String> typesList = [];
  final count = 0.obs;
  @override
  void onInit() async {
    super.onInit();
    // allcontentString = Get.arguments[0];
    slideData.value =
        SlideData.fromMap(Get.arguments[0] as Map<String, dynamic>);
  }

  void showGuideDialog() {
    Get.dialog(Dialog(
      backgroundColor: Colors.black54,
      surfaceTintColor: Colors.black54,
      child: TouchToSplitBox(),
    ));
  }

  Future<String> generatePPTX(BuildContext context, {String? mainTitle}) async {
    // var slideHeight = 1080.0;
    // var slideWidth = 1920.0;
    var slideHeight = SizeConfig.screenWidth * 9 / 16;
    var slideWidth = SizeConfig.screenWidth;
    try {
      final pres = FlutterPowerPoint();
      List<Widget> slides = [
        Container(
          height: slideHeight,
          width: slideWidth,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
          ),
          child: Center(
              child: Text(
            slideData.value.mainTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                color: Colors.red[900],
                fontWeight: FontWeight.w900),
          )),
        ),
      ];

      for (int i = 0; i < slideData.value.slidePart.length; i++) {
        slides.add(
          GetSlideView(
            index: i,
            slideHeight: slideHeight,
            slideWidth: slideWidth,
          ),
        );
      }
      for (Widget slide in slides) {
        await pres.addWidgetSlide((size) => slide,
            pixelRatio: 6.0, context: context);
      }

      final bytes = await pres.save();
      if (bytes == null || bytes.isEmpty) {
        throw Exception("Failed to generate PowerPoint content.");
      }

      Directory appDocDir = await getApplicationDocumentsDirectory();

      /// Sanitize the title to prevent double dots and invalid characters.
      String safeTitle = (slideData.value.mainTitle?.trim().isNotEmpty ?? false)
          ? slideData.value.mainTitle!
              .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
              .replaceAll(RegExp(r'\.+'), '.')
          : 'presentation';

      /// Ensure the filename ends with `.pptx`
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
      Get.snackbar("Error", "Failed to save the PowerPoint file.");
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

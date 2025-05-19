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
import 'package:napkin/app/widgets/touch_guide_animation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:markdown/markdown.dart' as md;
// import 'package:markdown/markdown.dart';

// import 'package:google_generative_ai/google_generative_ai.dart';

class AiResponceController extends GetxController {
  //TODO: Implement AiResponceController
  // Map<String,dynamic>? allcontentString;
  // List<String>? contentList;
  // List<String> slideContentList = <String>[];
  String mainTitle = "";
  Rx<SlideData> slideData =
      SlideData(mainTitle: '', slidePart: <Rx<SlidePart>>[].obs).obs;
  List<Widget> slides = [];
  var isAllowBackButton = true.obs;

  List<String> typesList = [];
  final count = 0.obs;
  @override
  void onInit() async {
    super.onInit();
    // allcontentString = Get.arguments[0];
    slideData.value =
        SlideData.fromMap(Get.arguments[0] as Map<String, dynamic>);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   showGuideDialog();
    // });
    // showGuideDialog();
    // parseParagraphs(allcontentString!);
  }

  void showGuideDialog() {
    Get.dialog(Dialog(
      backgroundColor: Colors.black54,
      surfaceTintColor: Colors.black54,
      child: TouchToSplitBox(),
    ));
  }

  Future<String> generatePPTX(BuildContext context, {String? mainTitle}) async {
    try {
      final pres = FlutterPowerPoint();

      for (Widget slide in slides) {
        await pres.addWidgetSlide((size) => slide,
            pixelRatio: 6.0, context: context);
        // await pres.addWidgetSlide(
        //   (size) => Center(
        //     child: AspectRatio(
        //       aspectRatio: 16 / 9,
        //       child: slide,
        //     ),
        //   ),
        //   pixelRatio: 6.0,
        //   context: context,
        // );
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
    final params = ShareParams(
      text: 'Great picture',
      files: [XFile(filePath)],
    );

    final result = await SharePlus.instance.share(params);

    if (result.status == ShareResultStatus.success) {
      print('Thank you for sharing the picture!');
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

// import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:get/get.dart';

class EditableMarkdown extends StatefulWidget {
  final String content;
  final void Function(String updatedContent) onUpdate;

  const EditableMarkdown({
    Key? key,
    required this.content,
    required this.onUpdate,
  }) : super(key: key);

  @override
  _EditableMarkdownState createState() => _EditableMarkdownState();
}

class _EditableMarkdownState extends State<EditableMarkdown> {
  late String markdownData;

  @override
  void initState() {
    super.initState();
    markdownData = widget.content;
  }

  void _editText(String original, String tag) async {
    TextEditingController controller = TextEditingController(text: original);

    await Get.dialog(
      AlertDialog(
        title: Text('Edit $tag'),
        content: TextField(
          controller: controller,
          maxLines: null,
          decoration: InputDecoration(hintText: 'Enter new text'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Replace only the first occurrence
              setState(() {
                markdownData =
                    markdownData.replaceFirst(original, controller.text);
              });
              widget.onUpdate(markdownData);
              Get.back();
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: markdownData,
      selectable: true,
      styleSheet: MarkdownStyleSheet(
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
        // listBullet: const TextStyle(
        //   fontSize: 10.08, // Increased by 20%
        //   color: Colors.black,
        // ),
        tableHead: const TextStyle(
          fontSize: 11.09, // Increased by 20%
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
        tableBody: const TextStyle(
          fontSize: 8.06, // Increased by 20%
          color: Color(0xFF333333),
        ),
        tableCellsPadding: const EdgeInsets.all(4.2), // Increased by 20%
        codeblockDecoration: BoxDecoration(
          color: const Color(0xff23241f),
          borderRadius: BorderRadius.circular(6.72), // Increased by 20%
        ),
      ),
      builders: {
        // 'p': _InteractiveBuilder(tag: 'p', onTap: _editText),

        // 'em': _InteractiveBuilder(tag: 'em', onTap: _editText),
        // 'code': _InteractiveBuilder(tag: 'code', onTap: _editText),
        // 'h1': _InteractiveBuilder(tag: 'h1', onTap: _editText),
        // 'h2': _InteractiveBuilder(tag: 'h2', onTap: _editText),
        // 'h3': _InteractiveBuilder(tag: 'h3', onTap: _editText),
        // 'a': _InteractiveBuilder(tag: 'a', onTap: _editText),
        // 'li': _InteractiveBuilder(tag: 'li', onTap: _editText),
        // 'strong': _InteractiveBuilder(tag: 'strong', onTap: _editText),
        // 'li': _BulletListBuilder(),
        // 'strong': _InteractiveBuilder(
      },
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
  Widget visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final mystyleSheet = MarkdownStyleSheet(
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

    return GestureDetector(
      onTap: () => onTap(element.textContent, tag),
      child: Text(
        element.textContent,
        style: preferredStyle ?? const TextStyle(),
      ),
    );
  }
}

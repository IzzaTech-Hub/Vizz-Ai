import 'dart:convert';
// import 'dart:math';
// import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/gemini_ai/ai_prompt.dart';
import 'package:napkin/app/data/gemini_ai/ai_schema.dart';
// import 'package:napkin/app/data/graph_handler.dart';
// import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/rc_variables.dart';
import 'package:napkin/app/routes/app_pages.dart';
import 'package:napkin/app/services/feedback_service.dart';
// import 'package:napkin/app/data/size_config.dart';

import '../controllers/ai_responce_controller.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:flutter/material.dart';
// import 'dart:';

class AiResponceView extends GetView<AiResponceController> {
  const AiResponceView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('VIZZ AI'),
        //   centerTitle: true,
        // ),
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.redAccent.shade700,
                    Colors.redAccent.shade400,
                    // Colors.red
                  ], // your gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            leading: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new_outlined,
                  color: Colors.white,
                )),
            title: const Text(
              'VIZZ AI',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0, // optional, for a flat look
            actions: [
              IconButton(
                  onPressed: () {
                    FeedbackService().showFeedbackDialog(
                        context, controller.allcontentString!);
                  },
                  icon: Icon(
                    Icons.flag,
                    color: Colors.white,
                  )),
              // IconButton(
              //     onPressed: () {},
              //     icon: Icon(
              //       Icons.refresh,
              //       color: Colors.white,
              //     )),
              SizedBox(
                width: 16,
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < controller.paragraphsList.length; i++)
                ParagraphContentView(
                  data: controller.paragraphsList[i],
                  type: controller.typesList[i],
                )
            ],
          ),
        ));
  }

  // Widget _theoryTypePageContent(String data) {
  //   // String paragraphMarkup = page.theoryTypePageContent!;
  //   return
  // }
}

class ParagraphContentView extends StatelessWidget {
  String data;
  String type;
  // RxBool generated = false.obs;
  // KeyPoints? keyPoints;
  // String genContent = '';
  ParagraphContentView({super.key, required this.data, required this.type});
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

// Hide the loading dialog
  void hideLoading(BuildContext context) {
    Navigator.pop(context);
  }

  Future<String> generateKeyWords() async {
    String sysinstructionprompt = AiPrompt().getSystemInstructions(type);
    // Each paragraph should contain only on one type.
    print(sysinstructionprompt);
    final model = GenerativeModel(
      model: RcVariables.geminiAiModel,
      // model: 'gemini-2.0-flash-lite',
      // model: 'gemini-1.5-pro',
      // model: 'gemini-1.5-flash-8b',
      // model: 'gemini-1.5-flash',
      // apiKey: 'AIzaSyCj-pkjlMrppk-ZNsPlkFq5U9t9jeUahr8',
      apiKey: RcVariables.apikey,
      generationConfig: GenerationConfig(
          temperature: 1,
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 8192,
          responseMimeType: 'application/json',
          responseSchema: AiSchema().getJsonSchema(type)),
      systemInstruction: Content.system(sysinstructionprompt),
    );

    final content = [
      // Content.multi([TextPart("Generate json")]),
      Content.text(
          // "Make The course content devided into 4 or more stages. each stage contains 2 to 5 chapter and each chapter covers 3 to 6 subtopics."
          data),
    ];

    try {
      final response = await model.generateContent(content);
      // print(response);
      // myresponce.value = response.text!;
      // keyPoints = KeyPoints.fromJson(response.text!);
      print('Respons: ${response.text}');
      return response.text!;
      // print('Respons: ${myresponce.value}');
    } catch (e) {
      print('failed');
      print(e.toString());
      // hasError.value = true;
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8),
      child: Stack(
        children: [
          // const Divider(),
          // Text(type),
          // const Divider(),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50, // Red background
                  // borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(
                      color: Colors.redAccent.shade400, // Dark red left border
                      width: 10, // Thick border
                    ),
                  ),
                ),
              ),
            ),
          ),

          InkWell(
            onTap: () async {
              showLoading(context);
              String pt = await generateKeyWords();
              hideLoading(context);
              Map<String, dynamic> ptt = jsonDecode(pt);
              // print('pt $ptt');

              // Get.toNamed(Routes.SHOW_GRAPH, arguments: [ptt]);
              Get.toNamed(Routes.SHOW_GRAPH, arguments: [type, ptt]);
              // Get.toNamed(Routes.SHOW_GRAPH, arguments: [keyPoints!]);
              // generated.value = true;
            },
            child: Container(
              padding: EdgeInsets.fromLTRB(32, 4, 4, 4),
              // decoration: BoxDecoration(border: Border.all()),
              child: MarkdownBody(
                data: data,
                // data: '$type\n$data',
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(
                      fontSize: 16, color: Color(0xFF333333)), // Dark gray text
                  strong: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue), // Bold text
                  em: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black), // Italic text
                  a: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF007AFF),
                      decoration:
                          TextDecoration.underline), // Link color (Blue)
                  code: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'monospace',
                      fontStyle: FontStyle.italic,
                      backgroundColor: Color.fromARGB(255, 255, 242, 217),
                      color: Color.fromARGB(255, 255, 95, 95)), // Code block
                  h1: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[900]), // H1
                  h2: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[600]), // H2
                  h3: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red), // H3
                  blockquoteDecoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    border: Border(
                        left: BorderSide(color: Color(0xFFCCCCCC), width: 4)),
                  ),
                  listBullet:
                      const TextStyle(fontSize: 16, color: Colors.black),
                  codeblockDecoration: BoxDecoration(
                    color: const Color(0xff23241f),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      //  Column(
      //   children: [
      //     // const Divider(),
      //     // Text(type),
      //     // const Divider(),
      //     InkWell(
      //       onTap: () async {
      //         showLoading(context);
      //         await generateKeyWords();
      //         hideLoading(context);
      //         Get.toNamed(Routes.SHOW_GRAPH, arguments: [keyPoints!]);
      //         // generated.value = true;
      //       },
      //       child: Row(
      //         crossAxisAlignment: CrossAxisAlignment.center,
      //         mainAxisAlignment: MainAxisAlignment.start,
      //         children: [
      //           // const Icon(Icons.abc),
      //           Container(
      //             // decoration: BoxDecoration(border: Border.all()),
      //             child: Flexible(
      //               // width: SizeConfig.screenWidth * 0.5,
      //               child: MarkdownBody(
      //                 data: data,
      //                 styleSheet: MarkdownStyleSheet(
      //                   p: const TextStyle(
      //                       fontSize: 16,
      //                       color: Color(0xFF333333)), // Dark gray text
      //                   strong: const TextStyle(
      //                       fontSize: 16,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.blue), // Bold text
      //                   em: const TextStyle(
      //                       fontSize: 16,
      //                       fontStyle: FontStyle.italic,
      //                       color: Colors.black), // Italic text
      //                   a: const TextStyle(
      //                       fontSize: 14,
      //                       color: Color(0xFF007AFF),
      //                       decoration:
      //                           TextDecoration.underline), // Link color (Blue)
      //                   code: const TextStyle(
      //                       fontSize: 14,
      //                       fontFamily: 'monospace',
      //                       fontStyle: FontStyle.italic,
      //                       backgroundColor: Color.fromARGB(255, 255, 242, 217),
      //                       color:
      //                           Color.fromARGB(255, 255, 95, 95)), // Code block
      //                   h1: TextStyle(
      //                       fontSize: 24,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.red[900]), // H1
      //                   h2: TextStyle(
      //                       fontSize: 20,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.purple[600]), // H2
      //                   h3: const TextStyle(
      //                       fontSize: 18,
      //                       fontWeight: FontWeight.bold,
      //                       color: Colors.red), // H3
      //                   blockquoteDecoration: const BoxDecoration(
      //                     color: Color(0xFFF5F5F5),
      //                     border: Border(
      //                         left: BorderSide(
      //                             color: Color(0xFFCCCCCC), width: 4)),
      //                   ), // Blockquote
      //                   listBullet: const TextStyle(
      //                       fontSize: 16, color: Colors.black), // List bullets
      //                   codeblockDecoration: BoxDecoration(
      //                     color: const Color(0xff23241f),
      //                     borderRadius: BorderRadius.circular(8),
      //                   ),
      //                 ),
      //                 // builders: {
      //                 //   'pre': CodeElementBuilder(context: context),
      //                 // },
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //     // // Flexible(child: Container()),
      //     // Obx(() => generated.value
      //     //     ? Container(
      //     //         child: Column(children: [
      //     //           GraphHandler().getGraph(keyPoints!),
      //     //         ]
      //     //             ),
      //     //       )
      //     //     : Container()),
      //   ],
      // ),
    );
  }
}

import 'dart:convert';
// import 'dart:math';
// import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:napkin/app/data/gemini_ai/ai_prompt.dart';
import 'package:napkin/app/data/gemini_ai/ai_schema.dart';
import 'package:napkin/app/data/model_classes/slideData.dart';
import 'package:napkin/app/data/model_classes/slidePart.dart';
// import 'package:napkin/app/data/graph_handler.dart';
// import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/rc_variables.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/data/view_handler/view_handler.dart';
import 'package:napkin/app/modules/home/controllers/home_controller.dart';
import 'package:napkin/app/routes/app_pages.dart';
import 'package:napkin/app/services/feedback_service.dart';
import 'package:napkin/app/services/rate_us_service.dart';
import 'package:napkin/app/widgets/start_feedback_widget.dart';
import 'package:napkin/app/widgets/touch_guide_animation.dart';
// import 'package:napkin/app/data/size_config.dart';

import '../controllers/ai_responce_controller.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:flutter/material.dart';
// import 'dart:';

class AiResponceView extends GetView<AiResponceController> {
  const AiResponceView({super.key});
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(Duration(milliseconds: 1000));
      RateUsService.rateus();
    });
    void showLoading(String massage) {
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text(massage, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          );
        },
      );
    }

// Hide the loading dialog
    void hideLoading() {
      Navigator.pop(context);
    }

    Future<String> generateKeyWords(SlidePart slidePart) async {
      String sysinstructionprompt =
          AiPrompt().getSystemInstructions(slidePart.type);
      // Each paragraph should contain only on one type.
      print(sysinstructionprompt);
      final model = GenerativeModel(
        model: RcVariables.geminiAiModel,
        apiKey: RcVariables.apikey,
        generationConfig: GenerationConfig(
            temperature: 1,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 8192,
            responseMimeType: 'application/json',
            responseSchema: AiSchema().getJsonSchema(slidePart.type)),
        systemInstruction: Content.system(sysinstructionprompt),
      );

      final content = [
        // Content.multi([TextPart("Generate json")]),
        Content.text(
            // "Make The course content devided into 4 or more stages. each stage contains 2 to 5 chapter and each chapter covers 3 to 6 subtopics."
            slidePart.slideContent),
      ];

      try {
        final response = await model.generateContent(content);

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

    var slideHeight = SizeConfig.screenWidth * 9 / 16;
    var slideWidth = SizeConfig.screenWidth;

    return WillPopScope(
      onWillPop: () async {
        return await controller.isBackAllowed();
      },
      child: Scaffold(
          // bottomSheet: Container(
          //   height: 64,
          //   // height: SizeConfig.blockSizeHorizontal * 20,
          //   // padding: EdgeInsets.only(top: 10),
          //   color: Colors.red.shade700, // Red background
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       IconButton(
          //           onPressed: () {
          //             controller.isEditable.toggle();
          //             print(controller.isEditable.value);
          //           },
          //           icon: Icon(
          //             Icons.edit,
          //             size: 32,
          //             color: Colors.white,
          //           )),
          //       IconButton(
          //           onPressed: () {},
          //           icon: Icon(
          //             Icons.download,
          //             color: Colors.white,
          //             size: 32,
          //           )),
          //       IconButton(
          //           onPressed: () async {
          //             {
          //               print("button pressed");
          //               // controller.slides = slides;
          //               controller.isAllowBackButton.value = false;
          //               final filePath = await Get.showOverlay(
          //                   asyncFunction: () async {
          //                     var filePath =
          //                         await controller.generatePPTX(context);
          //                     return filePath;
          //                   },
          //                   loadingWidget: Center(
          //                       child: Column(
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     children: [
          //                       CircularProgressIndicator(),
          //                       Container(
          //                         padding: EdgeInsets.only(
          //                             top: SizeConfig.blockSizeHorizontal * 5),
          //                         child: Text(
          //                           "Generating slides...",
          //                           textAlign: TextAlign.center,
          //                           style: TextStyle(
          //                               fontSize: 20,
          //                               decoration: TextDecoration.none,
          //                               color: Colors.white),
          //                         ),
          //                       )
          //                     ],
          //                   )));
          //               controller.isAllowBackButton.value = true;
          //               controller.shareFile(filePath);
          //             }
          //           },
          //           icon: Icon(
          //             Icons.share,
          //             size: 32,
          //             color: Colors.white,
          //           )),
          //       // GestureDetector(
          //       //   onTap: () async {
          //       //     print("button pressed");
          //       //     controller.slides = slides;
          //       //     controller.isAllowBackButton.value = false;
          //       //     final filePath = await Get.showOverlay(
          //       //         asyncFunction: () async {
          //       //           var filePath = await controller.generatePPTX(context);
          //       //           return filePath;
          //       //         },
          //       //         loadingWidget: Center(
          //       //             child: Column(
          //       //           mainAxisAlignment: MainAxisAlignment.center,
          //       //           children: [
          //       //             CircularProgressIndicator(),
          //       //             Container(
          //       //               padding: EdgeInsets.only(
          //       //                   top: SizeConfig.blockSizeHorizontal * 5),
          //       //               child: Text(
          //       //                 "Generating slides...",
          //       //                 textAlign: TextAlign.center,
          //       //                 style: TextStyle(
          //       //                     fontSize: 20,
          //       //                     decoration: TextDecoration.none,
          //       //                     color: Colors.white),
          //       //               ),
          //       //             )
          //       //           ],
          //       //         )));
          //       //     controller.isAllowBackButton.value = true;
          //       //     controller.shareFile(filePath);
          //       //   },
          //       //   child: Center(
          //       //     child: Container(
          //       //       padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          //       //       child: Text(
          //       //         "Save & Share",
          //       //         style: TextStyle(
          //       //             color: Colors.red,
          //       //             fontWeight: FontWeight.w900,
          //       //             fontSize: 16),
          //       //       ),
          //       //       decoration: BoxDecoration(
          //       //           boxShadow: [
          //       //             BoxShadow(
          //       //                 color: const Color.fromARGB(255, 196, 0, 0),
          //       //                 offset: Offset(2, 4),
          //       //                 blurRadius: 20,
          //       //                 spreadRadius: 3)
          //       //           ],
          //       //           borderRadius: BorderRadius.circular(15),
          //       //           color: Colors.white),
          //       //     ),
          //       //   ),
          //       // ),
          //       // GestureDetector(
          //       //   onTap: ()async{
          //       //   },
          //       // )
          //     ],
          //   ),
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
                    HomeController hc = Get.find();
                    hc.initPrompts();
                    hc.textEditingController.clear();
                    Get.back();
                    // Get.offAllNamed(Routes.HOME);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_rounded,
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
                StarFeedbackWidget(
                  // size: SizeConfig.blockSizeHorizontal * 5,
                  size: 30,
                  mainContext: context,
                  icon: Icons.flag,
                ),
                IconButton(
                    onPressed: () {
                      controller.isEditable.toggle();
                      // print(controller.isEditable.value);
                    },
                    icon: Icon(
                      Icons.edit,
                      // size: SizeConfig.blockSizeHorizontal * 5,
                      size: 30,
                      color: Colors.white,
                    )),
                IconButton(
                    onPressed: () async {
                      {
                        try {
                          final connectivity =
                              await Connectivity().checkConnectivity();
                          if (connectivity[0] == ConnectivityResult.none) {
                            Get.snackbar('No Internet Connection',
                                'Please check your internet and try again');
                            return;
                          }
                        } catch (e) {
                          print('Connectivity error: $e');
                          return;
                        }
                        showLoading('Creating Presentation...');
                        final filePath = await controller.generatePPTX(context);
                        // print("button pressed");
                        // controller.slides = slides;
                        // controller.isAllowBackButton.value = false;
                        // final filePath = await Get.showOverlay(
                        //     asyncFunction: () async {
                        //       var filePath =
                        //           await controller.generatePPTX(context);
                        //       return filePath;
                        //     },
                        //     loadingWidget: Center(
                        //         child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       children: [
                        //         CircularProgressIndicator(),
                        //         Container(
                        //           padding: EdgeInsets.only(
                        //               top: SizeConfig.blockSizeHorizontal * 5),
                        //           child: Text(
                        //             "Generating slides...",
                        //             textAlign: TextAlign.center,
                        //             style: TextStyle(
                        //                 fontSize: 20,
                        //                 decoration: TextDecoration.none,
                        //                 color: Colors.white),
                        //           ),
                        //         )
                        //       ],
                        //     )));

                        controller.isAllowBackButton.value = true;

                        controller.shareFile(filePath);
                        hideLoading();
                      }
                    },
                    icon: Icon(
                      Icons.share,
                      // size: SizeConfig.blockSizeHorizontal * 5,
                      size: 30,
                      color: Colors.white,
                    )),
                SizedBox(
                  width: 16,
                )
              ],
            ),
          ),
          body: Obx(() => controller.slideData.value.slidePart.isEmpty
              ? CircularProgressIndicator()
              : SafeArea(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: SizeConfig.blockSizeHorizontal * 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (int i = 0;
                              i <
                                  controller.slideData.value.slidePart.length -
                                      1;
                              i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 14),
                              child: Obx(() {
                                final part = controller
                                    .slideData.value.slidePart[i].value;
                                print(controller.slideData.value.slidePart[i]
                                    .value.slideContent);
                                return GestureDetector(
                                  onTap: () async {
                                    try {
                                      final connectivity = await Connectivity()
                                          .checkConnectivity();
                                      if (connectivity[0] ==
                                          ConnectivityResult.none) {
                                        Get.snackbar('No Internet Connection',
                                            'Please check your internet and try again');
                                        return;
                                      }
                                    } catch (e) {
                                      print('Connectivity error: $e');
                                      return;
                                    }
                                    showLoading('Generating...');
                                    String pt = await generateKeyWords(part);
                                    hideLoading();
                                    Map<String, dynamic> ptt = jsonDecode(pt);
                                    // print('pt $ptt');

                                    // Get.toNamed(Routes.SHOW_GRAPH, arguments: [ptt]);
                                    // controller.setGraph(index, ptt, part.type);

                                    Get.toNamed(Routes.SHOW_GRAPH,
                                        arguments: [part.type, ptt]);

                                    // Get.toNamed(Routes.SHOW_GRAPH, arguments: [keyPoints!]);
                                    // generated.value = true;
                                  },
                                  child: Container(
                                    height: slideHeight,
                                    width: slideWidth,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.red.shade50, // Red background
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockSizeHorizontal * 4),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                    alignment:
                                                        Alignment.topLeft,
                                                    // height: SizeConfig.screenHeight * 0.3,
                                                    // width: SizeConfig.screenWidth * 0.9,
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            0, 0, 10, 0),
                                                    // decoration: BoxDecoration(border: Border.all()),
                                                    child: Obx(() => controller
                                                            .isEditable.value
                                                        ? EditableMarkdown(
                                                            index: i,
                                                          )
                                                        : simpleMarkDown(
                                                            index: i,
                                                          ))),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }),
                            ),
                        ],
                      ),
                    ),
                  ),
                ))),
    );
  }
}

class ParagraphContentView extends StatelessWidget {
  Rx<SlidePart> slidePart;
  int index;
  AiResponceController controller;
  var slideHeight;
  var slideWidth;
  // RxBool generated = false.obs;
  // KeyPoints? keyPoints;
  // String genContent = '';
  ParagraphContentView(
      {super.key,
      required this.slidePart,
      required this.index,
      required this.controller,
      required this.slideHeight,
      required this.slideWidth});
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
    String sysinstructionprompt =
        AiPrompt().getSystemInstructions(slidePart.value.type);
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
          responseSchema: AiSchema().getJsonSchema(slidePart.value.type)),
      systemInstruction: Content.system(sysinstructionprompt),
    );

    final content = [
      // Content.multi([TextPart("Generate json")]),
      Content.text(
          // "Make The course content devided into 4 or more stages. each stage contains 2 to 5 chapter and each chapter covers 3 to 6 subtopics."
          slidePart.value.slideContent),
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
    RxBool clicked = false.obs;
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
        child: Obx(() {
          final part = slidePart.value;
          return GestureDetector(
            // onTap: () async {
            //   showLoading(context);
            //   String pt = await generateKeyWords();
            //   hideLoading(context);
            //   Map<String, dynamic> ptt = jsonDecode(pt);
            //   // print('pt $ptt');

            //   // Get.toNamed(Routes.SHOW_GRAPH, arguments: [ptt]);
            //   // controller.setGraph(index, ptt, part.type);
            //   Get.toNamed(Routes.SHOW_GRAPH, arguments: [part.type, ptt]);

            //   // Get.toNamed(Routes.SHOW_GRAPH, arguments: [keyPoints!]);
            //   // generated.value = true;
            // },
            child: Stack(
              children: [
                Container(
                  height: slideHeight,
                  width: slideWidth,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50, // Red background
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                alignment: Alignment.topLeft,
                                // height: SizeConfig.screenHeight * 0.3,
                                // width: SizeConfig.screenWidth * 0.9,
                                padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                                // decoration: BoxDecoration(border: Border.all()),
                                child:

                                    //----------------------------------------------------------------------------------------------------------------------
                                    //     EditableMarkdown(
                                    //   content: part.slideContent,
                                    //   onUpdate: (newMarkdown) {
                                    //     // Do something with the new markdown content (save or update in state)
                                    //     print(newMarkdown);
                                    //   },
                                    // )
                                    //--------------------------------------------------------------------------------------------------------------
                                    MarkdownBody(
                                  data: part.slideContent,
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
                                      backgroundColor:
                                          Color.fromARGB(255, 255, 242, 217),
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
                                    tableCellsPadding: const EdgeInsets.all(
                                        4.2), // Increased by 20%
                                    codeblockDecoration: BoxDecoration(
                                      color: const Color(0xff23241f),
                                      borderRadius: BorderRadius.circular(
                                          6.72), // Increased by 20%
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            part.isShowGraph.value
                                ? SizedBox(
                                    height: SizeConfig.blockSizeHorizontal * 30,
                                    width: SizeConfig.blockSizeHorizontal * 30,
                                    child: ViewHandler(
                                      type: part.type,
                                      hierarchy: part.hierarchy,
                                      keyPoints: part.keyPoints,
                                      graph: part.graph,
                                      sbs: part.sbs,
                                      comparison: part.comparison,
                                      themeIndex: 0,
                                    ),
                                  )
                                : Container()
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Positioned(
                //   right: 0,
                //   top: 0,
                //   child: IconButton(
                //     icon: Icon(Icons.more_vert),
                //     onPressed: () {},
                //   ),
                // ),
                // Positioned(
                //   right: 0,
                //   top: 0,
                //   child: PopupMenuButton<String>(
                //     icon: Icon(Icons.more_vert),
                //     onSelected: (value) {
                //       // Handle the selected option here
                //       if (value == 'edit') {
                //         // Do edit
                //       } else if (value == 'delete') {
                //         // Do delete
                //       } else if (value == 'share') {
                //         // Do share
                //       }
                //     },
                //     itemBuilder: (BuildContext context) =>
                //         <PopupMenuEntry<String>>[
                //       const PopupMenuItem<String>(
                //         value: 'edit',
                //         child: Text('Edit'),
                //       ),
                //       const PopupMenuItem<String>(
                //         value: 'delete',
                //         child: Text('Delete'),
                //       ),
                //       const PopupMenuItem<String>(
                //         value: 'share',
                //         child: Text('Share'),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          );
        }),
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
    });
  }
}

// class GetSlideView extends StatelessWidget {
//   int index;
//   double slideHeight;
//   double slideWidth;

//   GetSlideView(
//       {super.key,
//       required this.index,
//       required this.slideHeight,
//       required this.slideWidth});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14),
//         child: Container(
//           height: slideHeight,
//           width: slideWidth,
//           decoration: BoxDecoration(
//             color: Colors.red.shade50, // Red background
//             // borderRadius: BorderRadius.circular(16),
//           ),
//           padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 4),
//           child: simpleMarkDown(index: index),
//         ));
//   }
// }

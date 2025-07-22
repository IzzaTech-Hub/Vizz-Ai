import 'dart:convert';
// import 'dart:math';
// import 'dart:nativewrappers/_internal/vm/lib/mirrors_patch.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
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
import 'package:napkin/app/services/ads/admob_ads_prvider.dart';
import 'package:napkin/app/services/ads/adshandler.dart';
import 'package:napkin/app/services/feedback_service.dart';
import 'package:napkin/app/services/rate_us_service.dart';
import 'package:napkin/app/utills/app_strings.dart';
import 'package:napkin/app/widgets/start_feedback_widget.dart';
import 'package:napkin/app/widgets/touch_guide_animation.dart';
// import 'package:napkin/app/data/size_config.dart';

import '../controllers/ai_responce_controller.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:flutter/material.dart';
// import 'dart:';
import 'package:napkin/app/data/models/slide_content_new.dart';
import 'package:napkin/app/utills/app_colors.dart';
import 'package:napkin/app/widgets/presentation_slide.dart';
import 'package:napkin/app/services/templetes_handler.dart';
import 'package:napkin/app/data/models/templete.dart';
import 'dart:io';

class AiResponceView extends GetView<AiResponceController> {
  AiResponceView({Key? key}) : super(key: key);

  // // Banner Ad Implementation start // // //
// ? Commented by jamal start
  late BannerAd myBanner;
  RxBool isBannerLoaded = false.obs;

  initBanner() {
    BannerAdListener listener = BannerAdListener(
      // Called when an ad is successfully received.
      onAdLoaded: (Ad ad) {
        print('Ad loaded.');
        isBannerLoaded.value = true;
      },
      // Called when an ad request failed.
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        // Dispose the ad here to free resources.
        ad.dispose();
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) {
        print('Ad opened.');
      },
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) {
        print('Ad closed.');
      },
      // Called when an impression occurs on the ad.
      onAdImpression: (Ad ad) {
        print('Ad impression.');
      },
    );

    myBanner = BannerAd(
      adUnitId: AppStrings.ADMOB_BANNER,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBanner.load();
  } // ? Commented by jamal end

  // / Banner Ad Implementation End ///

  // Template selection state
  final RxList<Templete> templates = <Templete>[].obs;
  final Rx<Templete?> selectedTemplate = Rx<Templete?>(null);
  final RxBool isDownloading = false.obs;

  @override
  Widget build(BuildContext context) {
    initBanner(); // ? Commented by jamal

    // Fetch templates on first build
    if (templates.isEmpty) {
      TempletesHandler.fetchTemplatesFromFirebase().then((list) {
        templates.assignAll(list);
        if (list.isNotEmpty) selectedTemplate.value = list.first;
      });
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Generated Slides',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: MyAppColors.color2,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            AdsHandler().getAd();
            Get.back();
          },
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.toggleEditing(),
            icon: Obx(() => Icon(
                  controller.isEditing.value ? Icons.check : Icons.edit,
                  color: Colors.white,
                  // controller.isEditing.value ? Colors.green : Colors.white,
                )),
          ),
          StarFeedbackWidget(
            size: SizeConfig.blockSizeHorizontal * 5,
            mainContext: context,
            icon: Icons.flag,
          ),
          // IconButton(
          //   onPressed: () async {
          //     _showExportingOverlay(context);
          //     final filePath = await controller.generatePPTX();
          //     Navigator.of(context).pop(); // Dismiss the loading overlay
          //     if (filePath.isNotEmpty) {
          //       controller.shareFile(filePath);
          //     }
          //   },
          //   icon: Icon(Icons.share, color: Colors.white),
          //   tooltip: 'Save as PowerPoint',
          // ),
          SizedBox(width: 16), // Add spacing from right edge
        ],
      ),
      body: Obx(() {
        // Template bar at the top
        Widget templateBar = Container(
          height: 133,
          padding: EdgeInsets.only(top: 16, bottom: 16, left: 8, right: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final templete = templates[index];
              final isActive = selectedTemplate.value?.id == templete.id;
              return GestureDetector(
                onTap: () async {
                  if (await TempletesHandler.isTemplateDownloaded(templete)) {
                    selectedTemplate.value = templete;
                    controller.setSelectedTemplate(templete);
                  } else {
                    isDownloading.value = true;
                    final localPaths =
                        await TempletesHandler.downloadTemplateImages(templete);
                    isDownloading.value = false;
                    final newTemplate = Templete(
                      id: templete.id,
                      name: templete.name,
                      previewImageUrl: templete.previewImageUrl,
                      imageUrls: templete.imageUrls,
                      localImagePaths: localPaths,
                      titleColorHex: templete.titleColorHex,
                      textColorHex: templete.textColorHex,
                    );
                    selectedTemplate.value = newTemplate;
                    controller.setSelectedTemplate(newTemplate);
                  }
                },
                child: Container(
                  width: 140,
                  // height: 80,
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isActive ? Colors.blue : Colors.grey.shade300,
                      width: isActive ? 3 : 1,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          templete.previewImageUrl,
                          // width: 130,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) =>
                              Icon(Icons.image, size: 40),
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              templete.name,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isActive)
                            Padding(
                              padding: EdgeInsets.only(left: 4),
                              child: Icon(Icons.check_circle,
                                  color: Colors.blue, size: 16),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );

        // Show loading indicator if downloading
        if (isDownloading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.isLoading.value) {
          return Column(
            children: [
              templateBar,
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: MyAppColors.color2),
                      SizedBox(height: 16),
                      Text('Generating detailed slides...',
                          style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        if (controller.presentationContent.value == null) {
          return Column(
            children: [
              templateBar,
              Expanded(
                child: Center(
                  child: Text('No content generated yet'),
                ),
              ),
            ],
          );
        }

        // Use selectedTemplate for slide backgrounds and colors
        final templete = selectedTemplate.value;
        final slideBgImages = templete?.localImagePaths ?? [];
        final titleColor = templete != null
            ? Color(int.parse(templete.titleColorHex.replaceFirst('#', '0xff')))
            : Colors.black;
        final textColor = templete != null
            ? Color(int.parse(templete.textColorHex.replaceFirst('#', '0xff')))
            : Colors.black87;

        return Column(
          children: [
            templateBar,
            verticalSpace(16),
            Obx(() => isBannerLoaded.value &&
                    AdMobAdsProvider.instance.isAdEnable.value
                ? Container(
                    height: AdSize.banner.height.toDouble(),
                    child: AdWidget(ad: myBanner))
                : Container()), // ? Commented by jamal end
            verticalSpace(8),
            // Slides list
            Expanded(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: ListView.builder(
                  itemCount:
                      controller.presentationContent.value!.slides.length,
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final slide =
                        controller.presentationContent.value!.slides[index];
                    // Alternate background images
                    String? bgImagePath = slideBgImages.isNotEmpty
                        ? slideBgImages[index % slideBgImages.length]
                        : null;
                    return Container(
                      margin: EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: bgImagePath == null
                            ? Colors.white
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        image: bgImagePath != null
                            ? DecorationImage(
                                image: FileImage(File(bgImagePath)),
                                fit: BoxFit.cover,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: PresentationSlide(
                        title: slide.title,
                        paragraphs: slide.paragraphs,
                        imagePrompt: slide.imagePrompt,
                        selectedImage: controller.selectedImages[index],
                        onImageSelected: (file) =>
                            controller.handleImageSelected(index, file),
                        onGenerateImage: () => controller.generateImage(index),
                        isGenerating:
                            controller.imageGenerating[index] ?? false,
                        isEditing: controller.isEditing.value,
                        onTitleChanged: (value) =>
                            controller.updateSlideTitle(index, value),
                        onParagraphChanged: (paragraphIndex, value) =>
                            controller.updateSlideParagraph(
                                index, paragraphIndex, value),
                        onAddParagraph: (value) =>
                            controller.addSlideParagraph(index, value),
                        onRemoveParagraph: (paragraphIndex) => controller
                            .removeSlideParagraph(index, paragraphIndex),
                        titleColor: titleColor,
                        textColor: textColor,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: () => controller.showExportOptions(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MyAppColors.color2,
                  minimumSize: Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Export and Share',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
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
  // void showLoading(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // Prevents closing by tapping outside
  //     builder: (context) {
  //       return Dialog(
  //         backgroundColor: Colors.transparent,
  //         child: Container(
  //           padding: const EdgeInsets.all(20),
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           child: const Column(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               CircularProgressIndicator(),
  //               SizedBox(height: 10),
  //               Text("Loading...", style: TextStyle(fontSize: 16)),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

// Hide the loading dialog
  // void hideLoading(BuildContext context) {
  //   Navigator.pop(context);
  // }

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

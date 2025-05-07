import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:napkin/app/data/model_classes/slideData.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/routes/app_pages.dart';
import 'package:rive/rive.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // return Scaffold(
    //   body: Container(
    //     decoration: BoxDecoration(
    //       gradient: LinearGradient(
    //         colors: [
    //           Colors.redAccent.shade700, // redAccent.shade700
    //           Colors.redAccent.shade400, // redAccent.shade700
    //           // Color(0xFFFF5252), // redAccent.shade400
    //         ],
    //         begin: Alignment.topLeft,
    //         end: Alignment.bottomRight,
    //       ),
    //     ),
    //     padding: const EdgeInsets.symmetric(horizontal: 24.0),
    //     child: Center(
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           const FaIcon(
    //             FontAwesomeIcons.bookOpen,
    //             color: Colors.white,
    //             size: 64,
    //           ),
    //           const SizedBox(height: 24),
    //           TextField(
    //             controller: _controller,
    //             style: GoogleFonts.poppins(
    //               color: Colors.white,
    //               fontSize: 18,
    //             ),
    //             cursorColor: Colors.white,
    //             autofocus: true,
    //             decoration: InputDecoration(
    //               hintText: "Enter a topic...",
    //               hintStyle: GoogleFonts.poppins(
    //                 color: Colors.white70,
    //                 fontSize: 16,
    //               ),
    //               filled: true,
    //               fillColor: Colors.white.withOpacity(0.1),
    //               border: OutlineInputBorder(
    //                 borderRadius: BorderRadius.circular(16),
    //                 borderSide: BorderSide.none,
    //               ),
    //               contentPadding: const EdgeInsets.symmetric(
    //                 vertical: 20,
    //                 horizontal: 16,
    //               ),
    //             ),
    //           ),
    //           const SizedBox(height: 24),
    //           SizedBox(
    //             width: double.infinity,
    //             child: ElevatedButton(
    //               onPressed: () {
    //                 final topic = _controller.text.trim();
    //                 if (topic.isNotEmpty) {
    //                   // Navigation or logic here
    //                   ScaffoldMessenger.of(context).showSnackBar(
    //                     SnackBar(
    //                       content: Text("Continuing with topic: $topic"),
    //                     ),
    //                   );
    //                 } else {
    //                   ScaffoldMessenger.of(context).showSnackBar(
    //                     const SnackBar(
    //                       content: Text("Please enter a topic!"),
    //                     ),
    //                   );
    //                 }
    //               },
    //               style: ElevatedButton.styleFrom(
    //                 backgroundColor: Colors.white.withOpacity(0.15),
    //                 foregroundColor: Colors.white,
    //                 elevation: 0,
    //                 shape: RoundedRectangleBorder(
    //                   borderRadius: BorderRadius.circular(16),
    //                 ),
    //                 padding: const EdgeInsets.symmetric(vertical: 18),
    //                 textStyle: GoogleFonts.poppins(
    //                   fontSize: 18,
    //                   fontWeight: FontWeight.w600,
    //                 ),
    //               ),
    //               child: const Text("Continue"),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Header
              verticalSpace(SizeConfig.blockSizeVertical * 8),
              Text(
                'AI Visualizer',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent.shade700
                    // color: Colors.black
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Visualize your ideas in seconds',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.redAccent.shade400,
                  // color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),

              // Input Box
              Container(
                margin: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockSizeHorizontal * 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    TextField(
                      // onChanged: controller.setPrompt,
                      controller: controller.textEditingController,

                      decoration: InputDecoration(
                        hintText: 'What you want to visualize...',
                        hintStyle: TextStyle(
                            fontSize: SizeConfig.blockSizeHorizontal * 3.5,
                            color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFE9ECEF)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.redAccent.shade700),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => controller.isLoading.value
                            ? const CircularProgressIndicator()
                            : GestureDetector(
                                onTap: () async {
                                  controller.showLoading(context);
                                  String inputText =
                                      controller.textEditingController.text;
                                  String response = await controller
                                      .generateContent(inputText);
                                  Map<String, dynamic> slideDataMap =
                                      SlideData.fromMap(jsonDecode(response)).toMap();
                                  controller.hideLoading(context);
                                  Get.toNamed(Routes.AI_RESPONCE,
                                      arguments: [slideDataMap]);
                                },
                                child: Container(
                                  height: SizeConfig.blockSizeVertical * 6,
                                  width: SizeConfig.blockSizeHorizontal * 45,
                                  decoration: BoxDecoration(
                                      color: Colors.redAccent,
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.blockSizeHorizontal * 2)),
                                  child: Center(
                                    child: Text(
                                      "Generate",
                                      style: TextStyle(
                                          fontSize:
                                              SizeConfig.blockSizeHorizontal *
                                                  4,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                        // : ElevatedButton(
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor: const Color(0xFF6E56CF),
                        //       minimumSize: const Size(double.infinity, 48),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(8),
                        //       ),
                        //     ),
                        //     onPressed: controller.generateVisualization,
                        //     child: const Text(
                        //       'Generate',
                        //       style: TextStyle(
                        //         fontSize: 16,
                        //         fontWeight: FontWeight.w500,
                        //       ),
                        //     ),
                        //   ),
                        ),
                  ],
                ),
              ),

              // Example Prompts
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: SizeConfig.blockSizeHorizontal * 4),
                  child: Text(
                    'Try an example:',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade900,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Obx(() => Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.examplePrompts.map((prompt) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 35, bottom: 12),
                          child: GestureDetector(
                            onTap: () => controller.setPrompt(prompt),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE9ECEF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '"$prompt"',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// class HomeScreen extends StatelessWidget {
//   final TextEditingController topicController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
  
//   }
// }

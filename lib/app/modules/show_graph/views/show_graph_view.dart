// import 'dart:math';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

import 'package:get/get.dart';
import 'package:napkin/app/data/size_config.dart';
// import 'package:napkin/app/data/graph_handler.dart';
// import 'package:napkin/app/data/size_config.dart';
// import 'package:napkin/app/data/view_handler/hierarchy_views.dart';
// import 'package:napkin/app/data/view_handler/keypoints_views.dart';
import 'package:napkin/app/data/view_handler/view_handler.dart';
import 'package:napkin/app/services/feedback_service.dart';
import 'package:napkin/app/widgets/start_feedback_widget.dart';

import '../controllers/show_graph_controller.dart';

class ShowGraphView extends GetView<ShowGraphController> {
  const ShowGraphView({super.key});
  @override
  Widget build(BuildContext context) {
    // return HoneycombPage();
    return Scaffold(
        // backgroundColor: Colors.black,
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
            title: AutoSizeText(
              controller.heading!,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              minFontSize: 14,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0, // optional, for a flat look
            actions: [
              StarFeedbackWidget(
                  size: SizeConfig.blockSizeHorizontal * 5,
                  mainContext: context,
                  icon: Icons.flag),
              // IconButton(
              //     onPressed: () {
              //       FeedbackService().showFeedbackDialog(context,
              //           '${controller.jsonString!},(${controller.type})');
              //     },
              //     icon: Icon(
              //       Icons.flag,
              //       color: Colors.white,
              //     )),
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
        body: Container(
          child: ViewHandler(
            type: controller.type,
            hierarchy: controller.hierarchy,
            keyPoints: controller.keyPoints,
            graph: controller.graph,
            sbs: controller.sbs,
            comparison: controller.comparison,
            themeIndex: 0,
          ),
        ));
  }
}

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Honeycomb Layout',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const HoneycombPage(),
//     );
//   }
// }

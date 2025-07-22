import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:napkin/app/data/app_images.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/services/ads/admob_ads_prvider.dart';
import 'package:napkin/app/services/ads/adshandler.dart';
import 'package:napkin/app/services/templetes_handler.dart';
import 'package:napkin/app/utills/app_colors.dart';
import 'package:scroll_loop_auto_scroll/scroll_loop_auto_scroll.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});
  void _shareApp(BuildContext context) async {
    try {
      // Load image from assets
      final byteData = await rootBundle.load('assets/images/main_icon.png');

      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/thumbnail.jpg');

      // Write image to temp file
      await file.writeAsBytes(byteData.buffer.asUint8List());

      // Share it with text
      // [XFile(file.path)];

      SharePlus.instance.share(
        ShareParams(
            text: '''
🚀 *Boost Your Productivity Instantly!*

Discover *Vizz AI* - Make Professional Presentation in secondes. Vizz Ai Your smart assistant for taking lightning-fast notes, organizing thoughts, and staying ahead. 🧠✨

✅ AI-powered summaries  
✅ Clean & easy interface  
✅ Totally Free of cost

📲 Download now on Google Play:
https://play.google.com/store/apps/details?id=com.visualizerai.quicknotesai
''',
            title: 'Vizz Ai:One Click Presentation Maker',
            files: [XFile(file.path)]),
      );
    } catch (e) {
      print("Error sharing image: $e");
    }
  }

  void _sendFeedback(BuildContext context) async {
    final Uri emailLaunchUri = Uri.parse(
        'https://play.google.com/store/apps/details?id=com.visualizerai.quicknotesai');

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open email app')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SvgPicture.asset(
                AppImagesSVG.bgBottom, // Replace with your SVG asset path
                fit: BoxFit.cover,
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    verticalSpace(SizeConfig.blockSizeVertical * 16),
                    Text(
                      'AI Visualizer',
                      style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.black
                          // color: Colors.black
                          ),
                    ),
                    verticalSpace(SizeConfig.blockSizeVertical * 2),
                    Text(
                      'Visualize your ideas in seconds',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black54,
                          letterSpacing: 1.2),
                    ),
                    verticalSpace(SizeConfig.blockSizeVertical * 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          // border: Border.all(color: Colors.black26),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black38,
                                offset: Offset(2, 3),
                                blurRadius: 1.5)
                          ],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.textEditingController,
                                decoration: InputDecoration(
                                  hintText: 'What you want to visualize...',
                                  hintStyle: TextStyle(color: Colors.black38),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0),
                                  border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            IconButton(
                                onPressed: () async {
                                  // Interstitial Ad Implementation
                                  // AdMobAdsProvider.instance
                                  //     .showInterstitialAd(() {});
                                  AdsHandler().getAd();

                                  // AdMobAdsProvider.instance
                                  //     .ShowRewardedAd(() {});
                                  await controller.startGenerating(context);
                                },
                                icon: Icon(Icons.double_arrow))
                          ],
                        ),
                      ),
                    ),
                    verticalSpace(SizeConfig.blockSizeVertical * 8),
                    Row(
                      children: [
                        Text(
                          '   Example Topics:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    verticalSpace(SizeConfig.blockSizeVertical * 2),
                    AutoScrollingChips(
                      prompts: controller.premoptList1,
                      onPromptTap: (prompt) {
                        controller.textEditingController.text = prompt;
                      },
                      reverseScroll: true,
                      scrollDuration: Duration(seconds: 250),
                      gap: 0.0,
                    ),
                    verticalSpace(SizeConfig.blockSizeVertical * 0.5),
                    AutoScrollingChips(
                      prompts: controller.premoptList2,
                      onPromptTap: (prompt) {
                        controller.textEditingController.text = prompt;
                      },
                      reverseScroll: false,
                      scrollDuration: Duration(seconds: 300),
                      gap: 0.0,
                    ),
                    verticalSpace(SizeConfig.blockSizeVertical * 0.5),
                    AutoScrollingChips(
                      prompts: controller.premoptList3,
                      onPromptTap: (prompt) {
                        controller.textEditingController.text = prompt;
                      },
                      reverseScroll: true,
                      scrollDuration: Duration(seconds: 150),
                      gap: 0.0,
                    )
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Builder(
                builder: (context) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [MyAppColors.color1, MyAppColors.color2],
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                    child: Icon(
                      Icons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 24,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '"Your imagination is the only limit."',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  verticalSpace(8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'See beyond with AI',
                        style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade300.withOpacity(0.7)),
                        textAlign: TextAlign.center,
                      ),
                      Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.grey.shade300.withOpacity(0.7),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      endDrawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: MyAppColors.color2,
              ),
              child: Text('Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.star_rate),
              title: const Text('Feedback'),
              onTap: () => _sendFeedback(context),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share'),
              onTap: () => _shareApp(context),
            ),
            // ListTile(
            //   leading: const Icon(Icons.share),
            //   title: const Text('Testing'),
            //   onTap: () async {
            //     await TempletesHandler.initialize();
            //     print('Templates: ${TempletesHandler.templates.length}');
            //   },
            // ),
          ],
        ),
      ),
    );
  }
}

class AutoScrollingChips extends StatelessWidget {
  final List<String> prompts;
  final Function(String) onPromptTap;
  final bool reverseScroll;
  final Duration scrollDuration;
  final double gap;

  const AutoScrollingChips({
    Key? key,
    required this.prompts,
    required this.onPromptTap,
    this.reverseScroll = false,
    this.scrollDuration = const Duration(seconds: 30),
    this.gap = 16.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScrollLoopAutoScroll(
      scrollDirection: Axis.horizontal,
      delay: Duration.zero,
      duration: scrollDuration,
      gap: gap,
      duplicateChild: 1,
      reverseScroll: reverseScroll,
      enableScrollInput: true,
      delayAfterScrollInput: const Duration(seconds: 1),
      child: Row(
        children: prompts.map((prompt) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: InkWell(
              onTap: () => onPromptTap(prompt),
              child: Chip(
                label: Text('"$prompt"'),
                backgroundColor: Colors.white,
                shape:
                    const StadiumBorder(side: BorderSide(color: Colors.white)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

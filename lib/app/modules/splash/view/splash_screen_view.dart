import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:napkin/app/data/app_images.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/modules/splash/controller/splash_screen_ctl.dart';
import 'package:napkin/app/utills/app_colors.dart';
import 'package:rive/rive.dart';

class SplashScreen extends GetView<SplashController> {
  SplashScreen({Key? key}) : super(key: key);
  // Obtain shared preferences.
  bool? b;

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    // b = controller.isFirstTime;
    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 1.5,
                  child: SizedBox(
                    width: SizeConfig.screenWidth,
                    height: 350,
                    child: RiveAnimation.asset(
                      'assets/rives/vizz.riv',
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                ),
                Text(
                  "AI Visualizer",
                  style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "See Beyond with AI",
                  style: TextStyle(
                    fontSize: SizeConfig.blockSizeHorizontal * 5,
                  ),
                ),
              ],
            ),
          ),

          // Get Started Button
          Positioned(
            bottom: SizeConfig.blockSizeVertical * 10,
            left: 0,
            right: 0,
            child: Obx(() => AnimatedOpacity(
                  duration: Duration(milliseconds: 500),
                  opacity: controller.showGetStarted.value ? 1.0 : 0.0,
                  child: AnimatedSlide(
                    duration: Duration(milliseconds: 500),
                    offset: controller.showGetStarted.value
                        ? Offset.zero
                        : Offset(0, 0.2),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: ElevatedButton(
                        onPressed: controller.showGetStarted.value
                            ? controller.navigateToHome
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MyAppColors.color2,
                          padding: EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Get Started',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}

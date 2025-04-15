import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:napkin/app/data/app_images.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/modules/splash/controller/splash_screen_ctl.dart';
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
      body: 
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

                    Text("AI Visualizer",style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                      fontWeight: FontWeight.bold
                    ),),
                    Text("See Beyond with AI",style: TextStyle(
                      fontSize: SizeConfig.blockSizeHorizontal * 5,
                    ),)
  
    ],
  ),
)
    );
  }
}

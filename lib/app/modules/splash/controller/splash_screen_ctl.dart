import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:napkin/app/routes/app_pages.dart';
import 'package:napkin/app/services/ads/admob_ads_prvider.dart';
import 'package:napkin/app/services/remote_config_service.dart';

class SplashController extends GetxController {
  var tabIndex = 0.obs;
  Rx<int> percent = 0.obs;
  Rx<bool> isLoaded = false.obs;
  Rx<bool> showGetStarted = false.obs;

  @override
  void onInit() async {
    super.onInit();
    // await RemoteConfigService().initialize();
    AdMobAdsProvider.instance.initialize(); // Initialize ads
    Timer? timer;
    timer = Timer.periodic(Duration(milliseconds: 500), (_) {
      int n = Random().nextInt(10) + 5;
      percent.value += n;
      if (percent.value >= 100) {
        percent.value = 100;
        showGetStarted.value = true; // Show get started button
        timer!.cancel();
      }
    });

    // prefs.then((SharedPreferences pref) {
    //   isFirstTime = pref.getBool('first_time') ?? true;

    //   print("Is First Time from Init: $isFirstTime");
    // });
  }

  void navigateToHome() {
    // Show ad before navigation
    AdMobAdsProvider.instance.showInterstitialAd(() {
      // Navigate to home after ad is closed
    });
    Get.offNamed(Routes.HOME);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {}

  // void setFirstTime(bool bool) {
  //   prefs.then((SharedPreferences pref) {
  //     pref.setBool('first_time', bool);
  //     print("Is First Time: $isFirstTime");
  //   });
  // }
}

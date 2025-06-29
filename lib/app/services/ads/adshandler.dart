import 'package:napkin/app/services/ads/admob_ads_prvider.dart';

class AdsHandler {
  static int addcount = 0;
  getAd() {
    addcount++;
    if (addcount >= 3) {
      AdMobAdsProvider.instance.showInterstitialAd(() {});
      addcount = 0;
    }
  }
}

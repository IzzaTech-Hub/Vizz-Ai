import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:napkin/app/utills/app_strings.dart';


class AppOpenAdManager {
  AppOpenAd? appOpenAd;

  bool _isShowingAd = false;

  /// Load an AppOpenAd.

  /// Whether an ad is available to be shown.
  bool get isAdAvailable {
    return appOpenAd != null;
  }

  void loadAppOpenAd() {
    AppOpenAd.load(
      adUnitId: AppStrings.ADMOB_APP_OPEN,
      // orientation: AppOpenAd.orientationPortrait,
      request: AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          appOpenAd = ad;
          print('AppOpenAd Loaded');
        },
        onAdFailedToLoad: (error) {
          print('AppOpenAd failed to load: $error');
          // Handle the error.
        },
      ),
    );
  }

  void showAdIfAvailable() {
    print("ShowAdIFAvailable Called");
    if (!isAdAvailable) {
      print('Tried to show ad before available.');
      loadAppOpenAd();
      return;
    }
    if (_isShowingAd) {
      print('Tried to show ad while already showing an ad.');
      return;
    }
    // Set the fullScreenContentCallback and show the ad.
    appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        _isShowingAd = true;
        print('$ad onAdShowedFullScreenContent');
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        _isShowingAd = false;
        ad.dispose();
        appOpenAd = null;
      },
      onAdDismissedFullScreenContent: (ad) {
        print('$ad onAdDismissedFullScreenContent');
        _isShowingAd = false;
        ad.dispose();
        appOpenAd = null;
        loadAppOpenAd();
      },
    );
    appOpenAd!.show();
  }
}

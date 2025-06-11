import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:napkin/app/data/models/presentation_outline.dart';
import 'package:napkin/app/services/ads/admob_ads_prvider.dart';
import 'package:napkin/app/services/ads/adshandler.dart';
import 'package:napkin/app/utills/app_strings.dart';
import '../controllers/outline_controller.dart';
import 'package:napkin/app/utills/app_colors.dart';
import 'package:napkin/app/widgets/start_feedback_widget.dart';
import 'package:napkin/app/data/size_config.dart';

class OutlineView extends GetView<OutlineController> {
  OutlineView({super.key});

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
  @override
  Widget build(BuildContext context) {
    initBanner(); // ? Commented by jamal
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Presentation Outline',
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
          StarFeedbackWidget(
            size: SizeConfig.blockSizeHorizontal * 5,
            mainContext: context,
            icon: Icons.flag,
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: MyAppColors.color2),
                SizedBox(height: 16),
                Text('Generating presentation outline...',
                    style: TextStyle(fontSize: 16)),
              ],
            ),
          );
        }

        if (controller.outline.value == null) {
          return Center(
            child: Text('No outline generated yet'),
          );
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                MyAppColors.color2.withOpacity(0.1),
                Colors.grey.shade50,
              ],
            ),
          ),
          child: Column(
            children: [
              // Title Section
              Container(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    Obx(() => isBannerLoaded.value &&
                            AdMobAdsProvider.instance.isAdEnable.value
                        ? Container(
                            height: AdSize.banner.height.toDouble(),
                            child: AdWidget(ad: myBanner))
                        : Container()), // ? Commented by jamal end
                    verticalSpace(8),
                    Text(
                      controller.outline.value!.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        // color: MyAppColors.color1,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${controller.outline.value!.slides.length} Slides',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),

              // Slides List
              Expanded(
                child: ListView.builder(
                  itemCount: controller.outline.value!.slides.length,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  itemBuilder: (context, index) {
                    final slide = controller.outline.value!.slides[index];
                    return Stack(
                      children: [
                        // Vertical line connecting bullets
                        if (index < controller.outline.value!.slides.length - 1)
                          Positioned(
                            left: 15,
                            top: index == 0 ? 44 : 0,
                            bottom: 0,
                            child: Container(
                              width: 2,
                              color: MyAppColors.color2.withOpacity(0.2),
                            ),
                          ),
                        if (index ==
                            controller.outline.value!.slides.length - 1)
                          Positioned(
                            left: 15,
                            top: 0,
                            // bottom: 0,
                            child: Container(
                              height: 44,
                              width: 2,
                              color: MyAppColors.color2.withOpacity(0.2),
                            ),
                          ),

                        // Slide content with bullet
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Bullet point
                            Container(
                              margin: EdgeInsets.only(top: 12),
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: MyAppColors.color2,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: MyAppColors.color2.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),

                            // Card content
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Slide title and key points
                                    Padding(
                                      padding: EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            slide.slideTitle,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: MyAppColors.color2,
                                            ),
                                          ),
                                          SizedBox(height: 8),
                                          ...slide.keyPoints
                                              .map((point) => Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 4),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  top: 6),
                                                          child: Icon(
                                                              Icons.arrow_right,
                                                              color: MyAppColors
                                                                  .color2),
                                                        ),
                                                        SizedBox(width: 4),
                                                        Expanded(
                                                          child: Text(
                                                            point,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors
                                                                  .black54,
                                                              height: 1.5,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ))
                                              .toList(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Generate Slides Button
              Container(
                padding: EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () => controller.proceedToSlideGeneration(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyAppColors.color2,
                    minimumSize: Size(double.infinity, 56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Generate Slides',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

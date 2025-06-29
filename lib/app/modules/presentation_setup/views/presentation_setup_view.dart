import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:napkin/app/data/models/presentation_settings.dart';
import 'package:napkin/app/routes/app_pages.dart';
import 'package:napkin/app/services/ads/admob_ads_prvider.dart';
import 'package:napkin/app/services/ads/adshandler.dart';
import 'package:napkin/app/utills/app_colors.dart';
import 'package:napkin/app/utills/app_strings.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PresentationSetupView extends GetView<PresentationSettingsController> {
  PresentationSetupView({Key? key}) : super(key: key);

  // Banner Ad Implementation
  late BannerAd myBanner;
  RxBool isBannerLoaded = false.obs;

  void initBanner() {
    BannerAdListener listener = BannerAdListener(
      onAdLoaded: (Ad ad) {
        print('Ad loaded.');
        isBannerLoaded.value = true;
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        ad.dispose();
        print('Ad failed to load: $error');
      },
      onAdOpened: (Ad ad) => print('Ad opened.'),
      onAdClosed: (Ad ad) => print('Ad closed.'),
      onAdImpression: (Ad ad) => print('Ad impression.'),
    );

    myBanner = BannerAd(
      adUnitId: AppStrings.ADMOB_BANNER,
      size: AdSize.banner,
      request: AdRequest(),
      listener: listener,
    );
    myBanner.load();
  }

  @override
  Widget build(BuildContext context) {
    // Initialize the topic from the arguments and banner ad
    if (Get.arguments is String) {
      controller.updateTopic(Get.arguments as String);
    }
    initBanner();

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Presentation Setup',
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8),

            // Banner Ad
            Obx(() => isBannerLoaded.value &&
                    AdMobAdsProvider.instance.isAdEnable.value
                ? Container(
                    height: AdSize.banner.height.toDouble(),
                    child: AdWidget(ad: myBanner))
                : Container()),
            Container(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Topic Input
                  // Text(
                  //   'Topic',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //     color: MyAppColors.color2,
                  //   ),
                  // ),
                  // SizedBox(height: 8),
                  // Obx(() => TextField(
                  //       controller: TextEditingController(
                  //           text: controller.settings.value.topic),
                  //       onChanged: controller.updateTopic,
                  //       decoration: InputDecoration(
                  //         hintText: 'Enter your presentation topic',
                  //         border: OutlineInputBorder(
                  //           borderRadius: BorderRadius.circular(12),
                  //         ),
                  //         filled: true,
                  //         fillColor: Colors.white,
                  //       ),
                  //     )),
                  SizedBox(height: 16),

                  // Detail Level Selection

                  // Purpose Dropdown
                  Text(
                    'Purpose',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyAppColors.color2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.settings.value.purpose,
                        items: PresentationSettingsController.purposes
                            .map((purpose) => DropdownMenuItem(
                                  value: purpose,
                                  child: Text(purpose),
                                ))
                            .toList(),
                        onChanged: (value) => controller.updatePurpose(value!),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      )),
                  SizedBox(height: 24),
                  Text(
                    'Detail Level',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyAppColors.color2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: _buildDetailLevelButton(
                              context,
                              title: 'Short',
                              svgPath: 'assets/svgs/short.svg',
                              detailLevel: DetailLevel.short,
                              isSelected:
                                  controller.settings.value.detailLevel ==
                                      DetailLevel.short,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildDetailLevelButton(
                              context,
                              title: 'Medium',
                              svgPath: 'assets/svgs/medium.svg',
                              detailLevel: DetailLevel.medium,
                              isSelected:
                                  controller.settings.value.detailLevel ==
                                      DetailLevel.medium,
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: _buildDetailLevelButton(
                              context,
                              title: 'Detailed',
                              svgPath: 'assets/svgs/detailed.svg',
                              detailLevel: DetailLevel.detailed,
                              isSelected:
                                  controller.settings.value.detailLevel ==
                                      DetailLevel.detailed,
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 24),

                  // Number of Slides Slider
                  Text(
                    'Number of Slides',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyAppColors.color2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(() => Column(
                        children: [
                          Slider(
                            value: controller.settings.value.numberOfSlides
                                .toDouble(),
                            min: 5,
                            max: 15,
                            divisions: 10,
                            label:
                                '${controller.settings.value.numberOfSlides}',
                            onChanged: (value) =>
                                controller.updateNumberOfSlides(value.round()),
                            activeColor: MyAppColors.color2,
                          ),
                          Text(
                            '${controller.settings.value.numberOfSlides} slides',
                            style: TextStyle(color: Colors.black54),
                          ),
                        ],
                      )),
                  SizedBox(height: 24),

                  // Style Dropdown
                  Text(
                    'Presentation Style',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: MyAppColors.color2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Obx(() => DropdownButtonFormField<String>(
                        value: controller.settings.value.style,
                        items: PresentationSettingsController.styles
                            .map((style) => DropdownMenuItem(
                                  value: style,
                                  child: Text(style),
                                ))
                            .toList(),
                        onChanged: (value) => controller.updateStyle(value!),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      )),
                  SizedBox(height: 24),

                  // Include Images Switch
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Include Images',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: MyAppColors.color2,
                        ),
                      ),
                      Obx(() => Switch(
                            value: controller.settings.value.includeImages,
                            onChanged: controller.updateIncludeImages,
                            activeColor: MyAppColors.color2,
                          )),
                    ],
                  ),
                  SizedBox(height: 32),

                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.settings.value.topic.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please enter a topic',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        Get.toNamed(Routes.OUTLINE,
                            arguments: controller.settings.value);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyAppColors.color2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Generate Outline',
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailLevelButton(
    BuildContext context, {
    required String title,
    required String svgPath,
    required DetailLevel detailLevel,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () => controller.updateDetailLevel(detailLevel),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color:
              isSelected ? MyAppColors.color2.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? MyAppColors.color2 : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              svgPath,
              height: 36,
              width: 36,
              color: isSelected ? MyAppColors.color2 : Colors.grey.shade600,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? MyAppColors.color2 : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:napkin/app/modules/app_bindings.dart';
import 'package:napkin/app/services/rate_us_service.dart';
import 'package:napkin/app/services/remote_config_service.dart';
// import 'package:google_generative_ai/google_generative_ai.dart';
// import 'package:napkin/app/data/rc_variables.dart';
// import 'package:napkin/app/test_gemini.dart';
// import 'package:napkin/firebase_options.dart';

import 'app/routes/app_pages.dart';

// Future<void> testGeminiApi() async {
//   try {
//     print("DEBUG: Testing Gemini API...");

//     final model = GenerativeModel(
//       model: RcVariables.geminiAiModel,
//       apiKey: RcVariables.apikey,
//     );

//     print("DEBUG: Model initialized, sending test request");
//     final content = [Content.text("What is Flutter?")];
//     final response = await model.generateContent(content);

//     print(
//         "DEBUG: Test response received: ${response.text?.substring(0, 100)}...");
//   } catch (e) {
//     print("DEBUG: Gemini API test failed: $e");
//   }
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  RateUsService.initialize();

  await Firebase.initializeApp();
  RemoteConfigService().initialize();

  // // Test the Gemini API directly
  // print("TESTING SIMPLE API CALL");
  // await testGeminiApi();

  // print("\n\nTESTING OUTLINE GENERATION");
  // await testGenerateOutline();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Application",
      theme: ThemeData(useMaterial3: true),
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      initialBinding: AppBindings(),
    );
  }
}


    // GetMaterialApp(
    //   title: "Application",
    //   initialRoute: AppPages.INITIAL,
    //   getPages: AppPages.routes,
    //   debugShowCheckedModeBanner: false,
    // ),
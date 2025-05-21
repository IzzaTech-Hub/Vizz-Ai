import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:napkin/app/data/size_config.dart';
// import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slide_rating_dialog/slide_rating_dialog.dart';

class RateUsService {
  static bool isRated = false;
  static int rate = 0;

  static initialize() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    rate = 0;
    isRated = prefs.getBool('rated') ?? false;
  }

  static rateus() {
    // print('rating');
    if (isRated) {
      return;
    }
    rate++;
    if (rate > 2) {
      askForRateUs();
      rate = 0;
    }
  }

  static rated() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('rated', true);
    isRated = true;
  }

  static askForRateUs() {
    int finalRating = 5;
    Get.dialog(
      barrierDismissible: true,
      SlideRatingDialog(
        onRatingChanged: (rating) {
          finalRating = rating;
        },
        buttonOnTap: () async {
          final inAppReview = InAppReview.instance;
          if (finalRating >= 3) {
            if (await inAppReview.isAvailable()) {
              inAppReview.requestReview();
            } else {
              inAppReview.openStoreListing(
                appStoreId: 'com.visualizerai.quicknotesai',
              );
            }

            Get.back();

            await storeReviewCount(finalRating);
          } else {
            Get.back();

            await storeReviewCount(finalRating);
          }
          rated();
        },
      ),
    );
  }
}

Future<void> storeReviewCount(int rating) async {
  final firestore = FirebaseFirestore.instance;
  final ratingDocRef = firestore.collection('Rating').doc(rating.toString());

  // Use a transaction to ensure data consistency
  await firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(ratingDocRef);
    if (!snapshot.exists) {
      transaction.set(ratingDocRef, {'count': 0}); // Create with initial count
    }
    transaction.update(ratingDocRef, {'count': FieldValue.increment(1)});
  });
}

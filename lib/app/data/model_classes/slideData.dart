import 'dart:convert';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:napkin/app/data/model_classes/slidePart.dart';

class SlideData {
  String mainTitle;
  RxList<Rx<SlidePart>> slidePart;
  SlideData({
    required this.mainTitle,
    required this.slidePart,
  });

  factory SlideData.fromMap(Map<String, dynamic> map) {
    return SlideData(
        mainTitle: map['mainTitle'],
        slidePart: (map['slidePart'] as List)
            .map((slidePart) =>
                SlidePart.fromMap(slidePart as Map<String, dynamic>).obs)
            .toList()
            .obs);
  }

  Map<String, dynamic> toMap() {
    return {
      'mainTitle': mainTitle,
      'slidePart': slidePart.map((e) => e.value.toMap()).toList()
    };
  }
}

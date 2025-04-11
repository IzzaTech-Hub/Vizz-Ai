// File: keypoints_views.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:napkin/app/data/app_images.dart';
import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/data/theme_assets/theme_functions.dart';
import 'dart:ui' as ui;

class KeyPointsViews {
  static Widget getTheme(int index, KeyPoints model) {
    List<Widget> themes = [
      _theme0(model),
      //  _theme1(model), _theme2(model),
      _theme3(model)
    ];
    return themes[Random().nextInt(themes.length)];

    // switch (index) {
    //   case 0:
    //     return _theme0(model);
    //   case 1:
    //     return _theme1(model);
    //   case 2:
    //     return _theme2(model);
    //   case 3:
    //     return _theme3(model);
    //   default:
    //     return _theme0(model);
    // }
  }

  static Widget _theme0(KeyPoints keyPoints) {
    Widget _buildKeyPointArrow(KeyPoint kp, int index) {
      bool leftToRight = index % 2 == 1;
      Color color = ThemeFunctions().getRandomlightColor();
      return Stack(
        alignment: Alignment.center,
        children: [
          Transform(
            alignment: Alignment.center,
            transform: leftToRight
                ? Matrix4.diagonal3Values(-1, 1, 1)
                : Matrix4.diagonal3Values(1, 1, 1),
            child: Image.asset(
              AppImages.arrow,
              color: color,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (leftToRight)
                SizedBox(
                    width: (SizeConfig.screenWidth / 2) - 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: SizeConfig.screenWidth * 0.1,
                        ),
                        ThemeFunctions().getFlutterIcon(kp.flutterIconName,
                            size: 50,
                            color: ThemeFunctions().getInverseColor(color)),
                      ],
                    )),
              SizedBox(
                width: (SizeConfig.screenWidth / 2) - 16,
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        kp.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ThemeFunctions().getInverseColor(color),
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        kp.shortDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: ThemeFunctions().getInverseColor(color),
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              if (!leftToRight)
                SizedBox(
                    width: (SizeConfig.screenWidth / 2) - 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ThemeFunctions().getFlutterIcon(kp.flutterIconName,
                            size: 50,
                            color: ThemeFunctions().getInverseColor(color)),
                        SizedBox(
                          width: SizeConfig.screenWidth * 0.1,
                        ),
                      ],
                    )),
            ],
          )
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SizedBox(
        // height: 250, // Only uses a portion of the screen
        child: ListView.builder(
          // scrollDirection: Axis.horizontal,
          itemCount: keyPoints.keypoints.length,
          itemBuilder: (context, index) {
            final keyPoint = keyPoints.keypoints[index];
            return _buildKeyPointArrow(keyPoint, index);
          },
        ),
      ),
    );
  }

  // static Widget _theme1(KeyPoints keyPoints) {
  //   return Column(children: [
  //     for (KeyPoint keyPoint in keyPoints.keypoints)
  //       Container(
  //         color: ThemeFunctions().getRandomlightColor(),
  //         child: Row(
  //           children: [
  //             ThemeFunctions().getFlutterIcon(keyPoint.flutterIconName),
  //             Text(
  //               keyPoint.title,
  //               style: const TextStyle(fontWeight: FontWeight.bold),
  //             ),
  //             Text(keyPoint.shortDescription)
  //           ],
  //         ),
  //       )
  //   ]);
  // }

  // static Widget _theme2(KeyPoints keyPoints) {
  //   Widget _buildKeyPointCard(KeyPoint keyPoint) {
  //     return Container(
  //       width: 180,
  //       margin: const EdgeInsets.symmetric(horizontal: 8),
  //       padding: const EdgeInsets.all(12),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: ThemeFunctions().getGradientColors(),
  //           begin: Alignment.topLeft,
  //           end: Alignment.bottomRight,
  //         ),
  //         borderRadius: BorderRadius.circular(16),
  //         boxShadow: const [
  //           BoxShadow(
  //               color: Colors.black26, blurRadius: 6, offset: Offset(2, 4))
  //         ],
  //       ),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           // Icon(getFlutterIcon(keyPoint.flutterIconName), size: 40, color: Colors.white),
  //           ThemeFunctions().getFlutterIcon(keyPoint.flutterIconName,
  //               size: 40, color: Colors.white),
  //           const SizedBox(height: 8),
  //           Text(
  //             keyPoint.title,
  //             textAlign: TextAlign.center,
  //             style: const TextStyle(
  //                 fontSize: 16,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.white),
  //           ),
  //           const SizedBox(height: 4),
  //           Text(
  //             keyPoint.shortDescription,
  //             textAlign: TextAlign.center,
  //             style: const TextStyle(fontSize: 12, color: Colors.white70),
  //           ),
  //         ],
  //       ),
  //     );
  //   }

  //   return SizedBox(
  //     height: 250, // Only uses a portion of the screen
  //     child: ListView.builder(
  //       scrollDirection: Axis.horizontal,
  //       itemCount: keyPoints.keypoints.length,
  //       itemBuilder: (context, index) {
  //         final keyPoint = keyPoints.keypoints[index];
  //         return _buildKeyPointCard(keyPoint);
  //       },
  //     ),
  //   );
  // }

  static Widget _theme3(KeyPoints keyPoints) {
    final List<Color> colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      Colors.deepOrange,
      Colors.lime,
      // Colors.lightBlue,
      Colors.deepPurple,
      Colors.brown,
      Colors.lightGreen,
      Colors.blueGrey,
    ];

    final List<String> labels =
        keyPoints.keypoints.map((e) => e.title).toList();
    final int layers = labels.length;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 16),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: SizeConfig.screenWidth * 0.8,
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      // double stripeHeight = bounds.height / colors.length;

                      return LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: List.generate(
                          layers * 2,
                          (i) => i.isEven
                              ? (i ~/ 2) / layers
                              : ((i ~/ 2) + 1) / layers,
                        ),
                        colors: List.generate(
                          layers * 2,
                          (i) => colors[i ~/ 2],
                        ),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcIn,
                    child: Image.asset(
                      'assets/images/bulb.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Container(
                  // color: Colors.amber,
                  height: SizeConfig.screenWidth * 1.045,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        for (int i = 1; i <= layers; i++)
                          ThemeFunctions().getFlutterIcon(
                              keyPoints.keypoints[i - 1].flutterIconName,
                              size: SizeConfig.screenWidth * 1.045 / layers / 2,
                              color: Colors.white),
                        // Text(
                        //   keyPoints.keypoints[i - 1].title,
                        //   style: TextStyle(
                        //       fontSize: 24, color: colors[i - 1]),
                        // )
                      ]),
                ),
              ],
            ),
          ),
          SizedBox(height: 4),
          Container(
            width: SizeConfig.screenWidth * 0.24,
            height: 10,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(1000)),
          ),
          SizedBox(height: 4),
          Container(
            width: SizeConfig.screenWidth * 0.24,
            height: 10,
            decoration: BoxDecoration(
                color: Colors.black, borderRadius: BorderRadius.circular(1000)),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 1; i <= layers; i++)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // ThemeFunctions().getFlutterIcon(
                          //     keyPoints.keypoints[i - 1].flutterIconName,
                          //     size: 28,
                          //     color: colors[i - 1]),
                          Text(
                            keyPoints.keypoints[i - 1].title,
                            style:
                                TextStyle(fontSize: 24, color: colors[i - 1]),
                          )
                        ],
                      ),
                      Text(
                        keyPoints.keypoints[i - 1].shortDescription,
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class ColoredTextMask extends StatelessWidget {
  final List<Color> colors;
  final List<String> labels;

  const ColoredTextMask({
    super.key,
    required this.colors,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final int layers = labels.length;
    assert(colors.length >= layers,
        "You must provide at least as many colors as labels.");

    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        child: ShaderMask(
          shaderCallback: (bounds) {
            double stripeHeight = bounds.height / layers;

            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: List.generate(
                layers * 2,
                (i) => i.isEven ? (i ~/ 2) / layers : ((i ~/ 2) + 1) / layers,
              ),
              colors: List.generate(
                layers * 2,
                (i) => colors[i ~/ 2],
              ),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcIn,
          child: Column(
            children: List.generate(layers, (index) {
              return Expanded(
                child: Center(
                  child: Text(
                    labels[index],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

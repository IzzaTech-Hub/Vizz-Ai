// File: comparison_views.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:napkin/app/data/app_images.dart';
import 'package:napkin/app/data/model_classes/comparison.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/data/theme_assets/theme_animations.dart';
import 'package:napkin/app/data/theme_assets/theme_functions.dart';

class ComparisonViews {
  static Widget getTheme(int index, ComparisonModel model) {
    List<Widget> themes = [
      _theme0(model), _theme1(model),
      //  _theme2(model)
    ];
    return themes[Random().nextInt(themes.length)];
    // switch (index) {
    //   case 0:
    //     return _theme0(model);
    //   case 1:
    //     return _theme1(model);
    //   default:
    //     return _theme0(model);
    // }
  }

  static Widget _theme0(ComparisonModel model) {
    Widget makeArrow(int i) {
      Color thiscolor = ThemeFunctions().getRandomlightColor();
      return SizedBox(
        width: SizeConfig.screenWidth * 0.5,
        child: Stack(
          children: [
            Container(
              color: thiscolor,
            ),
            Image.asset(
              AppImages.arrowlong,
              color: Colors.white,
              // color: thiscolor,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: SizeConfig.screenHeight * 0.085,
                  ),
                  Container(
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: thiscolor),
                    padding: EdgeInsets.all(8),
                    child: ThemeFunctions().getFlutterIcon(
                        model.columns[i].flutterIconName,
                        size: 28,
                        color: Colors.white),
                  ),
                  Text(
                    model.columns[i].title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        // color: ThemeFunctions().getInverseColor(thiscolor),
                        fontSize: 18,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  for (ComparisonRow n in model.rows)
                    Column(
                      children: [
                        Text(
                          n.feature,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  ThemeFunctions().getInverseColor(thiscolor)),
                        ),
                        SizedBox(
                          width: SizeConfig.screenWidth * 0.25,
                          child: Center(
                            child: Text(
                              n.values[i],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                ],
              ),
            )
          ],
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i <= model.columns.length - 1; i++) makeArrow(i)
        ],
      ),
    );
    // return DataTable(
    //   columns: const [
    //     DataColumn(
    //         label: Row(
    //       children: [
    //         Icon(Icons.ac_unit),
    //         Text('Title'),
    //       ],
    //     )),
    //     DataColumn(label: Text('Description')),
    //   ],
    //   rows: model.columns.map((e) {
    //     return DataRow(cells: [
    //       DataCell(Text(e.title)),
    //       DataCell(Text(e.title)),
    //     ]);
    //   }).toList(),
    // );
  }

  static Widget _theme1(ComparisonModel model) {
    return HoneycombLayout(
      model: model,
    );
  }

  // static Widget _theme2(ComparisonModel model) {
  //   ComparisonModel(heading: 'hh', columns: [
  //     ComparisonColumn(title: 'title', flutterIconName: 'number'),
  //     ComparisonColumn(title: 'title', flutterIconName: 'arrow_left')
  //   ], rows: [
  //     ComparisonRow(feature: 'feature', values: ['0', '1'])
  //   ]);
  //   return ListView(
  //     children: model.columns
  //         .map((e) => Card(
  //               child: ListTile(
  //                 // leading: Icon(getIconByName(e.flutterIconName)),
  //                 title: Text(e.title),
  //                 subtitle: Text(e.flutterIconName),
  //               ),
  //             ))
  //         .toList(),
  //   );
  // }
}

class HoneycombLayout extends StatelessWidget {
  // final List<String> keywords;
  final ComparisonModel model;
  const HoneycombLayout({
    Key? key,
    // required this.keywords,
    required this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var keywords = model.rows.map((e) => e.feature).toList();

    // final size = MediaQuery.of(context).size;
    final width = SizeConfig.screenWidth; // Account for padding
    final hexWidth = width * 0.45; // Making hexagons sized relative to screen

    return Container(
      width: width,
      height: SizeConfig.screenHeight,
      color: Colors.amber[100], // Light yellow background
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        for (int i = 0; i < model.columns.length; i++)
                          HexagonCell(
                              width: hexWidth,
                              isHighlighted: i.isEven,
                              child: ThemeAnimations.heartbeatEffect(
                                Text(
                                  model.columns[i].title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              )),
                      ],
                    ),
                    for (int j = 0; j <= model.rows.length - 1; j++)
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 1;
                                  i <= model.columns.length - 1;
                                  i++)
                                // for (ComparisonColumn column in model.columns)
                                HexagonCell(
                                  width: hexWidth,
                                  isHighlighted: i.isOdd,
                                  child: ThemeAnimations.heartbeatEffect(
                                    SizedBox(
                                      width: SizeConfig.screenWidth * 0.24,
                                      child: Text(
                                        model.rows[j].feature,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for (int i = 0;
                                  i <= model.columns.length - 1;
                                  i++)
                                // for (ComparisonColumn column in model.columns)
                                HexagonCell(
                                  width: hexWidth,
                                  isHighlighted: i.isEven,
                                  child: Text(
                                    model.rows[j].values[i],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class HexagonCell extends StatelessWidget {
  final double width;
  // final String text;
  final Widget child;
  final bool isHighlighted;

  const HexagonCell({
    Key? key,
    required this.width,
    // required this.text,
    required this.child,
    this.isHighlighted = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate height based on hexagon geometry
    final height = width * sqrt(3) / 2;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: HexagonPainter(
          color: isHighlighted
              ? Colors.amber
              : Colors.amber[200] ?? Colors.amber.shade200,
          borderColor: Colors.white,
          borderWidth: 8,
        ),
        child: Center(
            child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: child,
        )),
      ),
    );
  }
}

class HexagonPainter extends CustomPainter {
  final Color color;
  final Color borderColor;
  final double borderWidth;

  HexagonPainter({
    required this.color,
    required this.borderColor,
    this.borderWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    const numberOfSides = 6;
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width / 2;

    // Starting angle from the right middle (for flat-topped hexagon)
    const double startAngle = -pi / 2;

    path.moveTo(
      centerX + radius * cos(startAngle),
      centerY + radius * sin(startAngle),
    );

    for (int i = 1; i <= numberOfSides; i++) {
      final angle = startAngle + i * 2 * pi / numberOfSides;
      path.lineTo(
        centerX + radius * cos(angle),
        centerY + radius * sin(angle),
      );
    }

    path.close();
    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant HexagonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}

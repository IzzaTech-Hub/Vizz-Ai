import 'dart:math';

import 'package:flutter/material.dart';
import 'package:napkin/app/data/model_classes/graph_class.dart';
import 'package:napkin/app/data/theme_assets/theme_functions.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';

class GraphViews {
  static Widget getTheme(int index, GraphModel model) {
    List<Widget> themes = [_theme0(model)];
    return themes[Random().nextInt(themes.length)];
    // switch (index) {
    //   case 0:
    //     return _theme0(model);
    //   default:
    //     return _theme0(model);
    // }
  }

  static Widget _theme0(GraphModel model) {
    final random = Random();
    List<_PieData> pieData = [];
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
      Colors.deepPurple,
    ];
    final availableColors = [...colors];
    for (int i = 0; i < model.dataPoints.length; i++) {
      int colorIndex = random.nextInt(availableColors.length);
      final selectedColor = availableColors.removeAt(colorIndex);
      pieData.add(_PieData(
          model.dataPoints[i].label,
          model.dataPoints[i].value,
          selectedColor,
          ThemeFunctions().getFlutterIcon(model.dataPoints[i].flutterIconName,
              color: selectedColor),
          model.dataPoints[i].description,
          model.dataPoints[i].value.toString()));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // SfCircularChart(
          //     title: ChartTitle(text: model.heading ?? 'Chart'),
          //     legend: Legend(
          //         isVisible: false,
          //         position: LegendPosition.right,
          //         legendItemBuilder:
          //             (String name, dynamic series, dynamic point, int index) {
          //           final item = pieData[index];
          //           return Text(
          //             item.xData,
          //             style: TextStyle(
          //                 color: item.color,
          //                 fontWeight: FontWeight.bold), // Customize label color
          //           );
          //         }),
          //     tooltipBehavior: TooltipBehavior(enable: true),
          //     series: <PieSeries<_PieData, String>>[
          //       PieSeries<_PieData, String>(
          //           dataSource: pieData,
          //           xValueMapper: (_PieData data, _) => data.xData,
          //           yValueMapper: (_PieData data, _) => data.yData,
          //           pointColorMapper: (_PieData data, _) => data.color,
          //           dataLabelMapper: (_PieData data, _) => data.text,
          //           dataLabelSettings: DataLabelSettings(isVisible: true)),
          //     ]), // your chart

          const SizedBox(height: 16),

          ...pieData.map((data) {
            return ListTile(
              leading: data.icon,
              //  data.icon != null ? Icon(data.icon) : null,
              title: Text(
                data.xData,
                style:
                    TextStyle(color: data.color, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data.description ?? ''),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _PieData {
  _PieData(this.xData, this.yData, this.color, this.icon, this.description,
      [this.text]);
  final String xData;
  final String description;
  final Icon icon;
  final num yData;
  final Color color;
  String? text;
}

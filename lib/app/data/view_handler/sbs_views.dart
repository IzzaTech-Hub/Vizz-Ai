// File: sbs_views.dart
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:napkin/app/data/model_classes/sbs.dart';
import 'package:napkin/app/data/size_config.dart';
import 'package:napkin/app/data/theme_assets/theme_functions.dart';

class StepByStepViews {
  static Widget getTheme(int index, StepByStepModel model) {
       List<Widget> themes = [_theme0(model), _theme1(model)];
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

  static Widget _theme0(StepByStepModel model) {
    return StepChainView(
      titles: model.steps.map((e) => e.title).toList(),
      subtitles: model.steps.map((e) => e.description).toList(),
      iconsnames: model.steps.map((e) => e.flutterIconName).toList(),
      steps: model.steps.length,
    );
    //  ListView.builder(
    //   itemCount: model.steps.length,
    //   itemBuilder: (context, i) {
    //     final step = model.steps[i];
    //     return ListTile(
    //       leading: CircleAvatar(child: Text('${i + 1}')),
    //       title: Text(step.title),
    //       subtitle: Text(step.description),
    //     );
    //   },
    // );
  }

  static Widget _theme1(StepByStepModel model) {
    return Column(
      children: model.steps.asMap().entries.map((entry) {
        int i = entry.key;
        var step = entry.value;
        return ListTile(
          leading: Icon(getIconByName(step.flutterIconName)),
          title: Text('Step ${i + 1}: ${step.title}'),
          subtitle: Text(step.description),
        );
      }).toList(),
    );
  }

  static IconData getIconByName(String name) {
    return Icons.numbers;
  }
}

class StepChainView extends StatelessWidget {
  final List<String> titles;
  final List<String> subtitles;
  final List<String> iconsnames;
  final int steps;

  const StepChainView({
    Key? key,
    required this.titles,
    required this.subtitles,
    required this.iconsnames,
    required this.steps,
  }) : super(key: key);

  Color getStepColor(int index) {
    // return Colors.blue[100 * (index + 1)]!;
    final baseColor = Colors.blue;
    final factor = 1.0 - (index * 0.2);
    return baseColor.withOpacity(max(factor, 0.2));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Stack(
        // crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(steps, (index) {
          final isRight = index.isOdd;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              children: [
                for (int ir = 1; ir <= index; ir++)
                  SizedBox(height: SizeConfig.screenWidth * 0.25),
                Row(
                  mainAxisAlignment:
                      isRight ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    SizedBox(
                        // width: SizeConfig.screenWidth,
                        ),
                    // if (!isRight) const SizedBox(height: 40),
                    _buildLink(index, titles[index], subtitles[index],
                        iconsnames[index], context),
                    // if (isRight) const SizedBox(height: 40),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLink(int index, String title, String subtitle, String icon,
      BuildContext context) {
    final color = ThemeFunctions().getRandomlightColor();
    // final color = getStepColor(index);
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Step ${index + 1} : $title'),
              content:
                  //  Text(
                  //   title,
                  //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  // ),
                  Text(
                subtitle,
                style: TextStyle(fontSize: 14),
              ),
              actions: [
                TextButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop(); // closes the dialog
                  },
                ),
              ],
            );
          },
        );
      },
      child: Column(
        children: [
          // Text(
          //   title,
          //   style: const TextStyle(fontWeight: FontWeight.bold),
          // ),
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: SizeConfig.screenWidth * 0.45,
                width: SizeConfig.screenWidth * 0.65,
                decoration: BoxDecoration(
                  border: Border.all(color: color, width: 15),
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
              Row(
                children: [
                  if (index.isEven)
                    ThemeFunctions()
                        .getFlutterIcon(icon, color: color, size: 30),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(' $title',
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                  // Text('${index + 1}. $title', style: TextStyle(color: color)),
                  if (index.isOdd)
                    ThemeFunctions()
                        .getFlutterIcon(icon, color: color, size: 30),
                ],
              ),
            ],
          ),
          // Text(
          //   subtitle,
          //   style: const TextStyle(fontSize: 12),
          // ),
        ],
      ),
    );
  }
}

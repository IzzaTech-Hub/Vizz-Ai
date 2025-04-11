import 'package:flutter/material.dart';
import 'package:napkin/app/data/model_classes/comparison.dart';
import 'package:napkin/app/data/model_classes/graph_class.dart';
import 'package:napkin/app/data/model_classes/hierarchy.dart';
import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/model_classes/sbs.dart';

// All views and themes
import 'hierarchy_views.dart';
import 'graph_views.dart';
import 'comparison_views.dart';
import 'keypoints_views.dart';
import 'sbs_views.dart';

class ViewHandler extends StatelessWidget {
  final String type;
  final HierarchyModel? hierarchy;
  final KeyPoints? keyPoints;
  final GraphModel? graph;
  final ComparisonModel? comparison;
  final StepByStepModel? sbs;
  final int themeIndex;

  const ViewHandler({
    super.key,
    required this.type,
    this.hierarchy,
    this.keyPoints,
    this.graph,
    this.comparison,
    this.sbs,
    this.themeIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case 'hierarchy':
        return HierarchyViews.getTheme(themeIndex, hierarchy!);

      case 'graph':
        return GraphViews.getTheme(themeIndex, graph!);

      case 'comparison':
      case 'comparison/differentiate':
        return ComparisonViews.getTheme(themeIndex, comparison!);

      case 'key_points':
        return KeyPointsViews.getTheme(themeIndex, keyPoints!);

      case 'step_by_step':
        return StepByStepViews.getTheme(themeIndex, sbs!);

      default:
        return const Center(child: Text('Unsupported type'));
    }
  }
}

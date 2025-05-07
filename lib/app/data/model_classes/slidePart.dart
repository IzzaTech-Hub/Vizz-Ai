import 'package:get/get.dart';
import 'package:napkin/app/data/model_classes/comparison.dart';
import 'package:napkin/app/data/model_classes/graph_class.dart';
import 'package:napkin/app/data/model_classes/hierarchy.dart';
import 'package:napkin/app/data/model_classes/key_points.dart';
import 'package:napkin/app/data/model_classes/sbs.dart';

class SlidePart {
  String slideContent;
  String type;
  HierarchyModel? hierarchy;
  KeyPoints? keyPoints;
  GraphModel? graph;
  ComparisonModel? comparison;
  StepByStepModel? sbs;
  String? heading;
  RxBool isShowGraph;

  // Updated constructor for SlidePart
  SlidePart({
    required this.slideContent,
    required this.type,
    this.hierarchy,
    this.keyPoints,
    this.graph,
    this.comparison,
    this.sbs,
    this.heading,
    bool isShowGraph = false, // Accept a normal bool value
  }) : isShowGraph = isShowGraph.obs; // Convert it to RxBool using .obs

  // Factory constructor to create an instance from a map
  factory SlidePart.fromMap(Map<String, dynamic> map) {
    return SlidePart(
      slideContent: map['slideContent'],
      type: map['type'],
      hierarchy: map['hierarchy'],
      keyPoints: map['keyPoints'],
      graph: map['graph'],
      comparison: map['comparison'],
      sbs: map['sbs'],
      heading: map['heading'],
      isShowGraph:
          map['isShowGraph'] ?? false, // Default to false if not provided
    );
  }

  // Method to convert an instance to a map
  Map<String, dynamic> toMap() {
    return {
      'slideContent': slideContent,
      'type': type,
      'hierarchy': hierarchy,
      'keyPoints': keyPoints,
      'graph': graph,
      'comparison': comparison,
      'sbs': sbs,
      'heading': heading,
      'isShowGraph':
          isShowGraph.value, // Use .value to get the bool value from RxBool
    };
  }
}

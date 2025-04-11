import 'package:flutter/material.dart';
import 'package:napkin/app/data/model_classes/hierarchy.dart';

class HierarchyViews {
  static Widget getTheme(int index, HierarchyModel model) {
    switch (index) {
      case 0:
        return _theme0(model);
      case 1:
        return _theme1(model);
      default:
        return _theme0(model);
    }
  }

  static Widget _theme0(HierarchyModel model) {
    return ListView(
      children: model.nodes.map((e) {
        return ListTile(
          leading: Icon(getIconByName(e.flutterIconName)),
          title: Text(e.title),
          subtitle: Text(e.description),
        );
      }).toList(),
    );
  }

  static Widget _theme1(HierarchyModel model) {
    return GridView.count(
      crossAxisCount: 2,
      children: model.nodes.map((e) {
        return Card(
          child: Column(
            children: [
              Icon(getIconByName(e.flutterIconName), size: 40),
              Text(e.title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(e.description),
            ],
          ),
        );
      }).toList(),
    );
  }

  static IconData getIconByName(String name) {
    // Replace with actual icon mapping
    return Icons.category;
  }
}

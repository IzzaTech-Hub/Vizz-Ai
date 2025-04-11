class HierarchyNode {
  final String title;
  final String flutterIconName;
  final String description;
  final List<HierarchyNode> children;

  HierarchyNode({
    required this.title,
    required this.flutterIconName,
    required this.description,
    this.children = const [],
  });

  factory HierarchyNode.fromJson(Map<String, dynamic> json) => HierarchyNode(
        title: json['title'],
        flutterIconName: json['flutter_icon_name'],
        description: json['description'],
        children: (json['children'] as List<dynamic>?)
                ?.map((e) => HierarchyNode.fromJson(e))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'flutter_icon_name': flutterIconName,
        'description': description,
        'children': children.map((e) => e.toJson()).toList(),
      };
}

class HierarchyModel {
  final String heading;
  final List<HierarchyNode> nodes;

  HierarchyModel({required this.heading, required this.nodes});

  factory HierarchyModel.fromJson(Map<String, dynamic> json) => HierarchyModel(
        heading: json['heading'],
        nodes: (json['nodes'] as List<dynamic>)
            .map((e) => HierarchyNode.fromJson(e))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'heading': heading,
        'nodes': nodes.map((e) => e.toJson()).toList(),
      };
}

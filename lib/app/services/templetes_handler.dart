import 'package:flutter/material.dart';
import 'package:napkin/app/data/models/templete.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TempletesHandler {
  static List<Templete> templates = [];

  static Future<void> initialize() async {
    templates = await fetchTemplatesFromFirebase();
  }

  static const String _localTemplatesKey = 'downloaded_templates';

  // Fetch templates metadata from Firestore
  static Future<List<Templete>> fetchTemplatesFromFirebase() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('templetes').get();
    List<Templete> templates = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      templates.add(Templete.fromJson({
        ...data,
        'id': doc.id,
        'localImagePaths': await _getLocalImagePaths(doc.id),
      }));
    }
    return templates;
  }

  // Download images for a template and save locally, then persist info
  static Future<List<String>> downloadTemplateImages(Templete templete) async {
    final dir = await getApplicationDocumentsDirectory();
    List<String> localPaths = [];
    for (int i = 0; i < templete.imageUrls.length; i++) {
      final url = templete.imageUrls[i];
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final filePath = '${dir.path}/${templete.id}_img_$i.png';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        localPaths.add(filePath);
      }
    }
    await saveTemplateLocally(templete, localPaths);
    return localPaths;
  }

  // Save downloaded template info in shared_preferences
  static Future<void> saveTemplateLocally(
      Templete templete, List<String> localPaths) async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getString(_localTemplatesKey);
    Map<String, dynamic> templatesMap =
        templatesJson != null ? json.decode(templatesJson) : {};
    templatesMap[templete.id] = {
      'id': templete.id,
      'name': templete.name,
      'previewImageUrl': templete.previewImageUrl,
      'imageUrls': templete.imageUrls,
      'localImagePaths': localPaths,
      'titleColor': templete.titleColorHex,
      'textColor': templete.textColorHex,
    };
    await prefs.setString(_localTemplatesKey, json.encode(templatesMap));
  }

  // Get local image paths for a template id
  static Future<List<String>> _getLocalImagePaths(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getString(_localTemplatesKey);
    if (templatesJson == null) return [];
    final templatesMap = json.decode(templatesJson);
    if (templatesMap[templateId] != null &&
        templatesMap[templateId]['localImagePaths'] != null) {
      return List<String>.from(templatesMap[templateId]['localImagePaths']);
    }
    return [];
  }

  // Check if a template is downloaded (all images exist locally)
  static Future<bool> isTemplateDownloaded(Templete templete) async {
    final localPaths = await _getLocalImagePaths(templete.id);
    if (localPaths.isEmpty) return false;
    for (final path in localPaths) {
      if (!await File(path).exists()) return false;
    }
    return true;
  }

  // Get templates that are downloaded (from shared_preferences)
  static Future<List<Templete>> getLocalTemplates() async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = prefs.getString(_localTemplatesKey);
    if (templatesJson == null) return [];
    final templatesMap = json.decode(templatesJson);
    List<Templete> templates = [];
    templatesMap.forEach((id, data) {
      templates.add(Templete.fromJson({...data, 'id': id}));
    });
    return templates;
  }
}

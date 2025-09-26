import 'package:flutter/material.dart';
import 'package:napkin/app/data/models/templete.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:crypto/crypto.dart';

/// Scalable and dynamic template handler that manages local storage
/// and syncs with Firebase automatically
class TempletesHandler {
  static TempletesHandler? _instance;
  static TempletesHandler get instance => _instance ??= TempletesHandler._();
  
  TempletesHandler._();

  // Storage keys
  static const String _localTemplatesKey = 'downloaded_templates';
  static const String _templateMetadataKey = 'template_metadata';
  static const String _lastSyncKey = 'last_sync_timestamp';
  static const String _downloadQueueKey = 'download_queue';
  
  // Cache and state management
  List<Templete> _cachedTemplates = [];
  bool _isInitialized = false;
  bool _isSyncing = false;
  final Set<String> _downloadingTemplates = {};
  final StreamController<List<Templete>> _templatesController = StreamController.broadcast();
  final StreamController<TemplateDownloadProgress> _downloadProgressController = StreamController.broadcast();
  
  // Configuration
  static const Duration _syncInterval = Duration(hours: 6);
  static const int _maxConcurrentDownloads = 3;
  static const int _retryAttempts = 3;
  
  /// Stream of template updates
  Stream<List<Templete>> get templatesStream => _templatesController.stream;
  
  /// Stream of download progress updates
  Stream<TemplateDownloadProgress> get downloadProgressStream => _downloadProgressController.stream;
  
  /// Get cached templates (available immediately)
  List<Templete> get cachedTemplates => List.unmodifiable(_cachedTemplates);
  
  /// Check if handler is initialized
  bool get isInitialized => _isInitialized;
  
  /// Initialize the template handler - call this at app startup
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    debugPrint('🚀 Initializing TempletesHandler...');
    
    try {
      // Load cached templates first for immediate availability
      await _loadCachedTemplates();
      
      // Start background sync process
      _startBackgroundSync();
      
      // Process any pending downloads
      _processPendingDownloads();
      
      _isInitialized = true;
      debugPrint('✅ TempletesHandler initialized successfully');
      
    } catch (e) {
      debugPrint('❌ Failed to initialize TempletesHandler: $e');
      rethrow;
    }
  }
  
  /// Get templates with automatic sync and download management
  Future<List<Templete>> getTemplates({bool forceSync = false}) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    if (forceSync || _shouldSync()) {
      await _syncWithFirebase();
    }
    
    return _cachedTemplates;
  }
  
  /// Get a specific template by ID
  Future<Templete?> getTemplateById(String templateId) async {
    final templates = await getTemplates();
    try {
      return templates.firstWhere((t) => t.id == templateId);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if template images are available locally
  Future<bool> isTemplateAvailableLocally(String templateId) async {
    final localPaths = await _getLocalImagePaths(templateId);
    if (localPaths.isEmpty) return false;
    
    // Verify all files exist
    for (final path in localPaths) {
      if (!await File(path).exists()) {
        // Clean up invalid entries
        await _removeInvalidLocalTemplate(templateId);
        return false;
      }
    }
    return true;
  }
  
  /// Download template images with progress tracking
  Future<bool> downloadTemplate(String templateId, {bool priority = false}) async {
    if (_downloadingTemplates.contains(templateId)) {
      debugPrint('⏳ Template $templateId is already being downloaded');
      return false;
    }
    
    final template = await getTemplateById(templateId);
    if (template == null) {
      debugPrint('❌ Template $templateId not found');
      return false;
    }
    
    if (await isTemplateAvailableLocally(templateId)) {
      debugPrint('✅ Template $templateId already available locally');
      return true;
    }
    
    if (priority) {
      return await _downloadTemplateImages(template);
    } else {
      await _addToDownloadQueue(templateId);
      _processPendingDownloads();
      return true;
    }
  }
  
  /// Force refresh from Firebase
  Future<void> refreshFromFirebase() async {
    await _syncWithFirebase(force: true);
  }
  
  /// Clear all local template data
  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_localTemplatesKey);
    await prefs.remove(_templateMetadataKey);
    await prefs.remove(_lastSyncKey);
    await prefs.remove(_downloadQueueKey);
    
    // Delete local files
    final dir = await _getTemplatesDirectory();
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
    
    _cachedTemplates.clear();
    _templatesController.add(_cachedTemplates);
    
    debugPrint('🗑️ Cleared all local template data');
  }
  
  /// Get storage usage statistics
  Future<TemplateStorageStats> getStorageStats() async {
    final dir = await _getTemplatesDirectory();
    int totalFiles = 0;
    int totalSize = 0;
    
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          totalFiles++;
          totalSize += await entity.length();
        }
      }
    }
    
    return TemplateStorageStats(
      totalTemplates: _cachedTemplates.length,
      downloadedTemplates: _cachedTemplates.where((t) => t.localImagePaths.isNotEmpty).length,
      totalFiles: totalFiles,
      totalSizeBytes: totalSize,
    );
  }
  
  // Private methods
  
  Future<void> _loadCachedTemplates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final templatesJson = prefs.getString(_templateMetadataKey);
      
      if (templatesJson != null) {
        final templatesData = json.decode(templatesJson) as Map<String, dynamic>;
        _cachedTemplates = templatesData.entries.map((entry) {
          return Templete.fromJson({...entry.value, 'id': entry.key});
        }).toList();
        
        debugPrint('📱 Loaded ${_cachedTemplates.length} cached templates');
        _templatesController.add(_cachedTemplates);
      }
    } catch (e) {
      debugPrint('⚠️ Failed to load cached templates: $e');
    }
  }
  
  void _startBackgroundSync() {
    Timer.periodic(_syncInterval, (timer) {
      if (!_isSyncing) {
        _syncWithFirebase();
      }
    });
  }
  
  bool _shouldSync() {
    // Implement logic to determine if sync is needed
    // For now, sync every time if not syncing
    return !_isSyncing;
  }
  
  Future<void> _syncWithFirebase({bool force = false}) async {
    if (_isSyncing && !force) return;
    
    _isSyncing = true;
    debugPrint('🔄 Syncing templates with Firebase...');
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('templetes')
          .get();
      
      final Map<String, Templete> newTemplates = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final templateId = doc.id;
        
        // Get local image paths if available
        final localPaths = await _getLocalImagePaths(templateId);
        
        final template = Templete.fromJson({
          ...data,
          'id': templateId,
          'localImagePaths': localPaths,
        });
        
        newTemplates[templateId] = template;
      }
      
      // Update cache
      _cachedTemplates = newTemplates.values.toList();
      
      // Save to local storage
      await _saveTemplateMetadata(newTemplates);
      
      // Update last sync timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
      
      _templatesController.add(_cachedTemplates);
      
      debugPrint('✅ Synced ${_cachedTemplates.length} templates from Firebase');
      
    } catch (e) {
      debugPrint('❌ Failed to sync with Firebase: $e');
    } finally {
      _isSyncing = false;
    }
  }
  
  Future<void> _saveTemplateMetadata(Map<String, Templete> templates) async {
    final prefs = await SharedPreferences.getInstance();
    final templatesJson = templates.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_templateMetadataKey, json.encode(templatesJson));
  }
  
  Future<List<String>> _getLocalImagePaths(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final localData = prefs.getString(_localTemplatesKey);
    
    if (localData != null) {
      final localTemplates = json.decode(localData) as Map<String, dynamic>;
      if (localTemplates.containsKey(templateId)) {
        return List<String>.from(localTemplates[templateId]['localImagePaths'] ?? []);
      }
    }
    
    return [];
  }
  
  Future<bool> _downloadTemplateImages(Templete template) async {
    if (_downloadingTemplates.contains(template.id)) return false;
    
    _downloadingTemplates.add(template.id);
    debugPrint('⬇️ Downloading images for template: ${template.name}');
    
    try {
      final dir = await _getTemplatesDirectory();
      final List<String> localPaths = [];
      
      for (int i = 0; i < template.imageUrls.length; i++) {
        final url = template.imageUrls[i];
        final fileName = '${template.id}_${_generateFileHash(url)}_$i.png';
        final filePath = '${dir.path}/$fileName';
        
        // Update progress
        _downloadProgressController.add(TemplateDownloadProgress(
          templateId: template.id,
          templateName: template.name,
          currentImage: i + 1,
          totalImages: template.imageUrls.length,
          isComplete: false,
        ));
        
        bool downloaded = false;
        for (int attempt = 0; attempt < _retryAttempts && !downloaded; attempt++) {
          try {
            final response = await http.get(Uri.parse(url));
            if (response.statusCode == 200) {
              final file = File(filePath);
              await file.create(recursive: true);
              await file.writeAsBytes(response.bodyBytes);
              localPaths.add(filePath);
              downloaded = true;
            }
          } catch (e) {
            debugPrint('⚠️ Attempt ${attempt + 1} failed for ${template.id}_$i: $e');
            if (attempt == _retryAttempts - 1) {
              throw e;
            }
            await Future.delayed(Duration(seconds: attempt + 1));
          }
        }
      }
      
      // Save local template data
      await _saveLocalTemplateData(template, localPaths);
      
      // Update cached template
      final updatedTemplate = Templete(
        id: template.id,
        name: template.name,
        imageUrls: template.imageUrls,
        localImagePaths: localPaths,
        titleColorHex: template.titleColorHex,
        textColorHex: template.textColorHex,
      );
      
      final index = _cachedTemplates.indexWhere((t) => t.id == template.id);
      if (index != -1) {
        _cachedTemplates[index] = updatedTemplate;
        _templatesController.add(_cachedTemplates);
      }
      
      // Complete progress
      _downloadProgressController.add(TemplateDownloadProgress(
        templateId: template.id,
        templateName: template.name,
        currentImage: template.imageUrls.length,
        totalImages: template.imageUrls.length,
        isComplete: true,
      ));
      
      debugPrint('✅ Successfully downloaded template: ${template.name}');
      return true;
      
    } catch (e) {
      debugPrint('❌ Failed to download template ${template.name}: $e');
      return false;
    } finally {
      _downloadingTemplates.remove(template.id);
    }
  }
  
  Future<void> _saveLocalTemplateData(Templete template, List<String> localPaths) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getString(_localTemplatesKey);
    
    Map<String, dynamic> localTemplates = existingData != null 
        ? json.decode(existingData) 
        : {};
    
    localTemplates[template.id] = {
      'localImagePaths': localPaths,
      'downloadedAt': DateTime.now().millisecondsSinceEpoch,
    };
    
    await prefs.setString(_localTemplatesKey, json.encode(localTemplates));
  }
  
  Future<Directory> _getTemplatesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final templatesDir = Directory('${appDir.path}/templates');
    if (!await templatesDir.exists()) {
      await templatesDir.create(recursive: true);
    }
    return templatesDir;
  }
  
  String _generateFileHash(String input) {
    return md5.convert(input.codeUnits).toString().substring(0, 8);
  }
  
  Future<void> _removeInvalidLocalTemplate(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final existingData = prefs.getString(_localTemplatesKey);
    
    if (existingData != null) {
      Map<String, dynamic> localTemplates = json.decode(existingData);
      localTemplates.remove(templateId);
      await prefs.setString(_localTemplatesKey, json.encode(localTemplates));
    }
  }
  
  Future<void> _addToDownloadQueue(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final queueData = prefs.getString(_downloadQueueKey);
    
    Set<String> queue = queueData != null 
        ? Set<String>.from(json.decode(queueData)) 
        : <String>{};
    
    queue.add(templateId);
    await prefs.setString(_downloadQueueKey, json.encode(queue.toList()));
  }
  
  void _processPendingDownloads() async {
    if (_downloadingTemplates.length >= _maxConcurrentDownloads) return;
    
    final prefs = await SharedPreferences.getInstance();
    final queueData = prefs.getString(_downloadQueueKey);
    
    if (queueData != null) {
      final queue = List<String>.from(json.decode(queueData));
      
      for (final templateId in queue) {
        if (_downloadingTemplates.length >= _maxConcurrentDownloads) break;
        
        if (!await isTemplateAvailableLocally(templateId)) {
          final template = await getTemplateById(templateId);
          if (template != null) {
            _downloadTemplateImages(template).then((_) {
              _removeFromDownloadQueue(templateId);
              _processPendingDownloads(); // Process next in queue
            });
          }
        } else {
          _removeFromDownloadQueue(templateId);
        }
      }
    }
  }
  
  Future<void> _removeFromDownloadQueue(String templateId) async {
    final prefs = await SharedPreferences.getInstance();
    final queueData = prefs.getString(_downloadQueueKey);
    
    if (queueData != null) {
      final queue = List<String>.from(json.decode(queueData));
      queue.remove(templateId);
      await prefs.setString(_downloadQueueKey, json.encode(queue));
    }
  }
  
  /// Dispose resources
  void dispose() {
    _templatesController.close();
    _downloadProgressController.close();
  }
  
  // Backward compatibility methods for existing code
  
  /// Legacy method - use getTemplates() instead
  static Future<List<Templete>> fetchTemplatesFromFirebase() async {
    return await instance.getTemplates();
  }
  
  /// Legacy method - use isTemplateAvailableLocally() instead
  static Future<bool> isTemplateDownloaded(Templete template) async {
    return await instance.isTemplateAvailableLocally(template.id);
  }
  
  /// Legacy method - use downloadTemplate() instead
  static Future<List<String>> downloadTemplateImages(Templete template) async {
    final success = await instance.downloadTemplate(template.id, priority: true);
    if (success) {
      return await instance._getLocalImagePaths(template.id);
    }
    return [];
  }
  
  /// Legacy method - use getTemplates() instead
  static Future<List<Templete>> getLocalTemplates() async {
    final templates = await instance.getTemplates();
    return templates.where((t) => t.localImagePaths.isNotEmpty).toList();
  }
}

/// Progress tracking for template downloads
class TemplateDownloadProgress {
  final String templateId;
  final String templateName;
  final int currentImage;
  final int totalImages;
  final bool isComplete;
  
  TemplateDownloadProgress({
    required this.templateId,
    required this.templateName,
    required this.currentImage,
    required this.totalImages,
    required this.isComplete,
  });
  
  double get progress => totalImages > 0 ? currentImage / totalImages : 0.0;
}

/// Storage statistics for templates
class TemplateStorageStats {
  final int totalTemplates;
  final int downloadedTemplates;
  final int totalFiles;
  final int totalSizeBytes;
  
  TemplateStorageStats({
    required this.totalTemplates,
    required this.downloadedTemplates,
    required this.totalFiles,
    required this.totalSizeBytes,
  });
  
  String get formattedSize {
    if (totalSizeBytes < 1024) return '${totalSizeBytes}B';
    if (totalSizeBytes < 1024 * 1024) return '${(totalSizeBytes / 1024).toStringAsFixed(1)}KB';
    return '${(totalSizeBytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }
}

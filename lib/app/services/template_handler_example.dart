import 'package:flutter/material.dart';
import 'dart:io';
import 'package:napkin/app/services/templetes_handler.dart';
import 'package:napkin/app/data/models/templete.dart';

/// Example usage of the new TempletesHandler
/// This demonstrates how to use the scalable template handler
class TemplateHandlerExample extends StatefulWidget {
  @override
  _TemplateHandlerExampleState createState() => _TemplateHandlerExampleState();
}

class _TemplateHandlerExampleState extends State<TemplateHandlerExample> {
  final TempletesHandler _handler = TempletesHandler.instance;
  List<Templete> _templates = [];
  TemplateStorageStats? _stats;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
    _listenToUpdates();
  }

  void _loadTemplates() async {
    setState(() => _isLoading = true);
    
    try {
      // Get templates (will auto-sync if needed)
      final templates = await _handler.getTemplates();
      final stats = await _handler.getStorageStats();
      
      setState(() {
        _templates = templates;
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading templates: $e');
      setState(() => _isLoading = false);
    }
  }

  void _listenToUpdates() {
    // Listen to template updates
    _handler.templatesStream.listen((templates) {
      setState(() {
        _templates = templates;
      });
    });

    // Listen to download progress
    _handler.downloadProgressStream.listen((progress) {
      print('Download progress: ${progress.templateName} - ${(progress.progress * 100).toInt()}%');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Template Handler Example'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _handler.refreshFromFirebase(),
          ),
          IconButton(
            icon: Icon(Icons.info),
            onPressed: _showStats,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats card
                if (_stats != null) _buildStatsCard(),
                
                // Templates list
                Expanded(
                  child: ListView.builder(
                    itemCount: _templates.length,
                    itemBuilder: (context, index) {
                      final template = _templates[index];
                      return _buildTemplateCard(template);
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _clearLocalData,
        child: Icon(Icons.delete),
        tooltip: 'Clear Local Data',
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: EdgeInsets.all(16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Storage Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Total Templates: ${_stats!.totalTemplates}'),
            Text('Downloaded: ${_stats!.downloadedTemplates}'),
            Text('Storage Used: ${_stats!.formattedSize}'),
            Text('Files: ${_stats!.totalFiles}'),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateCard(Templete template) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: _getTemplatePreviewImage(template),
        ),
        title: Text(template.name),
        subtitle: Text('Images: ${template.imageUrls.length}'),
        trailing: FutureBuilder<bool>(
          future: _handler.isTemplateAvailableLocally(template.id),
          builder: (context, snapshot) {
            final isLocal = snapshot.data ?? false;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isLocal ? Icons.download_done : Icons.download,
                  color: isLocal ? Colors.green : Colors.grey,
                ),
                SizedBox(width: 8),
                if (!isLocal)
                  ElevatedButton(
                    onPressed: () => _downloadTemplate(template.id),
                    child: Text('Download'),
                  ),
              ],
            );
          },
        ),
        onTap: () => _showTemplateDetails(template),
      ),
    );
  }

  ImageProvider _getTemplatePreviewImage(Templete template) {
    if (template.localImagePaths.isNotEmpty && File(template.localImagePaths.first).existsSync()) {
      return FileImage(File(template.localImagePaths.first));
    } else if (template.imageUrls.isNotEmpty) {
      return NetworkImage(template.imageUrls.first);
    } else {
      return const AssetImage('assets/placeholder.png'); // Ensure you have a placeholder image asset
    }
  }


  void _downloadTemplate(String templateId) async {
    try {
      await _handler.downloadTemplate(templateId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Template download started')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  void _showTemplateDetails(Templete template) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(template.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${template.id}'),
            Text('Images: ${template.imageUrls.length}'),
            Text('Local Images: ${template.localImagePaths.length}'),
            Text('Title Color: ${template.titleColorHex}'),
            Text('Text Color: ${template.textColorHex}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showStats() async {
    final stats = await _handler.getStorageStats();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Storage Statistics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Templates: ${stats.totalTemplates}'),
            Text('Downloaded Templates: ${stats.downloadedTemplates}'),
            Text('Total Files: ${stats.totalFiles}'),
            Text('Storage Used: ${stats.formattedSize}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _clearLocalData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear Local Data'),
        content: Text('This will delete all downloaded templates. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handler.clearLocalData();
      _loadTemplates();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Local data cleared')),
      );
    }
  }
}

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:mobcraft_storage/mobcraft_storage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobcraft Storage Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const StorageExamplePage(),
    );
  }
}

class StorageExamplePage extends StatefulWidget {
  const StorageExamplePage({super.key});

  @override
  State<StorageExamplePage> createState() => _StorageExamplePageState();
}

class _StorageExamplePageState extends State<StorageExamplePage> {
  final _apiKeyController = TextEditingController();
  MobcraftStorage? _storage;
  StorageQuota? _quota;
  List<StorageFile> _files = [];
  bool _isLoading = false;
  String? _error;
  String? _message;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _storage?.close();
    super.dispose();
  }

  void _initializeStorage() {
    final apiKey = _apiKeyController.text.trim();
    if (apiKey.isEmpty) {
      setState(() => _error = 'Please enter an API key');
      return;
    }

    setState(() {
      _storage = MobcraftStorage(apiKey: apiKey);
      _error = null;
      _message = 'Storage initialized successfully';
    });

    _loadQuota();
    _loadFiles();
  }

  Future<void> _loadQuota() async {
    if (_storage == null) return;

    setState(() => _isLoading = true);
    try {
      final quota = await _storage!.getQuota();
      setState(() {
        _quota = quota;
        _error = null;
      });
    } on MobcraftException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadFiles() async {
    if (_storage == null) return;

    setState(() => _isLoading = true);
    try {
      final response = await _storage!.listFiles(limit: 50);
      setState(() {
        _files = response.items;
        _error = null;
      });
    } on MobcraftException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadFile() async {
    if (_storage == null) {
      setState(() => _error = 'Please initialize storage first');
      return;
    }

    final result = await FilePicker.platform.pickFiles();
    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.first.path!);

    setState(() {
      _isLoading = true;
      _message = 'Uploading ${result.files.first.name}...';
    });

    try {
      final uploadResult = await _storage!.uploadFile(file);
      setState(() {
        _message = 'Uploaded successfully: ${uploadResult.fileName}';
        _error = null;
      });
      await _loadQuota();
      await _loadFiles();
    } on QuotaExceededException catch (e) {
      setState(() => _error = 'Quota exceeded: ${e.message}');
    } on FileSizeLimitException catch (e) {
      setState(() => _error = 'File too large: ${e.message}');
    } on MobcraftException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteFile(StorageFile file) async {
    if (_storage == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: Text('Are you sure you want to delete "${file.fileName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await _storage!.deleteFile(file.id);
      setState(() {
        _message = 'Deleted ${file.fileName}';
        _error = null;
      });
      await _loadQuota();
      await _loadFiles();
    } on MobcraftException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadFile(StorageFile file) async {
    if (_storage == null) return;

    setState(() {
      _isLoading = true;
      _message = 'Downloading ${file.fileName}...';
    });

    try {
      final url = await _storage!.getDownloadUrl(file.id);
      setState(() {
        _message = 'Download URL: $url';
        _error = null;
      });
    } on MobcraftException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobcraft Storage Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // API Key Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'API Key',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        hintText: 'Enter your Mobcraft API key',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _initializeStorage,
                      child: const Text('Initialize'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Messages
            if (_error != null)
              Card(
                color: Colors.red.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade900),
                  ),
                ),
              ),

            if (_message != null && _error == null)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _message!,
                    style: TextStyle(color: Colors.green.shade900),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Quota Card
            if (_quota != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Storage Quota',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Chip(
                            label: Text(_quota!.tier.toUpperCase()),
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _quota!.storagePercentage / 100,
                        backgroundColor: Colors.grey.shade300,
                        minHeight: 10,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_quota!.storageUsedFormatted} / ${_quota!.storageLimitFormatted} (${_quota!.storagePercentage}%)',
                      ),
                      Text('Files: ${_quota!.filesCount}'),
                      Text('Max file size: ${_quota!.fileSizeLimitFormatted}'),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Actions
            if (_storage != null)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _uploadFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload File'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _loadFiles,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 16),

            // Files List
            if (_files.isNotEmpty)
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Files',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _files.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        return ListTile(
                          leading: Icon(_getFileIcon(file.mimeType)),
                          title: Text(file.fileName),
                          subtitle: Text(file.fileSizeFormatted),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.download),
                                onPressed: () => _downloadFile(file),
                                tooltip: 'Download',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteFile(file),
                                tooltip: 'Delete',
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

            if (_isLoading)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String? mimeType) {
    if (mimeType == null) return Icons.insert_drive_file;
    if (mimeType.startsWith('image/')) return Icons.image;
    if (mimeType.startsWith('video/')) return Icons.video_file;
    if (mimeType.startsWith('audio/')) return Icons.audio_file;
    if (mimeType.startsWith('application/pdf')) return Icons.picture_as_pdf;
    if (mimeType.contains('document') || mimeType.contains('word')) {
      return Icons.description;
    }
    if (mimeType.contains('spreadsheet') || mimeType.contains('excel')) {
      return Icons.table_chart;
    }
    return Icons.insert_drive_file;
  }
}

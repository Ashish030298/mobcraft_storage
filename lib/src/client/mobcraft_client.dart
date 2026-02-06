import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../exceptions/mobcraft_exception.dart';
import '../models/models.dart';
import '../utils/file_utils.dart';

/// The main client for interacting with Mobcraft Storage API.
///
/// This class provides methods for uploading, downloading, and managing
/// files in Mobcraft Storage, as well as checking quota and tier information.
///
/// ## Quick Start
///
/// ```dart
/// final storage = MobcraftStorage(apiKey: 'your_api_key');
///
/// // Upload a file
/// final result = await storage.uploadFile(file);
/// print('Uploaded: ${result.downloadUrl}');
///
/// // Check quota
/// final quota = await storage.getQuota();
/// print('Used: ${quota.storageUsedFormatted}');
/// ```
class MobcraftStorage {
  /// Creates a new [MobcraftStorage] client.
  ///
  /// The [apiKey] is required and can be obtained from the Mobcraft dashboard.
  /// The [baseUrl] defaults to the production API but can be overridden
  /// for testing or development purposes.
  MobcraftStorage({
    required this.apiKey,
    this.baseUrl = 'https://storage.mobcraft.in',
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// The API key used for authentication.
  final String apiKey;

  /// The base URL for the API.
  final String baseUrl;

  /// The HTTP client used for making requests.
  final http.Client _httpClient;

  /// Default headers included in all requests.
  Map<String, String> get _headers => {
        'Authorization': 'Bearer $apiKey',
        'Accept': 'application/json',
      };

  // ==================== File Operations ====================

  /// Uploads a file from a [File] object.
  ///
  /// The [folder] parameter specifies the destination folder (default: '/').
  /// The [metadata] parameter allows attaching custom metadata to the file.
  ///
  /// Throws [QuotaExceededException] if the upload would exceed storage limits.
  /// Throws [FileSizeLimitException] if the file is too large for the current tier.
  ///
  /// Example:
  /// ```dart
  /// final file = File('/path/to/image.png');
  /// final result = await storage.uploadFile(file, folder: '/images');
  /// print('Uploaded: ${result.downloadUrl}');
  /// ```
  Future<UploadResult> uploadFile(
    File file, {
    String? folder,
    Map<String, dynamic>? metadata,
  }) async {
    final bytes = await file.readAsBytes();
    final fileName = file.uri.pathSegments.last;
    return uploadBytes(bytes, fileName, folder: folder, metadata: metadata);
  }

  /// Uploads a file from raw bytes.
  ///
  /// The [bytes] parameter contains the file content.
  /// The [fileName] parameter specifies the name for the uploaded file.
  /// The [folder] parameter specifies the destination folder (default: '/').
  /// The [mimeType] parameter overrides auto-detection of the MIME type.
  /// The [metadata] parameter allows attaching custom metadata to the file.
  ///
  /// Example:
  /// ```dart
  /// final bytes = Uint8List.fromList([...]);
  /// final result = await storage.uploadBytes(bytes, 'data.bin');
  /// ```
  Future<UploadResult> uploadBytes(
    Uint8List bytes,
    String fileName, {
    String? folder,
    String? mimeType,
    Map<String, dynamic>? metadata,
  }) async {
    final uri = Uri.parse('$baseUrl/api/v1/files');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(_headers);

    // Add file
    final detectedMimeType = mimeType ?? FileUtils.getMimeType(fileName);
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
        contentType: MediaType.parse(detectedMimeType),
      ),
    );

    // Add folder
    final normalizedFolder = FileUtils.normalizeFolderPath(folder);
    request.fields['folder'] = normalizedFolder;

    // Add metadata
    if (metadata != null && metadata.isNotEmpty) {
      request.fields['metadata'] = jsonEncode(metadata);
    }

    final streamedResponse = await _sendRequest(request);
    final response = await http.Response.fromStream(streamedResponse);

    _handleErrors(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UploadResult.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Gets metadata for a specific file.
  ///
  /// The [fileId] is the unique identifier returned when the file was uploaded.
  ///
  /// Throws [FileNotFoundException] if the file doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// final file = await storage.getFile('abc123');
  /// print('File: ${file.fileName}, Size: ${file.fileSizeFormatted}');
  /// ```
  Future<StorageFile> getFile(String fileId) async {
    final uri = Uri.parse('$baseUrl/api/v1/files/$fileId');

    final response = await _get(uri);
    _handleErrors(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return StorageFile.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Gets the download URL for a specific file.
  ///
  /// The returned URL can be used to download the file directly.
  ///
  /// Example:
  /// ```dart
  /// final url = await storage.getDownloadUrl('abc123');
  /// // Use the URL in an Image widget or download manager
  /// ```
  Future<String> getDownloadUrl(String fileId) async {
    final uri = Uri.parse('$baseUrl/api/v1/files/$fileId/download-url');

    final response = await _get(uri);
    _handleErrors(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return json['data']['url'] as String;
  }

  /// Downloads a file and returns its content as bytes.
  ///
  /// Example:
  /// ```dart
  /// final bytes = await storage.downloadFile('abc123');
  /// await File('downloaded.png').writeAsBytes(bytes);
  /// ```
  Future<Uint8List> downloadFile(String fileId) async {
    final downloadUrl = await getDownloadUrl(fileId);
    final uri = Uri.parse(downloadUrl);

    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw NetworkException(
        message: 'Failed to download file: ${response.statusCode}',
      );
    }

    return response.bodyBytes;
  }

  /// Deletes a file.
  ///
  /// Throws [FileNotFoundException] if the file doesn't exist.
  ///
  /// Example:
  /// ```dart
  /// await storage.deleteFile('abc123');
  /// print('File deleted successfully');
  /// ```
  Future<void> deleteFile(String fileId) async {
    final uri = Uri.parse('$baseUrl/api/v1/files/$fileId');

    final response = await _delete(uri);
    _handleErrors(response);
  }

  /// Lists files with pagination support.
  ///
  /// The [folder] parameter filters files by folder path.
  /// The [limit] parameter specifies the maximum number of items per page.
  /// The [offset] parameter specifies the starting position.
  /// The [sortBy] parameter specifies the field to sort by.
  /// The [sortOrder] parameter specifies 'asc' or 'desc'.
  ///
  /// Example:
  /// ```dart
  /// final response = await storage.listFiles(folder: '/images', limit: 20);
  /// for (final file in response.items) {
  ///   print('${file.fileName}: ${file.fileSizeFormatted}');
  /// }
  /// if (response.hasMore) {
  ///   final nextPage = await storage.listFiles(
  ///     folder: '/images',
  ///     limit: 20,
  ///     offset: response.nextOffset,
  ///   );
  /// }
  /// ```
  Future<PaginatedResponse<StorageFile>> listFiles({
    String? folder,
    int limit = 20,
    int offset = 0,
    String sortBy = 'created_at',
    String sortOrder = 'desc',
  }) async {
    final queryParams = {
      'limit': limit.toString(),
      'offset': offset.toString(),
      'sort_by': sortBy,
      'sort_order': sortOrder,
    };

    if (folder != null) {
      queryParams['folder'] = FileUtils.normalizeFolderPath(folder);
    }

    final uri = Uri.parse('$baseUrl/api/v1/files').replace(queryParameters: queryParams);

    final response = await _get(uri);
    _handleErrors(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return PaginatedResponse.fromJson(
      json['data'] as Map<String, dynamic>,
      StorageFile.fromJson,
    );
  }

  // ==================== Quota Operations ====================

  /// Gets the current quota and usage information.
  ///
  /// Example:
  /// ```dart
  /// final quota = await storage.getQuota();
  /// print('Tier: ${quota.tier}');
  /// print('Usage: ${quota.storageUsedFormatted} / ${quota.storageLimitFormatted}');
  /// print('Files: ${quota.filesCount}');
  /// ```
  Future<StorageQuota> getQuota() async {
    final uri = Uri.parse('$baseUrl/api/v1/quota');

    final response = await _get(uri);
    _handleErrors(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return StorageQuota.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Gets detailed usage breakdown by file type.
  ///
  /// Example:
  /// ```dart
  /// final breakdown = await storage.getUsageBreakdown();
  /// print('Total files: ${breakdown.totalFiles}');
  /// for (final entry in breakdown.categories.entries) {
  ///   print('${entry.key}: ${entry.value.sizeFormatted}');
  /// }
  /// ```
  Future<UsageBreakdown> getUsageBreakdown() async {
    final uri = Uri.parse('$baseUrl/api/v1/quota/breakdown');

    final response = await _get(uri);
    _handleErrors(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    return UsageBreakdown.fromJson(json['data'] as Map<String, dynamic>);
  }

  /// Gets information about available pricing tiers.
  ///
  /// Example:
  /// ```dart
  /// final tiers = await storage.getTiers();
  /// for (final tier in tiers) {
  ///   print('${tier.name}: ${tier.priceFormatted}');
  ///   print('  Storage: ${tier.storageLimitFormatted}');
  ///   print('  Features: ${tier.features.join(", ")}');
  /// }
  /// ```
  Future<List<TierInfo>> getTiers() async {
    final uri = Uri.parse('$baseUrl/api/v1/tiers');

    final response = await _get(uri);
    _handleErrors(response);

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tiersJson = json['data'] as List<dynamic>;
    return tiersJson
        .map((tier) => TierInfo.fromJson(tier as Map<String, dynamic>))
        .toList();
  }

  // ==================== Private Methods ====================

  Future<http.Response> _get(Uri uri) async {
    try {
      return await _httpClient.get(uri, headers: _headers);
    } on SocketException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException(message: 'HTTP error: ${e.message}');
    }
  }

  Future<http.Response> _delete(Uri uri) async {
    try {
      return await _httpClient.delete(uri, headers: _headers);
    } on SocketException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException(message: 'HTTP error: ${e.message}');
    }
  }

  Future<http.StreamedResponse> _sendRequest(http.BaseRequest request) async {
    try {
      return await _httpClient.send(request);
    } on SocketException catch (e) {
      throw NetworkException(message: 'Network error: ${e.message}');
    } on HttpException catch (e) {
      throw NetworkException(message: 'HTTP error: ${e.message}');
    }
  }

  void _handleErrors(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message;
    String code;

    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      message = json['message'] as String? ?? 'An error occurred';
      code = json['code'] as String? ?? 'UNKNOWN_ERROR';
    } catch (_) {
      message = 'An error occurred';
      code = 'UNKNOWN_ERROR';
    }

    switch (response.statusCode) {
      case 400:
        throw BadRequestException(message: message, code: code);
      case 401:
        throw AuthenticationException(message: message, code: code);
      case 404:
        throw FileNotFoundException(message: message, code: code);
      case 413:
        if (code == 'QUOTA_EXCEEDED') {
          throw QuotaExceededException(message: message, code: code);
        }
        throw FileSizeLimitException(message: message, code: code);
      case 429:
        throw RateLimitException(message: message, code: code);
      case >= 500:
        throw ServerException(message: message, code: code);
      default:
        throw MobcraftException(
          message: message,
          code: code,
          statusCode: response.statusCode,
        );
    }
  }

  /// Closes the HTTP client.
  ///
  /// Call this method when you're done using the client to free resources.
  void close() {
    _httpClient.close();
  }
}

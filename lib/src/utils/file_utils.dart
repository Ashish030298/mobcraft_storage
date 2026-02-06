import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

/// Utility functions for file operations.
class FileUtils {
  FileUtils._();

  /// Gets the MIME type for a file based on its name or extension.
  ///
  /// Returns the detected MIME type, or 'application/octet-stream'
  /// if the type cannot be determined.
  static String getMimeType(String fileName) {
    final mimeType = lookupMimeType(fileName);
    return mimeType ?? 'application/octet-stream';
  }

  /// Gets the file extension from a file name.
  ///
  /// Returns the extension without the leading dot, or an empty string
  /// if there is no extension.
  static String getExtension(String fileName) {
    final ext = path.extension(fileName);
    return ext.isNotEmpty ? ext.substring(1) : '';
  }

  /// Gets the file name without the extension.
  static String getBaseName(String fileName) {
    return path.basenameWithoutExtension(fileName);
  }

  /// Formats a file size in bytes to a human-readable string.
  ///
  /// Example: `formatFileSize(1536)` returns '1.5 KB'.
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  /// Checks if a file name has an image extension.
  static bool isImage(String fileName) {
    final ext = getExtension(fileName).toLowerCase();
    return ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg', 'ico']
        .contains(ext);
  }

  /// Checks if a file name has a video extension.
  static bool isVideo(String fileName) {
    final ext = getExtension(fileName).toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv', 'webm', 'flv', 'wmv', 'm4v']
        .contains(ext);
  }

  /// Checks if a file name has an audio extension.
  static bool isAudio(String fileName) {
    final ext = getExtension(fileName).toLowerCase();
    return ['mp3', 'wav', 'ogg', 'flac', 'aac', 'm4a', 'wma'].contains(ext);
  }

  /// Checks if a file name has a document extension.
  static bool isDocument(String fileName) {
    final ext = getExtension(fileName).toLowerCase();
    return [
      'pdf',
      'doc',
      'docx',
      'xls',
      'xlsx',
      'ppt',
      'pptx',
      'txt',
      'rtf',
      'odt'
    ].contains(ext);
  }

  /// Gets the category of a file based on its extension.
  ///
  /// Returns one of: 'images', 'videos', 'audio', 'documents', or 'other'.
  static String getCategory(String fileName) {
    if (isImage(fileName)) return 'images';
    if (isVideo(fileName)) return 'videos';
    if (isAudio(fileName)) return 'audio';
    if (isDocument(fileName)) return 'documents';
    return 'other';
  }

  /// Sanitizes a file name by removing invalid characters.
  static String sanitizeFileName(String fileName) {
    // Replace invalid characters with underscores
    return fileName.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
  }

  /// Normalizes a folder path.
  ///
  /// Ensures the path starts with '/' and doesn't end with '/'.
  static String normalizeFolderPath(String? folder) {
    if (folder == null || folder.isEmpty) {
      return '/';
    }

    var normalized = folder.trim();

    // Ensure it starts with /
    if (!normalized.startsWith('/')) {
      normalized = '/$normalized';
    }

    // Remove trailing slash (unless it's just '/')
    if (normalized.length > 1 && normalized.endsWith('/')) {
      normalized = normalized.substring(0, normalized.length - 1);
    }

    return normalized;
  }
}

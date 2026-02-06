/// Represents a file stored in Mobcraft Storage.
///
/// This model contains all metadata about a stored file, including
/// its unique identifier, name, size, and optional custom metadata.
class StorageFile {
  /// Creates a new [StorageFile] instance.
  const StorageFile({
    required this.id,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
    required this.folder,
    this.metadata,
    required this.createdAt,
    this.expiresAt,
  });

  /// Creates a [StorageFile] from a JSON map.
  factory StorageFile.fromJson(Map<String, dynamic> json) {
    return StorageFile(
      id: json['id'] as String,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String?,
      folder: json['folder'] as String? ?? '/',
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: json['expiresAt'] != null
          ? DateTime.parse(json['expiresAt'] as String)
          : null,
    );
  }

  /// The unique identifier for this file.
  final String id;

  /// The original file name.
  final String fileName;

  /// The file size in bytes.
  final int fileSize;

  /// The MIME type of the file (e.g., 'image/png', 'application/pdf').
  final String? mimeType;

  /// The folder path where the file is stored.
  final String folder;

  /// Custom metadata associated with the file.
  final Map<String, dynamic>? metadata;

  /// The timestamp when the file was created.
  final DateTime createdAt;

  /// The timestamp when the file will expire (if set).
  final DateTime? expiresAt;

  /// Converts this [StorageFile] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'folder': folder,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [StorageFile] with the given fields replaced.
  StorageFile copyWith({
    String? id,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? folder,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return StorageFile(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      folder: folder ?? this.folder,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  /// Returns the file size in a human-readable format.
  String get fileSizeFormatted {
    if (fileSize < 1024) {
      return '$fileSize B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
    }
  }

  @override
  String toString() =>
      'StorageFile(id: $id, fileName: $fileName, fileSize: $fileSizeFormatted)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StorageFile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

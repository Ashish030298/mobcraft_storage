/// Represents the result of a successful file upload.
///
/// This model contains information about the uploaded file, including
/// its unique identifier and the URL to download it.
class UploadResult {
  /// Creates a new [UploadResult] instance.
  const UploadResult({
    required this.fileId,
    required this.fileName,
    required this.fileSize,
    this.mimeType,
    required this.downloadUrl,
    required this.folder,
    required this.createdAt,
  });

  /// Creates an [UploadResult] from a JSON map.
  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      fileId: json['fileId'] as String,
      fileName: json['fileName'] as String,
      fileSize: json['fileSize'] as int,
      mimeType: json['mimeType'] as String?,
      downloadUrl: json['downloadUrl'] as String,
      folder: json['folder'] as String? ?? '/',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// The unique identifier for the uploaded file.
  final String fileId;

  /// The name of the uploaded file.
  final String fileName;

  /// The size of the uploaded file in bytes.
  final int fileSize;

  /// The MIME type of the uploaded file.
  final String? mimeType;

  /// The URL to download the file.
  final String downloadUrl;

  /// The folder where the file was uploaded.
  final String folder;

  /// The timestamp when the file was uploaded.
  final DateTime createdAt;

  /// Converts this [UploadResult] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'fileName': fileName,
      'fileSize': fileSize,
      'mimeType': mimeType,
      'downloadUrl': downloadUrl,
      'folder': folder,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this [UploadResult] with the given fields replaced.
  UploadResult copyWith({
    String? fileId,
    String? fileName,
    int? fileSize,
    String? mimeType,
    String? downloadUrl,
    String? folder,
    DateTime? createdAt,
  }) {
    return UploadResult(
      fileId: fileId ?? this.fileId,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      folder: folder ?? this.folder,
      createdAt: createdAt ?? this.createdAt,
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
      'UploadResult(fileId: $fileId, fileName: $fileName, downloadUrl: $downloadUrl)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadResult &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;
}

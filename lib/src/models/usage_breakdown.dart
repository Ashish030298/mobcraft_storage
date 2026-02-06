/// Represents detailed usage breakdown by file type.
///
/// This model provides a detailed view of storage usage,
/// categorized by file types like images, documents, etc.
class UsageBreakdown {
  /// Creates a new [UsageBreakdown] instance.
  const UsageBreakdown({
    required this.totalSize,
    required this.totalSizeFormatted,
    required this.totalFiles,
    required this.categories,
  });

  /// Creates a [UsageBreakdown] from a JSON map.
  factory UsageBreakdown.fromJson(Map<String, dynamic> json) {
    final categoriesJson = json['categories'] as Map<String, dynamic>;
    final categories = categoriesJson.map(
      (key, value) => MapEntry(
        key,
        UsageCategory.fromJson(value as Map<String, dynamic>),
      ),
    );

    return UsageBreakdown(
      totalSize: json['totalSize'] as int,
      totalSizeFormatted: json['totalSizeFormatted'] as String,
      totalFiles: json['totalFiles'] as int,
      categories: categories,
    );
  }

  /// Total storage used in bytes.
  final int totalSize;

  /// Total storage used in human-readable format.
  final String totalSizeFormatted;

  /// Total number of files.
  final int totalFiles;

  /// Usage breakdown by category (e.g., 'images', 'documents', 'videos').
  final Map<String, UsageCategory> categories;

  /// Converts this [UsageBreakdown] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'totalSize': totalSize,
      'totalSizeFormatted': totalSizeFormatted,
      'totalFiles': totalFiles,
      'categories': categories.map((key, value) => MapEntry(key, value.toJson())),
    };
  }

  /// Creates a copy of this [UsageBreakdown] with the given fields replaced.
  UsageBreakdown copyWith({
    int? totalSize,
    String? totalSizeFormatted,
    int? totalFiles,
    Map<String, UsageCategory>? categories,
  }) {
    return UsageBreakdown(
      totalSize: totalSize ?? this.totalSize,
      totalSizeFormatted: totalSizeFormatted ?? this.totalSizeFormatted,
      totalFiles: totalFiles ?? this.totalFiles,
      categories: categories ?? this.categories,
    );
  }

  @override
  String toString() => 'UsageBreakdown(totalFiles: $totalFiles, totalSize: $totalSizeFormatted)';
}

/// Represents usage statistics for a single category.
class UsageCategory {
  /// Creates a new [UsageCategory] instance.
  const UsageCategory({
    required this.size,
    required this.sizeFormatted,
    required this.count,
    required this.percentage,
  });

  /// Creates a [UsageCategory] from a JSON map.
  factory UsageCategory.fromJson(Map<String, dynamic> json) {
    return UsageCategory(
      size: json['size'] as int,
      sizeFormatted: json['sizeFormatted'] as String,
      count: json['count'] as int,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  /// Size used by this category in bytes.
  final int size;

  /// Size in human-readable format.
  final String sizeFormatted;

  /// Number of files in this category.
  final int count;

  /// Percentage of total storage used by this category.
  final double percentage;

  /// Converts this [UsageCategory] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'size': size,
      'sizeFormatted': sizeFormatted,
      'count': count,
      'percentage': percentage,
    };
  }

  /// Creates a copy of this [UsageCategory] with the given fields replaced.
  UsageCategory copyWith({
    int? size,
    String? sizeFormatted,
    int? count,
    double? percentage,
  }) {
    return UsageCategory(
      size: size ?? this.size,
      sizeFormatted: sizeFormatted ?? this.sizeFormatted,
      count: count ?? this.count,
      percentage: percentage ?? this.percentage,
    );
  }

  @override
  String toString() => 'UsageCategory(count: $count, size: $sizeFormatted, percentage: ${percentage.toStringAsFixed(1)}%)';
}

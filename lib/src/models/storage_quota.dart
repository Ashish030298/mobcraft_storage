/// Represents the storage quota and usage information for a user.
///
/// This model contains information about the current tier, storage usage,
/// limits, and available features.
class StorageQuota {
  /// Creates a new [StorageQuota] instance.
  const StorageQuota({
    required this.tier,
    required this.storageUsed,
    required this.storageLimit,
    required this.storageUsedFormatted,
    required this.storageLimitFormatted,
    required this.storagePercentage,
    required this.filesCount,
    required this.fileSizeLimit,
    required this.fileSizeLimitFormatted,
    required this.features,
    this.subscriptionExpiresAt,
  });

  /// Creates a [StorageQuota] from a JSON map.
  factory StorageQuota.fromJson(Map<String, dynamic> json) {
    return StorageQuota(
      tier: json['tier'] as String,
      storageUsed: json['storageUsed'] as int,
      storageLimit: json['storageLimit'] as int,
      storageUsedFormatted: json['storageUsedFormatted'] as String,
      storageLimitFormatted: json['storageLimitFormatted'] as String,
      storagePercentage: json['storagePercentage'] as int,
      filesCount: json['filesCount'] as int,
      fileSizeLimit: json['fileSizeLimit'] as int,
      fileSizeLimitFormatted: json['fileSizeLimitFormatted'] as String,
      features: (json['features'] as List<dynamic>).cast<String>(),
      subscriptionExpiresAt: json['subscriptionExpiresAt'] != null
          ? DateTime.parse(json['subscriptionExpiresAt'] as String)
          : null,
    );
  }

  /// The current tier name (e.g., 'free', 'pro', 'enterprise').
  final String tier;

  /// The total storage used in bytes.
  final int storageUsed;

  /// The total storage limit in bytes.
  final int storageLimit;

  /// The storage used in a human-readable format (e.g., '1.5 GB').
  final String storageUsedFormatted;

  /// The storage limit in a human-readable format (e.g., '10 GB').
  final String storageLimitFormatted;

  /// The percentage of storage used (0-100).
  final int storagePercentage;

  /// The total number of files stored.
  final int filesCount;

  /// The maximum file size allowed per upload in bytes.
  final int fileSizeLimit;

  /// The maximum file size in a human-readable format.
  final String fileSizeLimitFormatted;

  /// List of features available for this tier.
  final List<String> features;

  /// When the subscription expires (null for free tier).
  final DateTime? subscriptionExpiresAt;

  /// Converts this [StorageQuota] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'tier': tier,
      'storageUsed': storageUsed,
      'storageLimit': storageLimit,
      'storageUsedFormatted': storageUsedFormatted,
      'storageLimitFormatted': storageLimitFormatted,
      'storagePercentage': storagePercentage,
      'filesCount': filesCount,
      'fileSizeLimit': fileSizeLimit,
      'fileSizeLimitFormatted': fileSizeLimitFormatted,
      'features': features,
      'subscriptionExpiresAt': subscriptionExpiresAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this [StorageQuota] with the given fields replaced.
  StorageQuota copyWith({
    String? tier,
    int? storageUsed,
    int? storageLimit,
    String? storageUsedFormatted,
    String? storageLimitFormatted,
    int? storagePercentage,
    int? filesCount,
    int? fileSizeLimit,
    String? fileSizeLimitFormatted,
    List<String>? features,
    DateTime? subscriptionExpiresAt,
  }) {
    return StorageQuota(
      tier: tier ?? this.tier,
      storageUsed: storageUsed ?? this.storageUsed,
      storageLimit: storageLimit ?? this.storageLimit,
      storageUsedFormatted: storageUsedFormatted ?? this.storageUsedFormatted,
      storageLimitFormatted: storageLimitFormatted ?? this.storageLimitFormatted,
      storagePercentage: storagePercentage ?? this.storagePercentage,
      filesCount: filesCount ?? this.filesCount,
      fileSizeLimit: fileSizeLimit ?? this.fileSizeLimit,
      fileSizeLimitFormatted: fileSizeLimitFormatted ?? this.fileSizeLimitFormatted,
      features: features ?? this.features,
      subscriptionExpiresAt: subscriptionExpiresAt ?? this.subscriptionExpiresAt,
    );
  }

  /// Returns the remaining storage in bytes.
  int get storageRemaining => storageLimit - storageUsed;

  /// Returns true if the storage is almost full (>90% used).
  bool get isAlmostFull => storagePercentage >= 90;

  /// Returns true if the storage is full (100% used).
  bool get isFull => storagePercentage >= 100;

  @override
  String toString() => 'StorageQuota(tier: $tier, used: $storageUsedFormatted/$storageLimitFormatted)';
}

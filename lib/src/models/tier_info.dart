/// Represents information about a pricing tier.
///
/// This model contains details about available tiers, including
/// storage limits, pricing, and features.
class TierInfo {
  /// Creates a new [TierInfo] instance.
  const TierInfo({
    required this.id,
    required this.name,
    required this.storageLimit,
    required this.storageLimitFormatted,
    required this.fileSizeLimit,
    required this.fileSizeLimitFormatted,
    required this.price,
    required this.currency,
    required this.billingPeriod,
    required this.features,
    required this.isPopular,
    required this.isCurrent,
  });

  /// Creates a [TierInfo] from a JSON map.
  factory TierInfo.fromJson(Map<String, dynamic> json) {
    return TierInfo(
      id: json['tier'] as String,
      name: (json['tier'] as String).toUpperCase(),
      storageLimit: json['storageLimit'] as int,
      storageLimitFormatted: json['storageLimitFormatted'] as String,
      fileSizeLimit: json['fileSizeLimit'] as int,
      fileSizeLimitFormatted: json['fileSizeLimitFormatted'] as String,
      price: (json['priceMonthly'] as num).toDouble(),
      currency: 'USD',
      billingPeriod: 'monthly',
      features: (json['features'] as List<dynamic>).cast<String>(),
      isPopular: json['isPopular'] as bool? ?? false,
      isCurrent: json['isCurrent'] as bool? ?? false,
    );
  }

  /// Unique identifier for the tier.
  final String id;

  /// Display name of the tier (e.g., 'Free', 'Pro', 'Enterprise').
  final String name;

  /// Storage limit in bytes.
  final int storageLimit;

  /// Storage limit in human-readable format.
  final String storageLimitFormatted;

  /// Maximum file size per upload in bytes.
  final int fileSizeLimit;

  /// Maximum file size in human-readable format.
  final String fileSizeLimitFormatted;

  /// Price for this tier (0 for free tier, -1 for enterprise/custom).
  final double price;

  /// Currency code (e.g., 'USD', 'EUR').
  final String currency;

  /// Billing period (e.g., 'monthly', 'yearly').
  final String billingPeriod;

  /// List of features included in this tier.
  final List<String> features;

  /// Whether this is the most popular tier.
  final bool isPopular;

  /// Whether this is the user's current tier.
  final bool isCurrent;

  /// Converts this [TierInfo] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'tier': id,
      'storageLimit': storageLimit,
      'storageLimitFormatted': storageLimitFormatted,
      'fileSizeLimit': fileSizeLimit,
      'fileSizeLimitFormatted': fileSizeLimitFormatted,
      'priceMonthly': price,
      'features': features,
      'isPopular': isPopular,
      'isCurrent': isCurrent,
    };
  }

  /// Creates a copy of this [TierInfo] with the given fields replaced.
  TierInfo copyWith({
    String? id,
    String? name,
    int? storageLimit,
    String? storageLimitFormatted,
    int? fileSizeLimit,
    String? fileSizeLimitFormatted,
    double? price,
    String? currency,
    String? billingPeriod,
    List<String>? features,
    bool? isPopular,
    bool? isCurrent,
  }) {
    return TierInfo(
      id: id ?? this.id,
      name: name ?? this.name,
      storageLimit: storageLimit ?? this.storageLimit,
      storageLimitFormatted: storageLimitFormatted ?? this.storageLimitFormatted,
      fileSizeLimit: fileSizeLimit ?? this.fileSizeLimit,
      fileSizeLimitFormatted: fileSizeLimitFormatted ?? this.fileSizeLimitFormatted,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      features: features ?? this.features,
      isPopular: isPopular ?? this.isPopular,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  /// Returns true if this is a free tier.
  bool get isFree => price == 0;

  /// Returns the formatted price string.
  String get priceFormatted {
    if (isFree) return 'Free';
    if (price < 0) return 'Custom';
    return '$currency ${price.toStringAsFixed(2)}/$billingPeriod';
  }

  @override
  String toString() => 'TierInfo(name: $name, price: $priceFormatted, storage: $storageLimitFormatted)';
}

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
      id: json['id'] as String,
      name: json['name'] as String,
      storageLimit: json['storage_limit'] as int,
      storageLimitFormatted: json['storage_limit_formatted'] as String,
      fileSizeLimit: json['file_size_limit'] as int,
      fileSizeLimitFormatted: json['file_size_limit_formatted'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      billingPeriod: json['billing_period'] as String,
      features: (json['features'] as List<dynamic>).cast<String>(),
      isPopular: json['is_popular'] as bool? ?? false,
      isCurrent: json['is_current'] as bool? ?? false,
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

  /// Price for this tier (0 for free tier).
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
      'id': id,
      'name': name,
      'storage_limit': storageLimit,
      'storage_limit_formatted': storageLimitFormatted,
      'file_size_limit': fileSizeLimit,
      'file_size_limit_formatted': fileSizeLimitFormatted,
      'price': price,
      'currency': currency,
      'billing_period': billingPeriod,
      'features': features,
      'is_popular': isPopular,
      'is_current': isCurrent,
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
  String get priceFormatted => isFree ? 'Free' : '$currency ${price.toStringAsFixed(2)}/$billingPeriod';

  @override
  String toString() => 'TierInfo(name: $name, price: $priceFormatted, storage: $storageLimitFormatted)';
}

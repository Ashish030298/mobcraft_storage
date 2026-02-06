/// Represents a paginated response from the API.
///
/// This generic model is used for endpoints that return lists
/// of items with pagination support.
class PaginatedResponse<T> {
  /// Creates a new [PaginatedResponse] instance.
  const PaginatedResponse({
    required this.items,
    required this.total,
    required this.limit,
    required this.offset,
    required this.hasMore,
  });

  /// Creates a [PaginatedResponse] from a JSON map.
  ///
  /// The [fromJsonT] function is used to deserialize each item in the list.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final itemsJson = json['items'] as List<dynamic>;
    final items = itemsJson
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PaginatedResponse<T>(
      items: items,
      total: json['total'] as int,
      limit: json['limit'] as int,
      offset: json['offset'] as int,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The list of items in this page.
  final List<T> items;

  /// The total number of items across all pages.
  final int total;

  /// The maximum number of items per page.
  final int limit;

  /// The offset from the start of the list.
  final int offset;

  /// Whether there are more items available.
  final bool hasMore;

  /// Converts this [PaginatedResponse] to a JSON map.
  ///
  /// The [toJsonT] function is used to serialize each item in the list.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'items': items.map(toJsonT).toList(),
      'total': total,
      'limit': limit,
      'offset': offset,
      'has_more': hasMore,
    };
  }

  /// Creates a copy of this [PaginatedResponse] with the given fields replaced.
  PaginatedResponse<T> copyWith({
    List<T>? items,
    int? total,
    int? limit,
    int? offset,
    bool? hasMore,
  }) {
    return PaginatedResponse<T>(
      items: items ?? this.items,
      total: total ?? this.total,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  /// Returns the current page number (1-indexed).
  int get currentPage => (offset ~/ limit) + 1;

  /// Returns the total number of pages.
  int get totalPages => (total / limit).ceil();

  /// Returns true if this is the first page.
  bool get isFirstPage => offset == 0;

  /// Returns true if this is the last page.
  bool get isLastPage => !hasMore;

  /// Returns the offset for the next page.
  int get nextOffset => offset + limit;

  /// Returns the offset for the previous page.
  int get previousOffset => (offset - limit).clamp(0, total);

  /// Returns the number of items in this page.
  int get count => items.length;

  /// Returns true if this page is empty.
  bool get isEmpty => items.isEmpty;

  /// Returns true if this page has items.
  bool get isNotEmpty => items.isNotEmpty;

  @override
  String toString() => 'PaginatedResponse(items: ${items.length}, total: $total, page: $currentPage/$totalPages)';
}

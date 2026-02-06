# Mobcraft Storage

A Flutter SDK for Mobcraft Storage - Telegram-based cloud storage with freemium tiers.

[![pub package](https://img.shields.io/pub/v/mobcraft_storage.svg)](https://pub.dev/packages/mobcraft_storage)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Features

- **File Operations**: Upload, download, list, and delete files
- **Quota Management**: Check storage usage and limits
- **Tier Information**: View available pricing tiers and features
- **Type-Safe**: Full Dart type safety with comprehensive models
- **Error Handling**: Custom exceptions for different error scenarios

## Installation

Add `mobcraft_storage` to your `pubspec.yaml`:

```yaml
dependencies:
  mobcraft_storage: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Initialize the Client

```dart
import 'package:mobcraft_storage/mobcraft_storage.dart';

final storage = MobcraftStorage(apiKey: 'your_api_key');
```

### Upload a File

```dart
import 'dart:io';

// From a File object
final file = File('/path/to/image.png');
final result = await storage.uploadFile(
  file,
  folder: '/images',
  metadata: {'description': 'My photo'},
);
print('Uploaded: ${result.downloadUrl}');

// From bytes
final bytes = Uint8List.fromList([...]);
final result = await storage.uploadBytes(
  bytes,
  'document.pdf',
  folder: '/documents',
);
```

### List Files

```dart
final response = await storage.listFiles(
  folder: '/images',
  limit: 20,
  offset: 0,
);

for (final file in response.items) {
  print('${file.fileName}: ${file.fileSizeFormatted}');
}

// Check for more pages
if (response.hasMore) {
  final nextPage = await storage.listFiles(
    folder: '/images',
    limit: 20,
    offset: response.nextOffset,
  );
}
```

### Download a File

```dart
// Get download URL
final url = await storage.getDownloadUrl('file_id');

// Or download directly as bytes
final bytes = await storage.downloadFile('file_id');
await File('downloaded.png').writeAsBytes(bytes);
```

### Delete a File

```dart
await storage.deleteFile('file_id');
```

### Check Quota

```dart
final quota = await storage.getQuota();
print('Tier: ${quota.tier}');
print('Usage: ${quota.storageUsedFormatted} / ${quota.storageLimitFormatted}');
print('Files: ${quota.filesCount}');

if (quota.isAlmostFull) {
  print('Warning: Storage is almost full!');
}
```

### Get Usage Breakdown

```dart
final breakdown = await storage.getUsageBreakdown();
print('Total files: ${breakdown.totalFiles}');

for (final entry in breakdown.categories.entries) {
  print('${entry.key}: ${entry.value.sizeFormatted} (${entry.value.percentage}%)');
}
```

### View Available Tiers

```dart
final tiers = await storage.getTiers();
for (final tier in tiers) {
  print('${tier.name}: ${tier.priceFormatted}');
  print('  Storage: ${tier.storageLimitFormatted}');
  print('  Max file size: ${tier.fileSizeLimitFormatted}');
  print('  Features: ${tier.features.join(", ")}');
}
```

## Error Handling

The SDK provides specific exception types for different error scenarios:

```dart
try {
  await storage.uploadFile(file);
} on AuthenticationException catch (e) {
  // Invalid or expired API key
  print('Auth error: ${e.message}');
} on QuotaExceededException catch (e) {
  // Storage quota exceeded
  print('Upgrade your plan: ${e.message}');
} on FileSizeLimitException catch (e) {
  // File too large for current tier
  print('File too large: ${e.message}');
} on FileNotFoundException catch (e) {
  // File not found
  print('File not found: ${e.message}');
} on NetworkException catch (e) {
  // Network connectivity issues
  print('Network error: ${e.message}');
} on RateLimitException catch (e) {
  // Too many requests
  print('Rate limited: ${e.message}');
} on MobcraftException catch (e) {
  // Generic error
  print('Error: ${e.message} (code: ${e.code})');
}
```

## Models

### StorageFile

Represents a file stored in Mobcraft Storage:

```dart
class StorageFile {
  final String id;
  final String fileName;
  final int fileSize;
  final String? mimeType;
  final String folder;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? expiresAt;

  // Computed properties
  String get fileSizeFormatted;
}
```

### UploadResult

Returned after a successful upload:

```dart
class UploadResult {
  final String fileId;
  final String fileName;
  final int fileSize;
  final String? mimeType;
  final String downloadUrl;
  final String folder;
  final DateTime createdAt;
}
```

### StorageQuota

Current quota and usage information:

```dart
class StorageQuota {
  final String tier;
  final int storageUsed;
  final int storageLimit;
  final String storageUsedFormatted;
  final String storageLimitFormatted;
  final int storagePercentage;
  final int filesCount;
  final int fileSizeLimit;
  final String fileSizeLimitFormatted;
  final List<String> features;
  final DateTime? subscriptionExpiresAt;

  // Computed properties
  int get storageRemaining;
  bool get isAlmostFull;
  bool get isFull;
}
```

### PaginatedResponse

Used for list endpoints with pagination:

```dart
class PaginatedResponse<T> {
  final List<T> items;
  final int total;
  final int limit;
  final int offset;
  final bool hasMore;

  // Computed properties
  int get currentPage;
  int get totalPages;
  bool get isFirstPage;
  bool get isLastPage;
  int get nextOffset;
  int get previousOffset;
}
```

## Configuration

### Custom Base URL

For development or testing with a different API endpoint:

```dart
final storage = MobcraftStorage(
  apiKey: 'your_api_key',
  baseUrl: 'https://staging.storage.mobcraft.io',
);
```

### Cleanup

Remember to close the client when done:

```dart
storage.close();
```

## Example App

See the [example](example/) directory for a complete Flutter app demonstrating all SDK features.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- Documentation: [https://mobcraft.io/docs](https://mobcraft.io/docs)
- Issues: [https://github.com/mobcraft/mobcraft_storage_flutter/issues](https://github.com/mobcraft/mobcraft_storage_flutter/issues)
- Email: support@mobcraft.io

/// Flutter SDK for Mobcraft Storage - cloud storage with freemium tiers.
///
/// This library provides a simple and intuitive API for integrating
/// Mobcraft Storage into your Flutter applications.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:mobcraft_storage/mobcraft_storage.dart';
///
/// final storage = MobcraftStorage(apiKey: 'your_api_key');
///
/// // Upload a file
/// final result = await storage.uploadFile(file);
/// print('Uploaded: ${result.downloadUrl}');
///
/// // Check quota
/// final quota = await storage.getQuota();
/// print('Used: ${quota.storageUsedFormatted} / ${quota.storageLimitFormatted}');
/// ```
library mobcraft_storage;

export 'src/client/mobcraft_client.dart';
export 'src/exceptions/mobcraft_exception.dart';
export 'src/models/models.dart';

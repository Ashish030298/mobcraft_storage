import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mobcraft_storage/mobcraft_storage.dart';

void main() {
  group('StorageFile', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 'file123',
        'file_name': 'test.png',
        'file_size': 1024,
        'mime_type': 'image/png',
        'folder': '/images',
        'metadata': {'key': 'value'},
        'created_at': '2024-01-01T00:00:00.000Z',
        'expires_at': '2024-12-31T23:59:59.000Z',
      };

      final file = StorageFile.fromJson(json);

      expect(file.id, 'file123');
      expect(file.fileName, 'test.png');
      expect(file.fileSize, 1024);
      expect(file.mimeType, 'image/png');
      expect(file.folder, '/images');
      expect(file.metadata, {'key': 'value'});
      expect(file.createdAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
      expect(file.expiresAt, DateTime.parse('2024-12-31T23:59:59.000Z'));
    });

    test('toJson creates correct map', () {
      final file = StorageFile(
        id: 'file123',
        fileName: 'test.png',
        fileSize: 1024,
        mimeType: 'image/png',
        folder: '/images',
        metadata: {'key': 'value'},
        createdAt: DateTime.parse('2024-01-01T00:00:00.000Z'),
        expiresAt: DateTime.parse('2024-12-31T23:59:59.000Z'),
      );

      final json = file.toJson();

      expect(json['id'], 'file123');
      expect(json['file_name'], 'test.png');
      expect(json['file_size'], 1024);
      expect(json['mime_type'], 'image/png');
      expect(json['folder'], '/images');
    });

    test('fileSizeFormatted returns human-readable size', () {
      final now = DateTime.now();

      expect(
        StorageFile(
          id: '1',
          fileName: 'a',
          fileSize: 500,
          folder: '/',
          createdAt: now,
        ).fileSizeFormatted,
        '500 B',
      );

      expect(
        StorageFile(
          id: '1',
          fileName: 'a',
          fileSize: 1536,
          folder: '/',
          createdAt: now,
        ).fileSizeFormatted,
        '1.5 KB',
      );

      expect(
        StorageFile(
          id: '1',
          fileName: 'a',
          fileSize: 1572864,
          folder: '/',
          createdAt: DateTime.now(),
        ).fileSizeFormatted,
        '1.5 MB',
      );
    });

    test('copyWith creates new instance with updated fields', () {
      final original = StorageFile(
        id: 'file123',
        fileName: 'test.png',
        fileSize: 1024,
        folder: '/',
        createdAt: DateTime.now(),
      );

      final copied = original.copyWith(fileName: 'updated.png');

      expect(copied.id, original.id);
      expect(copied.fileName, 'updated.png');
      expect(copied.fileSize, original.fileSize);
    });
  });

  group('UploadResult', () {
    test('fromJson creates correct instance', () {
      final json = {
        'file_id': 'file123',
        'file_name': 'test.png',
        'file_size': 1024,
        'mime_type': 'image/png',
        'download_url': 'https://example.com/file123',
        'folder': '/images',
        'created_at': '2024-01-01T00:00:00.000Z',
      };

      final result = UploadResult.fromJson(json);

      expect(result.fileId, 'file123');
      expect(result.fileName, 'test.png');
      expect(result.fileSize, 1024);
      expect(result.downloadUrl, 'https://example.com/file123');
    });
  });

  group('StorageQuota', () {
    test('fromJson creates correct instance', () {
      final json = {
        'tier': 'pro',
        'storage_used': 1073741824,
        'storage_limit': 10737418240,
        'storage_used_formatted': '1 GB',
        'storage_limit_formatted': '10 GB',
        'storage_percentage': 10,
        'files_count': 100,
        'file_size_limit': 104857600,
        'file_size_limit_formatted': '100 MB',
        'features': ['feature1', 'feature2'],
        'subscription_expires_at': '2024-12-31T23:59:59.000Z',
      };

      final quota = StorageQuota.fromJson(json);

      expect(quota.tier, 'pro');
      expect(quota.storageUsed, 1073741824);
      expect(quota.storagePercentage, 10);
      expect(quota.features, ['feature1', 'feature2']);
    });

    test('isAlmostFull returns true when above 90%', () {
      const quota = StorageQuota(
        tier: 'free',
        storageUsed: 9500000000,
        storageLimit: 10000000000,
        storageUsedFormatted: '9.5 GB',
        storageLimitFormatted: '10 GB',
        storagePercentage: 95,
        filesCount: 100,
        fileSizeLimit: 104857600,
        fileSizeLimitFormatted: '100 MB',
        features: [],
      );

      expect(quota.isAlmostFull, true);
      expect(quota.isFull, false);
    });
  });

  group('PaginatedResponse', () {
    test('fromJson creates correct instance', () {
      final json = {
        'items': [
          {
            'id': 'file1',
            'file_name': 'test1.png',
            'file_size': 1024,
            'folder': '/',
            'created_at': '2024-01-01T00:00:00.000Z',
          },
          {
            'id': 'file2',
            'file_name': 'test2.png',
            'file_size': 2048,
            'folder': '/',
            'created_at': '2024-01-02T00:00:00.000Z',
          },
        ],
        'total': 50,
        'limit': 20,
        'offset': 0,
        'has_more': true,
      };

      final response = PaginatedResponse.fromJson(json, StorageFile.fromJson);

      expect(response.items.length, 2);
      expect(response.total, 50);
      expect(response.limit, 20);
      expect(response.hasMore, true);
      expect(response.currentPage, 1);
      expect(response.totalPages, 3);
    });

    test('pagination helpers work correctly', () {
      const response = PaginatedResponse<String>(
        items: ['a', 'b'],
        total: 100,
        limit: 20,
        offset: 40,
        hasMore: true,
      );

      expect(response.currentPage, 3);
      expect(response.totalPages, 5);
      expect(response.isFirstPage, false);
      expect(response.isLastPage, false);
      expect(response.nextOffset, 60);
      expect(response.previousOffset, 20);
    });
  });

  group('Exceptions', () {
    test('MobcraftException contains correct properties', () {
      const exception = MobcraftException(
        message: 'Test error',
        code: 'TEST_ERROR',
        statusCode: 400,
      );

      expect(exception.message, 'Test error');
      expect(exception.code, 'TEST_ERROR');
      expect(exception.statusCode, 400);
      expect(exception.toString(), contains('Test error'));
    });

    test('AuthenticationException has correct defaults', () {
      const exception = AuthenticationException();

      expect(exception.code, 'AUTHENTICATION_ERROR');
      expect(exception.statusCode, 401);
    });

    test('QuotaExceededException has correct defaults', () {
      const exception = QuotaExceededException();

      expect(exception.code, 'QUOTA_EXCEEDED');
      expect(exception.statusCode, 413);
    });
  });

  group('MobcraftStorage Client', () {
    late MobcraftStorage storage;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        final path = request.url.path;

        if (path == '/api/v1/quota') {
          return http.Response(
            jsonEncode({
              'data': {
                'tier': 'free',
                'storage_used': 1024,
                'storage_limit': 1073741824,
                'storage_used_formatted': '1 KB',
                'storage_limit_formatted': '1 GB',
                'storage_percentage': 0,
                'files_count': 1,
                'file_size_limit': 26214400,
                'file_size_limit_formatted': '25 MB',
                'features': ['basic_storage'],
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        if (path == '/api/v1/files') {
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'data': {
                  'items': [
                    {
                      'id': 'file1',
                      'file_name': 'test.png',
                      'file_size': 1024,
                      'mime_type': 'image/png',
                      'folder': '/',
                      'created_at': '2024-01-01T00:00:00.000Z',
                    },
                  ],
                  'total': 1,
                  'limit': 20,
                  'offset': 0,
                  'has_more': false,
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
        }

        if (path == '/api/v1/files/file1') {
          if (request.method == 'GET') {
            return http.Response(
              jsonEncode({
                'data': {
                  'id': 'file1',
                  'file_name': 'test.png',
                  'file_size': 1024,
                  'mime_type': 'image/png',
                  'folder': '/',
                  'created_at': '2024-01-01T00:00:00.000Z',
                },
              }),
              200,
              headers: {'content-type': 'application/json'},
            );
          }
          if (request.method == 'DELETE') {
            return http.Response('', 204);
          }
        }

        if (path == '/api/v1/files/notfound') {
          return http.Response(
            jsonEncode({
              'message': 'File not found',
              'code': 'FILE_NOT_FOUND',
            }),
            404,
            headers: {'content-type': 'application/json'},
          );
        }

        if (path == '/api/v1/tiers') {
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 'free',
                  'name': 'Free',
                  'storage_limit': 1073741824,
                  'storage_limit_formatted': '1 GB',
                  'file_size_limit': 26214400,
                  'file_size_limit_formatted': '25 MB',
                  'price': 0,
                  'currency': 'USD',
                  'billing_period': 'monthly',
                  'features': ['basic_storage'],
                  'is_popular': false,
                  'is_current': true,
                },
              ],
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }

        return http.Response('Not found', 404);
      });

      storage = MobcraftStorage(
        apiKey: 'test_api_key',
        baseUrl: 'https://test.mobcraft.io',
        httpClient: mockClient,
      );
    });

    test('getQuota returns correct data', () async {
      final quota = await storage.getQuota();

      expect(quota.tier, 'free');
      expect(quota.storageUsed, 1024);
      expect(quota.filesCount, 1);
    });

    test('listFiles returns paginated response', () async {
      final response = await storage.listFiles();

      expect(response.items.length, 1);
      expect(response.items.first.fileName, 'test.png');
      expect(response.hasMore, false);
    });

    test('getFile returns file metadata', () async {
      final file = await storage.getFile('file1');

      expect(file.id, 'file1');
      expect(file.fileName, 'test.png');
      expect(file.mimeType, 'image/png');
    });

    test('getFile throws FileNotFoundException for missing file', () async {
      expect(
        () => storage.getFile('notfound'),
        throwsA(isA<FileNotFoundException>()),
      );
    });

    test('deleteFile completes without error', () async {
      await storage.deleteFile('file1');
      // No exception means success
    });

    test('getTiers returns tier list', () async {
      final tiers = await storage.getTiers();

      expect(tiers.length, 1);
      expect(tiers.first.name, 'Free');
      expect(tiers.first.isFree, true);
    });

    test('uploadBytes creates multipart request', () async {
      var uploadCalled = false;

      final uploadMockClient = MockClient((request) async {
        if (request.url.path == '/api/v1/files' && request.method == 'POST') {
          uploadCalled = true;
          return http.Response(
            jsonEncode({
              'data': {
                'file_id': 'newfile',
                'file_name': 'test.txt',
                'file_size': 11,
                'mime_type': 'text/plain',
                'download_url': 'https://test.mobcraft.io/files/newfile',
                'folder': '/',
                'created_at': '2024-01-01T00:00:00.000Z',
              },
            }),
            201,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not found', 404);
      });

      final uploadStorage = MobcraftStorage(
        apiKey: 'test_api_key',
        baseUrl: 'https://test.mobcraft.io',
        httpClient: uploadMockClient,
      );

      final result = await uploadStorage.uploadBytes(
        Uint8List.fromList('Hello World'.codeUnits),
        'test.txt',
      );

      expect(uploadCalled, true);
      expect(result.fileId, 'newfile');
      expect(result.fileName, 'test.txt');
    });

    test('authentication error is handled correctly', () async {
      final authMockClient = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'Invalid API key',
            'code': 'INVALID_API_KEY',
          }),
          401,
          headers: {'content-type': 'application/json'},
        );
      });

      final authStorage = MobcraftStorage(
        apiKey: 'invalid_key',
        baseUrl: 'https://test.mobcraft.io',
        httpClient: authMockClient,
      );

      expect(
        authStorage.getQuota,
        throwsA(isA<AuthenticationException>()),
      );
    });
  });

  group('TierInfo', () {
    test('fromJson creates correct instance', () {
      final json = {
        'id': 'pro',
        'name': 'Pro',
        'storage_limit': 10737418240,
        'storage_limit_formatted': '10 GB',
        'file_size_limit': 104857600,
        'file_size_limit_formatted': '100 MB',
        'price': 9.99,
        'currency': 'USD',
        'billing_period': 'monthly',
        'features': ['priority_support', 'api_access'],
        'is_popular': true,
        'is_current': false,
      };

      final tier = TierInfo.fromJson(json);

      expect(tier.id, 'pro');
      expect(tier.name, 'Pro');
      expect(tier.price, 9.99);
      expect(tier.isPopular, true);
      expect(tier.isFree, false);
      expect(tier.priceFormatted, 'USD 9.99/monthly');
    });

    test('free tier has correct priceFormatted', () {
      const tier = TierInfo(
        id: 'free',
        name: 'Free',
        storageLimit: 1073741824,
        storageLimitFormatted: '1 GB',
        fileSizeLimit: 26214400,
        fileSizeLimitFormatted: '25 MB',
        price: 0,
        currency: 'USD',
        billingPeriod: 'monthly',
        features: [],
        isPopular: false,
        isCurrent: true,
      );

      expect(tier.isFree, true);
      expect(tier.priceFormatted, 'Free');
    });
  });

  group('UsageBreakdown', () {
    test('fromJson creates correct instance', () {
      final json = {
        'total_size': 10737418240,
        'total_size_formatted': '10 GB',
        'total_files': 500,
        'categories': {
          'images': {
            'size': 5368709120,
            'size_formatted': '5 GB',
            'count': 300,
            'percentage': 50.0,
          },
          'documents': {
            'size': 2147483648,
            'size_formatted': '2 GB',
            'count': 100,
            'percentage': 20.0,
          },
        },
      };

      final breakdown = UsageBreakdown.fromJson(json);

      expect(breakdown.totalFiles, 500);
      expect(breakdown.categories.length, 2);
      expect(breakdown.categories['images']?.count, 300);
      expect(breakdown.categories['documents']?.percentage, 20.0);
    });
  });
}

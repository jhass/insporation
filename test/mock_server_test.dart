import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../tool/mock_server.dart';

void main() {
  group('mock server', () {
    late DemoMockServer server;
    late Uri baseApiUri;

    setUp(() async {
      server = DemoMockServer(port: 0);
      final uri = await server.start();
      baseApiUri = uri.replace(path: '/api/v1');
    });

    tearDown(() async {
      await server.stop();
    });

    test('serves stream content with rich media', () async {
      final response = await http.get(baseApiUri.replace(path: '${baseApiUri.path}/streams/main'));
      expect(response.statusCode, 200);

      final payload = jsonDecode(response.body) as List<dynamic>;
      expect(payload, isNotEmpty);

      final hasPhotos = payload.any((post) => (post as Map<String, dynamic>)['photos'] is List && (post)['photos'].isNotEmpty);
      final hasPoll = payload.any((post) => (post as Map<String, dynamic>)['poll'] != null);
      final hasLocation = payload.any((post) => (post as Map<String, dynamic>)['location'] != null);

      expect(hasPhotos, isTrue);
      expect(hasPoll, isTrue);
      expect(hasLocation, isTrue);
    });

    test('covers feature endpoints used by the app', () async {
      final endpointPaths = <String>[
        '/user',
        '/aspects',
        '/notifications',
        '/conversations',
        '/tag_followings',
        '/search/users',
        '/search/tags',
        '/streams/main',
        '/streams/activity',
        '/streams/mentions',
        '/streams/tags',
        '/streams/liked',
        '/streams/commented',
      ];

      for (final path in endpointPaths) {
        final response = await http.get(baseApiUri.replace(path: '${baseApiUri.path}$path'));
        expect(response.statusCode, 200, reason: 'Expected 200 for $path but got ${response.statusCode}');
      }
    });
  });
}

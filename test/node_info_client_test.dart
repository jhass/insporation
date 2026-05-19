import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:insporation/src/node_info_client.dart';

void main() {
  test('fetchServerVersion tolerates malformed content-type media type', () async {
    final client = NodeInfoClient(
      client: MockClient((request) async {
        if (request.url.path == '/.well-known/nodeinfo') {
          return http.Response(
            jsonEncode({
              'links': [
                {
                  'rel': 'http://nodeinfo.diaspora.software/ns/schema/2.1',
                  'href': '/nodeinfo/2.1',
                }
              ]
            }),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        if (request.url.path == '/nodeinfo/2.1') {
          return http.Response.bytes(
            utf8.encode(jsonEncode({'software': {'version': '1.2.3'}})),
            200,
            headers: {
              'content-type':
                  'application/json; profile=http://nodeinfo.diaspora.software/ns/schema/2.1#; charset=utf-8'
            },
          );
        }

        return http.Response('Not found', 404);
      }),
    );

    final version = await client.fetchServerVersion(Uri.parse('https://example.org'));
    expect(version, '1.2.3');
  });

  test('fetchServerVersion returns null when nodeinfo index is unavailable', () async {
    final client = NodeInfoClient(
      client: MockClient((_) async => http.Response('not found', 404)),
    );

    final version = await client.fetchServerVersion(Uri.parse('https://example.org'));
    expect(version, isNull);
  });
}

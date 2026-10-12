import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:insporation/src/http_client_factory.dart';

void main() {
  test('createHttpClient sends the Insporation user agent', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final receivedUserAgent = server.first.then((request) async {
      final userAgent = request.headers.value(HttpHeaders.userAgentHeader);
      await request.response.close();
      return userAgent;
    });
    final client = createHttpClient();
    addTearDown(() async {
      client.close();
      await server.close(force: true);
    });

    final response = await client.get(
      Uri(scheme: 'http', host: '127.0.0.1', port: server.port),
    );

    expect(await receivedUserAgent, 'Insporation');
    expect(response.statusCode, 200);
  });
}

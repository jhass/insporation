import 'dart:convert';

import 'package:http/http.dart' as http;

import 'pod_version_support.dart';

class NodeInfoClient {
  NodeInfoClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String?> fetchServerVersion(Uri baseUri) async {
    final nodeInfoIndexUri = baseUri.replace(path: '/.well-known/nodeinfo', queryParameters: {});
    final nodeInfoIndexJson = await _fetchJsonMap(nodeInfoIndexUri);
    if (nodeInfoIndexJson == null) {
      return null;
    }

    final nodeInfoUri = PodVersionSupport.bestNodeInfoUri(baseUri, nodeInfoIndexJson['links']);
    if (nodeInfoUri == null) {
      return null;
    }

    final nodeInfoJson = await _fetchJsonMap(nodeInfoUri);
    if (nodeInfoJson == null) {
      return null;
    }

    final software = nodeInfoJson['software'];
    return software is Map<String, dynamic> ? software['version'] as String? : null;
  }

  Future<Map<String, dynamic>?> _fetchJsonMap(Uri uri) async {
    final response = await _client.get(uri).timeout(Duration(seconds: 12));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return null;
    }

    final json = jsonDecode(_decodeResponseBody(response));
    return json is Map<String, dynamic> ? json : null;
  }
}

String _decodeResponseBody(http.Response response) {
  return utf8.decode(response.bodyBytes, allowMalformed: true);
}
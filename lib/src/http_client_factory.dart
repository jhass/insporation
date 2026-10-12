import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cronet_http/cronet_http.dart';
import 'package:cupertino_http/cupertino_http.dart';
import 'package:package_info_plus/package_info_plus.dart';

Future<String>? _applicationVersion;

http.Client createHttpClient() {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return _UserAgentClient(http.Client());
  }

  if (!kIsWeb && Platform.isAndroid) {
    final engine = CronetEngine.build(
      enableHttp2: true,
      enableQuic: true,
    );
    return _UserAgentClient(CronetClient.fromCronetEngine(engine));
  }
  if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
    return _UserAgentClient(CupertinoClient.defaultSessionConfiguration());
  }
  return _UserAgentClient(http.Client());
}

class _UserAgentClient extends http.BaseClient {
  _UserAgentClient(this._inner);

  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final version = await (_applicationVersion ??= PackageInfo.fromPlatform().then((info) => info.version));
    request.headers['user-agent'] = 'Insporation/$version';
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
  }
}

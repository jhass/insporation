import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:cronet_http/cronet_http.dart';
import 'package:cupertino_http/cupertino_http.dart';

http.Client createHttpClient() {
  if (Platform.environment.containsKey('FLUTTER_TEST')) {
    return http.Client();
  }

  if (!kIsWeb && Platform.isAndroid) {
    final engine = CronetEngine.build(
      enableHttp2: true,
      enableQuic: true,
    );
    return CronetClient.fromCronetEngine(engine);
  }
  if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
    return CupertinoClient.defaultSessionConfiguration();
  }
  return http.Client();
}

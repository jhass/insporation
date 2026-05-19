import 'package:flutter_test/flutter_test.dart';
import 'package:insporation/src/pod_version_support.dart';

void main() {
  test('supportsRequiredVersion accepts diaspora versions >= 0.9', () {
    expect(PodVersionSupport.supportsRequiredVersion("0.9.0"), isTrue);
    expect(PodVersionSupport.supportsRequiredVersion("0.9.1"), isTrue);
    expect(PodVersionSupport.supportsRequiredVersion("1.0.0"), isTrue);
  });

  test('supportsRequiredVersion rejects diaspora versions < 0.9', () {
    expect(PodVersionSupport.supportsRequiredVersion("0.8.9"), isFalse);
    expect(PodVersionSupport.supportsRequiredVersion("0.8.0.0"), isFalse);
  });

  test('supportsRequiredVersion keeps sign in permissive for unparsable versions', () {
    expect(PodVersionSupport.supportsRequiredVersion("develop"), isTrue);
    expect(PodVersionSupport.supportsRequiredVersion(null), isTrue);
  });

  test('bestNodeInfoUri picks highest schema version and resolves relative href', () {
    final uri = PodVersionSupport.bestNodeInfoUri(Uri.parse("https://example.org"), [
      {
        "rel": "http://nodeinfo.diaspora.software/ns/schema/1.0",
        "href": "/nodeinfo/1"
      },
      {
        "rel": "http://nodeinfo.diaspora.software/ns/schema/2.1",
        "href": "/nodeinfo/2"
      },
      {
        "rel": "http://nodeinfo.diaspora.software/ns/schema/2.0",
        "href": "/nodeinfo/2_0"
      }
    ]);

    expect(uri, Uri.parse("https://example.org/nodeinfo/2"));
  });

  test('bestNodeInfoUri returns null for invalid payloads', () {
    expect(PodVersionSupport.bestNodeInfoUri(Uri.parse("https://example.org"), null), isNull);
    expect(PodVersionSupport.bestNodeInfoUri(Uri.parse("https://example.org"), []), isNull);
    expect(PodVersionSupport.bestNodeInfoUri(Uri.parse("https://example.org"), [
      {"rel": "https://example.org/schema/2.1", "href": "/nodeinfo/2"},
      {"rel": "http://nodeinfo.diaspora.software/ns/schema/2.1"}
    ]), isNull);
  });
}

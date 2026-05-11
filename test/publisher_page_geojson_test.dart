import 'package:flutter_test/flutter_test.dart';
import 'package:insporation/publisher_page.dart';

void main() {
  test('photon locations preserve address formatting and lng/lat mapping', () {
    const photonResponse = '''
{
  "type": "FeatureCollection",
  "features": [
    {
      "type": "Feature",
      "properties": {
        "name": "Cafe Central",
        "street": "Main St 1",
        "city": "Vienna",
        "state": "Vienna",
        "country": "Austria"
      },
      "geometry": {
        "type": "Point",
        "coordinates": [16.3725, 48.2089]
      }
    },
    {
      "type": "Feature",
      "properties": {
        "name": "Cafe Central",
        "street": "Main St 1",
        "city": "Vienna",
        "state": "Vienna",
        "country": "Austria"
      },
      "geometry": {
        "type": "Point",
        "coordinates": [99.0, 88.0]
      }
    },
    {
      "type": "Feature",
      "properties": {
        "name": "Museum Quarter",
        "city": "Vienna",
        "country": "Austria"
      },
      "geometry": {
        "type": "Point",
        "coordinates": [16.3611, 48.2033]
      }
    }
  ]
}
''';

    final locations = photonLocationsFromFeatures(
      photonFeaturesFromGeoJson(photonResponse),
    ).toList();

    expect(locations, hasLength(2));
    expect(locations.first.address, 'Cafe Central, Main St 1, Vienna, Austria');
    expect(locations.first.lat, 48.2089);
    expect(locations.first.lng, 16.3725);
    expect(locations.last.address, 'Museum Quarter, Vienna, Austria');
    expect(locations.last.lat, 48.2033);
    expect(locations.last.lng, 16.3611);
  });
}
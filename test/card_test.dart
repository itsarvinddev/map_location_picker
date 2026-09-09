import 'package:flutter_test/flutter_test.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:map_location_picker/src/card.dart';

/// Regression tests for the bottom card and the nearby-places sheet.
///
/// `addressTitle` replaces
/// `(result.addressComponents?.first.longName ?? "").substring(0, 1)`, which
/// threw for every one of the inputs below.
void main() {
  group('addressTitle', () {
    test('returns an empty string for a null result', () {
      expect(addressTitle(null), '');
    });

    test('does not throw when addressComponents is null', () {
      // The old code did `(null?.first.longName ?? "").substring(0, 1)`,
      // i.e. "".substring(0, 1) -> RangeError.
      final result = GeocodingResult(formattedAddress: null);
      expect(addressTitle(result), '');
    });

    test('does not throw when addressComponents is empty', () {
      // The old code did `[].first` -> Bad state: No element. The Geocoding API
      // returns this for plus-code-only results.
      final result = GeocodingResult(addressComponents: const []);
      expect(addressTitle(result), '');
    });

    test('does not throw when longName is an empty string', () {
      final result = GeocodingResult(
        addressComponents: [AddressComponent(longName: '')],
      );
      expect(addressTitle(result), '');
    });

    test('falls back to the formatted address when components are missing', () {
      final result = GeocodingResult(
        formattedAddress: 'baker street, London, UK',
      );
      expect(addressTitle(result), 'Baker street');
    });

    test('capitalises the first address component', () {
      final result = GeocodingResult(
        addressComponents: [AddressComponent(longName: 'baker street')],
        formattedAddress: 'baker street, London',
      );
      expect(addressTitle(result), 'Baker street');
    });

    test('leaves an already-capitalised name alone', () {
      final result = GeocodingResult(
        addressComponents: [AddressComponent(longName: 'Baker Street')],
      );
      expect(addressTitle(result), 'Baker Street');
    });

    test('handles a single-character name', () {
      final result = GeocodingResult(
        addressComponents: [AddressComponent(longName: 'a')],
      );
      expect(addressTitle(result), 'A');
    });
  });

  group('GeocodingResultParts', () {
    final result = GeocodingResult(
      formattedAddress: '10 Downing St, London SW1A 2AA, UK',
      addressComponents: [
        AddressComponent(
          longName: '10',
          shortName: '10',
          types: const ['street_number'],
        ),
        AddressComponent(
          longName: 'Downing Street',
          shortName: 'Downing St',
          types: const ['route'],
        ),
        AddressComponent(
          longName: 'London',
          shortName: 'London',
          types: const ['postal_town'],
        ),
        AddressComponent(
          longName: 'SW1A 2AA',
          shortName: 'SW1A 2AA',
          types: const ['postal_code'],
        ),
        AddressComponent(
          longName: 'United Kingdom',
          shortName: 'GB',
          types: const ['country', 'political'],
        ),
      ],
    );

    test('reads individual components by type', () {
      expect(result.streetNumber, '10');
      expect(result.street, 'Downing Street');
      expect(result.city, 'London');
      expect(result.postalCode, 'SW1A 2AA');
      expect(result.country, 'United Kingdom');
    });

    test('reads short names', () {
      expect(result.countryCode, 'GB');
    });

    test('returns null for a type that is not present', () {
      expect(result.component('locality'), isNull);
      expect(result.administrativeArea, isNull);
    });

    test('is safe on a result with no components', () {
      final empty = GeocodingResult();
      expect(empty.city, isNull);
      expect(empty.countryCode, isNull);
      expect(empty.latLng, isNull);
    });
  });
}

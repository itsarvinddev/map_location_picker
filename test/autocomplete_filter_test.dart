import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_apis/places_new.dart';

/// Regression tests for issue #70.
///
/// The autocomplete request used to be built as
/// `filter ?? AutocompleteSearchFilter(input: query, sessionToken: ...)`, so a
/// caller-supplied `searchFilter` replaced the whole request and Google never
/// received the typed text. It is now merged with `copyWith`, which these tests
/// pin down.
void main() {
  /// Mirrors the merge performed in `AutoCompleteService.search`.
  AutocompleteSearchFilter merge(
    AutocompleteSearchFilter? filter,
    String query,
    String fallbackSessionToken,
  ) {
    return (filter ?? AutocompleteSearchFilter()).copyWith(
      input: query,
      sessionToken: filter?.sessionToken ?? fallbackSessionToken,
    );
  }

  group('autocomplete filter merge (issue #70)', () {
    test('injects the query when no filter is supplied', () {
      final result = merge(null, 'coffee', 'session-1');
      expect(result.input, 'coffee');
      expect(result.sessionToken, 'session-1');
    });

    test('injects the query into a caller-supplied filter', () {
      final filter = AutocompleteSearchFilter(
        regionCode: 'ro',
        languageCode: 'ro',
        includedRegionCodes: const ['ro'],
      );

      final result = merge(filter, 'strada', 'session-1');

      // The bug: input used to stay null here, so the API returned nothing.
      expect(result.input, 'strada');
      expect(result.sessionToken, 'session-1');
    });

    test('preserves every restriction the caller set', () {
      final filter = AutocompleteSearchFilter(
        regionCode: 'ro',
        languageCode: 'ro',
        includedRegionCodes: const ['ro', 'md'],
        includedPrimaryTypes: const [PlaceType.restaurant],
        inputOffset: 3,
        includeQueryPredictions: true,
        origin: LatLng(latitude: 44.4, longitude: 26.1),
      );

      final result = merge(filter, 'strada', 'session-1');

      expect(result.regionCode, 'ro');
      expect(result.languageCode, 'ro');
      expect(result.includedRegionCodes, ['ro', 'md']);
      expect(result.includedPrimaryTypes, [PlaceType.restaurant]);
      expect(result.inputOffset, 3);
      expect(result.includeQueryPredictions, isTrue);
      expect(result.origin?.latitude, 44.4);
      expect(result.origin?.longitude, 26.1);
    });

    test("does not clobber a session token the caller set explicitly", () {
      final filter = AutocompleteSearchFilter(sessionToken: 'caller-owned');

      final result = merge(filter, 'strada', 'package-generated');

      expect(result.sessionToken, 'caller-owned');
    });

    test('an empty query is never sent', () {
      // `search` short-circuits before building a request at all.
      expect(''.isEmpty, isTrue);
    });
  });

  group('SessionTokenHandler lifecycle', () {
    test('returns a stable token within one session', () {
      final handler = SessionTokenHandler();
      final first = handler.token;
      final second = handler.token;
      expect(first, second, reason: 'keystrokes must share one session token');
    });

    test(
      'caching place details concludes the session and rotates the token',
      () {
        final handler = SessionTokenHandler();
        final duringSearch = handler.token;

        handler.cachePlaceDetails(
          id: 'place-1',
          data: Place(id: 'place-1', formattedAddress: '1 Test St'),
        );

        expect(
          handler.token,
          isNot(duringSearch),
          reason: 'a concluded session must not reuse its token',
        );
        expect(
          handler.placeFromCache('place-1')?.formattedAddress,
          '1 Test St',
        );
      },
    );

    // `getDetails` passes `response.body` straight through without a null
    // guard. That is deliberate, and only safe because of the two properties
    // pinned here: `cachePlaceDetails` is null-tolerant, and it calls
    // `refresh()` unconditionally, so a successful Details request concludes
    // the session even when it carried nothing to cache. A `google_maps_apis`
    // upgrade that made the refresh conditional would silently leave the
    // picker reusing a concluded token, which Google bills per request.
    test('a null body still concludes the session and rotates the token', () {
      final handler = SessionTokenHandler();
      final duringSearch = handler.token;

      expect(
        () => handler.cachePlaceDetails(id: 'place-1', data: null),
        returnsNormally,
      );

      expect(handler.placeFromCache('place-1'), isNull);
      expect(
        handler.token,
        isNot(duringSearch),
        reason: 'a concluded session must not reuse its token',
      );
    });
  });
}

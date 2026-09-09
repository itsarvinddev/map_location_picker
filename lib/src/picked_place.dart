import 'package:flutter/foundation.dart';
import 'package:google_maps_apis/geocoding.dart';
import 'package:google_maps_apis/places_new.dart' as places;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'geocoding_service.dart';

/// What the user picked.
///
/// Returned by [showMapLocationPicker]. It always carries [latLng], even when
/// reverse geocoding failed — previously there was no way to get the raw
/// coordinate back out of the picker if the Geocoding API returned nothing, so
/// a bad API key or a point over water meant the user could not confirm at all.
///
/// ```dart
/// final picked = await showMapLocationPicker(context, config: myConfig);
/// if (picked != null) {
///   print('${picked.latLng} — ${picked.name ?? picked.formattedAddress}');
/// }
/// ```
@immutable
class PickedPlace {
  /// The selected coordinates. Always present.
  final LatLng latLng;

  /// A human-readable name, when the selection came from a search suggestion.
  ///
  /// Reverse geocoding a point of interest returns its street address, so this
  /// is the only way to keep "Heathrow Terminal 5" rather than
  /// "Nelson Rd, Hounslow".
  final String? name;

  /// The Google place id, when known.
  final String? placeId;

  /// The full formatted address, when one was resolved.
  final String? formattedAddress;

  /// The street name.
  final String? street;

  /// The street number.
  final String? streetNumber;

  /// The city or town.
  final String? locality;

  /// The state, province or region.
  final String? administrativeArea;

  /// The postal or ZIP code.
  final String? postalCode;

  /// The country name.
  final String? country;

  /// The ISO 3166-1 alpha-2 country code, e.g. `GB`.
  final String? countryCode;

  /// The underlying geocoding result, when there was one.
  final GeocodingResult? result;

  /// The underlying Places result, when the selection came from a search.
  final places.Place? place;

  /// Creates a picked place.
  const PickedPlace({
    required this.latLng,
    this.name,
    this.placeId,
    this.formattedAddress,
    this.street,
    this.streetNumber,
    this.locality,
    this.administrativeArea,
    this.postalCode,
    this.country,
    this.countryCode,
    this.result,
    this.place,
  });

  /// Builds a [PickedPlace] from whatever the picker managed to resolve.
  factory PickedPlace.from({
    required LatLng latLng,
    GeocodingResult? result,
    places.Place? place,
    String? name,
  }) {
    return PickedPlace(
      latLng: latLng,
      name: name ?? place?.displayName?.text,
      placeId: place?.id ?? result?.placeId,
      formattedAddress: result?.formattedAddress ?? place?.formattedAddress,
      street: result?.street,
      streetNumber: result?.streetNumber,
      locality: result?.city,
      administrativeArea: result?.administrativeArea,
      postalCode: result?.postalCode,
      country: result?.country,
      countryCode: result?.countryCode,
      result: result,
      place: place,
    );
  }

  /// The best single label for this place.
  String get displayLabel =>
      name ?? formattedAddress ?? '${latLng.latitude}, ${latLng.longitude}';

  @override
  String toString() =>
      'PickedPlace($latLng, ${name ?? formattedAddress ?? 'no address'})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PickedPlace &&
          other.latLng == latLng &&
          other.placeId == placeId &&
          other.formattedAddress == formattedAddress &&
          other.name == name;

  @override
  int get hashCode => Object.hash(latLng, placeId, formattedAddress, name);
}

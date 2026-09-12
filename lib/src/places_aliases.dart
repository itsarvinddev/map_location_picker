import 'package:google_maps_apis/places_new.dart' as places;

/// The Places (New) circle, used by [places.LocationBias] and
/// [places.LocationRestriction].
///
/// Aliased because `google_maps_flutter`'s `Circle` — a map overlay — already
/// owns that name in this package's barrel, and Dart cannot rename on export.
/// Without the alias, `Circle(center: ..., radius: ...)` silently resolves to
/// the map type and fails with "circleId is required".
typedef PlacesCircle = places.Circle;

/// The Places (New) lat/lng, used by `AutocompleteSearchFilter.origin`.
///
/// Aliased for the same reason as [PlacesCircle]: `LatLng` in this barrel is
/// `google_maps_flutter`'s, which takes positional `(lat, lng)` rather than
/// the named `latitude:`/`longitude:` the Places API uses.
typedef PlacesLatLng = places.LatLng;

/// The Places (New) address component.
///
/// Aliased because the barrel already exports the *geocoding*
/// `AddressComponent`, and exporting both would be ambiguous.
typedef PlacesAddressComponent = places.AddressComponent;

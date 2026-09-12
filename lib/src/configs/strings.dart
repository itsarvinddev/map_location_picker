import 'package:google_maps_flutter/google_maps_flutter.dart' show MapType;

/// Every user-visible string the picker renders.
///
/// The package ships English defaults. Pass a different instance to
/// `MapLocationPickerConfig.strings` to translate the UI, or to reword it:
///
/// ```dart
/// MapLocationPickerConfig(
///   apiKey: key,
///   strings: const MapLocationPickerStrings(
///     confirmAddress: 'Livrer ici',
///     loadingAddress: 'Recherche de l\'adresse…',
///     noAddressFound: 'Adresse introuvable',
///   ),
/// )
/// ```
///
/// To follow the app locale, build it from your own localizations:
///
/// ```dart
/// strings: MapLocationPickerStrings(
///   confirmAddress: AppLocalizations.of(context)!.confirmAddress,
/// )
/// ```
class MapLocationPickerStrings {
  /// Title of the bottom card while the address is being resolved.
  final String loadingAddress;

  /// Subtitle of the bottom card while the address is being resolved.
  final String loadingAddressSubtitle;

  /// Label of the primary confirmation button.
  final String confirmAddress;

  /// Shown when reverse geocoding returned nothing.
  final String noAddressFound;

  /// Tooltip and semantic label of the map-type button.
  final String mapTypeTooltip;

  /// Title of the map-type sheet.
  final String mapTypeTitle;

  /// Explanatory line in the map-type sheet.
  final String mapTypeMessage;

  /// Label for [MapType.normal].
  final String mapTypeNormal;

  /// Label for [MapType.satellite].
  final String mapTypeSatellite;

  /// Label for [MapType.terrain].
  final String mapTypeTerrain;

  /// Label for [MapType.hybrid].
  final String mapTypeHybrid;

  /// Generic cancel label.
  final String cancel;

  /// Label of the "show the other geocoder matches" button, given the number
  /// of matches.
  final String Function(int count) nearbyPlacesCount;

  /// Title of the nearby-places sheet, given the number of matches.
  final String Function(int count) nearbyPlacesTitle;

  /// Shown on the matching-addresses button while results are loading.
  final String loadingNearbyPlaces;

  /// Explanatory line in the nearby-places sheet.
  final String tapToSelect;

  /// Placeholder text for the search field.
  final String searchHint;

  /// Creates a set of strings. Every field has an English default.
  const MapLocationPickerStrings({
    this.loadingAddress = 'Loading address...',
    this.loadingAddressSubtitle = 'Fetching location details.',
    this.confirmAddress = 'Confirm Address',
    this.noAddressFound = 'No address found',
    this.mapTypeTooltip = 'Map type',
    this.mapTypeTitle = 'Map type',
    this.mapTypeMessage = 'Select the map type you want to see.',
    this.mapTypeNormal = 'Standard Map',
    this.mapTypeSatellite = 'Satellite Map',
    this.mapTypeTerrain = 'Terrain Map',
    this.mapTypeHybrid = 'Hybrid Map',
    this.cancel = 'Cancel',
    this.nearbyPlacesCount = _defaultNearbyPlacesCount,
    this.nearbyPlacesTitle = _defaultNearbyPlacesCount,
    this.loadingNearbyPlaces = 'Loading addresses...',
    this.tapToSelect = 'tap to select',
    this.searchHint = 'Search for place, address, landmark, etc.',
  });

  static String _defaultNearbyPlacesCount(int count) =>
      // These are the geocoder's alternative interpretations of one coordinate,
      // not nearby points of interest -- the old "N places found nearby" label
      // described something the list never contained.
      count == 1 ? '1 matching address' : '$count matching addresses';

  /// The label for [type].
  String mapTypeName(MapType type) => switch (type) {
    MapType.normal => mapTypeNormal,
    MapType.satellite => mapTypeSatellite,
    MapType.terrain => mapTypeTerrain,
    MapType.hybrid => mapTypeHybrid,
    _ => mapTypeNormal,
  };

  /// Returns a copy with the given fields replaced.
  MapLocationPickerStrings copyWith({
    String? loadingAddress,
    String? loadingAddressSubtitle,
    String? confirmAddress,
    String? noAddressFound,
    String? mapTypeTooltip,
    String? mapTypeTitle,
    String? mapTypeMessage,
    String? mapTypeNormal,
    String? mapTypeSatellite,
    String? mapTypeTerrain,
    String? mapTypeHybrid,
    String? cancel,
    String Function(int count)? nearbyPlacesCount,
    String Function(int count)? nearbyPlacesTitle,
    String? loadingNearbyPlaces,
    String? tapToSelect,
    String? searchHint,
  }) {
    return MapLocationPickerStrings(
      loadingAddress: loadingAddress ?? this.loadingAddress,
      loadingAddressSubtitle:
          loadingAddressSubtitle ?? this.loadingAddressSubtitle,
      confirmAddress: confirmAddress ?? this.confirmAddress,
      noAddressFound: noAddressFound ?? this.noAddressFound,
      mapTypeTooltip: mapTypeTooltip ?? this.mapTypeTooltip,
      mapTypeTitle: mapTypeTitle ?? this.mapTypeTitle,
      mapTypeMessage: mapTypeMessage ?? this.mapTypeMessage,
      mapTypeNormal: mapTypeNormal ?? this.mapTypeNormal,
      mapTypeSatellite: mapTypeSatellite ?? this.mapTypeSatellite,
      mapTypeTerrain: mapTypeTerrain ?? this.mapTypeTerrain,
      mapTypeHybrid: mapTypeHybrid ?? this.mapTypeHybrid,
      cancel: cancel ?? this.cancel,
      nearbyPlacesCount: nearbyPlacesCount ?? this.nearbyPlacesCount,
      nearbyPlacesTitle: nearbyPlacesTitle ?? this.nearbyPlacesTitle,
      loadingNearbyPlaces: loadingNearbyPlaces ?? this.loadingNearbyPlaces,
      tapToSelect: tapToSelect ?? this.tapToSelect,
      searchHint: searchHint ?? this.searchHint,
    );
  }
}

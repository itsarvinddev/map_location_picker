## 3.1.0

- cancelToken, headers & interceptors added to the new apis only.
- roof top geocoding api fixed.

## 3.0.0

- google_maps_apis package added.
- now new places api is used for geocoding and autocomplete.
- new bottom card options added.

## 2.0.3

- add context.mounted check for geocoding result.

## 2.0.2

- searchBarBuilder added to customize the search bar.
- bottomCardTitle added to customize the bottom card title.
- hideBottomCardOnKeyboard added to hide the bottom card when the keyboard is visible.
- hideSearchBar added to hide the search bar.
- hideBottomCard added to hide the bottom card.
- popOnNext added to pop the next button.

## 2.0.1

- autocomplete configurations to improve clarity and consistency.
- Renamed MapPickerConfig to MapLocationPickerConfig and PlacesAutocompleteConfig to SearchConfig, updating related references throughout the codebase. This enhances the structure and readability of the location picking functionality.

## 2.0.0+2

- custom logger added.

## 2.0.0+1

- dependencies updated.
- form_builder_extra_fields package removed from dependencies.

## 2.0.0

- Added `defaultAddressText` parameter to customize the default address text shown when no location is selected.
- Fixed FloatingActionButton hero tag conflict ([#62](https://github.com/itsarvinddev/map_location_picker/issues/62)), thanks to [Anthony1701](https://github.com/Anthony1701) for [PR #63](https://github.com/itsarvinddev/map_location_picker/pull/63).
- Confirmed compatibility with latest flutter_typeahead (5.2.0) ([#51](https://github.com/itsarvinddev/map_location_picker/issues/51)).
- Fixed TextEditingController disposal issue to prevent double disposal errors ([#56](https://github.com/itsarvinddev/map_location_picker/issues/56)).
- Improved back button placement with prominent top positioning and title ([#47](https://github.com/itsarvinddev/map_location_picker/issues/47)).
- Added padding to autocomplete list items for better visual spacing and readability ([#39](https://github.com/itsarvinddev/map_location_picker/issues/39)).
- Enhanced documentation and examples for custom map styles feature ([#58](https://github.com/itsarvinddev/map_location_picker/issues/58)).
- Added `onMapCreated` callback to provide access to GoogleMapController for manual customization ([#61](https://github.com/itsarvinddev/map_location_picker/issues/61)).
- Enhanced custom markers support with icons, info windows, and tap handlers ([#59](https://github.com/itsarvinddev/map_location_picker/issues/59)).
- Improved API key restrictions documentation with security best practices ([#60](https://github.com/itsarvinddev/map_location_picker/issues/60)).
- Enhanced map type functionality with change callback and better documentation.
- Fixed web autocomplete focus issues in Safari and Firefox browsers ([#57](https://github.com/itsarvinddev/map_location_picker/issues/57)).

## 1.3.4

- dependencies updated.

## 1.3.3

- dependencies updated.

## 1.3.2

- debouncer added to search.

## 1.3.1

- updated dependencies.
- https://pub.dev/packages/flutter_typeahead#migrations

## 1.3.0

- useState now private.

## 1.2.9+2

- bottomCardBuilder added to customize the bottom card.

## 1.2.9+1

- updated dependencies.

## 1.2.9

- updated dependencies.

## 1.2.8+2

- Topics updated.
- minor changes in readme.

## 1.2.8+1

- Tags and screenshots added.

## 1.2.8

- Readme updated.

## 1.2.7

- dependencies updated.
- #29 not issue not found while testing.
- #27 Map scroll and singlechildscrollview both can't be used at the same time.
- #26 fixed.
- New contribution by [Raju Prasad](https://github.com/rajuprasad-dev)
- New contribution by [Hemil Gandhi](https://github.com/hgandhi67)

## 1.2.6

- [#22](https://github.com/rvndsngwn/map_location_picker/issues/22) fixed
- [#25](https://github.com/rvndsngwn/map_location_picker/issues/25) fixed

## 1.2.5

- now if currentLatLng != null GoogleMapsGeocoding added on init. #22

## 1.2.4

- warnings, lints, or formatting issues fixed.
- `lints_core` added to dev_dependencies.

## 1.2.3

- google_maps_flutter_web removed from dependencies because it is now supported by google_maps_flutter package.

## 1.2.2

- search card safe area parameters [bottom, left, maintainBottomViewPadding, minimum, right, top] added. #19
- parameters added for hide my location button [hideLocationButton], map type button [hideLocationButton] and bottom
  card [hideBottomCard]. #20
- onDecodeAddress parameter added.
- showBackButton changed to hideBackButton.
- canPopOnNextButtonTaped changed to popOnNextButtonTaped.

## 1.2.1-dev.1

- Dependencies updated.

## 1.2.1

- Dependencies updated.

## 1.2.0

- Dependencies updated.
- Google map API's updated.

## 1.1.1

- Miner improvements

## 1.1.0

- Major update. Now you can more customize the UI of the `PlacesAutocomplete`.

## 1.0.4

- There is now an optional `searchController` parameter in the `PlacesAutocomplete` class.
- There are two new parameters in the `PlacesAutocomplete` class: `initialValue` and `validator`.
- Try to fix the issue of [#10](https://github.com/rvndsngwn/map_location_picker/issues/10) -- Let me know if it works.

## 1.0.3

- Support additional markers. Thanks to [Frankely Diaz](https://github.com/frankely) #9 for contribution.
- Dependencies updated.

## 1.0.2

- [#7](https://github.com/rvndsngwn/map_location_picker/issues/7) Enhancement: Add support for current position.
- New Parameters in `MapLocationPicker` class :- `currentLatLng`, `mapType` and `searchController`
- Now PlacesAutocomplete search text field is a separate widget `PlacesAutocomplete` which can be used independently.
- Dependencies updated.
- Provider removed.

## 1.0.1

- google_maps_flutter package updated to 2.1.10
- form_builder_extra_fields package updated to 8.3.0
- geolocator package updated to 9.0.1
- Cannot select a location directly after searching in the search
  bar [#5](https://github.com/rvndsngwn/map_location_picker/issues/5) resolved.
- LateInitializationError on \_geocodingresult [#6](https://github.com/rvndsngwn/map_location_picker/issues/6) resolved.

## 1.0.0+2

- Readme updated

## 1.0.0+1

- Readme updated

## 1.0.0

- Remake of the entire project form scratch.
- Added new features and UI customizations.
- Added flutter web support.
- [#2](https://github.com/rvndsngwn/map_location_picker/issues/2) bug fixed.
- [#3](https://github.com/rvndsngwn/map_location_picker/issues/3) bug fixed.
- [#4](https://github.com/rvndsngwn/map_location_picker/issues/4) Enhancement has been postponed.

## 0.0.2

- Merge pull request [#1](https://github.com/rvndsngwn/map_location_picker/pull/1)
  from [jeffmilanes/new_update](https://github.com/jeffmilanes)
- Search results text color changed to black
- Permission handler removed
- Code cleanup
- Readme updated

## 0.0.1+1

- Clean code and performance improvements.
- Removed google_api_header package.
- Added all dependencies constraint version number.

## 0.0.1

- initial release.

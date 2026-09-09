## 4.0.0

A full audit release: every open issue closed, every open pull request merged or
superseded with credit, the dependency stack brought current, and the parts of
the package that were quietly broken made to actually work.

**Requires Flutter 3.38 / Dart 3.10.** See
[MIGRATION_GUIDE.md](https://github.com/itsarvinddev/map_location_picker/blob/master/MIGRATION_GUIDE.md)
for the upgrade from 3.x.

### Fixed

- **The "my location" button did nothing the first time permission was granted.**
  The guard read `permission != whileInUse || permission != always`, which no
  enum value can fail, so the method always returned right after the OS dialog.
  Every failure path — services disabled, denied, denied forever, timeout — now
  reports a distinct error instead of returning silently.
- **`searchFilter` broke autocomplete completely**
  ([#70](https://github.com/itsarvinddev/map_location_picker/issues/70)). A
  caller-supplied filter replaced the whole request, so the typed text never
  reached Google. Filters are now merged, and a `sessionToken` you set yourself
  is preserved. Thanks [@CaptainRiley](https://github.com/CaptainRiley) for the
  root-cause analysis and [@vkourtis](https://github.com/vkourtis) for
  [#67](https://github.com/itsarvinddev/map_location_picker/pull/67), which is
  superseded by this fix — the file that PR patched had been orphaned by an
  earlier refactor, so the change would never have executed.
- **Build failure on google_maps_apis 4.0.0**
  ([#68](https://github.com/itsarvinddev/map_location_picker/issues/68)):
  `CustomParseErrorLogger.logError` took three positional arguments where
  retrofit ≥ 4.9.0 requires four. Fixed by moving to google_maps_apis 5.1 and
  dropping the `retrofit` pin that caused it. Thanks
  [@jansvanda](https://github.com/jansvanda) for the report and
  [@CarmeloBeeapp](https://github.com/CarmeloBeeapp) for
  [#71](https://github.com/itsarvinddev/map_location_picker/pull/71).
- **The picker could not be embedded in an existing screen**
  ([#65](https://github.com/itsarvinddev/map_location_picker/issues/65)). It
  always returned its own `Scaffold`, so nesting it gave the inner scaffold
  unbounded constraints and rendered it squashed into a corner. Use the new
  `MapLocationPickerView`, which has no `Scaffold`. Thanks
  [@Brandon2255p](https://github.com/Brandon2255p).
- **Flutter web**
  ([#14](https://github.com/itsarvinddev/map_location_picker/issues/14)). The
  Places REST endpoints now support CORS, so search works from a browser
  directly — no proxy. Place *details* previously never worked on web at all.
  Overlays are wrapped in `PointerInterceptor`, without which the search field
  and Confirm button were unclickable over the map. Thanks
  [@Bylinkk](https://github.com/Bylinkk).
- **Every autocomplete keystroke was billed as its own Places session.** A fresh
  session token was minted per request and never passed to the details call. One
  token now covers a whole search and is retired when details are fetched.
- **The bottom card and the "nearby places" sheet crashed** on
  `.substring(0, 1)` of an empty string and `.first` of an empty list — both
  reachable from ordinary geocoding responses.
- **Overlapping lookups returned the wrong address.** Two quick taps on a slow
  connection could leave the older response overwriting the newer one, so
  Confirm returned a location the user never picked. Requests are now sequenced.
- **The Confirm button was a dead filled button** whenever geocoding failed —
  a bad key, an exceeded quota or a point over water left no way to confirm.
  It now returns the raw coordinate; set `requireGeocodedAddress: true` for the
  old behaviour.
- Tapping an entry in the nearby sheet fired `onNext` and popped twice instead
  of updating the selection.
- Supplying a `searchConfig` silently discarded `config.apiKey`, so autocomplete
  ran with an empty key and returned nothing, forever.
- Async continuations wrote disposed state when leaving the screen mid-request.
- Awaiting the map controller had no timeout, so a missing API key pinned the
  spinner permanently.
- `additionalMarkers['main']` collided with the built-in marker id.
- A new `http.Client` was created for every reverse geocode and never closed.
- `LatLng(0, 0)` was treated as an "unset" sentinel; use `skipInitialGeocode`.
- Selecting a suggestion paid for a second reverse-geocode that could overwrite
  the address it had just fetched.
- Horizontal safe-area insets were stripped, pushing controls under the notch.
- The Google logo was covered by the bottom card, contrary to the Maps Platform
  terms.
- The example could not compile from a clean clone — `example/lib/key.dart` was
  gitignored — and its `pubspec.yaml` declared an unsatisfiable SDK range.

### Added

- **`PickerPinMode.centerPin`** — a fixed pin with the map panning underneath,
  resolving when the map settles. Customise it with `centerPinBuilder`.
- **`MapLocationPickerController`** — drive the picker from outside the widget
  tree and read its state: `moveTo`, `goToCurrentLocation`, `refreshAddress`,
  `selectPlace`, `setMapType`, `confirm`.
- **`showMapLocationPicker(context, config: ...)`** returning **`PickedPlace`**,
  replacing the Navigator + `onNext` + `pop` boilerplate. `PickedPlace.latLng`
  is always populated, and `name` survives from Place Details so a point of
  interest keeps its name instead of the street address.
- **`MapLocationPickerStrings`** — all 17 user-visible strings, for translation.
- **`MapLocationPickerException` / `MapPickerErrorKind` / `onError`** — typed
  failures. An invalid API key, an exceeded quota and "no results here" were
  previously all the same silent empty state.
- **Nearby places** via the Places API (New) — `showNearbyPlaces`,
  `nearbyPlaceTypes`, `nearbyPlacesRadius`, `nearbyPlacesLimit`.
- **`countries` and `placeTypes`** as first-class search restrictions. The
  README documented a `components` parameter for years; it never existed.
- **`startWithCurrentLocation`**, with a timeout and last-known-position
  fallback.
- **`showBackButton` / `backButtonBuilder`** — the picker had no exit control.
- A draggable main marker with **`onMainMarkerPositionChanged`**, reporting
  every move. Thanks [@demon36](https://github.com/demon36) for
  [#72](https://github.com/itsarvinddev/map_location_picker/pull/72).
- **`GeocodingResultParts`** — `city`, `postalCode`, `countryCode`, `street`
  and friends, instead of hand-searching `addressComponents`.
- `FloatingControlsPosition`, configurable FAB hero tags (two pickers in one
  route used to throw), `tapToSelect`, `showSearchBar`, `showMapTypeButton`,
  `showMyLocationButton`, `mapBottomInset`, `pinIdleDebounce`.
- `MapPickerLogLevel` and `mapLogger.onLog` to quieten or redirect the package's
  logging.
- `SearchConfig.constrainWidth`, from flutter_typeahead 6.
- Semantics on the floating buttons and the confirm button.
- A GitHub Actions workflow: analyze, format, generated-code drift, tests,
  Android/iOS/web/wasm builds, publish dry-run and a pana gate.

### Changed

- **Requires Flutter 3.38 / Dart 3.10.** google_maps_apis 5.x needs
  `meta ^1.17.0`, and the Flutter SDK pins `meta` exactly — 1.16.0 up to Flutter
  3.37, 1.17.0 from 3.38. Anything lower cannot resolve.
- **The barrel exports far less.** It used to re-export all of `geolocator`,
  `google_maps_flutter` and both the legacy and new `google_maps_apis`
  libraries — hundreds of symbols and nine name collisions. It now exports
  exactly the types in this package's signatures, including ones you previously
  had to add `dio`, `http` and `flutter_typeahead` to your own pubspec to name.
- `google_maps_apis` → `>=5.1.0 <6.0.0`, `flutter_typeahead` → `>=6.0.0 <7.0.0`,
  `google_maps_flutter` → `>=2.13.1 <3.0.0`.
- `retrofit` and `web` removed — neither was ever imported.
- `pointer_interceptor` added, for clickable web overlays.
- The `flutter.plugin.platforms` block is replaced by a top-level `platforms:`
  key. The old one was federated-plugin endorsement for a package with no native
  code, and made the Flutter tool register a plugin in every consumer app.
- "N places found nearby" now reads "N matching addresses", which is what that
  list has always actually contained.
- The README's restricted-API-key section is corrected: `X-Android-Cert` takes
  the Base16 SHA-1 with the colons stripped, and the surrounding snippet used a
  parameter (`geoCodingApiHeaders`) that does not exist. Thanks
  [@Elbarae1921](https://github.com/Elbarae1921) for
  [#66](https://github.com/itsarvinddev/map_location_picker/pull/66) and
  [@dend456](https://github.com/dend456) for the original finding.

### Deprecated

- `SearchConfig.hideWithKeyboard` — removed upstream in flutter_typeahead 6.0.0
  because closing the keyboard also drops focus. Use `hideOnUnfocus`.
- `MapLocationPickerConfig.bottomCardType` — was never read. Use `cardType`.

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

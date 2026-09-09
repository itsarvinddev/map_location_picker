# map_location_picker

[![Pub Version](https://img.shields.io/pub/v/map_location_picker?color=blue&style=plastic)](https://pub.dev/packages/map_location_picker)
[![Pub Points](https://img.shields.io/pub/points/map_location_picker?color=blue&style=plastic)](https://pub.dev/packages/map_location_picker/score)
[![GitHub Repo stars](https://img.shields.io/github/stars/itsarvinddev/map_location_picker?color=gold&style=plastic)](https://github.com/itsarvinddev/map_location_picker/stargazers)
[![GitHub Repo issues](https://img.shields.io/github/issues/itsarvinddev/map_location_picker?color=coral&style=plastic)](https://github.com/itsarvinddev/map_location_picker/issues)
[![GitHub Repo contributors](https://img.shields.io/github/contributors/itsarvinddev/map_location_picker?color=green&style=plastic)](https://github.com/itsarvinddev/map_location_picker/graphs/contributors)

A Google Maps location picker for Flutter, on the Places API (New).

Pick a point, get a typed address back. Works on Android, iOS and web — search
included, with no CORS proxy.

<table>
  <tr>
    <td>Default View</td>
    <td>Dark Mode</td>
    <td>Custom Markers</td>
    <td>Custom Map Type</td>
    <td>Liquid Card</td>
  </tr>
  <tr>
    <td><img src="https://raw.githubusercontent.com/itsarvinddev/map_location_picker/master/assets/iphone_14_pro_1_0.png" width=210 alt=""></td>
    <td><img src="https://raw.githubusercontent.com/itsarvinddev/map_location_picker/master/assets/iphone_14_pro_2_1.png" width=210 alt=""></td>
    <td><img src="https://raw.githubusercontent.com/itsarvinddev/map_location_picker/master/assets/iphone_14_pro_3_2.png" width=210 alt=""></td>
    <td><img src="https://raw.githubusercontent.com/itsarvinddev/map_location_picker/master/assets/iphone_14_pro_4_3.png" width=210 alt=""></td>
    <td><img src="https://raw.githubusercontent.com/itsarvinddev/map_location_picker/master/assets/iphone_14_pro_5_4.png" width=210 alt=""></td>
  </tr>
</table>

---

## Quick start

```yaml
dependencies:
  map_location_picker: ^4.0.0
```

```dart
import 'package:map_location_picker/map_location_picker.dart';

final picked = await showMapLocationPicker(
  context,
  config: const MapLocationPickerConfig(apiKey: 'YOUR_API_KEY'),
);

if (picked != null) {
  print(picked.latLng);            // always present
  print(picked.formattedAddress);  // '10 Downing St, London SW1A 2AA, UK'
  print(picked.city);              // 'London'
  print(picked.countryCode);       // 'GB'
}
```

That is the whole integration. Everything below is optional.

**Requires Flutter 3.38 / Dart 3.10.** Upgrading from 3.x? See the
[migration guide](MIGRATION_GUIDE.md).

---

## Setup

Get an API key from the [Google Cloud console](https://console.cloud.google.com/google/maps-apis/)
and enable, for the platforms you ship:

| API | Needed for |
|---|---|
| Maps SDK for Android / iOS | rendering the map |
| Maps JavaScript API | rendering the map on web |
| **Places API (New)** | search and place details |
| Geocoding API | turning coordinates into addresses |
| Maps Static API | only for `googleStaticMapWithMarker` previews |

Billing must be enabled on the project.

> Enable **Places API (New)**, not the legacy "Places API". This package uses
> the new endpoints; the legacy ones are closed to projects created after
> 1 March 2025.

### Android

`android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
  <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
  <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
  <application>
    <meta-data android:name="com.google.android.geo.API_KEY"
               android:value="YOUR_API_KEY"/>
  </application>
</manifest>
```

`minSdkVersion` must be 21 or higher.

### iOS

`ios/Runner/AppDelegate.swift`:

```swift
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

`ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Shows your current location on the map so you can pick an address.</string>
```

> Only add `NSLocationAlwaysUsageDescription` or `UIBackgroundModes: location`
> if your app genuinely needs background location for something else. A location
> picker does not, and requesting it invites an App Store rejection.

### Web

Add the Maps JavaScript API to `web/index.html`, **after** `<base href>`:

```html
<base href="$FLUTTER_BASE_HREF">

<script async
  src="https://maps.googleapis.com/maps/api/js?key=YOUR_API_KEY&loading=async"></script>
```

That tag is what lets `google_maps_flutter_web` *render* the map. Search does
not need it: this package calls the Places REST API directly, and
`places.googleapis.com` supports CORS. **No proxy is required.**

If you restrict your key, use an **HTTP referrer** restriction matching your
origin. Do not add custom headers on web — they turn a simple request into a
preflight that `maps.googleapis.com` rejects.

### Platform support

| Platform | Status |
|---|---|
| Android | ✅ |
| iOS | ✅ |
| Web | ✅ (JS and WebAssembly) |
| macOS / Windows / Linux | ❌ — `google_maps_flutter` has no desktop implementation |

Desktop is an upstream limitation, not something this package can work around.

---

## Restricting the API key

Restricting a key to your bundle identifier is strongly recommended. When you
do, the REST calls need identifying headers:

```dart
import 'dart:io' show Platform;

final headers = <String, String>{
  if (Platform.isIOS || Platform.isMacOS)
    'X-Ios-Bundle-Identifier': 'com.example.app',
  if (Platform.isAndroid) ...{
    'X-Android-Package': 'com.example.app',
    // Base16 (hex) SHA-1 of the signing certificate, colons stripped.
    // keytool prints AA:BB:CC:... — remove the colons. Case does not matter.
    'X-Android-Cert': '00112233445566778899AABBCCDDEEFF00112233',
  },
};

MapLocationPickerConfig(
  apiKey: 'YOUR_API_KEY',
  geocodingApiHeaders: headers,              // Geocoding API
  placesApi: PlacesAPINew(                   // Places API (New)
    apiKey: 'YOUR_API_KEY',
    headers: headers,
  ),
)
```

Both are needed: `geocodingApiHeaders` only reaches the Geocoding client.

See [Google's API security best practices](https://developers.google.com/maps/api-security-best-practices).

---

## Usage

### Picking modes

```dart
// Tap or drag a marker (default).
const MapLocationPickerConfig(apiKey: key)

// A fixed pin with the map moving underneath, the way most delivery and
// ride-hailing apps work. Resolves when the map settles.
const MapLocationPickerConfig(apiKey: key, pinMode: PickerPinMode.centerPin)
```

### Starting at the user's location

```dart
const MapLocationPickerConfig(
  apiKey: key,
  startWithCurrentLocation: true,
  locationTimeout: Duration(seconds: 8),
)
```

Falls back to `initialPosition` if permission is refused or no fix arrives in
time, so the picker is never blank.

### Restricting the search

```dart
const MapLocationPickerConfig(
  apiKey: key,
  countries: ['gb', 'ie'],                  // ISO 3166-1 alpha-2, up to 15
  placeTypes: [PlaceType.streetAddress],    // up to 5
  language: 'en',
)
```

For anything more specific, build the filter yourself — it wins over the
shorthands above:

```dart
SearchConfig(
  searchFilter: AutocompleteSearchFilter(
    locationBias: /* ... */,
    includeQueryPredictions: true,
  ),
)
```

### Embedding it in a screen you already have

```dart
SizedBox(
  height: 420,
  child: MapLocationPickerView(         // no Scaffold of its own
    config: MapLocationPickerConfig(
      apiKey: key,
      onNext: (result) => print(result?.formattedAddress),
    ),
  ),
)
```

`MapLocationPickerView` needs bounded constraints. Use `MapLocationPicker` (which
adds the `Scaffold`) when pushing a full-screen route.

### Driving it programmatically

```dart
final controller = MapLocationPickerController(
  config: const MapLocationPickerConfig(apiKey: key),
);

MapLocationPicker(config: config, controller: controller);

await controller.moveTo(const LatLng(48.8584, 2.2945));
await controller.goToCurrentLocation();
controller.setMapType(MapType.hybrid);
print(controller.address);

// It is a ChangeNotifier.
ListenableBuilder(
  listenable: controller,
  builder: (context, _) => Text(controller.address),
);
```

Remember to `dispose()` a controller you created.

### Handling failures

Every failure is typed. Previously an invalid key, an exceeded quota and "no
results here" were all the same silent empty state.

```dart
MapLocationPickerConfig(
  apiKey: key,
  onError: (e) {
    switch (e.kind) {
      case MapPickerErrorKind.requestDenied:
        // Wrong key, key restrictions, or the API isn't enabled.
      case MapPickerErrorKind.quotaExceeded:
      case MapPickerErrorKind.network:
      case MapPickerErrorKind.locationPermissionDeniedForever:
        // Send them to system settings.
      default:
        break;
    }
  },
)
```

### Translating the UI

Every visible string lives on one object:

```dart
MapLocationPickerConfig(
  apiKey: key,
  strings: MapLocationPickerStrings(
    confirmAddress: AppLocalizations.of(context)!.confirmAddress,
    searchHint: AppLocalizations.of(context)!.searchHint,
    noAddressFound: AppLocalizations.of(context)!.noAddressFound,
    // ... 14 more, all with English defaults
  ),
)
```

### Reading the result

```dart
final picked = await showMapLocationPicker(context, config: config);

picked!.latLng;             // always present, even if geocoding failed
picked.name;                // 'Heathrow Terminal 5' — kept from search results
picked.formattedAddress;
picked.street;
picked.locality;
picked.postalCode;
picked.countryCode;
picked.result;              // the raw GeocodingResult
picked.place;               // the raw Places result, if search was used
```

Or work from a `GeocodingResult` directly:

```dart
result.city;
result.postalCode;
result.countryCode;
result.component('administrative_area_level_2');
result.latLng;
```

### Nearby places

```dart
const MapLocationPickerConfig(
  apiKey: key,
  showNearbyPlaces: true,
  nearbyPlacesRadius: 300,
  nearbyPlaceTypes: [PlaceType.restaurant, PlaceType.cafe],
)
```

### The search field on its own

```dart
PlacesAutocomplete(
  config: const SearchConfig(apiKey: 'YOUR_API_KEY'),
  onGetDetails: (place) => print(place?.formattedAddress),
  onError: (e) => print(e),
)
```

### Customising the chrome

```dart
MapLocationPickerConfig(
  apiKey: key,
  cardType: CardType.liquidCard,
  floatingControlsPosition: FloatingControlsPosition.bottomStart,
  showBackButton: true,
  bottomCardTitle: 'Where should we deliver?',
  mainMarkerIcon: myBitmapDescriptor,
  centerPinBuilder: (context, state) => MyPin(state: state),
  bottomCardBuilder: (context, result, results, address, isLoading, onNext, searchBar) {
    return MyCard(address: address, onConfirm: onNext);
  },
)
```

---

## Costs

Places autocomplete is billed per session, not per keystroke — but only if the
session token is reused across the search and then retired by the details call.
This package handles that for you. (Before 4.0.0 it did not: every keystroke
opened its own session.)

To cut the Place Details bill, ask for fewer fields:

```dart
SearchConfig(
  apiKey: key,
  placesAllFields: false,
  placeFields: ['id', 'location', 'formattedAddress', 'displayName'],
)
```

See [Places pricing](https://developers.google.com/maps/documentation/places/web-service/usage-and-billing).

---

## Troubleshooting

**The suggestion list is always empty.** Almost always the API key. Add an
`onError` callback — `MapPickerErrorKind.requestDenied` means the key is wrong,
restricted to a different app, or **Places API (New)** is not enabled.

**"Confirm" does nothing / stays greyed out.** Geocoding failed. `onError` will
say why. The button still returns the raw coordinate unless you set
`requireGeocodedAddress: true`.

**The picker renders squashed in a corner.** You nested `MapLocationPicker`
(which contains a `Scaffold`) inside a `Column` or scroll view. Use
`MapLocationPickerView` and give it bounded constraints.

**Nothing is clickable on web.** The map is an HTML platform view that wins
hit-testing. The package wraps its own overlays in `PointerInterceptor`; if you
stack your own widgets over the map, do the same.

**The map is blank on Android.** The `com.google.android.geo.API_KEY` meta-data
is missing or the Maps SDK for Android is not enabled.

---

## Contributing

Issues and pull requests are welcome — see [CONTRIBUTING.md](CONTRIBUTING.md).

## Support

[![BuyMeACoffee](https://img.shields.io/badge/Buy%20Me%20a%20Coffee-ffdd00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/rvndsngwn)
[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/rvndsngwn)
[![GitHub Sponsors](https://img.shields.io/badge/GitHub%20Sponsors-ea4aaa?style=for-the-badge&logo=github&logoColor=white)](https://github.com/sponsors/itsarvinddev)

## Contributors

<a href="https://github.com/itsarvinddev/map_location_picker/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=itsarvinddev/map_location_picker" />
</a>

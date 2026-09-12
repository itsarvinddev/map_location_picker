# Migration Guide

## 3.x → 4.0.0

Most apps need two changes: raise the Flutter version, and add imports for
symbols the barrel no longer re-exports. Everything else is additive.

---

### 1. Flutter 3.38.1 / Dart 3.10 is required

```yaml
environment:
  sdk: ">=3.10.0 <4.0.0"
  flutter: ">=3.38.1"
```

This is not a preference. `google_maps_apis` 5.x — the version that fixes the
build failure in [#68](https://github.com/itsarvinddev/map_location_picker/issues/68)
— requires `meta ^1.17.0`, and the Flutter SDK pins `meta` **exactly**:

| Flutter | pinned `meta` |
|---|---|
| 3.32 – 3.37 | 1.16.0 |
| 3.38+ | 1.17.0 |

The floor is 3.38**.1**, not 3.38.0, for a second reason: 3.38.0 shipped Dart
`3.10.0-290.4.beta`, and pub ranks a prerelease *below* the release it precedes,
so `sdk: ">=3.10.0"` excludes it. 3.38.1 is the first stable reporting a plain
`3.10.0`.

So there is no version of this package that both fixes #68 and runs on Flutter
3.37 or below. If you cannot upgrade Flutter yet, stay on `3.1.0` and pin
`retrofit: ">=4.7.3 <4.9.1"` in your own `pubspec.yaml` to avoid #68.

> **Note:** 3.1.0 claimed `flutter: ">=3.27.0"`, but that was never
> satisfiable — `google_maps_apis` 4.x already required Dart 3.8 (Flutter 3.32).

---

### 2. The barrel exports less

3.x re-exported all of `geolocator`, `google_maps_flutter`, and **both** the
legacy and new `google_maps_apis` libraries. That dumped several hundred symbols
into every file that imported the package, along with nine name collisions —
including two different `LatLng` and two different `AddressComponent`. It is why
the package's own source had to write `hide LatLng` and `hide Circle`.

4.0.0 exports only the types that appear in this package's public signatures.
**Most apps are unaffected**, because the common ones are still there:
`LatLng`, `MapType`, `Marker`, `GoogleMapController`, `GeocodingResult`,
`AddressComponent`, `Place`, `Suggestion`, `PlacesAPINew`,
`AutocompleteSearchFilter`, `SessionTokenHandler`, `CancelToken`,
`SuggestionsController`, `LocationSettings`, `LocationPermission`, `Position`.

Newly exported (you can delete these from your own `pubspec.yaml` if you added
them only for this): `CancelToken` from `dio`, `SuggestionsController` from
`flutter_typeahead`, `Client` from `http`.

If you relied on something that is now gone, import it directly:

```dart
// Legacy Places API types — no longer re-exported (nothing in this package
// uses them, and they collided with the new Places types).
import 'package:google_maps_apis/places.dart';

// The Places (New) AddressComponent, which collides with the geocoding one.
import 'package:google_maps_apis/places_new.dart' as places_new;
```

There is a compile-time guard for this surface at
[`example/lib/api_surface_check.dart`](example/lib/api_surface_check.dart); if
something you need is missing, that is a bug worth filing.

---

### 3. Embedding the picker: use `MapLocationPickerView`

`MapLocationPicker` still returns a `Scaffold`, so pushing it as a route is
unchanged. But if you were putting it inside a `Column`, a `SingleChildScrollView`
or a sized `Container`, that never worked — it is
[#65](https://github.com/itsarvinddev/map_location_picker/issues/65), and it
rendered squashed into a corner.

```diff
  SizedBox(
    height: 420,
-   child: MapLocationPicker(config: config),
+   child: MapLocationPickerView(config: config),
  )
```

`MapLocationPickerView` is the same widget without the `Scaffold`. It needs
bounded constraints.

---

### 4. Behaviour changes worth knowing

| What changed | Why | What to do |
|---|---|---|
| Tapping an entry in the "matching addresses" sheet no longer fires `onNext` | It used to confirm and pop the whole picker just because you looked at an alternative | Use `onAddressSelected` to observe; `onNext` is now only the Confirm button |
| Confirm works even when geocoding fails | Previously a bad key or a point over water left a dead button and no way out | Set `requireGeocodedAddress: true` for the old behaviour |
| `LatLng(0, 0)` is no longer an "unset" sentinel | It is a real coordinate in the Gulf of Guinea; passing it gave a marker-less, address-less picker | Use `skipInitialGeocode: true` if you meant "don't look anything up yet" |
| The main marker is draggable | | `draggableMarker: false` to restore |
| The map gets a bottom inset | The bottom card covered the Google logo, which the Maps Platform terms require to stay visible | Set `padding` yourself, or tune `mapBottomInset` |
| The search hint defaults to `strings.searchHint` | So the hint follows localization | Set `SearchConfig.searchHintText` to override. A standalone `PlacesAutocomplete` still falls back to the English default |
| `bottomCardTitle` is now rendered, and defaults to empty | It was declared in 3.x but no widget ever read it, so setting it did nothing. Leaving the old `'Select your location'` default would have made a title appear on every picker | Nothing, if you never set it. If you did, that text now appears above the address — pass `bottomCardTitle: ''` to keep the 3.x look |
| Picking an entry in the matching-addresses sheet fires `onAddressSelected` once, not twice | It was invoked directly *and* through the controller | Nothing — this was a defect |
| `searchBarBuilder`'s result goes straight into the `Stack` again | 4.0.0 briefly wrapped it in a `Positioned`/`SafeArea`/`Padding`, which made a returned `Positioned` throw a `ParentDataWidget` assertion | Return a `Positioned`, as on 3.x |

---

### 5. Deprecated

```dart
// Superseded by onError, which reports a typed MapLocationPickerException for
// every failure rather than only location ones. Still invoked for
// current-location failures, with the raw thrown object, as in 3.x.
MapLocationPickerConfig(onLocationError: (e) => ...)  // works, deprecated
MapLocationPickerConfig(onError: (e) => ...)          // prefer this

// Now nullable, and superseded by the localizable strings object.
MapLocationPickerConfig(noAddressFoundText: 'None')   // works, deprecated
MapLocationPickerConfig(
  strings: MapLocationPickerStrings(noAddressFound: 'None'),
)                                                     // prefer this

// flutter_typeahead 6 removed this: closing the keyboard also drops focus,
// which hideOnUnfocus already handles.
SearchConfig(hideWithKeyboard: false)  // ignored
SearchConfig(hideOnUnfocus: false)     // use this

// Was never read by anything.
MapLocationPickerConfig(bottomCardType: ...)  // ignored
MapLocationPickerConfig(cardType: ...)        // use this
```

Both still compile in 4.x and will be removed in 5.0.0.

---

### 6. Worth adopting

None of these are required, but they are why the release exists.

**Get the result directly** instead of wiring `onNext` to a `Navigator.pop`:

```dart
final picked = await showMapLocationPicker(
  context,
  config: const MapLocationPickerConfig(apiKey: 'YOUR_API_KEY'),
);
if (picked != null) {
  print(picked.latLng);         // always present
  print(picked.formattedAddress);
  print(picked.city);
  print(picked.countryCode);
}
```

**See failures** instead of a silent empty state:

```dart
MapLocationPickerConfig(
  apiKey: key,
  onError: (e) {
    if (e.kind == MapPickerErrorKind.requestDenied) {
      // Wrong key, key restrictions, or the API isn't enabled.
    }
  },
)
```

**Centre-pin mode**, the interaction most delivery and ride-hailing apps use:

```dart
MapLocationPickerConfig(apiKey: key, pinMode: PickerPinMode.centerPin)
```

**Restrict the search** — the README used to document a `components` parameter
that did not exist:

```dart
MapLocationPickerConfig(apiKey: key, countries: ['gb', 'ie'])
```

---

## 1.x → 2.0.0

Version 2.0 replaced the Material UI with Cupertino components and moved every
parameter into configuration objects.

### Configuration objects

Parameters that used to sit on the widget now live on `MapLocationPickerConfig`
and `SearchConfig`:

```diff
- MapLocationPicker(
-   apiKey: 'YOUR_API_KEY',
-   initialPosition: LatLng(37.7749, -122.4194),
- )
+ MapLocationPicker(
+   config: MapLocationPickerConfig(
+     apiKey: 'YOUR_API_KEY',
+     initialPosition: LatLng(37.7749, -122.4194),
+   ),
+ )
```

> Note: 2.0.1 renamed `MapPickerConfig` to `MapLocationPickerConfig` and
> `PlacesAutocompleteConfig` to `SearchConfig`.

### UI framework

The search field and bottom card are Cupertino-based and adapt to the ambient
theme automatically. Custom `InputDecoration` no longer applies; use
`SearchConfig.builder` to supply your own field.

### Services

`GeoCodingConfig` performs reverse geocoding, and `AutoCompleteService` performs
place search. Both can be supplied directly if you need custom HTTP behaviour.

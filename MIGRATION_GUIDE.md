# Migration Guide: Map Location Picker 2.0

This guide helps you migrate to the new Cupertino-based architecture with enhanced customization capabilities. The refactor focused on:

1. 🍎 Native Cupertino UI components
2. 🌗 Built-in theme support (light/dark)
3. 🧩 Decoupled service architecture
4. 🚀 Performance optimizations
5. 🗺️ Advanced map customization

## Key Structural Changes

### 1. File Structure Changes

```
lib/
├── src/
│   ├── autocomplete_service.dart      // Autocomplete business logic
│   ├── autocomplete_view.dart         // Cupertino-style search UI
│   ├── geocoding_service.dart         // Reverse geocoding logic
│   ├── map_location_picker.dart       // Main picker widget
│   ├── debouncer.dart                 // Debounce utility
│   └── logger.dart                    // Logging utility
└── map_location_picker.dart           // Main export
```

### 2. UI Framework Shift (Breaking Change)

**Changed from Material to Cupertino:**

```diff
// Old (Material)
PlacesAutocomplete(
  decoration: InputDecoration(...),
)

// New (Cupertino)
PlacesAutocomplete(
  // Uses CupertinoTypeAheadField internally
)
```

**Migration Strategy:**

1. Replace Material widgets with Cupertino equivalents
2. Use new Cupertino-style configuration options
3. Remove manual theme handling - it's now automatic

### 3. Configuration Objects

**New Configuration Approach:**

```dart
MapLocationPicker(
  config: MapPickerConfig(
    apiKey: '...',
    initialPosition: LatLng(...),
    // Map-specific parameters
    bottomCardBuilder: (ctx, result, address, isLoading, onNext) {
      return CupertinoActionSheet(...);
    }
  ),
  searchConfig: PlacesAutocompleteConfig(
    apiKey: '...',
    searchHintText: 'Search locations...',
    // Autocomplete parameters
  ),
)
```

### 4. Service Architecture

**Decoupled Services:**

```dart
// Geocoding Service
final geoCodingService = GeoCodingService(apiKey: "...");
final (result, allResults) = await geoCodingService.reverseGeocode(position);

// Autocomplete Service
final autoCompleteService = AutoCompleteService();
final predictions = await autoCompleteService.search(query: "Paris");
```

### 5. Parameter Mapping Guide

| Old Parameter        | New Location                                   | Notes             |
| -------------------- | ---------------------------------------------- | ----------------- |
| `apiKey`             | `MapPickerConfig.apiKey`                       |                   |
| `currentLatLng`      | `MapPickerConfig.initialPosition`              |                   |
| `searchHintText`     | `PlacesAutocompleteConfig.searchHintText`      |                   |
| `language`           | `PlacesAutocompleteConfig.suggestionsLanguage` |                   |
| `onMapCreated`       | `MapPickerConfig.onMapCreated`                 |                   |
| `onMapTypeChanged`   | `MapPickerConfig.onMapTypeChanged`             |                   |
| `additionalMarkers`  | `MapPickerConfig.additionalMarkers`            |                   |
| `customMarkerIcons`  | `MapPickerConfig.customMarkerIcons`            |                   |
| `bottomCardBuilder`  | `MapPickerConfig.bottomCardBuilder`            | Signature changed |
| `defaultAddressText` | `PlacesAutocompleteConfig.defaultAddressText`  |                   |
| `mapStyle`           | `MapPickerConfig.mapStyle`                     |                   |

### 6. Signature Changes

#### Bottom Card Builder

**Old:**

```dart
bottomCardBuilder: (ctx, result, address, isLoading) {...}
```

**New:**

```dart
bottomCardBuilder: (ctx, result, address, isLoading, onNext) {
  return CupertinoActionSheet(
    actions: [
      CupertinoActionSheetAction(
        onPressed: onNext, // New callback
        child: Text(address),
      ),
    ],
  );
}
```

#### Map Controls

**New Approach:**

```dart
MapPickerConfig(
  mapTypeButton: CupertinoButton(...), // Fully customizable
  locationButton: CustomLocationButton(),
)
```

### 7. New Features

#### 1. Static Map Previews

```dart
Image.network(
  googleStaticMapWithMarker(
    lat, lng, zoom,
    apiKey: "YOUR_KEY"
  ),
)
```

#### 2. Theme Support

Automatic light/dark theme adaptation:

```dart
final _themeMode = ValueNotifier<ThemeMode>(ThemeMode.dark);

MapLocationPicker(
  config: MapPickerConfig(), // Automatically adapts to theme
)
```

#### 3. Custom Marker Icons

```dart
void _createMarkerIcon() async {
  _customMarkerIcon = await BitmapDescriptor.asset(
    const ImageConfiguration(size: Size(48, 48)),
    'assets/marker.webp',
  );
}

MapPickerConfig(
  mainMarkerIcon: _customMarkerIcon,
)
```

#### 4. Advanced Bottom Sheets

```dart
MapPickerConfig(
  bottomCardBuilder: (ctx, result, address, isLoading, onNext) {
    return CupertinoActionSheet(
      title: Text("Confirm Location"),
      actions: [
        CupertinoActionSheetAction(
          onPressed: onNext,
          isDefaultAction: true,
          child: Text(address),
        ),
      ],
    );
  },
)
```

## Migration Steps

### 1. Update Dependencies

```yaml
dependencies:
  map_location_picker: ^2.0.0
```

### 2. Replace Widget Structures

**Old:**

```dart
MapLocationPicker(
  apiKey: "...",
  currentLatLng: LatLng(...),
  // 100+ parameters
)
```

**New:**

```dart
MapLocationPicker(
  config: MapPickerConfig(
    apiKey: "...",
    initialPosition: LatLng(...),
    // Map config
  ),
  searchConfig: PlacesAutocompleteConfig(
    apiKey: "...",
    // Search config
  ),
)
```

### 3. Update Custom Builders

**Bottom Card:**

```dart
// Old
bottomCardBuilder: (ctx, result, address, isLoading) {...}

// New
config: MapPickerConfig(
  bottomCardBuilder: (ctx, result, address, isLoading, onNext) {
    return CupertinoActionSheet(
      actions: [
        CupertinoActionSheetAction(
          onPressed: onNext,
          child: Text(address),
        ),
      ],
    );
  }
)
```

### 4. Handle Service Instances (Optional)

For advanced use cases:

```dart
MapLocationPicker(
  geoCodingService: MyCustomGeoCodingService(),
  // Other services...
)
```

### 5. Theme Integration

Remove manual theme handling:

```diff
- Theme(
-   data: ThemeData.dark(),
-   child: MapLocationPicker(...)
- )

// The picker now automatically adapts to app theme
```

## Troubleshooting

**Problem:** UI elements look different
**Solution:** The UI has been updated to Cupertino design. Use new customization options:

```dart
PlacesAutocompleteConfig(
  decorationBuilder: (context, child) {
    return CupertinoBoxDecoration(child: child);
  }
)
```

**Problem:** Bottom card not working
**Solution:** Signature changed - now includes `onNext` callback:

```dart
bottomCardBuilder: (ctx, result, address, isLoading, onNext) {
  return Button(onPressed: onNext, child: Text("Select"));
}
```

**Problem:** Markers not showing
**Solution:** Use new marker configuration:

```dart
MapPickerConfig(
  mainMarkerIcon: BitmapDescriptor.defaultMarker,
  additionalMarkers: {
    "custom": LatLng(37.422, -122.084),
  },
  customMarkerIcons: {
    "custom": BitmapDescriptor.defaultMarkerWithHue(120),
  },
)
```

**Problem:** Search not working
**Solution:** Ensure you're using the new config:

```dart
PlacesAutocomplete(
  config: PlacesAutocompleteConfig(
    apiKey: "YOUR_KEY",
    minCharsForSuggestions: 2,
  ),
  // Not in MapPickerConfig
)
```

## Benefits of Migration

1. **Native Experience**: Cupertino design for iOS and Material for Android
2. **Theme Support**: Automatic light/dark mode adaptation
3. **Better Performance**: Optimized rebuilds and memoization
4. **Enhanced Customization**: More control over UI components
5. **Simplified Maintenance**: Decoupled architecture
6. **New Features**: Static map previews, better markers, etc.

For additional help, refer to the updated example app or file an issue on GitHub.

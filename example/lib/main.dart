import 'package:example/key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';

void main() => runApp(const MyApp());

final _themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: _themeMode,
      builder: (context, themeMode, child) {
        return MaterialApp(
          title: 'Location Picker Demo',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeMode,
          home: const LocationPickerScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  LatLng? _pickedLocation;
  String _formattedAddress = "No location selected";
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _createMarkerIcon();
  }

  void _createMarkerIcon() async {
    _customMarkerIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/marker.webp', // Replace with your marker asset
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Map Preview Section
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              height: (MediaQuery.of(context).size.height / 5),
              width: MediaQuery.of(context).size.width,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: (_pickedLocation == null
                      ? const Center(
                          child: Text('Select a location to preview'),
                        )
                      : Image.network(
                          googleStaticMapWithMarker(
                            _pickedLocation!.latitude,
                            _pickedLocation!.longitude,
                            18,
                            apiKey: YOUR_API_KEY,
                          ),
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                          height: (MediaQuery.of(context).size.height / 5),
                        ))),
            ),

            // Formatted Address Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade900
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _formattedAddress,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // Options Section
            Column(
              children: [
                const Text(
                  "PICK LOCATION OPTIONS",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),

                // Standard Picker
                _buildOptionCard(
                  icon: Icons.map,
                  title: "Standard Map Picker",
                  description: "Open map with default settings",
                  onTap: () => _openLocationPicker(
                    const MapLocationPickerConfig(
                      apiKey: YOUR_API_KEY,
                    ),
                  ),
                ),

                // Dark Theme Picker
                _buildOptionCard(
                  icon: Icons.dark_mode,
                  title: "Dark Theme Picker",
                  description: "Open map with dark theme",
                  onTap: () async {
                    _themeMode.value = ThemeMode.dark;
                    await _openLocationPicker(
                      MapLocationPickerConfig(
                        apiKey: YOUR_API_KEY,
                        mapStyle: _darkMapStyle,
                      ),
                    );
                    _themeMode.value = ThemeMode.light;
                  },
                ),

                // Satellite View Picker
                _buildOptionCard(
                  icon: Icons.satellite,
                  title: "Satellite View",
                  description: "Open with satellite imagery",
                  onTap: () => _openLocationPicker(
                    const MapLocationPickerConfig(
                      apiKey: YOUR_API_KEY,
                      initialMapType: MapType.satellite,
                    ),
                  ),
                ),

                // Custom Markers Picker
                _buildOptionCard(
                  icon: Icons.pin_drop,
                  title: "Custom Markers",
                  description: "Add custom markers to the map",
                  onTap: () => _openLocationPicker(
                    MapLocationPickerConfig(
                      apiKey: YOUR_API_KEY,
                      mainMarkerIcon: _customMarkerIcon,
                      additionalMarkers: const {
                        "landmark1": LatLng(37.422, -122.084),
                        "landmark2": LatLng(37.426, -122.083),
                      },
                      customMarkerIcons: {
                        "landmark1": BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueYellow,
                        ),
                        "landmark2": BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue,
                        ),
                      },
                    ),
                  ),
                ),

                // Liquid Card Picker
                _buildOptionCard(
                  icon: Icons.square_rounded,
                  title: "Liquid Card",
                  description: "Card options: default, liquid",
                  onTap: () => _openLocationPicker(
                    MapLocationPickerConfig(
                      apiKey: YOUR_API_KEY,
                      mainMarkerIcon: _customMarkerIcon,
                      cardType: CardType.liquidCard,
                      cardColor: CupertinoColors.systemFill,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0.2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.blue),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openLocationPicker(MapLocationPickerConfig config) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapLocationPicker(
          config: config.copyWith(
            initialPosition:
                _pickedLocation ?? const LatLng(28.8993468, 76.6250249),
            onNext: (result) {
              if (result != null) {
                setState(() {
                  _pickedLocation = LatLng(
                    result.location?.latitude ?? 0,
                    result.location?.longitude ?? 0,
                  );
                  _formattedAddress =
                      result.formattedAddress ?? "Address not available";
                });
              }
              if (context.mounted) {
                Navigator.pop(context, result);
              }
            },
          ),
        ),
      ),
    );
  }

  // Dark map style JSON (truncated for brevity)
  final String _darkMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      { "color": "#212121" }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      { "visibility": "off" }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#757575" }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      { "color": "#212121" }
    ]
  },
  {
    "featureType": "administrative",
    "elementType": "geometry",
    "stylers": [
      { "color": "#757575" }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      { "color": "#313131" }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      { "color": "#263c3f" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.fill",
    "stylers": [
      { "color": "#2c2c2c" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      { "color": "#212121" }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#8a8a8a" }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      { "color": "#2f3948" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      { "color": "#000000" }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      { "color": "#3d3d3d" }
    ]
  }
]
  ''';
}

import 'package:example/key.dart';
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
          theme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          themeMode: themeMode,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PickedPlace? _picked;
  BitmapDescriptor? _customMarkerIcon;

  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
  }

  Future<void> _loadMarkerIcon() async {
    final icon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/marker.webp',
    );
    if (mounted) setState(() => _customMarkerIcon = icon);
  }

  /// Every demo funnels through here.
  ///
  /// `showMapLocationPicker` returns the result directly — no `onNext` +
  /// `Navigator.pop` wiring required.
  Future<void> _open(MapLocationPickerConfig config) async {
    final picked = await showMapLocationPicker(
      context,
      config: config.copyWith(
        apiKey: YOUR_API_KEY,
        // Start where the user last picked, if they picked anything.
        initialPosition: _picked?.latLng ?? config.initialPosition,
        showBackButton: true,
        onError: (error) {
          if (!mounted) return;
          // Typed failures: an invalid key is now distinguishable from
          // "nothing here".
          if (!error.isUserFacing) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${error.kind.name}: ${error.message}')),
          );
        },
      ),
    );
    if (picked != null && mounted) setState(() => _picked = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Picker'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(
              _themeMode.value == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () =>
                _themeMode.value = _themeMode.value == ThemeMode.dark
                ? ThemeMode.light
                : ThemeMode.dark,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SelectionCard(picked: _picked),
          const SizedBox(height: 24),

          Text('PICKER MODES', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _Option(
            icon: Icons.touch_app,
            title: 'Tap to place',
            description: 'The classic marker you tap or drag into position.',
            onTap: () => _open(const MapLocationPickerConfig()),
          ),
          _Option(
            icon: Icons.center_focus_strong,
            title: 'Centre pin',
            description:
                'The pin stays put and the map moves under it, the way most '
                'delivery apps work. Resolves when the map settles.',
            onTap: () => _open(
              const MapLocationPickerConfig(
                pinMode: PickerPinMode.centerPin,
                bottomCardTitle: 'Where should we deliver?',
              ),
            ),
          ),
          _Option(
            icon: Icons.my_location,
            title: 'Start at my location',
            description:
                'Resolves the device position on open, falling back to the '
                'initial position if permission is refused.',
            onTap: () => _open(
              const MapLocationPickerConfig(startWithCurrentLocation: true),
            ),
          ),

          const SizedBox(height: 24),
          Text('CUSTOMISATION', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          _Option(
            icon: Icons.travel_explore,
            title: 'Restricted to two countries',
            description:
                'countries: [gb, ie] — search results never leave those two.',
            onTap: () => _open(
              const MapLocationPickerConfig(
                countries: ['gb', 'ie'],
                initialPosition: LatLng(51.5072, -0.1276),
              ),
            ),
          ),
          _Option(
            icon: Icons.translate,
            title: 'Translated UI',
            description:
                'Every visible string comes from MapLocationPickerStrings.',
            onTap: () => _open(
              const MapLocationPickerConfig(
                language: 'fr',
                countries: ['fr'],
                initialPosition: LatLng(48.8566, 2.3522),
                strings: MapLocationPickerStrings(
                  confirmAddress: 'Confirmer l\'adresse',
                  loadingAddress: 'Chargement de l\'adresse...',
                  loadingAddressSubtitle: 'Récupération des détails.',
                  noAddressFound: 'Aucune adresse trouvée',
                  mapTypeTitle: 'Type de carte',
                  mapTypeMessage: 'Choisissez le type de carte.',
                  mapTypeNormal: 'Plan',
                  mapTypeSatellite: 'Satellite',
                  mapTypeTerrain: 'Relief',
                  mapTypeHybrid: 'Hybride',
                  cancel: 'Annuler',
                  tapToSelect: 'appuyez pour sélectionner',
                  searchHint: 'Rechercher une adresse...',
                ),
              ),
            ),
          ),
          _Option(
            icon: Icons.place,
            title: 'Custom markers and controls',
            description:
                'A custom pin, extra markers, and the FABs on the left.',
            onTap: () => _open(
              MapLocationPickerConfig(
                mainMarkerIcon: _customMarkerIcon,
                floatingControlsPosition: FloatingControlsPosition.bottomStart,
                initialPosition: const LatLng(37.4220, -122.0841),
                additionalMarkers: const {
                  'googleplex': LatLng(37.4220, -122.0841),
                  'shoreline': LatLng(37.4260, -122.0830),
                },
                customInfoWindows: const {
                  'googleplex': InfoWindow(title: 'Googleplex'),
                },
              ),
            ),
          ),
          _Option(
            icon: Icons.dark_mode,
            title: 'Nearby places',
            description:
                'A row of places around the pin, from the Places API (New).',
            onTap: () => _open(
              const MapLocationPickerConfig(
                showNearbyPlaces: true,
                initialPosition: LatLng(40.7580, -73.9855),
              ),
            ),
          ),

          const SizedBox(height: 24),
          Text('EMBEDDED', style: theme.textTheme.labelLarge),
          const SizedBox(height: 8),
          Text(
            'MapLocationPickerView has no Scaffold of its own, so it can live '
            'inside a screen you already have. It only needs bounded '
            'constraints.',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 420,
              child: MapLocationPickerView(
                config: MapLocationPickerConfig(
                  apiKey: YOUR_API_KEY,
                  initialPosition: const LatLng(35.6595, 139.7005),
                  hideMoreOptions: true,
                  strings: const MapLocationPickerStrings(
                    confirmAddress: 'Use this address',
                  ),
                  onNext: (result) {
                    if (result == null) return;
                    setState(() {
                      _picked = PickedPlace.from(
                        latLng:
                            result.latLng ?? const LatLng(35.6595, 139.7005),
                        result: result,
                      );
                    });
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

/// Shows what came back from the picker.
class _SelectionCard extends StatelessWidget {
  const _SelectionCard({required this.picked});

  final PickedPlace? picked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final place = picked;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 160,
            child: place == null
                ? Center(
                    child: Text(
                      'Nothing picked yet',
                      style: theme.textTheme.bodyMedium,
                    ),
                  )
                : Image.network(
                    googleStaticMapWithMarker(
                      place.latLng.latitude,
                      place.latLng.longitude,
                      16,
                      apiKey: YOUR_API_KEY,
                    ),
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, _) => const Center(
                      child: Text('Enable the Maps Static API for a preview'),
                    ),
                  ),
          ),
          if (place != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(place.displayLabel, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  _Row(
                    'Coordinates',
                    '${place.latLng.latitude.toStringAsFixed(5)}, '
                        '${place.latLng.longitude.toStringAsFixed(5)}',
                  ),
                  if (place.locality != null) _Row('City', place.locality!),
                  if (place.postalCode != null)
                    _Row('Postcode', place.postalCode!),
                  if (place.countryCode != null)
                    _Row('Country', place.countryCode!),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          foregroundColor: theme.colorScheme.onPrimaryContainer,
          child: Icon(icon),
        ),
        title: Text(title),
        subtitle: Text(description, style: theme.textTheme.bodySmall),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

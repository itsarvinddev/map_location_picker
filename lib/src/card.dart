import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../map_location_picker.dart';

/// A rounded, blurred surface used for the search bar and the bottom card.
class CustomMapCard extends StatelessWidget {
  /// The card's contents.
  final Widget child;

  /// Corner radius. Defaults to [kRadius] on every corner.
  final BorderRadiusGeometry? radius;

  /// Padding around [child].
  final EdgeInsets? padding;

  /// Background colour. Defaults to the theme's surface colour.
  final Color? color;

  /// Border. Defaults to a hairline outline.
  final BoxBorder? border;

  /// Creates a card.
  const CustomMapCard({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.color,
    this.border,
  });

  /// The default corner radius used across the picker.
  static const kRadius = 12.0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: radius ?? BorderRadius.circular(kRadius),
      clipBehavior: Clip.antiAlias,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: color ?? Theme.of(context).colorScheme.surface,
            borderRadius: radius ?? BorderRadius.circular(kRadius + 0.5),
            border:
                border ??
                Border.all(
                  color: Theme.of(context).colorScheme.outlineVariant,
                  width: 0.5,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// A short, human-readable title for [result].
///
/// Falls back through the first address component, then the first segment of
/// the formatted address, then an empty string.
///
/// Written defensively on purpose: the previous implementation did
/// `(result.addressComponents?.first.longName ?? "").substring(0, 1)`, which
/// threw `RangeError` whenever the components list was null (the `?? ""`
/// guaranteed it) and `Bad state: No element` whenever it was empty — which the
/// Geocoding API does return for plus-code-only results and for results
/// filtered by `resultType`/`locationType`.
String addressTitle(GeocodingResult? result) {
  final name = result?.addressComponents?.firstOrNull?.longName?.trim();
  if (name != null && name.isNotEmpty) {
    return name[0].toUpperCase() + name.substring(1);
  }
  final formatted = result?.formattedAddress?.split(',').first.trim();
  if (formatted != null && formatted.isNotEmpty) {
    return formatted[0].toUpperCase() + formatted.substring(1);
  }
  return '';
}

/// The bottom card shown below the map.
///
/// Override it wholesale with [MapLocationPickerConfig.bottomCardBuilder].
Widget defaultBottomCard(
  BuildContext context,
  GeocodingResult? result,
  String address,
  bool isLoading,
  List<GeocodingResult> results,
  MapLocationPickerConfig config,
  VoidCallback onNext, {

  /// Called when the user picks one of the other nearby matches.
  ValueChanged<GeocodingResult>? onResultSelected,
}) {
  final theme = Theme.of(context);
  final strings = config.strings;
  final title = addressTitle(result);

  return Padding(
    padding: const EdgeInsets.only(top: 12),
    child: CustomMapCard(
      radius: config.cardRadius ?? BorderRadius.circular(CustomMapCard.kRadius),
      color: config.cardColor,
      border: config.cardBorder,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (config.bottomCardTitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    config.bottomCardTitle,
                    style: theme.textTheme.labelLarge,
                  ),
                ),
              ),
            ListTile(
              title: isLoading
                  ? Text(strings.loadingAddress, textAlign: TextAlign.start)
                  : (title.isEmpty
                        ? null
                        : Text(title, style: theme.textTheme.titleMedium)),
              subtitle: isLoading
                  ? Text(
                      strings.loadingAddressSubtitle,
                      textAlign: TextAlign.start,
                    )
                  : Text(
                      address,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                    ),
            ),
            config.confirmButton?.call(context, onNext) ??
                Builder(
                  builder: (context) {
                    // Never render a filled, enabled-looking button wired to a
                    // no-op: that is what made "Confirm does nothing" the most
                    // common report. Either it works, or it looks disabled.
                    final canConfirm =
                        !isLoading &&
                        (result != null || !config.requireGeocodedAddress);
                    return Semantics(
                      button: true,
                      enabled: canConfirm,
                      label: strings.confirmAddress,
                      child: CupertinoButton.filled(
                        minimumSize: const Size(double.infinity, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        pressedOpacity: 0.9,
                        onPressed: canConfirm ? onNext : null,
                        child: isLoading
                            // No backgroundColor: it paints a grey track on
                            // Android/web/desktop and is dropped entirely on
                            // iOS/macOS.
                            ? const SizedBox.square(
                                dimension: 22,
                                child: CircularProgressIndicator.adaptive(
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(strings.confirmAddress),
                      ),
                    );
                  },
                ),
            if (results.length > 1 && !config.hideMoreOptions) ...[
              const SizedBox(height: 12),
              CupertinoButton.tinted(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                minimumSize: const Size(100, 10),
                pressedOpacity: 0.9,
                onPressed: isLoading
                    ? null
                    : () => showAddressOptions(
                        context,
                        results,
                        config,
                        onResultSelected: onResultSelected,
                      ),
                child: Text(
                  isLoading
                      ? strings.loadingNearbyPlaces
                      : strings.nearbyPlacesCount(results.length),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// Builds the decoration for a row in the nearby-places list.
BoxDecoration buildBoxDecoration(BuildContext context, int index, bool isLast) {
  return BoxDecoration(
    color: CupertinoColors.systemFill,
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(index == 0 ? CustomMapCard.kRadius : 0),
      topRight: Radius.circular(index == 0 ? CustomMapCard.kRadius : 0),
      bottomLeft: Radius.circular(isLast ? CustomMapCard.kRadius : 0),
      bottomRight: Radius.circular(isLast ? CustomMapCard.kRadius : 0),
    ),
    border: Border(
      bottom: isLast
          ? BorderSide.none
          : const BorderSide(
              color: CupertinoColors.opaqueSeparator,
              width: 0.5,
            ),
    ),
  );
}

/// Shows the other geocoding matches for the current pin.
///
/// Picking one updates the picker's selection. It deliberately does *not*
/// invoke `onNext`: the previous implementation fired `onNext` here as well as
/// `onAddressSelected`, so an app that popped the route in `onNext` popped
/// twice, and the picker's own state was never updated.
void showAddressOptions(
  BuildContext context,
  List<GeocodingResult> results,
  MapLocationPickerConfig config, {
  ValueChanged<GeocodingResult>? onResultSelected,
}) {
  final strings = config.strings;
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    builder: (sheetContext) => Material(
      type: MaterialType.transparency,
      child: CupertinoActionSheet(
        title: Text(strings.nearbyPlacesTitle(results.length)),
        message: Text(strings.tapToSelect),
        actions: results.map((result) {
          final title = addressTitle(result);
          return CupertinoActionSheetAction(
            onPressed: () {
              onResultSelected?.call(result);
              config.onAddressSelected?.call(result);
              Navigator.pop(sheetContext);
            },
            child: CupertinoListTile(
              padding: EdgeInsets.zero,
              title: Text(
                title.isEmpty ? (result.formattedAddress ?? '') : title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Text(
                result.formattedAddress ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              leading: const Icon(Icons.pin_drop, size: 20),
            ),
          );
        }).toList(),
        cancelButton: CupertinoButton(
          minimumSize: const Size(double.infinity, 40),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          onPressed: () => Navigator.pop(sheetContext),
          child: Text(strings.cancel),
        ),
      ),
    ),
  );
}

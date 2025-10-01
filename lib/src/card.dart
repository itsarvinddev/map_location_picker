import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../map_location_picker.dart';

/// The default bottom card for the map location picker.
class CustomMapCard extends StatelessWidget {
  final Widget child;
  final BorderRadiusGeometry? radius;
  final EdgeInsets? padding;
  final Color? color;
  final BoxBorder? border;
  const CustomMapCard({
    super.key,
    required this.child,
    this.radius,
    this.padding,
    this.color,
    this.border,
  });

  /// Default radius for the map location picker.
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
            border: border ??
                Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 0.5),
          ),
          child: child,
        ),
      ),
    );
  }
}

Widget defaultBottomCard(
  BuildContext context,
  GeocodingResult? result,
  String address,
  bool isLoading,
  List<GeocodingResult> results,
  MapLocationPickerConfig config,
  VoidCallback onNext,
) {
  final theme = Theme.of(context);
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
            ListTile(
              title: isLoading
                  ? const Text(
                      "Loading address...",
                      textAlign: TextAlign.start,
                    )
                  : result?.addressComponents?.first.longName != null
                      ? Text(
                          (result?.addressComponents?.first.longName ?? "")
                                  .substring(0, 1)
                                  .toUpperCase() +
                              (result?.addressComponents?.first.longName ?? "")
                                  .substring(1),
                          style: theme.textTheme.titleMedium,
                        )
                      : null,
              subtitle: isLoading
                  ? const Text(
                      "Fetching location details.",
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
                ((!isLoading && result != null)
                    ? CupertinoButton.filled(
                        minimumSize: const Size(double.infinity, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const Text("Confirm Address"),
                        onPressed: onNext,
                        pressedOpacity: 0.9,
                      )
                    : CupertinoButton.filled(
                        minimumSize: const Size(double.infinity, 40),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: isLoading
                            ? const CircularProgressIndicator.adaptive(
                                backgroundColor: Colors.grey,
                              )
                            : Text(address),
                        onPressed: () {},
                      )),
            if (results.length > 1 && !config.hideMoreOptions) ...[
              const SizedBox(height: 12),
              CupertinoButton.tinted(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 2,
                ),
                minimumSize: const Size(100, 10),
                child: Text(
                  isLoading
                      ? "Loading nearby places..."
                      : "${results.length} places found nearby",
                  style: theme.textTheme.bodyMedium,
                ),
                pressedOpacity: 0.9,
                onPressed: isLoading
                    ? () {}
                    : () => _showAddressOptions(context, results, config),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

BoxDecoration buildBoxDecoration(
  BuildContext context,
  int index,
  bool isLast,
) {
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
          : BorderSide(
              color: CupertinoColors.opaqueSeparator,
              width: 0.5,
            ),
    ),
  );
}

void _showAddressOptions(
  BuildContext context,
  List<GeocodingResult> results,
  MapLocationPickerConfig config,
) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black38,
    builder: (context) => CupertinoActionSheet(
      title: Text("${results.length} places found nearby"),
      message: Text("tap to select"),
      actions: results.map((result) {
        return CupertinoActionSheetAction(
          child: CupertinoListTile(
            padding: EdgeInsets.zero,
            title: Text(
              (result.addressComponents?.first.longName ?? "")
                      .substring(0, 1)
                      .toUpperCase() +
                  (result.addressComponents?.first.longName ?? "").substring(1),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            subtitle: Text(
              result.formattedAddress ?? "",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            leading: Icon(Icons.pin_drop, size: 20),
          ),
          onPressed: () {
            config.onAddressSelected?.call(result);
            config.onNext?.call(result);
            Navigator.pop(context);
          },
        );
      }).toList(),
      cancelButton: CupertinoButton(
        child: Text("Cancel"),
        minimumSize: const Size(double.infinity, 40),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        onPressed: () => Navigator.pop(context),
      ),
    ),
  );
}

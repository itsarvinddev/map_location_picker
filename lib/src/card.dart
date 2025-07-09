import 'dart:ui' show ImageFilter;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_apis/places_new.dart';

import '../map_location_picker.dart';

/// Default radius for the map location picker.
const _radius = 12.0;

/// The default bottom card for the map location picker.
class LiquidCard extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets? padding;
  final Color? color;
  const LiquidCard({
    super.key,
    required this.child,
    required this.radius,
    this.padding,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(radius),
          ),
          child: child,
        ),
      ),
    );
  }
}

Widget defaultBottomCard(
  BuildContext context,
  Place? result,
  String address,
  bool isLoading,
  List<Place> results,
  MapLocationPickerConfig config,
  VoidCallback onNext,
) {
  final theme = Theme.of(context);
  return config.cardType == CardType.defaultCard
      ? CupertinoActionSheet(
          title: config.bottomCardTitle.isNotEmpty
              ? Text(config.bottomCardTitle)
              : null,
          actions: [
            if (isLoading)
              CupertinoActionSheetAction(
                child: Text("Loading address..."),
                onPressed: () {},
              )
            else
              CupertinoActionSheetAction(
                onPressed: onNext,
                child: Text(address),
              ),
            if (config.confirmButton != null)
              config.confirmButton?.call(context, onNext) ??
                  const SizedBox.shrink(),
            if (results.isNotEmpty &&
                !config.hideMoreOptions &&
                results.length > 1)
              CupertinoActionSheetAction(
                child: Text(
                  "Nearby places (${results.length})",
                  style: theme.textTheme.bodyMedium,
                ),
                onPressed: () => _showAddressOptions(context, results, config),
              ),
          ],
        )
      : Padding(
          padding: const EdgeInsets.only(top: 12),
          child: LiquidCard(
            radius: _radius,
            color: config.cardColor,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: isLoading
                        ? const Text(
                            "Loading address...",
                            textAlign: TextAlign.center,
                          )
                        : Text(
                            address,
                            style: theme.textTheme.titleMedium,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.start,
                          ),
                  ),
                  config.confirmButton?.call(context, onNext) ??
                      ((!isLoading && result != null)
                          ? CupertinoButton.filled(
                              minimumSize: const Size(double.infinity, 40),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: const Text("Confirm Address"),
                              onPressed: onNext,
                            )
                          : CupertinoButton.filled(
                              minimumSize: const Size(double.infinity, 40),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: isLoading
                                  ? const CircularProgressIndicator.adaptive(
                                      backgroundColor: Colors.grey,
                                    )
                                  : Text(address),
                              onPressed: () {},
                            )),
                  if (results.length > 1) ...[
                    const SizedBox(height: 12),
                    CupertinoButton.tinted(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      minimumSize: const Size(200, 10),
                      child: Text(
                        "Show Nearby Places (${results.length})",
                        style: theme.textTheme.bodyMedium,
                      ),
                      onPressed: () =>
                          _showAddressOptions(context, results, config),
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
      topLeft: Radius.circular(index == 0 ? _radius : 0),
      topRight: Radius.circular(index == 0 ? _radius : 0),
      bottomLeft: Radius.circular(isLast ? _radius : 0),
      bottomRight: Radius.circular(isLast ? _radius : 0),
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
  List<Place> results,
  MapLocationPickerConfig config,
) {
  final theme = Theme.of(context);
  showCupertinoModalPopup(
    context: context,
    builder: (context) => CupertinoActionSheet(
      title: Text("Nearby ${results.length} places found"),
      actions: results.map((result) {
        return CupertinoActionSheetAction(
          child: Row(
            children: [
              Expanded(
                child: Text(
                  result.formattedAddress ?? "",
                  style: theme.textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
            ],
          ),
          onPressed: () {
            config.onAddressSelected?.call(result);
            config.onNext?.call(result);
            Navigator.pop(context);
          },
        );
      }).toList(),
      cancelButton: CupertinoActionSheetAction(
        child: Text("Cancel"),
        onPressed: () => Navigator.pop(context),
      ),
    ),
  );
}

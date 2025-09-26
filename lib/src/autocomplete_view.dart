import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_apis/places_new.dart';
import 'package:map_location_picker/map_location_picker.dart';

import 'card.dart';
import 'logger.dart';

/// The autocomplete view for the map location picker.
/// [PlacesAutocomplete] is a widget that shows a list of suggestions as the user types.
/// It is a wrapper around [CupertinoTypeAheadField] and [AutoCompleteService].
///
/// ```dart
/// PlacesAutocomplete(
///   config: SearchConfig(
///     apiKey: "YOUR_API_KEY",
///     placesApi: PlacesAPINew(apiKey: "YOUR_API_KEY"),
///   ),
/// );
/// ```
///
class PlacesAutocomplete extends HookWidget {
  /// The configuration for the autocomplete view.
  final SearchConfig config;

  /// The initial value for the autocomplete view.
  final Suggestion? initialValue;

  /// The callback for when a place is selected.
  final void Function(Place?)? onGetDetails;

  /// The callback for when a place is selected.
  final void Function(Suggestion)? onSelected;

  final CardType cardType;

  final Color? cardColor;

  final BorderRadiusGeometry? cardRadius;

  /// The constructor for the autocomplete view.
  const PlacesAutocomplete({
    super.key,
    required this.config,
    this.initialValue,
    this.onGetDetails,
    this.onSelected,
    this.cardType = CardType.defaultCard,
    this.cardColor,
    this.cardRadius,
  });

  @override
  Widget build(BuildContext context) {
    /// Text controller for the search field.
    final textController = useTextEditingController(
      text: initialValue?.placePrediction?.text?.text ??
          config.defaultAddressText,
    );

    /// Auto complete service.
    final service = useMemoized(
      () => AutoCompleteService(placesApi: config.placesApi),
    );

    /// Cupertino type ahead field. It is a text field that shows a list of suggestions as the user types.
    return CupertinoTypeAheadField<Suggestion>(
      controller: textController,
      itemBuilder: config.itemBuilder ?? _defaultItemBuilder(),
      suggestionsCallback: (query) => _getSuggestions(query, service),
      onSelected: (value) {
        _handleSelection(value, context, textController, service);
        config.onSelected?.call(value);
        FocusManager.instance.primaryFocus?.unfocus();
      },
      errorBuilder: config.errorBuilder,
      animationDuration: config.animationDuration,
      autoFlipDirection: config.autoFlipDirection,
      debounceDuration: config.debounceDuration,
      direction: config.direction,
      hideOnEmpty: config.hideOnEmpty,
      hideOnError: config.hideOnError,
      hideOnLoading: config.hideOnLoading,
      loadingBuilder: config.loadingBuilder,
      transitionBuilder: config.transitionBuilder,
      autoFlipMinHeight: config.autoFlipMinHeight,
      constraints: config.constraints ?? BoxConstraints(maxHeight: 500),
      hideOnSelect: config.hideOnSelect,
      hideOnUnfocus: config.hideOnUnfocus,
      hideWithKeyboard: config.hideWithKeyboard,
      itemSeparatorBuilder: config.itemSeparatorBuilder ??
          (context, index) => const Divider(
                color: CupertinoColors.opaqueSeparator,
                thickness: 0.5,
                indent: 12,
                endIndent: 12,
                height: 0,
              ),
      listBuilder: config.listBuilder,
      offset: config.offset ?? Offset(0, 12),
      retainOnLoading: config.retainOnLoading,
      showOnFocus: config.showOnFocus,
      suggestionsController: config.suggestionsController,
      decorationBuilder: config.decorationBuilder ??
          (context, child) {
            return CustomMapCard(
              radius:
                  cardRadius ?? BorderRadius.circular(CustomMapCard.kRadius),
              padding: EdgeInsets.zero,
              color: cardColor,
              child: child,
            );
          },
      emptyBuilder: config.emptyBuilder,
      scrollController: config.scrollController,
      focusNode: config.focusNode,
      hideKeyboardOnDrag: config.hideKeyboardOnDrag,
      builder: config.builder ??
          (context, controller, focusNode) {
            final child = CupertinoSearchTextField(
              controller: controller,
              focusNode: focusNode,
              placeholder: config.searchHintText,
              placeholderStyle: config.searchHintStyle,
              decoration: BoxDecoration(
                color: cardType == CardType.liquidCard ? null : cardColor,
                borderRadius: BorderRadius.circular(CustomMapCard.kRadius),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              keyboardType: TextInputType.streetAddress,
            );
            return CustomMapCard(
              radius:
                  cardRadius ?? BorderRadius.circular(CustomMapCard.kRadius),
              padding: EdgeInsets.zero,
              color: cardColor,
              child: child,
            );
          },
    );
  }

  Widget Function(BuildContext, Suggestion) _defaultItemBuilder() {
    return (context, content) {
      final mainText =
          content.placePrediction?.structuredFormat?.mainText?.text ?? "";
      final secondaryText =
          content.placePrediction?.structuredFormat?.secondaryText?.text ?? "";

      final style = Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.grey[600],
          );

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text.rich(
          TextSpan(
            children: [
              if (mainText.isNotEmpty)
                TextSpan(
                  text: mainText,
                  style: style?.copyWith(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              TextSpan(
                text: " ",
              ),
              if (secondaryText.isNotEmpty)
                TextSpan(
                  text: secondaryText,
                  style: style,
                ),
            ],
          ),
        ),
        // subtitle: Text(
        //   content.placePrediction?.structuredFormat?.mainText?.text ??
        //       "See locations",
        // ),
      );
    };
  }

  /// Get suggestions from the autocomplete service.
  Future<List<Suggestion>> _getSuggestions(
    String query,
    AutoCompleteService service,
  ) async {
    if (query.length < config.minCharsForSuggestions) return [];
    return service.search(
      query: query,
      apiKey: config.apiKey,
      allFields: config.searchAllFields,
      fields: config.searchFields,
      filter: config.searchFilter,
      instanceFields: config.searchInstanceFields,
      sessionToken: config.sessionToken,
    );
  }

  /// Handle the selection of a suggestion.
  void _handleSelection(
    Suggestion value,
    BuildContext context,
    TextEditingController controller,
    AutoCompleteService service,
  ) async {
    try {
      controller.selection =
          TextSelection.collapsed(offset: controller.text.length);
      final placeId = value.placePrediction?.placeId ?? "";
      if (placeId.isEmpty) {
        mapLogger.i("Place ID is empty, skipping place details.");
        return;
      }
      await _getPlaceDetails(placeId, context, service);
      onSelected?.call(value);
    } catch (e) {
      mapLogger.e(e);
    }
  }

  /// Get the details of a place.
  Future<void> _getPlaceDetails(
    String placeId,
    BuildContext context,
    AutoCompleteService service,
  ) async {
    try {
      final places = service.placesApi ?? PlacesAPINew(apiKey: config.apiKey);
      final response = await places.getDetails(
        id: placeId,
        fields: config.placeFields,
        allFields: config.placesAllFields,
        filter: config.placeDetailsFilter,
        instanceFields: config.placeInstanceFields,
      );

      if (_isErrorResponse(response)) {
        _showErrorSnackbar(response.error?.error?.message, context);
        return;
      }
      onGetDetails?.call(response.body);
    } catch (e) {
      mapLogger.e(e);
    }
  }

  /// Check if the response is an error response.
  bool _isErrorResponse(GoogleHTTPResponse<Place?> response) {
    final isError = response.error != null && !response.isSuccessful;
    if (isError) {
      mapLogger.e(response.error?.error?.toJsonString());
    }
    return isError;
  }

  /// Show an error snackbar.
  void _showErrorSnackbar(String? message, BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Address not found")),
      );
    }
  }
}

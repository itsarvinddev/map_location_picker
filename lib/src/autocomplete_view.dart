import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:map_location_picker/map_location_picker.dart';

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

  /// Called for every failure raised while searching or fetching details.
  ///
  /// Without this a failed lookup looks identical to "no matches" — see
  /// [MapLocationPickerException] for the failure kinds.
  final MapPickerErrorCallback? onError;

  final CardType cardType;

  final Color? cardColor;

  final BorderRadiusGeometry? cardRadius;

  final BoxBorder? cardBorder;

  /// The constructor for the autocomplete view.
  const PlacesAutocomplete({
    super.key,
    required this.config,
    this.initialValue,
    this.onGetDetails,
    this.onSelected,
    this.onError,
    this.cardType = CardType.defaultCard,
    this.cardColor,
    this.cardRadius,
    this.cardBorder,
  });

  @override
  Widget build(BuildContext context) {
    /// Text controller for the search field.
    final textController = useTextEditingController(
      text:
          initialValue?.placePrediction?.text?.text ??
          config.defaultAddressText,
    );

    /// One session token for the whole search, so Google bills the keystrokes
    /// and the final details call as a single Autocomplete session instead of
    /// charging per request.
    final sessionToken = useMemoized(
      () => config.sessionToken ?? SessionTokenHandler(),
      [config.sessionToken],
    );

    /// Auto complete service. Rebuilt when the credentials change so a
    /// `copyWith(apiKey: ...)` is not silently ignored.
    final service = useMemoized(
      () => AutoCompleteService(placesApi: config.placesApi, onError: onError),
      [config.placesApi, config.apiKey, onError],
    );
    // Without this the service's own HTTP client leaks on unmount and on every
    // credential change.
    useEffect(() => service.dispose, [service]);

    /// Cupertino type ahead field. It is a text field that shows a list of suggestions as the user types.
    return CupertinoTypeAheadField<Suggestion>(
      controller: textController,
      itemBuilder: config.itemBuilder ?? _defaultItemBuilder(),
      suggestionsCallback: (query) =>
          _getSuggestions(query, service, sessionToken),
      onSelected: (value) {
        _handleSelection(value, context, textController, service, sessionToken);
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
      constrainWidth: config.constrainWidth,
      itemSeparatorBuilder:
          config.itemSeparatorBuilder ??
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
      decorationBuilder:
          config.decorationBuilder ??
          (context, child) {
            // The suggestions box floats over the GoogleMap platform view on
            // web, where it would otherwise be unclickable.
            return _intercept(
              child: CustomMapCard(
                radius:
                    cardRadius ?? BorderRadius.circular(CustomMapCard.kRadius),
                padding: EdgeInsets.zero,
                color: cardColor,
                border: cardBorder,
                child: child,
              ),
            );
          },
      emptyBuilder: config.emptyBuilder,
      scrollController: config.scrollController,
      focusNode: config.focusNode,
      hideKeyboardOnDrag: config.hideKeyboardOnDrag,
      builder:
          config.builder ??
          (context, controller, focusNode) {
            final child = CupertinoSearchTextField(
              controller: controller,
              focusNode: focusNode,
              // The picker substitutes its localized `strings.searchHint`
              // before this point; the fallback is for the standalone widget,
              // whose SearchConfig default is empty.
              placeholder: config.searchHintText.isEmpty
                  ? const MapLocationPickerStrings().searchHint
                  : config.searchHintText,
              placeholderStyle: config.searchHintStyle,
              decoration: BoxDecoration(
                color: cardType == CardType.liquidCard ? null : cardColor,
                borderRadius: BorderRadius.circular(CustomMapCard.kRadius),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              keyboardType: TextInputType.streetAddress,
            );
            return CustomMapCard(
              radius:
                  cardRadius ?? BorderRadius.circular(CustomMapCard.kRadius),
              padding: EdgeInsets.zero,
              color: cardColor,
              border: cardBorder,
              child: child,
            );
          },
    );
  }

  /// Wraps [child] so it receives mouse events over the map on web.
  static Widget _intercept({required Widget child}) =>
      kIsWeb ? PointerInterceptor(child: child) : child;

  Widget Function(BuildContext, Suggestion) _defaultItemBuilder() {
    return (context, content) {
      // A suggestion is either a place prediction or -- with
      // `includeQueryPredictions` -- a query prediction, which has no
      // placePrediction at all and used to render as a blank tappable row.
      final place = content.placePrediction;
      final query = content.queryPrediction;
      final mainText =
          place?.structuredFormat?.mainText?.text ??
          query?.structuredFormat?.mainText?.text ??
          query?.text?.text ??
          "";
      final secondaryText =
          place?.structuredFormat?.secondaryText?.text ??
          query?.structuredFormat?.secondaryText?.text ??
          "";

      final style = Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]);

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
              TextSpan(text: " "),
              if (secondaryText.isNotEmpty)
                TextSpan(text: secondaryText, style: style),
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
    SessionTokenHandler sessionToken,
  ) async {
    if (query.length < config.minCharsForSuggestions) return const [];
    return service.search(
      query: query,
      apiKey: config.apiKey,
      allFields: config.searchAllFields,
      fields: config.searchFields,
      filter: config.searchFilter,
      instanceFields: config.searchInstanceFields,
      sessionToken: sessionToken,
      cancelToken: config.cancelToken,
    );
  }

  /// Handle the selection of a suggestion.
  void _handleSelection(
    Suggestion value,
    BuildContext context,
    TextEditingController controller,
    AutoCompleteService service,
    SessionTokenHandler sessionToken,
  ) async {
    try {
      // Show what the user picked. Previously only the caret was moved, so the
      // field kept whatever partial text had been typed.
      final prediction = value.placePrediction;
      final queryText =
          value.queryPrediction?.text?.text ??
          value.queryPrediction?.structuredFormat?.mainText?.text;
      final selectedText =
          prediction?.text?.text ??
          prediction?.structuredFormat?.mainText?.text ??
          queryText ??
          controller.text;
      controller.value = TextEditingValue(
        text: selectedText,
        selection: TextSelection.collapsed(offset: selectedText.length),
      );

      final placeId = prediction?.placeId ?? "";
      if (placeId.isEmpty) {
        // A query prediction is a refined search term, not a place: put it in
        // the field and reopen the list rather than silently doing nothing.
        if (queryText != null && queryText.isNotEmpty) {
          config.suggestionsController?.open();
          onSelected?.call(value);
          return;
        }
        mapLogger.i("Place ID is empty, skipping place details.");
        return;
      }
      await _getPlaceDetails(placeId, context, service, sessionToken);
      onSelected?.call(value);
    } catch (e, stack) {
      mapLogger.e(e, stackTrace: stack);
      onError?.call(
        MapLocationPickerException(
          MapPickerErrorKind.unknown,
          'Failed to handle the selected suggestion: $e',
          cause: e,
          stackTrace: stack,
        ),
      );
    }
  }

  /// Get the details of a place.
  ///
  /// Routed through [AutoCompleteService] rather than calling [PlacesAPINew]
  /// directly, so the lookup carries the same [SessionTokenHandler] as the
  /// searches that preceded it — which is what bills the whole search as one
  /// Places session instead of one charge per keystroke — reuses the per-key
  /// client, reads the session's place-details cache, and reports failures
  /// through [onError]. There is one REST transport on every platform, web
  /// included.
  Future<void> _getPlaceDetails(
    String placeId,
    BuildContext context,
    AutoCompleteService service,
    SessionTokenHandler sessionToken,
  ) async {
    final place = await service.getDetails(
      placeId: placeId,
      apiKey: config.apiKey,
      fields: config.placeFields,
      allFields: config.placesAllFields,
      filter: config.placeDetailsFilter,
      instanceFields: config.placeInstanceFields,
      sessionToken: sessionToken,
    );
    if (place == null) return;
    onGetDetails?.call(place);
  }
}

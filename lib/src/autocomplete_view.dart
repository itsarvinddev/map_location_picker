import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_apis/places_new.dart';
import 'package:map_location_picker/map_location_picker.dart';

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

  /// The constructor for the autocomplete view.
  const PlacesAutocomplete({
    super.key,
    required this.config,
    this.initialValue,
    this.onGetDetails,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    /// Text controller for the search field.
    final textController = useTextEditingController(
      text: initialValue?.placePrediction?.text?.text ??
          config.defaultAddressText,
    );

    /// Focus node for the search field. handle focus and unfocus.
    final focusNode = useFocusNode();

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
        focusNode.unfocus();
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
                color: CupertinoColors.systemGrey5,
                height: 0,
              ),
      listBuilder: config.listBuilder,
      offset: config.offset ?? Offset(0, 12),
      retainOnLoading: config.retainOnLoading,
      showOnFocus: config.showOnFocus,
      suggestionsController: config.suggestionsController,
      decorationBuilder: config.decorationBuilder ??
          (context, child) {
            return Material(
              type: MaterialType.card,
              elevation: 0,
              borderRadius: BorderRadius.circular(12),
              child: child,
            );
          },
      emptyBuilder: config.emptyBuilder,
      scrollController: config.scrollController,
      focusNode: config.focusNode ?? focusNode,
      hideKeyboardOnDrag: config.hideKeyboardOnDrag,
      builder: config.builder ??
          (context, controller, focusNode) => CupertinoSearchTextField(
                controller: controller,
                focusNode: focusNode,
                placeholder: config.searchHintText,
                placeholderStyle: config.searchHintStyle,
                decoration: BoxDecoration(
                  color: CupertinoColors.tertiarySystemBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                keyboardType: TextInputType.streetAddress,
                style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
                      fontSize: 16,
                    ),
              ),
    );
  }

  Widget Function(BuildContext, Suggestion) _defaultItemBuilder() {
    return (context, content) {
      final mainText =
          content.placePrediction?.structuredFormat?.mainText?.text ?? "";
      final secondaryText =
          content.placePrediction?.structuredFormat?.secondaryText?.text ?? "";

      final style = Theme.of(context).textTheme.titleMedium?.copyWith(
            color: CupertinoColors.systemGrey,
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
        fields: config.baseFields,
        allFields: config.placesAllFields,
        filter: config.placeDetailsFilter,
        instanceFields: config.placeDetails,
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

/// The configuration for the autocomplete view.
/// [SearchConfig] is a class that contains the configuration for the autocomplete view.
///
/// ```dart
/// final config = SearchConfig(
///   apiKey: "YOUR_API_KEY",
///   placesApi: PlacesAPINew(apiKey: "YOUR_API_KEY"),
/// );
/// ```
///
class SearchConfig {
  final String apiKey;
  final PlacesAPINew? placesApi;
  final bool placesAllFields;
  final PlaceDetailsFilter? placeDetailsFilter;
  final Place? placeDetails;
  final SessionTokenHandler? sessionToken;
  final bool searchAllFields;
  final List<String>? searchFields;
  final AutocompleteSearchFilter? searchFilter;
  final PlacesSuggestions? searchInstanceFields;
  final List<String> baseFields;
  final String searchHintText;
  final TextStyle? searchHintStyle;
  final int minCharsForSuggestions;
  final Duration debounceDuration;
  final String defaultAddressText;
  final Widget Function(BuildContext, Suggestion)? itemBuilder;
  final void Function(Suggestion)? onSelected;
  final Widget Function(BuildContext, Object)? errorBuilder;
  final Duration animationDuration;
  final bool autoFlipDirection;
  final VerticalDirection? direction;
  final bool hideOnEmpty;
  final bool hideOnError;
  final bool hideOnLoading;
  final Widget Function(BuildContext)? loadingBuilder;
  final Widget Function(BuildContext, Animation<double>, Widget)?
      transitionBuilder;
  final double autoFlipMinHeight;
  final BoxConstraints? constraints;
  final bool hideOnSelect;
  final bool hideOnUnfocus;
  final bool hideWithKeyboard;
  final Widget Function(BuildContext, int)? itemSeparatorBuilder;
  final Widget Function(BuildContext, List<Widget>)? listBuilder;
  final Offset? offset;
  final bool retainOnLoading;
  final bool showOnFocus;
  final SuggestionsController<Suggestion>? suggestionsController;
  final Widget Function(BuildContext, Widget)? decorationBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final ScrollController? scrollController;
  final FocusNode? focusNode;
  final bool hideKeyboardOnDrag;
  final Widget Function(BuildContext, TextEditingController, FocusNode)?
      builder;

  const SearchConfig({
    this.apiKey = "",
    this.baseFields = const [],
    this.placesApi,
    this.placesAllFields = true,
    this.placeDetailsFilter,
    this.placeDetails,
    this.searchAllFields = true,
    this.searchFields,
    this.searchFilter,
    this.searchInstanceFields,
    this.sessionToken,
    this.searchHintText = "Search for place, address, landmark, etc.",
    this.searchHintStyle,
    this.minCharsForSuggestions = 3,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.defaultAddressText = "",
    this.itemBuilder,
    this.onSelected,
    this.errorBuilder,
    this.animationDuration = const Duration(milliseconds: 300),
    this.autoFlipDirection = false,
    this.direction,
    this.hideOnEmpty = false,
    this.hideOnError = false,
    this.hideOnLoading = false,
    this.loadingBuilder,
    this.transitionBuilder,
    this.autoFlipMinHeight = 0,
    this.constraints,
    this.hideOnSelect = true,
    this.hideOnUnfocus = true,
    this.hideWithKeyboard = true,
    this.itemSeparatorBuilder,
    this.listBuilder,
    this.offset,
    this.retainOnLoading = false,
    this.showOnFocus = true,
    this.suggestionsController,
    this.decorationBuilder,
    this.emptyBuilder,
    this.scrollController,
    this.focusNode,
    this.hideKeyboardOnDrag = true,
    this.builder,
  });

  /// Copy with the configuration for the autocomplete view.
  ///
  /// ```dart
  /// final config = config.copyWith(
  ///   apiKey: "YOUR_API_KEY",
  ///   placesApi: PlacesAPINew(apiKey: "YOUR_API_KEY"),
  /// );
  /// ```
  ///
  SearchConfig copyWith({
    String? apiKey,
    PlacesAPINew? placesApi,
    bool? placesAllFields,
    PlaceDetailsFilter? placeDetailsFilter,
    Place? placeDetails,
    bool? searchAllFields,
    List<String>? searchFields,
    AutocompleteSearchFilter? searchFilter,
    PlacesSuggestions? searchInstanceFields,
    SessionTokenHandler? sessionToken,
    String? searchHintText,
    TextStyle? searchHintStyle,
    int? minCharsForSuggestions,
    Duration? debounceDuration,
    String? defaultAddressText,
    Widget Function(BuildContext, Suggestion)? itemBuilder,
    void Function(Suggestion)? onSelected,
    Widget Function(BuildContext, Object)? errorBuilder,
    Duration? animationDuration,
    bool? autoFlipDirection,
    VerticalDirection? direction,
    bool? hideOnEmpty,
    bool? hideOnError,
    bool? hideOnLoading,
    Widget Function(BuildContext)? loadingBuilder,
    Widget Function(BuildContext, Animation<double>, Widget)? transitionBuilder,
    double? autoFlipMinHeight,
    BoxConstraints? constraints,
    bool? hideOnSelect,
    bool? hideOnUnfocus,
    bool? hideWithKeyboard,
    Widget Function(BuildContext, int)? itemSeparatorBuilder,
    Widget Function(BuildContext, List<Widget>)? listBuilder,
    Offset? offset,
    bool? retainOnLoading,
    bool? showOnFocus,
    SuggestionsController<Suggestion>? suggestionsController,
    Widget Function(BuildContext, Widget)? decorationBuilder,
    Widget Function(BuildContext)? emptyBuilder,
    ScrollController? scrollController,
    FocusNode? focusNode,
    bool? hideKeyboardOnDrag,
    Widget Function(BuildContext, TextEditingController, FocusNode)? builder,
  }) {
    return SearchConfig(
      apiKey: apiKey ?? this.apiKey,
      placesApi: placesApi ?? this.placesApi,
      placesAllFields: placesAllFields ?? this.placesAllFields,
      placeDetailsFilter: placeDetailsFilter ?? this.placeDetailsFilter,
      placeDetails: placeDetails ?? this.placeDetails,
      searchAllFields: searchAllFields ?? this.searchAllFields,
      searchFields: searchFields ?? this.searchFields,
      searchFilter: searchFilter ?? this.searchFilter,
      searchInstanceFields: searchInstanceFields ?? this.searchInstanceFields,
      sessionToken: sessionToken ?? this.sessionToken,
      searchHintText: searchHintText ?? this.searchHintText,
      searchHintStyle: searchHintStyle ?? this.searchHintStyle,
      minCharsForSuggestions:
          minCharsForSuggestions ?? this.minCharsForSuggestions,
      debounceDuration: debounceDuration ?? this.debounceDuration,
      defaultAddressText: defaultAddressText ?? this.defaultAddressText,
      itemBuilder: itemBuilder ?? this.itemBuilder,
      onSelected: onSelected ?? this.onSelected,
      errorBuilder: errorBuilder ?? this.errorBuilder,
      animationDuration: animationDuration ?? this.animationDuration,
      autoFlipDirection: autoFlipDirection ?? this.autoFlipDirection,
      direction: direction ?? this.direction,
      hideOnEmpty: hideOnEmpty ?? this.hideOnEmpty,
      hideOnError: hideOnError ?? this.hideOnError,
      hideOnLoading: hideOnLoading ?? this.hideOnLoading,
      loadingBuilder: loadingBuilder ?? this.loadingBuilder,
      transitionBuilder: transitionBuilder ?? this.transitionBuilder,
      autoFlipMinHeight: autoFlipMinHeight ?? this.autoFlipMinHeight,
      constraints: constraints ?? this.constraints,
      hideOnSelect: hideOnSelect ?? this.hideOnSelect,
      hideOnUnfocus: hideOnUnfocus ?? this.hideOnUnfocus,
      hideWithKeyboard: hideWithKeyboard ?? this.hideWithKeyboard,
      itemSeparatorBuilder: itemSeparatorBuilder ?? this.itemSeparatorBuilder,
      listBuilder: listBuilder ?? this.listBuilder,
      offset: offset ?? this.offset,
      retainOnLoading: retainOnLoading ?? this.retainOnLoading,
      showOnFocus: showOnFocus ?? this.showOnFocus,
      suggestionsController:
          suggestionsController ?? this.suggestionsController,
      decorationBuilder: decorationBuilder ?? this.decorationBuilder,
      emptyBuilder: emptyBuilder ?? this.emptyBuilder,
      scrollController: scrollController ?? this.scrollController,
      focusNode: focusNode ?? this.focusNode,
      hideKeyboardOnDrag: hideKeyboardOnDrag ?? this.hideKeyboardOnDrag,
      builder: builder ?? this.builder,
    );
  }
}

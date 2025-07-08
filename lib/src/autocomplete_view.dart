import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:map_location_picker/map_location_picker.dart';

import 'logger.dart';

/// The autocomplete view for the map location picker.
class PlacesAutocomplete extends HookWidget {
  /// The configuration for the autocomplete view.
  final SearchConfig config;

  /// The initial value for the autocomplete view.
  final Prediction? initialValue;

  /// The callback for when a place is selected.
  final void Function(PlacesDetailsResponse?)? onGetDetails;

  /// The callback for when a place is selected.
  final void Function(Prediction)? onSelected;

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
    final textController = useTextEditingController(
        text: initialValue?.description ?? config.defaultAddressText);

    final focusNode = useFocusNode();

    final service = useMemoized(
      () => AutoCompleteService(
        httpClient: config.baseClient,
        apiHeaders: config.baseApiHeaders,
        baseUrl: config.baseBaseUrl,
      ),
    );

    return CupertinoTypeAheadField<Prediction>(
      controller: textController,
      itemBuilder: config.itemBuilder ?? _defaultItemBuilder(context),
      suggestionsCallback: (query) => _getSuggestions(query, service),
      onSelected: (value) {
        _handleSelection(value, context, textController);
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
      suggestionsController:
          config.suggestionsController as SuggestionsController<Prediction>?,
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
      builder: (context, controller, focusNode) => CupertinoSearchTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: config.searchHintText,
        placeholderStyle: config.searchHintStyle,
        decoration: BoxDecoration(
          color: CupertinoColors.tertiarySystemBackground,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        keyboardType: TextInputType.streetAddress,
        style: CupertinoTheme.of(context).textTheme.textStyle.copyWith(
              fontSize: 16,
            ),
      ),
    );
  }

  Widget Function(BuildContext, Prediction) _defaultItemBuilder(
      BuildContext context) {
    return (context, content) => ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            content.description ?? "",
          ),
          subtitle: Text(
            content.structuredFormatting?.secondaryText ??
                content.structuredFormatting?.mainText ??
                "",
          ),
        );
  }

  Future<List<Prediction>> _getSuggestions(
      String query, AutoCompleteService service) async {
    if (query.length < config.minCharsForSuggestions) return [];
    return service.search(
      query: query,
      apiKey: config.apiKey,
      language: config.suggestionsLanguage,
      sessionToken: config.sessionToken,
      region: config.suggestionsRegion,
      components: config.suggestionsComponents,
      location: config.suggestionsLocation,
      offset: config.suggestionsOffset,
      origin: config.suggestionsOrigin,
      radius: config.suggestionsRadius,
      strictbounds: config.suggestionsStrictbounds,
      types: config.suggestionsTypes,
    );
  }

  void _handleSelection(
    Prediction value,
    BuildContext context,
    TextEditingController controller,
  ) async {
    controller.selection =
        TextSelection.collapsed(offset: controller.text.length);
    await _getPlaceDetails(value.placeId ?? value.id ?? "", context);
    onSelected?.call(value);
  }

  Future<void> _getPlaceDetails(String placeId, BuildContext context) async {
    try {
      final places = GoogleMapsPlaces(
        apiKey: config.apiKey,
        httpClient: config.baseClient,
        apiHeaders: config.baseApiHeaders,
        baseUrl: config.baseBaseUrl,
      );

      final response = await places.getDetailsByPlaceId(
        placeId,
        region: config.baseRegion,
        sessionToken: config.baseSessionToken,
        language: config.baseLanguage,
        fields: config.baseFields,
      );

      if (_isErrorResponse(response)) {
        _showErrorSnackbar(response.errorMessage, context);
        return;
      }
      onGetDetails?.call(response);
    } catch (e) {
      mapLogger.e(e);
    }
  }

  bool _isErrorResponse(PlacesDetailsResponse response) {
    return response.hasNoResults ||
        response.isDenied ||
        response.isInvalid ||
        response.isNotFound ||
        response.unknownError ||
        response.isOverQueryLimit;
  }

  void _showErrorSnackbar(String? message, BuildContext context) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message ?? "Address not found")),
      );
    }
  }
}

class SearchConfig<Prediction> {
  final String apiKey;
  final Client? baseClient;
  final String? baseRegion;
  final String? baseSessionToken;
  final String? baseLanguage;
  final List<String> baseFields;
  final Map<String, String>? baseApiHeaders;
  final String? baseBaseUrl;
  final String? suggestionsLanguage;
  final String? suggestionsRegion;
  final List<Component> suggestionsComponents;
  final Location? suggestionsLocation;
  final num? suggestionsOffset;
  final Location? suggestionsOrigin;
  final num? suggestionsRadius;
  final bool suggestionsStrictbounds;
  final List<String> suggestionsTypes;
  final String? sessionToken;
  final String searchHintText;
  final TextStyle? searchHintStyle;
  final int minCharsForSuggestions;
  final Duration debounceDuration;
  final String defaultAddressText;
  final Widget Function(BuildContext, Prediction)? itemBuilder;
  final void Function(Prediction)? onSelected;
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
  final SuggestionsController<Prediction>? suggestionsController;
  final Widget Function(BuildContext, Widget)? decorationBuilder;
  final Widget Function(BuildContext)? emptyBuilder;
  final ScrollController? scrollController;
  final FocusNode? focusNode;
  final bool hideKeyboardOnDrag;

  const SearchConfig({
    this.apiKey = "",
    this.baseClient,
    this.baseRegion,
    this.baseSessionToken,
    this.baseLanguage,
    this.baseFields = const [],
    this.baseApiHeaders,
    this.baseBaseUrl,
    this.suggestionsLanguage,
    this.suggestionsRegion,
    this.suggestionsComponents = const [],
    this.suggestionsLocation,
    this.suggestionsOffset,
    this.suggestionsOrigin,
    this.suggestionsRadius,
    this.suggestionsStrictbounds = false,
    this.suggestionsTypes = const [],
    this.sessionToken,
    this.searchHintText = "Start typing to search",
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
  });

  SearchConfig copyWith({
    String? apiKey,
    Client? baseClient,
    String? baseRegion,
    String? baseSessionToken,
    String? baseLanguage,
    List<String>? baseFields,
    Map<String, String>? baseApiHeaders,
    String? baseBaseUrl,
    String? suggestionsLanguage,
    String? suggestionsRegion,
    List<Component>? suggestionsComponents,
    Location? suggestionsLocation,
    num? suggestionsOffset,
    Location? suggestionsOrigin,
    num? suggestionsRadius,
    bool? suggestionsStrictbounds,
    List<String>? suggestionsTypes,
    String? sessionToken,
    String? searchHintText,
    TextStyle? searchHintStyle,
    int? minCharsForSuggestions,
    Duration? debounceDuration,
    String? defaultAddressText,
    Widget Function(BuildContext, Prediction)? itemBuilder,
    void Function(Prediction)? onSelected,
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
    SuggestionsController<Prediction>? suggestionsController,
    Widget Function(BuildContext, Widget)? decorationBuilder,
    Widget Function(BuildContext)? emptyBuilder,
    ScrollController? scrollController,
    FocusNode? focusNode,
    bool? hideKeyboardOnDrag,
  }) {
    return SearchConfig(
      apiKey: apiKey ?? this.apiKey,
      baseClient: baseClient ?? this.baseClient,
      baseRegion: baseRegion ?? this.baseRegion,
      baseSessionToken: baseSessionToken ?? this.baseSessionToken,
      baseLanguage: baseLanguage ?? this.baseLanguage,
      baseFields: baseFields ?? this.baseFields,
      baseApiHeaders: baseApiHeaders ?? this.baseApiHeaders,
      baseBaseUrl: baseBaseUrl ?? this.baseBaseUrl,
      suggestionsLanguage: suggestionsLanguage ?? this.suggestionsLanguage,
      suggestionsRegion: suggestionsRegion ?? this.suggestionsRegion,
      suggestionsComponents:
          suggestionsComponents ?? this.suggestionsComponents,
      suggestionsLocation: suggestionsLocation ?? this.suggestionsLocation,
      suggestionsOffset: suggestionsOffset ?? this.suggestionsOffset,
      suggestionsOrigin: suggestionsOrigin ?? this.suggestionsOrigin,
      suggestionsRadius: suggestionsRadius ?? this.suggestionsRadius,
      suggestionsStrictbounds:
          suggestionsStrictbounds ?? this.suggestionsStrictbounds,
      suggestionsTypes: suggestionsTypes ?? this.suggestionsTypes,
      sessionToken: sessionToken ?? this.sessionToken,
      searchHintText: searchHintText ?? this.searchHintText,
      searchHintStyle: searchHintStyle ?? this.searchHintStyle,
      minCharsForSuggestions:
          minCharsForSuggestions ?? this.minCharsForSuggestions,
      debounceDuration: debounceDuration ?? this.debounceDuration,
      defaultAddressText: defaultAddressText ?? this.defaultAddressText,
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
    );
  }
}

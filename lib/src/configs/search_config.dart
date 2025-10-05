import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_maps_apis/places_new.dart';

part 'search_config.freezed.dart';

typedef TextFieldBuilder = Widget Function(
    BuildContext, TextEditingController, FocusNode)?;
typedef ItemBuilder = Widget Function(BuildContext, Suggestion)?;
typedef OnSelected = void Function(Suggestion)?;
typedef ErrorBuilder = Widget Function(BuildContext, Object)?;
typedef LoadingBuilder = Widget Function(BuildContext)?;
typedef TransitionBuilder = Widget Function(
    BuildContext, Animation<double>, Widget)?;
typedef ItemSeparatorBuilder = Widget Function(BuildContext, int)?;
typedef ListBuilder = Widget Function(BuildContext, List<Widget>)?;
typedef DecorationBuilder = Widget Function(BuildContext, Widget)?;
typedef EmptyBuilder = Widget Function(BuildContext)?;

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
/// Copy with the configuration for the autocomplete view.
///
/// ```dart
/// final config = config.copyWith(
///   apiKey: "YOUR_API_KEY",
///   placesApi: PlacesAPINew(apiKey: "YOUR_API_KEY"),
/// );
/// ```
///
@freezed
abstract class SearchConfig with _$SearchConfig {
  const factory SearchConfig({
    @Default('') String apiKey,
    @Default(null) PlacesAPINew? placesApi,
    @Default(true) bool placesAllFields,
    @Default(null) PlaceDetailsFilter? placeDetailsFilter,
    @Default(null) Place? placeInstanceFields,
    @Default(null) List<String>? placeFields,
    @Default(true) bool searchAllFields,
    @Default(null) List<String>? searchFields,
    @Default(null) AutocompleteSearchFilter? searchFilter,
    @Default(null) PlacesSuggestions? searchInstanceFields,
    @Default(null) SessionTokenHandler? sessionToken,
    @Default('Search for place, address, landmark, etc.') String searchHintText,
    @Default(null) TextStyle? searchHintStyle,
    @Default(3) int minCharsForSuggestions,
    @Default(Duration(milliseconds: 500)) Duration debounceDuration,
    @Default('') String defaultAddressText,
    @Default(null) Suggestion? initialValue,
    @Default(null) ItemBuilder itemBuilder,
    @Default(null) OnSelected onSelected,
    @Default(null) ErrorBuilder errorBuilder,
    @Default(Duration(milliseconds: 300)) Duration animationDuration,
    @Default(false) bool autoFlipDirection,
    @Default(null) VerticalDirection? direction,
    @Default(false) bool hideOnEmpty,
    @Default(false) bool hideOnError,
    @Default(false) bool hideOnLoading,
    @Default(null) LoadingBuilder loadingBuilder,
    @Default(null) TransitionBuilder transitionBuilder,
    @Default(0) double autoFlipMinHeight,
    @Default(null) BoxConstraints? constraints,
    @Default(true) bool hideOnSelect,
    @Default(true) bool hideOnUnfocus,
    @Default(true) bool hideWithKeyboard,
    @Default(null) ItemSeparatorBuilder itemSeparatorBuilder,
    @Default(null) ListBuilder listBuilder,
    @Default(null) Offset? offset,
    @Default(false) bool retainOnLoading,
    @Default(true) bool showOnFocus,
    @Default(null) SuggestionsController<Suggestion>? suggestionsController,
    @Default(null) DecorationBuilder decorationBuilder,
    @Default(null) EmptyBuilder emptyBuilder,
    @Default(null) ScrollController? scrollController,
    @Default(null) FocusNode? focusNode,
    @Default(true) bool hideKeyboardOnDrag,
    @Default(null) TextFieldBuilder builder,
    @Default(null) CancelToken? cancelToken,
  }) = _SearchConfig;
}

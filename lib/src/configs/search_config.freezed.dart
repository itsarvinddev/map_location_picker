// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SearchConfig {
  String get apiKey;
  PlacesAPINew? get placesApi;
  bool get placesAllFields;
  PlaceDetailsFilter? get placeDetailsFilter;
  Place? get placeInstanceFields;
  List<String>? get placeFields;
  bool get searchAllFields;
  List<String>? get searchFields;
  AutocompleteSearchFilter? get searchFilter;
  PlacesSuggestions? get searchInstanceFields;
  SessionTokenHandler? get sessionToken;
  String get searchHintText;
  TextStyle? get searchHintStyle;
  int get minCharsForSuggestions;
  Duration get debounceDuration;
  String get defaultAddressText;
  Suggestion? get initialValue;
  ItemBuilder get itemBuilder;
  OnSelected get onSelected;
  ErrorBuilder get errorBuilder;
  Duration get animationDuration;
  bool get autoFlipDirection;
  VerticalDirection? get direction;
  bool get hideOnEmpty;
  bool get hideOnError;
  bool get hideOnLoading;
  LoadingBuilder get loadingBuilder;
  TransitionBuilder get transitionBuilder;
  double get autoFlipMinHeight;
  BoxConstraints? get constraints;
  bool get hideOnSelect;
  bool get hideOnUnfocus;
  bool get hideWithKeyboard;
  ItemSeparatorBuilder get itemSeparatorBuilder;
  ListBuilder get listBuilder;
  Offset? get offset;
  bool get retainOnLoading;
  bool get showOnFocus;
  SuggestionsController<Suggestion>? get suggestionsController;
  DecorationBuilder get decorationBuilder;
  EmptyBuilder get emptyBuilder;
  ScrollController? get scrollController;
  FocusNode? get focusNode;
  bool get hideKeyboardOnDrag;
  TextFieldBuilder get builder;

  /// Create a copy of SearchConfig
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SearchConfigCopyWith<SearchConfig> get copyWith =>
      _$SearchConfigCopyWithImpl<SearchConfig>(
          this as SearchConfig, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SearchConfig &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            const DeepCollectionEquality().equals(other.placesApi, placesApi) &&
            (identical(other.placesAllFields, placesAllFields) ||
                other.placesAllFields == placesAllFields) &&
            const DeepCollectionEquality()
                .equals(other.placeDetailsFilter, placeDetailsFilter) &&
            const DeepCollectionEquality()
                .equals(other.placeInstanceFields, placeInstanceFields) &&
            const DeepCollectionEquality()
                .equals(other.placeFields, placeFields) &&
            (identical(other.searchAllFields, searchAllFields) ||
                other.searchAllFields == searchAllFields) &&
            const DeepCollectionEquality()
                .equals(other.searchFields, searchFields) &&
            const DeepCollectionEquality()
                .equals(other.searchFilter, searchFilter) &&
            const DeepCollectionEquality()
                .equals(other.searchInstanceFields, searchInstanceFields) &&
            const DeepCollectionEquality()
                .equals(other.sessionToken, sessionToken) &&
            (identical(other.searchHintText, searchHintText) ||
                other.searchHintText == searchHintText) &&
            (identical(other.searchHintStyle, searchHintStyle) ||
                other.searchHintStyle == searchHintStyle) &&
            (identical(other.minCharsForSuggestions, minCharsForSuggestions) ||
                other.minCharsForSuggestions == minCharsForSuggestions) &&
            (identical(other.debounceDuration, debounceDuration) ||
                other.debounceDuration == debounceDuration) &&
            (identical(other.defaultAddressText, defaultAddressText) ||
                other.defaultAddressText == defaultAddressText) &&
            const DeepCollectionEquality()
                .equals(other.initialValue, initialValue) &&
            (identical(other.itemBuilder, itemBuilder) ||
                other.itemBuilder == itemBuilder) &&
            (identical(other.onSelected, onSelected) ||
                other.onSelected == onSelected) &&
            (identical(other.errorBuilder, errorBuilder) ||
                other.errorBuilder == errorBuilder) &&
            (identical(other.animationDuration, animationDuration) ||
                other.animationDuration == animationDuration) &&
            (identical(other.autoFlipDirection, autoFlipDirection) ||
                other.autoFlipDirection == autoFlipDirection) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.hideOnEmpty, hideOnEmpty) ||
                other.hideOnEmpty == hideOnEmpty) &&
            (identical(other.hideOnError, hideOnError) ||
                other.hideOnError == hideOnError) &&
            (identical(other.hideOnLoading, hideOnLoading) ||
                other.hideOnLoading == hideOnLoading) &&
            (identical(other.loadingBuilder, loadingBuilder) ||
                other.loadingBuilder == loadingBuilder) &&
            (identical(other.transitionBuilder, transitionBuilder) ||
                other.transitionBuilder == transitionBuilder) &&
            (identical(other.autoFlipMinHeight, autoFlipMinHeight) ||
                other.autoFlipMinHeight == autoFlipMinHeight) &&
            (identical(other.constraints, constraints) ||
                other.constraints == constraints) &&
            (identical(other.hideOnSelect, hideOnSelect) ||
                other.hideOnSelect == hideOnSelect) &&
            (identical(other.hideOnUnfocus, hideOnUnfocus) ||
                other.hideOnUnfocus == hideOnUnfocus) &&
            (identical(other.hideWithKeyboard, hideWithKeyboard) ||
                other.hideWithKeyboard == hideWithKeyboard) &&
            (identical(other.itemSeparatorBuilder, itemSeparatorBuilder) ||
                other.itemSeparatorBuilder == itemSeparatorBuilder) &&
            (identical(other.listBuilder, listBuilder) ||
                other.listBuilder == listBuilder) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.retainOnLoading, retainOnLoading) ||
                other.retainOnLoading == retainOnLoading) &&
            (identical(other.showOnFocus, showOnFocus) ||
                other.showOnFocus == showOnFocus) &&
            (identical(other.suggestionsController, suggestionsController) ||
                other.suggestionsController == suggestionsController) &&
            (identical(other.decorationBuilder, decorationBuilder) ||
                other.decorationBuilder == decorationBuilder) &&
            (identical(other.emptyBuilder, emptyBuilder) ||
                other.emptyBuilder == emptyBuilder) &&
            (identical(other.scrollController, scrollController) ||
                other.scrollController == scrollController) &&
            (identical(other.focusNode, focusNode) ||
                other.focusNode == focusNode) &&
            (identical(other.hideKeyboardOnDrag, hideKeyboardOnDrag) ||
                other.hideKeyboardOnDrag == hideKeyboardOnDrag) &&
            (identical(other.builder, builder) || other.builder == builder));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        apiKey,
        const DeepCollectionEquality().hash(placesApi),
        placesAllFields,
        const DeepCollectionEquality().hash(placeDetailsFilter),
        const DeepCollectionEquality().hash(placeInstanceFields),
        const DeepCollectionEquality().hash(placeFields),
        searchAllFields,
        const DeepCollectionEquality().hash(searchFields),
        const DeepCollectionEquality().hash(searchFilter),
        const DeepCollectionEquality().hash(searchInstanceFields),
        const DeepCollectionEquality().hash(sessionToken),
        searchHintText,
        searchHintStyle,
        minCharsForSuggestions,
        debounceDuration,
        defaultAddressText,
        const DeepCollectionEquality().hash(initialValue),
        itemBuilder,
        onSelected,
        errorBuilder,
        animationDuration,
        autoFlipDirection,
        direction,
        hideOnEmpty,
        hideOnError,
        hideOnLoading,
        loadingBuilder,
        transitionBuilder,
        autoFlipMinHeight,
        constraints,
        hideOnSelect,
        hideOnUnfocus,
        hideWithKeyboard,
        itemSeparatorBuilder,
        listBuilder,
        offset,
        retainOnLoading,
        showOnFocus,
        suggestionsController,
        decorationBuilder,
        emptyBuilder,
        scrollController,
        focusNode,
        hideKeyboardOnDrag,
        builder
      ]);

  @override
  String toString() {
    return 'SearchConfig(apiKey: $apiKey, placesApi: $placesApi, placesAllFields: $placesAllFields, placeDetailsFilter: $placeDetailsFilter, placeInstanceFields: $placeInstanceFields, placeFields: $placeFields, searchAllFields: $searchAllFields, searchFields: $searchFields, searchFilter: $searchFilter, searchInstanceFields: $searchInstanceFields, sessionToken: $sessionToken, searchHintText: $searchHintText, searchHintStyle: $searchHintStyle, minCharsForSuggestions: $minCharsForSuggestions, debounceDuration: $debounceDuration, defaultAddressText: $defaultAddressText, initialValue: $initialValue, itemBuilder: $itemBuilder, onSelected: $onSelected, errorBuilder: $errorBuilder, animationDuration: $animationDuration, autoFlipDirection: $autoFlipDirection, direction: $direction, hideOnEmpty: $hideOnEmpty, hideOnError: $hideOnError, hideOnLoading: $hideOnLoading, loadingBuilder: $loadingBuilder, transitionBuilder: $transitionBuilder, autoFlipMinHeight: $autoFlipMinHeight, constraints: $constraints, hideOnSelect: $hideOnSelect, hideOnUnfocus: $hideOnUnfocus, hideWithKeyboard: $hideWithKeyboard, itemSeparatorBuilder: $itemSeparatorBuilder, listBuilder: $listBuilder, offset: $offset, retainOnLoading: $retainOnLoading, showOnFocus: $showOnFocus, suggestionsController: $suggestionsController, decorationBuilder: $decorationBuilder, emptyBuilder: $emptyBuilder, scrollController: $scrollController, focusNode: $focusNode, hideKeyboardOnDrag: $hideKeyboardOnDrag, builder: $builder)';
  }
}

/// @nodoc
abstract mixin class $SearchConfigCopyWith<$Res> {
  factory $SearchConfigCopyWith(
          SearchConfig value, $Res Function(SearchConfig) _then) =
      _$SearchConfigCopyWithImpl;
  @useResult
  $Res call(
      {String apiKey,
      PlacesAPINew? placesApi,
      bool placesAllFields,
      PlaceDetailsFilter? placeDetailsFilter,
      Place? placeInstanceFields,
      List<String>? placeFields,
      bool searchAllFields,
      List<String>? searchFields,
      AutocompleteSearchFilter? searchFilter,
      PlacesSuggestions? searchInstanceFields,
      SessionTokenHandler? sessionToken,
      String searchHintText,
      TextStyle? searchHintStyle,
      int minCharsForSuggestions,
      Duration debounceDuration,
      String defaultAddressText,
      Suggestion? initialValue,
      ItemBuilder itemBuilder,
      OnSelected onSelected,
      ErrorBuilder errorBuilder,
      Duration animationDuration,
      bool autoFlipDirection,
      VerticalDirection? direction,
      bool hideOnEmpty,
      bool hideOnError,
      bool hideOnLoading,
      LoadingBuilder loadingBuilder,
      TransitionBuilder transitionBuilder,
      double autoFlipMinHeight,
      BoxConstraints? constraints,
      bool hideOnSelect,
      bool hideOnUnfocus,
      bool hideWithKeyboard,
      ItemSeparatorBuilder itemSeparatorBuilder,
      ListBuilder listBuilder,
      Offset? offset,
      bool retainOnLoading,
      bool showOnFocus,
      SuggestionsController<Suggestion>? suggestionsController,
      DecorationBuilder decorationBuilder,
      EmptyBuilder emptyBuilder,
      ScrollController? scrollController,
      FocusNode? focusNode,
      bool hideKeyboardOnDrag,
      TextFieldBuilder builder});
}

/// @nodoc
class _$SearchConfigCopyWithImpl<$Res> implements $SearchConfigCopyWith<$Res> {
  _$SearchConfigCopyWithImpl(this._self, this._then);

  final SearchConfig _self;
  final $Res Function(SearchConfig) _then;

  /// Create a copy of SearchConfig
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apiKey = null,
    Object? placesApi = freezed,
    Object? placesAllFields = null,
    Object? placeDetailsFilter = freezed,
    Object? placeInstanceFields = freezed,
    Object? placeFields = freezed,
    Object? searchAllFields = null,
    Object? searchFields = freezed,
    Object? searchFilter = freezed,
    Object? searchInstanceFields = freezed,
    Object? sessionToken = freezed,
    Object? searchHintText = null,
    Object? searchHintStyle = freezed,
    Object? minCharsForSuggestions = null,
    Object? debounceDuration = null,
    Object? defaultAddressText = null,
    Object? initialValue = freezed,
    Object? itemBuilder = freezed,
    Object? onSelected = freezed,
    Object? errorBuilder = freezed,
    Object? animationDuration = null,
    Object? autoFlipDirection = null,
    Object? direction = freezed,
    Object? hideOnEmpty = null,
    Object? hideOnError = null,
    Object? hideOnLoading = null,
    Object? loadingBuilder = freezed,
    Object? transitionBuilder = freezed,
    Object? autoFlipMinHeight = null,
    Object? constraints = freezed,
    Object? hideOnSelect = null,
    Object? hideOnUnfocus = null,
    Object? hideWithKeyboard = null,
    Object? itemSeparatorBuilder = freezed,
    Object? listBuilder = freezed,
    Object? offset = freezed,
    Object? retainOnLoading = null,
    Object? showOnFocus = null,
    Object? suggestionsController = freezed,
    Object? decorationBuilder = freezed,
    Object? emptyBuilder = freezed,
    Object? scrollController = freezed,
    Object? focusNode = freezed,
    Object? hideKeyboardOnDrag = null,
    Object? builder = freezed,
  }) {
    return _then(_self.copyWith(
      apiKey: null == apiKey
          ? _self.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      placesApi: freezed == placesApi
          ? _self.placesApi
          : placesApi // ignore: cast_nullable_to_non_nullable
              as PlacesAPINew?,
      placesAllFields: null == placesAllFields
          ? _self.placesAllFields
          : placesAllFields // ignore: cast_nullable_to_non_nullable
              as bool,
      placeDetailsFilter: freezed == placeDetailsFilter
          ? _self.placeDetailsFilter
          : placeDetailsFilter // ignore: cast_nullable_to_non_nullable
              as PlaceDetailsFilter?,
      placeInstanceFields: freezed == placeInstanceFields
          ? _self.placeInstanceFields
          : placeInstanceFields // ignore: cast_nullable_to_non_nullable
              as Place?,
      placeFields: freezed == placeFields
          ? _self.placeFields
          : placeFields // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      searchAllFields: null == searchAllFields
          ? _self.searchAllFields
          : searchAllFields // ignore: cast_nullable_to_non_nullable
              as bool,
      searchFields: freezed == searchFields
          ? _self.searchFields
          : searchFields // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      searchFilter: freezed == searchFilter
          ? _self.searchFilter
          : searchFilter // ignore: cast_nullable_to_non_nullable
              as AutocompleteSearchFilter?,
      searchInstanceFields: freezed == searchInstanceFields
          ? _self.searchInstanceFields
          : searchInstanceFields // ignore: cast_nullable_to_non_nullable
              as PlacesSuggestions?,
      sessionToken: freezed == sessionToken
          ? _self.sessionToken
          : sessionToken // ignore: cast_nullable_to_non_nullable
              as SessionTokenHandler?,
      searchHintText: null == searchHintText
          ? _self.searchHintText
          : searchHintText // ignore: cast_nullable_to_non_nullable
              as String,
      searchHintStyle: freezed == searchHintStyle
          ? _self.searchHintStyle
          : searchHintStyle // ignore: cast_nullable_to_non_nullable
              as TextStyle?,
      minCharsForSuggestions: null == minCharsForSuggestions
          ? _self.minCharsForSuggestions
          : minCharsForSuggestions // ignore: cast_nullable_to_non_nullable
              as int,
      debounceDuration: null == debounceDuration
          ? _self.debounceDuration
          : debounceDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      defaultAddressText: null == defaultAddressText
          ? _self.defaultAddressText
          : defaultAddressText // ignore: cast_nullable_to_non_nullable
              as String,
      initialValue: freezed == initialValue
          ? _self.initialValue
          : initialValue // ignore: cast_nullable_to_non_nullable
              as Suggestion?,
      itemBuilder: freezed == itemBuilder
          ? _self.itemBuilder
          : itemBuilder // ignore: cast_nullable_to_non_nullable
              as ItemBuilder,
      onSelected: freezed == onSelected
          ? _self.onSelected
          : onSelected // ignore: cast_nullable_to_non_nullable
              as OnSelected,
      errorBuilder: freezed == errorBuilder
          ? _self.errorBuilder
          : errorBuilder // ignore: cast_nullable_to_non_nullable
              as ErrorBuilder,
      animationDuration: null == animationDuration
          ? _self.animationDuration
          : animationDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      autoFlipDirection: null == autoFlipDirection
          ? _self.autoFlipDirection
          : autoFlipDirection // ignore: cast_nullable_to_non_nullable
              as bool,
      direction: freezed == direction
          ? _self.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as VerticalDirection?,
      hideOnEmpty: null == hideOnEmpty
          ? _self.hideOnEmpty
          : hideOnEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      hideOnError: null == hideOnError
          ? _self.hideOnError
          : hideOnError // ignore: cast_nullable_to_non_nullable
              as bool,
      hideOnLoading: null == hideOnLoading
          ? _self.hideOnLoading
          : hideOnLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      loadingBuilder: freezed == loadingBuilder
          ? _self.loadingBuilder
          : loadingBuilder // ignore: cast_nullable_to_non_nullable
              as LoadingBuilder,
      transitionBuilder: freezed == transitionBuilder
          ? _self.transitionBuilder
          : transitionBuilder // ignore: cast_nullable_to_non_nullable
              as TransitionBuilder,
      autoFlipMinHeight: null == autoFlipMinHeight
          ? _self.autoFlipMinHeight
          : autoFlipMinHeight // ignore: cast_nullable_to_non_nullable
              as double,
      constraints: freezed == constraints
          ? _self.constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as BoxConstraints?,
      hideOnSelect: null == hideOnSelect
          ? _self.hideOnSelect
          : hideOnSelect // ignore: cast_nullable_to_non_nullable
              as bool,
      hideOnUnfocus: null == hideOnUnfocus
          ? _self.hideOnUnfocus
          : hideOnUnfocus // ignore: cast_nullable_to_non_nullable
              as bool,
      hideWithKeyboard: null == hideWithKeyboard
          ? _self.hideWithKeyboard
          : hideWithKeyboard // ignore: cast_nullable_to_non_nullable
              as bool,
      itemSeparatorBuilder: freezed == itemSeparatorBuilder
          ? _self.itemSeparatorBuilder
          : itemSeparatorBuilder // ignore: cast_nullable_to_non_nullable
              as ItemSeparatorBuilder,
      listBuilder: freezed == listBuilder
          ? _self.listBuilder
          : listBuilder // ignore: cast_nullable_to_non_nullable
              as ListBuilder,
      offset: freezed == offset
          ? _self.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as Offset?,
      retainOnLoading: null == retainOnLoading
          ? _self.retainOnLoading
          : retainOnLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      showOnFocus: null == showOnFocus
          ? _self.showOnFocus
          : showOnFocus // ignore: cast_nullable_to_non_nullable
              as bool,
      suggestionsController: freezed == suggestionsController
          ? _self.suggestionsController
          : suggestionsController // ignore: cast_nullable_to_non_nullable
              as SuggestionsController<Suggestion>?,
      decorationBuilder: freezed == decorationBuilder
          ? _self.decorationBuilder
          : decorationBuilder // ignore: cast_nullable_to_non_nullable
              as DecorationBuilder,
      emptyBuilder: freezed == emptyBuilder
          ? _self.emptyBuilder
          : emptyBuilder // ignore: cast_nullable_to_non_nullable
              as EmptyBuilder,
      scrollController: freezed == scrollController
          ? _self.scrollController
          : scrollController // ignore: cast_nullable_to_non_nullable
              as ScrollController?,
      focusNode: freezed == focusNode
          ? _self.focusNode
          : focusNode // ignore: cast_nullable_to_non_nullable
              as FocusNode?,
      hideKeyboardOnDrag: null == hideKeyboardOnDrag
          ? _self.hideKeyboardOnDrag
          : hideKeyboardOnDrag // ignore: cast_nullable_to_non_nullable
              as bool,
      builder: freezed == builder
          ? _self.builder
          : builder // ignore: cast_nullable_to_non_nullable
              as TextFieldBuilder,
    ));
  }
}

/// Adds pattern-matching-related methods to [SearchConfig].
extension SearchConfigPatterns on SearchConfig {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_SearchConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SearchConfig() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_SearchConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchConfig():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_SearchConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchConfig() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String apiKey,
            PlacesAPINew? placesApi,
            bool placesAllFields,
            PlaceDetailsFilter? placeDetailsFilter,
            Place? placeInstanceFields,
            List<String>? placeFields,
            bool searchAllFields,
            List<String>? searchFields,
            AutocompleteSearchFilter? searchFilter,
            PlacesSuggestions? searchInstanceFields,
            SessionTokenHandler? sessionToken,
            String searchHintText,
            TextStyle? searchHintStyle,
            int minCharsForSuggestions,
            Duration debounceDuration,
            String defaultAddressText,
            Suggestion? initialValue,
            ItemBuilder itemBuilder,
            OnSelected onSelected,
            ErrorBuilder errorBuilder,
            Duration animationDuration,
            bool autoFlipDirection,
            VerticalDirection? direction,
            bool hideOnEmpty,
            bool hideOnError,
            bool hideOnLoading,
            LoadingBuilder loadingBuilder,
            TransitionBuilder transitionBuilder,
            double autoFlipMinHeight,
            BoxConstraints? constraints,
            bool hideOnSelect,
            bool hideOnUnfocus,
            bool hideWithKeyboard,
            ItemSeparatorBuilder itemSeparatorBuilder,
            ListBuilder listBuilder,
            Offset? offset,
            bool retainOnLoading,
            bool showOnFocus,
            SuggestionsController<Suggestion>? suggestionsController,
            DecorationBuilder decorationBuilder,
            EmptyBuilder emptyBuilder,
            ScrollController? scrollController,
            FocusNode? focusNode,
            bool hideKeyboardOnDrag,
            TextFieldBuilder builder)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SearchConfig() when $default != null:
        return $default(
            _that.apiKey,
            _that.placesApi,
            _that.placesAllFields,
            _that.placeDetailsFilter,
            _that.placeInstanceFields,
            _that.placeFields,
            _that.searchAllFields,
            _that.searchFields,
            _that.searchFilter,
            _that.searchInstanceFields,
            _that.sessionToken,
            _that.searchHintText,
            _that.searchHintStyle,
            _that.minCharsForSuggestions,
            _that.debounceDuration,
            _that.defaultAddressText,
            _that.initialValue,
            _that.itemBuilder,
            _that.onSelected,
            _that.errorBuilder,
            _that.animationDuration,
            _that.autoFlipDirection,
            _that.direction,
            _that.hideOnEmpty,
            _that.hideOnError,
            _that.hideOnLoading,
            _that.loadingBuilder,
            _that.transitionBuilder,
            _that.autoFlipMinHeight,
            _that.constraints,
            _that.hideOnSelect,
            _that.hideOnUnfocus,
            _that.hideWithKeyboard,
            _that.itemSeparatorBuilder,
            _that.listBuilder,
            _that.offset,
            _that.retainOnLoading,
            _that.showOnFocus,
            _that.suggestionsController,
            _that.decorationBuilder,
            _that.emptyBuilder,
            _that.scrollController,
            _that.focusNode,
            _that.hideKeyboardOnDrag,
            _that.builder);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String apiKey,
            PlacesAPINew? placesApi,
            bool placesAllFields,
            PlaceDetailsFilter? placeDetailsFilter,
            Place? placeInstanceFields,
            List<String>? placeFields,
            bool searchAllFields,
            List<String>? searchFields,
            AutocompleteSearchFilter? searchFilter,
            PlacesSuggestions? searchInstanceFields,
            SessionTokenHandler? sessionToken,
            String searchHintText,
            TextStyle? searchHintStyle,
            int minCharsForSuggestions,
            Duration debounceDuration,
            String defaultAddressText,
            Suggestion? initialValue,
            ItemBuilder itemBuilder,
            OnSelected onSelected,
            ErrorBuilder errorBuilder,
            Duration animationDuration,
            bool autoFlipDirection,
            VerticalDirection? direction,
            bool hideOnEmpty,
            bool hideOnError,
            bool hideOnLoading,
            LoadingBuilder loadingBuilder,
            TransitionBuilder transitionBuilder,
            double autoFlipMinHeight,
            BoxConstraints? constraints,
            bool hideOnSelect,
            bool hideOnUnfocus,
            bool hideWithKeyboard,
            ItemSeparatorBuilder itemSeparatorBuilder,
            ListBuilder listBuilder,
            Offset? offset,
            bool retainOnLoading,
            bool showOnFocus,
            SuggestionsController<Suggestion>? suggestionsController,
            DecorationBuilder decorationBuilder,
            EmptyBuilder emptyBuilder,
            ScrollController? scrollController,
            FocusNode? focusNode,
            bool hideKeyboardOnDrag,
            TextFieldBuilder builder)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchConfig():
        return $default(
            _that.apiKey,
            _that.placesApi,
            _that.placesAllFields,
            _that.placeDetailsFilter,
            _that.placeInstanceFields,
            _that.placeFields,
            _that.searchAllFields,
            _that.searchFields,
            _that.searchFilter,
            _that.searchInstanceFields,
            _that.sessionToken,
            _that.searchHintText,
            _that.searchHintStyle,
            _that.minCharsForSuggestions,
            _that.debounceDuration,
            _that.defaultAddressText,
            _that.initialValue,
            _that.itemBuilder,
            _that.onSelected,
            _that.errorBuilder,
            _that.animationDuration,
            _that.autoFlipDirection,
            _that.direction,
            _that.hideOnEmpty,
            _that.hideOnError,
            _that.hideOnLoading,
            _that.loadingBuilder,
            _that.transitionBuilder,
            _that.autoFlipMinHeight,
            _that.constraints,
            _that.hideOnSelect,
            _that.hideOnUnfocus,
            _that.hideWithKeyboard,
            _that.itemSeparatorBuilder,
            _that.listBuilder,
            _that.offset,
            _that.retainOnLoading,
            _that.showOnFocus,
            _that.suggestionsController,
            _that.decorationBuilder,
            _that.emptyBuilder,
            _that.scrollController,
            _that.focusNode,
            _that.hideKeyboardOnDrag,
            _that.builder);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String apiKey,
            PlacesAPINew? placesApi,
            bool placesAllFields,
            PlaceDetailsFilter? placeDetailsFilter,
            Place? placeInstanceFields,
            List<String>? placeFields,
            bool searchAllFields,
            List<String>? searchFields,
            AutocompleteSearchFilter? searchFilter,
            PlacesSuggestions? searchInstanceFields,
            SessionTokenHandler? sessionToken,
            String searchHintText,
            TextStyle? searchHintStyle,
            int minCharsForSuggestions,
            Duration debounceDuration,
            String defaultAddressText,
            Suggestion? initialValue,
            ItemBuilder itemBuilder,
            OnSelected onSelected,
            ErrorBuilder errorBuilder,
            Duration animationDuration,
            bool autoFlipDirection,
            VerticalDirection? direction,
            bool hideOnEmpty,
            bool hideOnError,
            bool hideOnLoading,
            LoadingBuilder loadingBuilder,
            TransitionBuilder transitionBuilder,
            double autoFlipMinHeight,
            BoxConstraints? constraints,
            bool hideOnSelect,
            bool hideOnUnfocus,
            bool hideWithKeyboard,
            ItemSeparatorBuilder itemSeparatorBuilder,
            ListBuilder listBuilder,
            Offset? offset,
            bool retainOnLoading,
            bool showOnFocus,
            SuggestionsController<Suggestion>? suggestionsController,
            DecorationBuilder decorationBuilder,
            EmptyBuilder emptyBuilder,
            ScrollController? scrollController,
            FocusNode? focusNode,
            bool hideKeyboardOnDrag,
            TextFieldBuilder builder)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SearchConfig() when $default != null:
        return $default(
            _that.apiKey,
            _that.placesApi,
            _that.placesAllFields,
            _that.placeDetailsFilter,
            _that.placeInstanceFields,
            _that.placeFields,
            _that.searchAllFields,
            _that.searchFields,
            _that.searchFilter,
            _that.searchInstanceFields,
            _that.sessionToken,
            _that.searchHintText,
            _that.searchHintStyle,
            _that.minCharsForSuggestions,
            _that.debounceDuration,
            _that.defaultAddressText,
            _that.initialValue,
            _that.itemBuilder,
            _that.onSelected,
            _that.errorBuilder,
            _that.animationDuration,
            _that.autoFlipDirection,
            _that.direction,
            _that.hideOnEmpty,
            _that.hideOnError,
            _that.hideOnLoading,
            _that.loadingBuilder,
            _that.transitionBuilder,
            _that.autoFlipMinHeight,
            _that.constraints,
            _that.hideOnSelect,
            _that.hideOnUnfocus,
            _that.hideWithKeyboard,
            _that.itemSeparatorBuilder,
            _that.listBuilder,
            _that.offset,
            _that.retainOnLoading,
            _that.showOnFocus,
            _that.suggestionsController,
            _that.decorationBuilder,
            _that.emptyBuilder,
            _that.scrollController,
            _that.focusNode,
            _that.hideKeyboardOnDrag,
            _that.builder);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SearchConfig implements SearchConfig {
  const _SearchConfig(
      {this.apiKey = '',
      this.placesApi = null,
      this.placesAllFields = true,
      this.placeDetailsFilter = null,
      this.placeInstanceFields = null,
      final List<String>? placeFields = null,
      this.searchAllFields = true,
      final List<String>? searchFields = null,
      this.searchFilter = null,
      this.searchInstanceFields = null,
      this.sessionToken = null,
      this.searchHintText = 'Search for place, address, landmark, etc.',
      this.searchHintStyle = null,
      this.minCharsForSuggestions = 3,
      this.debounceDuration = const Duration(milliseconds: 500),
      this.defaultAddressText = '',
      this.initialValue = null,
      this.itemBuilder = null,
      this.onSelected = null,
      this.errorBuilder = null,
      this.animationDuration = const Duration(milliseconds: 300),
      this.autoFlipDirection = false,
      this.direction = null,
      this.hideOnEmpty = false,
      this.hideOnError = false,
      this.hideOnLoading = false,
      this.loadingBuilder = null,
      this.transitionBuilder = null,
      this.autoFlipMinHeight = 0,
      this.constraints = null,
      this.hideOnSelect = true,
      this.hideOnUnfocus = true,
      this.hideWithKeyboard = true,
      this.itemSeparatorBuilder = null,
      this.listBuilder = null,
      this.offset = null,
      this.retainOnLoading = false,
      this.showOnFocus = true,
      this.suggestionsController = null,
      this.decorationBuilder = null,
      this.emptyBuilder = null,
      this.scrollController = null,
      this.focusNode = null,
      this.hideKeyboardOnDrag = true,
      this.builder = null})
      : _placeFields = placeFields,
        _searchFields = searchFields;

  @override
  @JsonKey()
  final String apiKey;
  @override
  @JsonKey()
  final PlacesAPINew? placesApi;
  @override
  @JsonKey()
  final bool placesAllFields;
  @override
  @JsonKey()
  final PlaceDetailsFilter? placeDetailsFilter;
  @override
  @JsonKey()
  final Place? placeInstanceFields;
  final List<String>? _placeFields;
  @override
  @JsonKey()
  List<String>? get placeFields {
    final value = _placeFields;
    if (value == null) return null;
    if (_placeFields is EqualUnmodifiableListView) return _placeFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool searchAllFields;
  final List<String>? _searchFields;
  @override
  @JsonKey()
  List<String>? get searchFields {
    final value = _searchFields;
    if (value == null) return null;
    if (_searchFields is EqualUnmodifiableListView) return _searchFields;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final AutocompleteSearchFilter? searchFilter;
  @override
  @JsonKey()
  final PlacesSuggestions? searchInstanceFields;
  @override
  @JsonKey()
  final SessionTokenHandler? sessionToken;
  @override
  @JsonKey()
  final String searchHintText;
  @override
  @JsonKey()
  final TextStyle? searchHintStyle;
  @override
  @JsonKey()
  final int minCharsForSuggestions;
  @override
  @JsonKey()
  final Duration debounceDuration;
  @override
  @JsonKey()
  final String defaultAddressText;
  @override
  @JsonKey()
  final Suggestion? initialValue;
  @override
  @JsonKey()
  final ItemBuilder itemBuilder;
  @override
  @JsonKey()
  final OnSelected onSelected;
  @override
  @JsonKey()
  final ErrorBuilder errorBuilder;
  @override
  @JsonKey()
  final Duration animationDuration;
  @override
  @JsonKey()
  final bool autoFlipDirection;
  @override
  @JsonKey()
  final VerticalDirection? direction;
  @override
  @JsonKey()
  final bool hideOnEmpty;
  @override
  @JsonKey()
  final bool hideOnError;
  @override
  @JsonKey()
  final bool hideOnLoading;
  @override
  @JsonKey()
  final LoadingBuilder loadingBuilder;
  @override
  @JsonKey()
  final TransitionBuilder transitionBuilder;
  @override
  @JsonKey()
  final double autoFlipMinHeight;
  @override
  @JsonKey()
  final BoxConstraints? constraints;
  @override
  @JsonKey()
  final bool hideOnSelect;
  @override
  @JsonKey()
  final bool hideOnUnfocus;
  @override
  @JsonKey()
  final bool hideWithKeyboard;
  @override
  @JsonKey()
  final ItemSeparatorBuilder itemSeparatorBuilder;
  @override
  @JsonKey()
  final ListBuilder listBuilder;
  @override
  @JsonKey()
  final Offset? offset;
  @override
  @JsonKey()
  final bool retainOnLoading;
  @override
  @JsonKey()
  final bool showOnFocus;
  @override
  @JsonKey()
  final SuggestionsController<Suggestion>? suggestionsController;
  @override
  @JsonKey()
  final DecorationBuilder decorationBuilder;
  @override
  @JsonKey()
  final EmptyBuilder emptyBuilder;
  @override
  @JsonKey()
  final ScrollController? scrollController;
  @override
  @JsonKey()
  final FocusNode? focusNode;
  @override
  @JsonKey()
  final bool hideKeyboardOnDrag;
  @override
  @JsonKey()
  final TextFieldBuilder builder;

  /// Create a copy of SearchConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SearchConfigCopyWith<_SearchConfig> get copyWith =>
      __$SearchConfigCopyWithImpl<_SearchConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SearchConfig &&
            (identical(other.apiKey, apiKey) || other.apiKey == apiKey) &&
            const DeepCollectionEquality().equals(other.placesApi, placesApi) &&
            (identical(other.placesAllFields, placesAllFields) ||
                other.placesAllFields == placesAllFields) &&
            const DeepCollectionEquality()
                .equals(other.placeDetailsFilter, placeDetailsFilter) &&
            const DeepCollectionEquality()
                .equals(other.placeInstanceFields, placeInstanceFields) &&
            const DeepCollectionEquality()
                .equals(other._placeFields, _placeFields) &&
            (identical(other.searchAllFields, searchAllFields) ||
                other.searchAllFields == searchAllFields) &&
            const DeepCollectionEquality()
                .equals(other._searchFields, _searchFields) &&
            const DeepCollectionEquality()
                .equals(other.searchFilter, searchFilter) &&
            const DeepCollectionEquality()
                .equals(other.searchInstanceFields, searchInstanceFields) &&
            const DeepCollectionEquality()
                .equals(other.sessionToken, sessionToken) &&
            (identical(other.searchHintText, searchHintText) ||
                other.searchHintText == searchHintText) &&
            (identical(other.searchHintStyle, searchHintStyle) ||
                other.searchHintStyle == searchHintStyle) &&
            (identical(other.minCharsForSuggestions, minCharsForSuggestions) ||
                other.minCharsForSuggestions == minCharsForSuggestions) &&
            (identical(other.debounceDuration, debounceDuration) ||
                other.debounceDuration == debounceDuration) &&
            (identical(other.defaultAddressText, defaultAddressText) ||
                other.defaultAddressText == defaultAddressText) &&
            const DeepCollectionEquality()
                .equals(other.initialValue, initialValue) &&
            (identical(other.itemBuilder, itemBuilder) ||
                other.itemBuilder == itemBuilder) &&
            (identical(other.onSelected, onSelected) ||
                other.onSelected == onSelected) &&
            (identical(other.errorBuilder, errorBuilder) ||
                other.errorBuilder == errorBuilder) &&
            (identical(other.animationDuration, animationDuration) ||
                other.animationDuration == animationDuration) &&
            (identical(other.autoFlipDirection, autoFlipDirection) ||
                other.autoFlipDirection == autoFlipDirection) &&
            (identical(other.direction, direction) ||
                other.direction == direction) &&
            (identical(other.hideOnEmpty, hideOnEmpty) ||
                other.hideOnEmpty == hideOnEmpty) &&
            (identical(other.hideOnError, hideOnError) ||
                other.hideOnError == hideOnError) &&
            (identical(other.hideOnLoading, hideOnLoading) ||
                other.hideOnLoading == hideOnLoading) &&
            (identical(other.loadingBuilder, loadingBuilder) ||
                other.loadingBuilder == loadingBuilder) &&
            (identical(other.transitionBuilder, transitionBuilder) ||
                other.transitionBuilder == transitionBuilder) &&
            (identical(other.autoFlipMinHeight, autoFlipMinHeight) ||
                other.autoFlipMinHeight == autoFlipMinHeight) &&
            (identical(other.constraints, constraints) ||
                other.constraints == constraints) &&
            (identical(other.hideOnSelect, hideOnSelect) ||
                other.hideOnSelect == hideOnSelect) &&
            (identical(other.hideOnUnfocus, hideOnUnfocus) ||
                other.hideOnUnfocus == hideOnUnfocus) &&
            (identical(other.hideWithKeyboard, hideWithKeyboard) ||
                other.hideWithKeyboard == hideWithKeyboard) &&
            (identical(other.itemSeparatorBuilder, itemSeparatorBuilder) ||
                other.itemSeparatorBuilder == itemSeparatorBuilder) &&
            (identical(other.listBuilder, listBuilder) ||
                other.listBuilder == listBuilder) &&
            (identical(other.offset, offset) || other.offset == offset) &&
            (identical(other.retainOnLoading, retainOnLoading) ||
                other.retainOnLoading == retainOnLoading) &&
            (identical(other.showOnFocus, showOnFocus) ||
                other.showOnFocus == showOnFocus) &&
            (identical(other.suggestionsController, suggestionsController) ||
                other.suggestionsController == suggestionsController) &&
            (identical(other.decorationBuilder, decorationBuilder) ||
                other.decorationBuilder == decorationBuilder) &&
            (identical(other.emptyBuilder, emptyBuilder) ||
                other.emptyBuilder == emptyBuilder) &&
            (identical(other.scrollController, scrollController) ||
                other.scrollController == scrollController) &&
            (identical(other.focusNode, focusNode) ||
                other.focusNode == focusNode) &&
            (identical(other.hideKeyboardOnDrag, hideKeyboardOnDrag) ||
                other.hideKeyboardOnDrag == hideKeyboardOnDrag) &&
            (identical(other.builder, builder) || other.builder == builder));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        apiKey,
        const DeepCollectionEquality().hash(placesApi),
        placesAllFields,
        const DeepCollectionEquality().hash(placeDetailsFilter),
        const DeepCollectionEquality().hash(placeInstanceFields),
        const DeepCollectionEquality().hash(_placeFields),
        searchAllFields,
        const DeepCollectionEquality().hash(_searchFields),
        const DeepCollectionEquality().hash(searchFilter),
        const DeepCollectionEquality().hash(searchInstanceFields),
        const DeepCollectionEquality().hash(sessionToken),
        searchHintText,
        searchHintStyle,
        minCharsForSuggestions,
        debounceDuration,
        defaultAddressText,
        const DeepCollectionEquality().hash(initialValue),
        itemBuilder,
        onSelected,
        errorBuilder,
        animationDuration,
        autoFlipDirection,
        direction,
        hideOnEmpty,
        hideOnError,
        hideOnLoading,
        loadingBuilder,
        transitionBuilder,
        autoFlipMinHeight,
        constraints,
        hideOnSelect,
        hideOnUnfocus,
        hideWithKeyboard,
        itemSeparatorBuilder,
        listBuilder,
        offset,
        retainOnLoading,
        showOnFocus,
        suggestionsController,
        decorationBuilder,
        emptyBuilder,
        scrollController,
        focusNode,
        hideKeyboardOnDrag,
        builder
      ]);

  @override
  String toString() {
    return 'SearchConfig(apiKey: $apiKey, placesApi: $placesApi, placesAllFields: $placesAllFields, placeDetailsFilter: $placeDetailsFilter, placeInstanceFields: $placeInstanceFields, placeFields: $placeFields, searchAllFields: $searchAllFields, searchFields: $searchFields, searchFilter: $searchFilter, searchInstanceFields: $searchInstanceFields, sessionToken: $sessionToken, searchHintText: $searchHintText, searchHintStyle: $searchHintStyle, minCharsForSuggestions: $minCharsForSuggestions, debounceDuration: $debounceDuration, defaultAddressText: $defaultAddressText, initialValue: $initialValue, itemBuilder: $itemBuilder, onSelected: $onSelected, errorBuilder: $errorBuilder, animationDuration: $animationDuration, autoFlipDirection: $autoFlipDirection, direction: $direction, hideOnEmpty: $hideOnEmpty, hideOnError: $hideOnError, hideOnLoading: $hideOnLoading, loadingBuilder: $loadingBuilder, transitionBuilder: $transitionBuilder, autoFlipMinHeight: $autoFlipMinHeight, constraints: $constraints, hideOnSelect: $hideOnSelect, hideOnUnfocus: $hideOnUnfocus, hideWithKeyboard: $hideWithKeyboard, itemSeparatorBuilder: $itemSeparatorBuilder, listBuilder: $listBuilder, offset: $offset, retainOnLoading: $retainOnLoading, showOnFocus: $showOnFocus, suggestionsController: $suggestionsController, decorationBuilder: $decorationBuilder, emptyBuilder: $emptyBuilder, scrollController: $scrollController, focusNode: $focusNode, hideKeyboardOnDrag: $hideKeyboardOnDrag, builder: $builder)';
  }
}

/// @nodoc
abstract mixin class _$SearchConfigCopyWith<$Res>
    implements $SearchConfigCopyWith<$Res> {
  factory _$SearchConfigCopyWith(
          _SearchConfig value, $Res Function(_SearchConfig) _then) =
      __$SearchConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String apiKey,
      PlacesAPINew? placesApi,
      bool placesAllFields,
      PlaceDetailsFilter? placeDetailsFilter,
      Place? placeInstanceFields,
      List<String>? placeFields,
      bool searchAllFields,
      List<String>? searchFields,
      AutocompleteSearchFilter? searchFilter,
      PlacesSuggestions? searchInstanceFields,
      SessionTokenHandler? sessionToken,
      String searchHintText,
      TextStyle? searchHintStyle,
      int minCharsForSuggestions,
      Duration debounceDuration,
      String defaultAddressText,
      Suggestion? initialValue,
      ItemBuilder itemBuilder,
      OnSelected onSelected,
      ErrorBuilder errorBuilder,
      Duration animationDuration,
      bool autoFlipDirection,
      VerticalDirection? direction,
      bool hideOnEmpty,
      bool hideOnError,
      bool hideOnLoading,
      LoadingBuilder loadingBuilder,
      TransitionBuilder transitionBuilder,
      double autoFlipMinHeight,
      BoxConstraints? constraints,
      bool hideOnSelect,
      bool hideOnUnfocus,
      bool hideWithKeyboard,
      ItemSeparatorBuilder itemSeparatorBuilder,
      ListBuilder listBuilder,
      Offset? offset,
      bool retainOnLoading,
      bool showOnFocus,
      SuggestionsController<Suggestion>? suggestionsController,
      DecorationBuilder decorationBuilder,
      EmptyBuilder emptyBuilder,
      ScrollController? scrollController,
      FocusNode? focusNode,
      bool hideKeyboardOnDrag,
      TextFieldBuilder builder});
}

/// @nodoc
class __$SearchConfigCopyWithImpl<$Res>
    implements _$SearchConfigCopyWith<$Res> {
  __$SearchConfigCopyWithImpl(this._self, this._then);

  final _SearchConfig _self;
  final $Res Function(_SearchConfig) _then;

  /// Create a copy of SearchConfig
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? apiKey = null,
    Object? placesApi = freezed,
    Object? placesAllFields = null,
    Object? placeDetailsFilter = freezed,
    Object? placeInstanceFields = freezed,
    Object? placeFields = freezed,
    Object? searchAllFields = null,
    Object? searchFields = freezed,
    Object? searchFilter = freezed,
    Object? searchInstanceFields = freezed,
    Object? sessionToken = freezed,
    Object? searchHintText = null,
    Object? searchHintStyle = freezed,
    Object? minCharsForSuggestions = null,
    Object? debounceDuration = null,
    Object? defaultAddressText = null,
    Object? initialValue = freezed,
    Object? itemBuilder = freezed,
    Object? onSelected = freezed,
    Object? errorBuilder = freezed,
    Object? animationDuration = null,
    Object? autoFlipDirection = null,
    Object? direction = freezed,
    Object? hideOnEmpty = null,
    Object? hideOnError = null,
    Object? hideOnLoading = null,
    Object? loadingBuilder = freezed,
    Object? transitionBuilder = freezed,
    Object? autoFlipMinHeight = null,
    Object? constraints = freezed,
    Object? hideOnSelect = null,
    Object? hideOnUnfocus = null,
    Object? hideWithKeyboard = null,
    Object? itemSeparatorBuilder = freezed,
    Object? listBuilder = freezed,
    Object? offset = freezed,
    Object? retainOnLoading = null,
    Object? showOnFocus = null,
    Object? suggestionsController = freezed,
    Object? decorationBuilder = freezed,
    Object? emptyBuilder = freezed,
    Object? scrollController = freezed,
    Object? focusNode = freezed,
    Object? hideKeyboardOnDrag = null,
    Object? builder = freezed,
  }) {
    return _then(_SearchConfig(
      apiKey: null == apiKey
          ? _self.apiKey
          : apiKey // ignore: cast_nullable_to_non_nullable
              as String,
      placesApi: freezed == placesApi
          ? _self.placesApi
          : placesApi // ignore: cast_nullable_to_non_nullable
              as PlacesAPINew?,
      placesAllFields: null == placesAllFields
          ? _self.placesAllFields
          : placesAllFields // ignore: cast_nullable_to_non_nullable
              as bool,
      placeDetailsFilter: freezed == placeDetailsFilter
          ? _self.placeDetailsFilter
          : placeDetailsFilter // ignore: cast_nullable_to_non_nullable
              as PlaceDetailsFilter?,
      placeInstanceFields: freezed == placeInstanceFields
          ? _self.placeInstanceFields
          : placeInstanceFields // ignore: cast_nullable_to_non_nullable
              as Place?,
      placeFields: freezed == placeFields
          ? _self._placeFields
          : placeFields // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      searchAllFields: null == searchAllFields
          ? _self.searchAllFields
          : searchAllFields // ignore: cast_nullable_to_non_nullable
              as bool,
      searchFields: freezed == searchFields
          ? _self._searchFields
          : searchFields // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      searchFilter: freezed == searchFilter
          ? _self.searchFilter
          : searchFilter // ignore: cast_nullable_to_non_nullable
              as AutocompleteSearchFilter?,
      searchInstanceFields: freezed == searchInstanceFields
          ? _self.searchInstanceFields
          : searchInstanceFields // ignore: cast_nullable_to_non_nullable
              as PlacesSuggestions?,
      sessionToken: freezed == sessionToken
          ? _self.sessionToken
          : sessionToken // ignore: cast_nullable_to_non_nullable
              as SessionTokenHandler?,
      searchHintText: null == searchHintText
          ? _self.searchHintText
          : searchHintText // ignore: cast_nullable_to_non_nullable
              as String,
      searchHintStyle: freezed == searchHintStyle
          ? _self.searchHintStyle
          : searchHintStyle // ignore: cast_nullable_to_non_nullable
              as TextStyle?,
      minCharsForSuggestions: null == minCharsForSuggestions
          ? _self.minCharsForSuggestions
          : minCharsForSuggestions // ignore: cast_nullable_to_non_nullable
              as int,
      debounceDuration: null == debounceDuration
          ? _self.debounceDuration
          : debounceDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      defaultAddressText: null == defaultAddressText
          ? _self.defaultAddressText
          : defaultAddressText // ignore: cast_nullable_to_non_nullable
              as String,
      initialValue: freezed == initialValue
          ? _self.initialValue
          : initialValue // ignore: cast_nullable_to_non_nullable
              as Suggestion?,
      itemBuilder: freezed == itemBuilder
          ? _self.itemBuilder
          : itemBuilder // ignore: cast_nullable_to_non_nullable
              as ItemBuilder,
      onSelected: freezed == onSelected
          ? _self.onSelected
          : onSelected // ignore: cast_nullable_to_non_nullable
              as OnSelected,
      errorBuilder: freezed == errorBuilder
          ? _self.errorBuilder
          : errorBuilder // ignore: cast_nullable_to_non_nullable
              as ErrorBuilder,
      animationDuration: null == animationDuration
          ? _self.animationDuration
          : animationDuration // ignore: cast_nullable_to_non_nullable
              as Duration,
      autoFlipDirection: null == autoFlipDirection
          ? _self.autoFlipDirection
          : autoFlipDirection // ignore: cast_nullable_to_non_nullable
              as bool,
      direction: freezed == direction
          ? _self.direction
          : direction // ignore: cast_nullable_to_non_nullable
              as VerticalDirection?,
      hideOnEmpty: null == hideOnEmpty
          ? _self.hideOnEmpty
          : hideOnEmpty // ignore: cast_nullable_to_non_nullable
              as bool,
      hideOnError: null == hideOnError
          ? _self.hideOnError
          : hideOnError // ignore: cast_nullable_to_non_nullable
              as bool,
      hideOnLoading: null == hideOnLoading
          ? _self.hideOnLoading
          : hideOnLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      loadingBuilder: freezed == loadingBuilder
          ? _self.loadingBuilder
          : loadingBuilder // ignore: cast_nullable_to_non_nullable
              as LoadingBuilder,
      transitionBuilder: freezed == transitionBuilder
          ? _self.transitionBuilder
          : transitionBuilder // ignore: cast_nullable_to_non_nullable
              as TransitionBuilder,
      autoFlipMinHeight: null == autoFlipMinHeight
          ? _self.autoFlipMinHeight
          : autoFlipMinHeight // ignore: cast_nullable_to_non_nullable
              as double,
      constraints: freezed == constraints
          ? _self.constraints
          : constraints // ignore: cast_nullable_to_non_nullable
              as BoxConstraints?,
      hideOnSelect: null == hideOnSelect
          ? _self.hideOnSelect
          : hideOnSelect // ignore: cast_nullable_to_non_nullable
              as bool,
      hideOnUnfocus: null == hideOnUnfocus
          ? _self.hideOnUnfocus
          : hideOnUnfocus // ignore: cast_nullable_to_non_nullable
              as bool,
      hideWithKeyboard: null == hideWithKeyboard
          ? _self.hideWithKeyboard
          : hideWithKeyboard // ignore: cast_nullable_to_non_nullable
              as bool,
      itemSeparatorBuilder: freezed == itemSeparatorBuilder
          ? _self.itemSeparatorBuilder
          : itemSeparatorBuilder // ignore: cast_nullable_to_non_nullable
              as ItemSeparatorBuilder,
      listBuilder: freezed == listBuilder
          ? _self.listBuilder
          : listBuilder // ignore: cast_nullable_to_non_nullable
              as ListBuilder,
      offset: freezed == offset
          ? _self.offset
          : offset // ignore: cast_nullable_to_non_nullable
              as Offset?,
      retainOnLoading: null == retainOnLoading
          ? _self.retainOnLoading
          : retainOnLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      showOnFocus: null == showOnFocus
          ? _self.showOnFocus
          : showOnFocus // ignore: cast_nullable_to_non_nullable
              as bool,
      suggestionsController: freezed == suggestionsController
          ? _self.suggestionsController
          : suggestionsController // ignore: cast_nullable_to_non_nullable
              as SuggestionsController<Suggestion>?,
      decorationBuilder: freezed == decorationBuilder
          ? _self.decorationBuilder
          : decorationBuilder // ignore: cast_nullable_to_non_nullable
              as DecorationBuilder,
      emptyBuilder: freezed == emptyBuilder
          ? _self.emptyBuilder
          : emptyBuilder // ignore: cast_nullable_to_non_nullable
              as EmptyBuilder,
      scrollController: freezed == scrollController
          ? _self.scrollController
          : scrollController // ignore: cast_nullable_to_non_nullable
              as ScrollController?,
      focusNode: freezed == focusNode
          ? _self.focusNode
          : focusNode // ignore: cast_nullable_to_non_nullable
              as FocusNode?,
      hideKeyboardOnDrag: null == hideKeyboardOnDrag
          ? _self.hideKeyboardOnDrag
          : hideKeyboardOnDrag // ignore: cast_nullable_to_non_nullable
              as bool,
      builder: freezed == builder
          ? _self.builder
          : builder // ignore: cast_nullable_to_non_nullable
              as TextFieldBuilder,
    ));
  }
}

// dart format on

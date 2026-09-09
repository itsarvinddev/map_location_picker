import 'package:flutter/foundation.dart';

/// The category of a [MapLocationPickerException].
///
/// Use this to decide how to react to a failure without string-matching on
/// [MapLocationPickerException.message]. Every failure surfaced through
/// `MapLocationPickerConfig.onError` carries one of these.
enum MapPickerErrorKind {
  /// The device has no usable connection, or the request never reached Google.
  network,

  /// The request was cancelled, usually because a newer request superseded it
  /// or the widget was disposed. Normally safe to ignore.
  cancelled,

  /// Google rejected the request as malformed — most often a bad filter, an
  /// empty field mask, or an out-of-range value.
  invalidRequest,

  /// The API key is missing, invalid, restricted to other bundle identifiers,
  /// or the required API is not enabled for the project.
  ///
  /// This is by far the most common cause of an autocomplete list that stays
  /// empty forever, so it is worth surfacing to the user during development.
  requestDenied,

  /// The project exceeded its quota or billing is not enabled.
  quotaExceeded,

  /// The request succeeded but Google returned no usable result.
  noResults,

  /// Location services are switched off on the device.
  locationServiceDisabled,

  /// The user declined the location permission for this session.
  locationPermissionDenied,

  /// The user declined the location permission permanently; only the OS
  /// settings screen can grant it now.
  locationPermissionDeniedForever,

  /// A location fix could not be obtained in time.
  locationTimeout,

  /// The map never finished initialising, so an operation that needs the
  /// [GoogleMapController] timed out. Usually a missing API key on Android or a
  /// missing Maps JavaScript API script tag on web.
  mapUnavailable,

  /// The operation is not supported on the current platform.
  unsupportedPlatform,

  /// Anything not covered above.
  unknown,
}

/// A failure raised by `map_location_picker`.
///
/// Every failure the package can produce is reported through
/// `MapLocationPickerConfig.onError` as one of these, so a host app can
/// distinguish "no results here" from "your API key is wrong" — a distinction
/// the package used to collapse into a silent empty list.
@immutable
class MapLocationPickerException implements Exception {
  /// What kind of failure this is.
  final MapPickerErrorKind kind;

  /// A human-readable description, suitable for a debug log.
  ///
  /// Do not parse this — switch on [kind] instead.
  final String message;

  /// The HTTP status code Google returned, when the failure came from an API
  /// call.
  final int? statusCode;

  /// The underlying error, when this exception wraps one.
  final Object? cause;

  /// The stack trace of [cause], when available.
  final StackTrace? stackTrace;

  /// Creates a failure.
  const MapLocationPickerException(
    this.kind,
    this.message, {
    this.statusCode,
    this.cause,
    this.stackTrace,
  });

  /// Whether this failure is worth showing to an end user.
  ///
  /// [MapPickerErrorKind.cancelled] and [MapPickerErrorKind.noResults] are
  /// normal control flow rather than problems.
  bool get isUserFacing =>
      kind != MapPickerErrorKind.cancelled &&
      kind != MapPickerErrorKind.noResults;

  @override
  String toString() =>
      'MapLocationPickerException(${kind.name}: $message'
      '${statusCode != null ? ', status $statusCode' : ''})';
}

/// Signature for the callback that receives every failure the picker produces.
typedef MapPickerErrorCallback =
    void Function(MapLocationPickerException error);

/// Maps a Google Places / Geocoding HTTP status code onto a
/// [MapPickerErrorKind].
MapPickerErrorKind mapPickerErrorKindFromStatus(int? statusCode) {
  return switch (statusCode) {
    400 => MapPickerErrorKind.invalidRequest,
    401 || 403 => MapPickerErrorKind.requestDenied,
    404 => MapPickerErrorKind.noResults,
    429 => MapPickerErrorKind.quotaExceeded,
    _ => MapPickerErrorKind.unknown,
  };
}

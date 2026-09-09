/// Fallback implementation of the autocomplete service.
///
/// Selected when neither `dart:io` nor `dart:js_interop` is available. The REST
/// implementation has no `dart:io` dependency of its own, so it works here too.
///
/// Do not import this file directly — use `autocomplete_service.dart`.
library;

export 'autocomplete_service_io.dart';

import 'dart:async';

import 'package:flutter/foundation.dart';

/// The debouncer for the map location picker.
class DeBouncer {
  /// The duration for the debouncer.
  final Duration duration;

  /// The timer for the debouncer.
  Timer? _timer;

  DeBouncer({required this.duration});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(duration, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}

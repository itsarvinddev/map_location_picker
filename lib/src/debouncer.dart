import 'dart:async';

import 'package:flutter/foundation.dart';

class DeBouncer {
  final Duration duration;
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

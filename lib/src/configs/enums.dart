/// How the user picks a point on the map.
enum PickerPinMode {
  /// A marker is dropped where the map is tapped, and can be dragged.
  ///
  /// The classic behaviour, and the default.
  marker,

  /// A pin is fixed at the centre of the screen and the map pans underneath
  /// it. The address resolves when the map comes to rest.
  ///
  /// This is the interaction most ride-hailing and food-delivery apps use, and
  /// it reads better on small screens because the pin never sits under the
  /// user's finger.
  centerPin,
}

/// The state of the centre pin in [PickerPinMode.centerPin].
enum PinState {
  /// The map is still initialising; the pin is not shown yet.
  preparing,

  /// The map is at rest.
  idle,

  /// The map is being panned under the pin.
  dragging,
}

/// Where the floating controls sit inside the picker.
enum FloatingControlsPosition {
  /// Above the bottom card, aligned to the trailing edge. The default.
  bottomEnd,

  /// Above the bottom card, aligned to the leading edge.
  bottomStart,

  /// Below the search bar, aligned to the trailing edge.
  topEnd,

  /// Below the search bar, aligned to the leading edge.
  topStart,
}

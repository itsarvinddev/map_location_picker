# Contributing

Thanks for helping out. This document is short on purpose.

## Getting set up

```bash
git clone https://github.com/itsarvinddev/map_location_picker.git
cd map_location_picker
flutter pub get
```

You need **Flutter 3.38.1 or newer** — that is the floor the package declares,
and CI compiles against it explicitly, not just against the latest stable.

That second job is not ceremony: it has caught an unsatisfiable SDK floor, a
dependency bound that resolved but did not build, and analyzer diagnostics that
only the older SDK reports. None of them were visible on a recent Flutter. If
you touch `pubspec.yaml` or add a deprecation, install the floor SDK and run
against it before pushing:

```bash
# Once
cd ~/development
curl -LO https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.38.1-stable.zip
unzip -q flutter_macos_arm64_3.38.1-stable.zip -d f3381 && mv f3381/flutter flutter-3.38.1

# Per change — this is exactly what the `min` CI job runs
export PATH="$HOME/development/flutter-3.38.1/bin:$PATH"
flutter pub get
flutter pub downgrade && flutter analyze --no-fatal-infos && flutter pub get
flutter analyze --fatal-infos
flutter test
```

To run the example you need a Google Maps API key. Put it in
`example/lib/key.dart`:

```dart
const String YOUR_API_KEY = 'your-key-here';
```

That file is committed with a placeholder so the example compiles from a clean
clone. **Do not commit a real key.** Keep your local edit out of `git` with:

```bash
git update-index --skip-worktree example/lib/key.dart
```

## Before you open a pull request

CI runs all of these, so running them locally saves a round trip:

```bash
dart format .
flutter analyze --fatal-infos
flutter test

# Generated code must be current and byte-identical.
dart run build_runner build
git diff --exit-code -- '*.freezed.dart' '*.g.dart'
```

Two things worth knowing:

- **Never hand-edit a `.freezed.dart` file.** `freezed` and `build_runner` are
  pinned to exact versions precisely so everyone's generated output matches;
  CI fails on any drift.
- **If you change the public API**, add the new types to
  `example/lib/api_surface_check.dart`. That file imports only the package
  barrel and names every public type, so a missing `show` clause fails
  `flutter analyze` instead of a user's build.
- **If you change a README code sample**, update
  `example/lib/readme_samples.dart` to match. Every sample in the README is
  compiled there.

## Reporting a bug

Please include:

- the output of `flutter doctor -v`
- your `map_location_picker` version
- the platform (and whether it is web JS or WebAssembly)
- a minimal `MapLocationPickerConfig` that reproduces it

If something "just doesn't work", attach an `onError` callback first — it will
usually say exactly what is wrong:

```dart
MapLocationPickerConfig(
  apiKey: key,
  onError: (e) => debugPrint('${e.kind}: ${e.message}'),
)
```

The most common cause by far is an API key that is missing, restricted to a
different app, or does not have **Places API (New)** enabled.

## Adding a fix

Every bug fix should come with a test that fails without it. The existing tests
in `test/` are organised that way — each one names the defect it locks down.

Widget-level behaviour that needs a live `GoogleMap` cannot be unit tested (the
platform view will not initialise in a test harness), so prefer putting logic in
`MapLocationPickerController`, which is plain Dart and fully testable.

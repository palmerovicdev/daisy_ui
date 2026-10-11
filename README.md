# daisy_ui

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/to/develop-plugins),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Code generation

Models can use [Freezed](https://pub.dev/packages/freezed) for immutable data
classes and `json_serializable` for JSON serialization. Generated `.freezed.dart`
and `.g.dart` files go in a `generated/` subdirectory beside each source file.
Use relative part directives in your models:

```dart
part 'generated/my_model.freezed.dart';
part 'generated/my_model.g.dart';
```

After adding or changing an annotated model, run:

```sh
dart run build_runner build --delete-conflicting-outputs
```

Keep the generated files in version control.

# daisy_ui

DaisyUI themes and design tokens for Flutter. This is a Flutter package with no
native plugin registration or platform-specific implementation.

## Getting Started

Import the public API:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    DaisyThemeScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            final theme = context.daisyTheme;
            return Scaffold(
              backgroundColor: theme.colors.base.base.toColor(),
              body: Center(
                child: Text(
                  theme.name,
                  style: TextStyle(color: theme.colors.base.content.toColor()),
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}
```

`DaisyThemes` contains 35 built-in themes. Read `context.daisyTheme` in a
descendant's `build` method to rebuild when the current theme changes:

```dart
DaisyThemeService.setTheme(DaisyThemes.dark);
```

`DaisyThemeService.theme` is a read-only `ValueListenable<DaisyThemeModel>`.
Change the global theme with `setTheme`; the underlying signal is private.
DaisyUI tokens are applied explicitly; they do not automatically configure
Material's `ThemeData`.

## Independent themes

Pass a controller to give a subtree its own theme:

```dart
final controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);

// Place above the widgets that read context.daisyTheme.
DaisyThemeScope(controller: controller, child: const MyPreview());

controller.setTheme(DaisyThemes.dark);
```

Each consumer watches the nearest scope. Without a controller, a scope uses the
global service. A controller's `theme` property also exposes a read-only
`ValueListenable<DaisyThemeModel>`.

Create each controller once in its owner's `initState`, and call
`controller.dispose()` from that owner's `dispose`. Scopes borrow controllers
and never dispose them. See the preview in [the example](example/lib/main.dart)
for the complete lifecycle.

## Serialization

`toJson()` converts all nested theme tokens and colors into JSON maps:

```dart
final map = DaisyThemes.light.toJson();
final restored = DaisyThemeModel.fromJson(map);
```

Encoding a theme with `jsonEncode(theme)` is also supported.

The `example/` application demonstrates global theme changes and an independent
preview:

```sh
cd example
flutter run -d chrome
```

## Validation

Run `flutter test` from the package root and from `example/`. Run
`flutter build web` from `example/` to compile the example for web.

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
dart run build_runner build
```

Keep the generated files in version control.

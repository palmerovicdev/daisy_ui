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

## Theme tokens

`context.daisyTheme` returns an immutable `DaisyThemeModel`. Its `id`, `name`
and `description` identify the theme; `colors`, `radius`, `size` and `border`
contain the values to apply to your widgets. The context must be **below** a
`DaisyThemeScope`; reading it registers the widget as a dependent of the
nearest scope.

```dart
final theme = context.daisyTheme;
final primary = theme.colors.primary;

Container(
  height: theme.size.fields.md.toDouble(),
  decoration: BoxDecoration(
    color: primary.base.toColor(),
    borderRadius: BorderRadius.circular(theme.radius.fields.toDouble()),
    border: Border.all(
      color: theme.colors.neutral.base.toColor(),
      width: theme.border,
    ),
  ),
  alignment: Alignment.center,
  child: Text('Continue', style: TextStyle(color: primary.content.toColor())),
)
```

### Colors

Each `DaisyThemeColorPair` has a `base` surface and a `content` foreground
intended for text or icons on that surface. `colors.base` also provides the
optional `base200` and `base300` stepped surfaces. These are populated in the
built-in themes; custom themes can leave them null. The remaining roles are
`primary`, `secondary`, `accent`, `neutral`, `info`, `success`, `warning`,
`error` and `danger`. Built-in themes use the same values for `danger` and
`error`; a custom theme may choose different values.

Colors are `RayOklch` values. Call `toColor()` to use one with Flutter, or
construct a color with `RayOklch.fromComponents(lightness, chroma, hue)` and
an optional fourth opacity argument. `DaisyThemeColorPalette` provides named
constants such as `indigo700`; each constant's API documentation lists its
exact OKLCH components. Check contrast for your actual foreground, background
and context when creating custom combinations.

### Radius and border presets

Values are in Flutter logical pixels. Apply the radius explicitly with
`BorderRadius.circular(value.toDouble())` and the border width with
`Border.all(width: value)`.

| Radius preset | Value | Typical use |
| --- | ---: | --- |
| `DaisyThemeRadiusPreset.sharp` | 0 | Square corners |
| `DaisyThemeRadiusPreset.soft` | 4 | Subtle rounding |
| `DaisyThemeRadiusPreset.medium` | 8 | Moderate rounding |
| `DaisyThemeRadiusPreset.large` | 16 | Rounded surfaces |
| `DaisyThemeRadiusPreset.full` | 32 | More rounded surfaces |

`full` is a fixed radius of 32 logical pixels; whether a shape appears fully
round depends on its dimensions. A theme specifies separate `radius.boxes`
(cards, dialogs), `radius.fields` (buttons, inputs) and `radius.selectors`
(checkboxes, toggles) values. These groups are guidance for consumers, not
automatic styling.

| Border preset | Value |
| --- | ---: |
| `DaisyThemeBorderWidthPreset.hairline` | 0.5 |
| `DaisyThemeBorderWidthPreset.thin` | 1 |
| `DaisyThemeBorderWidthPreset.medium` | 1.5 |
| `DaisyThemeBorderWidthPreset.thick` | 2 |

### Size presets

`DaisyThemeSize` contains independent `fields` and `selectors` scales.
Both are `DaisyThemeSizePresets` with a configurable `base` step; the getters
return integer logical-pixel values. All built-in themes currently use
`base: 4` for both groups:

| Getter | Formula | With `base: 4` |
| --- | ---: | ---: |
| `xs` | `base * 6` | 24 |
| `sm` | `base * 8` | 32 |
| `md` | `base * 10` | 40 |
| `lg` | `base * 12` | 48 |
| `xl` | `base * 14` | 56 |

For example, `const DaisyThemeSizePresets(base: 5).md` is 50. Changing a
scale changes all its derived sizes; it does not resize widgets until those
widgets use the values.

### Customize a theme

Start from a preset and replace only the tokens you need. The original remains
unchanged:

```dart
final custom = DaisyThemes.light.copyWith(
  id: 'my-brand',
  name: 'My brand',
  border: DaisyThemeBorderWidthPreset.medium, // 1.5 logical pixels
  radius: DaisyThemes.light.radius.copyWith(fields: DaisyThemeRadiusPreset.large),
  size: DaisyThemes.light.size.copyWith(
    fields: const DaisyThemeSizePresets(base: 5),
  ),
  colors: DaisyThemes.light.colors.copyWith(
    primary: const DaisyThemeColorPair(
      base: DaisyThemeColorPalette.indigo700,
      content: DaisyThemeColorPalette.indigo100,
    ),
  ),
);
DaisyThemeService.setTheme(custom);
```

The built-in `DaisyThemes` constants include `light`, `dark`, `cupcake`,
`dracula`, `nord` and others. Their API documentation describes each theme and
its border, radius and size values; inspect its color roles for the exact
palette. The model does not include DaisyUI's color-scheme, depth or noise
tokens.

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

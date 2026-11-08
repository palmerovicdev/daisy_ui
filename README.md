# daisy_ui

DaisyUI themes and design tokens for Flutter. This is a Flutter package with no
native plugin registration or platform-specific implementation.

## Getting Started

The project uses Flutter 3.47.8 and its bundled Dart 3.13.7. Install the
version selected by `.fvmrc` and resolve the package dependencies with FVM:

```sh
fvm install
fvm flutter pub get
```

Initialize the global theme service before starting the app, then place a
`DaisyThemeScope` above the widgets that read the theme:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DaisyThemeService.initialize();
  runApp(
    DaisyThemeScope(
      child: MaterialApp(
        home: Builder(
          builder: (context) {
            final theme = context.daisyTheme;
            return Scaffold(
              backgroundColor: theme.colors.base.base,
              body: Center(
                child: Text(
                  theme.name,
                  style: TextStyle(color: theme.colors.base.content),
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

`DaisyThemeService.initialize()` starts the global theme-change subscription;
repeated calls do not add another subscription. Call it before `runApp` when
using the global service. Initialization is not enforced at runtime, and
saving or restoring the theme is not implemented yet.

`DaisyThemeService.theme` is a read-only `ValueListenable<DaisyThemeModel>`.
Change the global theme with `setTheme`; the underlying signal is private.
DaisyUI tokens are applied explicitly; they do not automatically configure
Material's `ThemeData`.

## Buttons

`DaisyButton` owns its surface and interaction; pass its contents as `child`.
It reads colors, field size, radius and border width from the nearest
`DaisyThemeScope` and updates when that theme changes.

```dart
DaisyButton(
  theme: const DaisyButtonTheme(
    type: DaisyButtonType.outlined,
    style: DaisyButtonStyle.primary,
    size: DaisyButtonSize.md,
    modifier: DaisyButtonModifier.wide,
  ),
  onPressed: () {},
  child: const Text('Continue'),
)
```

`type` selects filled, outlined, dashed, soft, ghost or link appearance;
`style` selects a semantic color role. `size` selects the theme's field size:
24, 32, 40, 48 or 56 logical pixels with the built-in scale. This is a minimum
height for content-sized buttons and the side length of square/circle buttons,
subject to parent constraints. `wide` is the default modifier, `block` fills
bounded available width, and `none` adds no special shape. Circle buttons
clip their content. Use a suitably sized touch target and verify contrast for
custom themes and content.

The button is disabled when `enabled` is false or both callbacks are null.
Tap, long press, hover, keyboard activation and focus are handled by Flutter's
interaction primitives. Explicit styles or decorations in `child` can
intentionally override or cover the default foreground and surface.

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
    color: primary.base,
    borderRadius: BorderRadius.circular(theme.radius.fields.toDouble()),
    border: Border.all(
      color: theme.colors.neutral.base,
      width: theme.border,
    ),
  ),
  alignment: Alignment.center,
  child: Text('Continue', style: TextStyle(color: primary.content)),
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

The `base`, `content`, `base200` and `base300` getters return Flutter `Color`
values directly (the last two are nullable). Their underlying `baseOklch`,
`contentOklch`, `base200Oklch` and `base300Oklch` values preserve the original
constant OKLCH definitions. Construct an OKLCH color with
`RayOklch.fromComponents(lightness, chroma, hue)` and an optional fourth
opacity argument. `DaisyThemeColorPalette` provides named
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
      baseOklch: DaisyThemeColorPalette.indigo700,
      contentOklch: DaisyThemeColorPalette.indigo100,
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
controller.initialize();

// Place above the widgets that read context.daisyTheme.
DaisyThemeScope(controller: controller, child: const MyPreview());

controller.setTheme(DaisyThemes.dark);
```

Each consumer watches the nearest scope. Without a controller,
`DaisyThemeScope` observes the global service. A controller's `theme` property
also exposes a read-only `ValueListenable<DaisyThemeModel>`.

Create and initialize each independent controller once in its owner's
`initState`; initializing the global service does not initialize independent
controllers. Call `controller.dispose()` from that owner's `dispose` after its
scope is unmounted. Scopes borrow controllers and never dispose them. The
controller's subscription currently does not save or restore themes.

## Serialization

`toJson()` converts all nested theme tokens and colors into JSON maps:

```dart
final map = DaisyThemes.light.toJson();
final restored = DaisyThemeModel.fromJson(map);
```

Encoding a theme with `jsonEncode(theme)` is also supported.

The `example/` application demonstrates the global theme scope with a button
preview:

```sh
cd example
fvm flutter run -d chrome
```

## Validation

Run `fvm flutter test` from the package root and from `example/`. Run
`fvm flutter build web` from `example/` to compile the example for web.

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
fvm dart run build_runner build
```

Keep the generated files in version control.

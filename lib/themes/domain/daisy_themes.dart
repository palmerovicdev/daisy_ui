import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:daisy_ui/themes/domain/theme_border.dart';
import 'package:daisy_ui/themes/domain/theme_color.dart';
import 'package:daisy_ui/themes/domain/theme_radius.dart';
import 'package:daisy_ui/themes/domain/theme_size.dart';
import 'package:prism_flutter/prism_flutter.dart';

/// Prebuilt themes, ready to use.
///
/// All 35 built-in themes from https://daisyui.com/theme-generator/
/// (DaisyUI 5.7.47), with the same OKLCH colors, radius, size and border.
/// `danger` reuses `error`, which is the destructive role in DaisyUI.
/// The model does not represent color-scheme, depth or noise tokens.
abstract final class DaisyThemes {
  /// Light theme with white/zinc bases.
  ///
  /// Crisp white surfaces with indigo, pink and teal accents for a clean,
  /// colorful everyday interface.
  ///
  /// Border: thin (1 px). Radii: boxes medium (8 px),
  /// fields soft (4 px), selectors medium (8 px). Size base: 4 px for both groups.
  static const DaisyThemeModel light = DaisyThemeModel(
    id: 'light',
    name: 'Light',
    description:
        'Crisp white surfaces with indigo, pink and teal accents for a clean, '
        'colorful everyday interface.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: DaisyThemeColorPalette.zinc900,
        base200Oklch: DaisyThemeColorPalette.zinc50,
        base300Oklch: RayOklch.fromComponents(0.95, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.indigo700,
        contentOklch: DaisyThemeColorPalette.indigo100,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.pink500,
        contentOklch: DaisyThemeColorPalette.pink100,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.teal400,
        contentOklch: DaisyThemeColorPalette.teal900,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.zinc950,
        contentOklch: DaisyThemeColorPalette.zinc200,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky400,
        contentOklch: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.emerald400,
        contentOklch: DaisyThemeColorPalette.emerald900,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.rose400,
        contentOklch: DaisyThemeColorPalette.rose950,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.amber400,
        contentOklch: DaisyThemeColorPalette.amber900,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.rose400,
        contentOklch: DaisyThemeColorPalette.rose950,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.medium,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// Dark theme with custom dark-blue bases; accent roles reuse the
  /// Tailwind palette.
  ///
  /// Deep blue gray surfaces with vivid indigo, pink and teal accents for an
  /// expressive dark interface.
  ///
  /// Border: thin (1 px). Radii: boxes medium (8 px),
  /// fields soft (4 px), selectors medium (8 px). Size base: 4 px for both groups.
  static const DaisyThemeModel dark = DaisyThemeModel(
    id: 'dark',
    name: 'Dark',
    description:
        'Deep blue gray surfaces with vivid indigo, pink and teal accents for '
        'an expressive dark interface.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2533, 0.016, 252.42),
        contentOklch: RayOklch.fromComponents(
          0.97807,
          0.029,
          256.847,
        ),
        base200Oklch: RayOklch.fromComponents(0.2326, 0.014, 253.1),
        base300Oklch: RayOklch.fromComponents(0.2115, 0.012, 254.09),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.indigo500,
        contentOklch: DaisyThemeColorPalette.indigo50,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.pink500,
        contentOklch: DaisyThemeColorPalette.pink100,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.teal400,
        contentOklch: DaisyThemeColorPalette.teal900,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.zinc950,
        contentOklch: DaisyThemeColorPalette.zinc200,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky400,
        contentOklch: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.emerald400,
        contentOklch: DaisyThemeColorPalette.emerald900,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.rose400,
        contentOklch: DaisyThemeColorPalette.rose950,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.amber400,
        contentOklch: DaisyThemeColorPalette.amber900,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.rose400,
        contentOklch: DaisyThemeColorPalette.rose950,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.medium,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI cupcake theme.
  ///
  /// Cream surfaces, mint, pink and peach accents, and pill shaped controls
  /// create a soft, playful look.
  ///
  /// Border: thick (2 px). Radii: boxes large (16 px),
  /// fields full (32 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel cupcake = DaisyThemeModel(
    id: 'cupcake',
    name: 'Cupcake',
    description:
        'Cream surfaces, mint, pink and peach accents, and pill shaped '
        'controls create a soft, playful look.',
    border: DaisyThemeBorderWidthPreset.thick,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.97788, 0.004, 56.375),
        contentOklch: RayOklch.fromComponents(0.23574, 0.066, 313.189),
        base200Oklch: RayOklch.fromComponents(0.93982, 0.007, 61.449),
        base300Oklch: RayOklch.fromComponents(0.91586, 0.006, 53.44),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.teal300,
        contentOklch: DaisyThemeColorPalette.teal800,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.pink200,
        contentOklch: DaisyThemeColorPalette.pink800,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.orange200,
        contentOklch: DaisyThemeColorPalette.orange800,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.zinc800,
        contentOklch: DaisyThemeColorPalette.zinc200,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky500,
        contentOklch: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.emerald500,
        contentOklch: DaisyThemeColorPalette.emerald950,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.rose500,
        contentOklch: DaisyThemeColorPalette.rose950,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.yellow500,
        contentOklch: DaisyThemeColorPalette.yellow950,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.rose500,
        contentOklch: DaisyThemeColorPalette.rose950,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI bumblebee theme.
  ///
  /// Bright white surfaces meet honey yellow, warm orange and bold black accents
  /// for a lively, confident look.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel bumblebee = DaisyThemeModel(
    id: 'bumblebee',
    name: 'Bumblebee',
    description:
        'Bright white surfaces meet honey yellow, warm orange and bold black '
        'accents for a lively, confident look.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: DaisyThemeColorPalette.neutral900,
        base200Oklch: DaisyThemeColorPalette.neutral100,
        base300Oklch: DaisyThemeColorPalette.neutral200,
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.yellow400,
        contentOklch: DaisyThemeColorPalette.yellow900,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.orange400,
        contentOklch: DaisyThemeColorPalette.orange900,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.black,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.stone700,
        contentOklch: DaisyThemeColorPalette.stone200,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky400,
        contentOklch: DaisyThemeColorPalette.sky900,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.emerald400,
        contentOklch: DaisyThemeColorPalette.emerald900,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red400,
        contentOklch: DaisyThemeColorPalette.red900,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.amber400,
        contentOklch: DaisyThemeColorPalette.amber900,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red400,
        contentOklch: DaisyThemeColorPalette.red900,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI emerald theme.
  ///
  /// Fresh emerald green, cool blue and coral accents on white surfaces create a
  /// balanced, cheerful palette.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel emerald = DaisyThemeModel(
    id: 'emerald',
    name: 'Emerald',
    description:
        'Fresh emerald green, cool blue and coral accents on white surfaces '
        'create a balanced, cheerful palette.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: RayOklch.fromComponents(0.35519, 0.032, 262.988),
        base200Oklch: RayOklch.fromComponents(0.93, 0, 0),
        base300Oklch: RayOklch.fromComponents(0.86, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.76662, 0.135, 153.45),
        contentOklch: RayOklch.fromComponents(0.33387, 0.04, 162.24),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.61302, 0.202, 261.294),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.72772, 0.149, 33.2),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.35519, 0.032, 262.988),
        contentOklch: RayOklch.fromComponents(0.98462, 0.001, 247.838),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.648, 0.15, 160),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI corporate theme.
  ///
  /// White surfaces, restrained blue and teal accents, and subtle corners give
  /// professional interfaces a tidy look.
  ///
  /// Border: thin (1 px). Radii: boxes soft (4 px),
  /// fields soft (4 px), selectors soft (4 px). Size base: 4 px for both groups.
  static const DaisyThemeModel corporate = DaisyThemeModel(
    id: 'corporate',
    name: 'Corporate',
    description:
        'White surfaces, restrained blue and teal accents, and subtle corners '
        'give professional interfaces a tidy look.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: RayOklch.fromComponents(0.22389, 0.031, 278.072),
        base200Oklch: RayOklch.fromComponents(0.93, 0, 0),
        base300Oklch: RayOklch.fromComponents(0.86, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky600,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.slate500,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.teal600,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.black,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.cyan600,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.green600,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red400,
        contentOklch: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.yellow400,
        contentOklch: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red400,
        contentOklch: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.soft,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.soft,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI synthwave theme.
  ///
  /// Deep violet surfaces with neon pink, cyan and orange accents capture the
  /// energy of retro arcades.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel synthwave = DaisyThemeModel(
    id: 'synthwave',
    name: 'Synthwave',
    description:
        'Deep violet surfaces with neon pink, cyan and orange accents capture '
        'the energy of retro arcades.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.15, 0.09, 281.288),
        contentOklch: DaisyThemeColorPalette.indigo300,
        base200Oklch: RayOklch.fromComponents(0.2, 0.09, 281.288),
        base300Oklch: DaisyThemeColorPalette.indigo950,
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.pink400,
        contentOklch: DaisyThemeColorPalette.pink950,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky300,
        contentOklch: DaisyThemeColorPalette.sky950,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.orange400,
        contentOklch: DaisyThemeColorPalette.orange950,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.indigo700,
        contentOklch: DaisyThemeColorPalette.indigo200,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky400,
        contentOklch: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.teal400,
        contentOklch: DaisyThemeColorPalette.teal950,
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.737, 0.121, 32.639),
        contentOklch: RayOklch.fromComponents(0.23501, 0.096, 290.329),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.yellow300,
        contentOklch: DaisyThemeColorPalette.yellow900,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.737, 0.121, 32.639),
        contentOklch: RayOklch.fromComponents(0.23501, 0.096, 290.329),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI retro theme.
  ///
  /// Warm cream surfaces with faded red, mint and mustard accents evoke vintage
  /// posters and nostalgic print design.
  ///
  /// Border: thin (1 px). Radii: boxes medium (8 px),
  /// fields soft (4 px), selectors soft (4 px). Size base: 4 px for both groups.
  static const DaisyThemeModel retro = DaisyThemeModel(
    id: 'retro',
    name: 'Retro',
    description:
        'Warm cream surfaces with faded red, mint and mustard accents evoke '
        'vintage posters and nostalgic print design.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.91637, 0.034, 90.515),
        contentOklch: DaisyThemeColorPalette.amber900,
        base200Oklch: RayOklch.fromComponents(0.88272, 0.049, 91.774),
        base300Oklch: RayOklch.fromComponents(0.84133, 0.065, 90.856),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red300,
        contentOklch: DaisyThemeColorPalette.red900,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.green200,
        contentOklch: DaisyThemeColorPalette.green800,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.yellow600,
        contentOklch: DaisyThemeColorPalette.amber900,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.stone600,
        contentOklch: DaisyThemeColorPalette.stone300,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky600,
        contentOklch: DaisyThemeColorPalette.amber100,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.teal700,
        contentOklch: DaisyThemeColorPalette.amber100,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red400,
        contentOklch: DaisyThemeColorPalette.orange900,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.orange600,
        contentOklch: DaisyThemeColorPalette.amber100,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red400,
        contentOklch: DaisyThemeColorPalette.orange900,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.soft,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI cyberpunk theme.
  ///
  /// Vivid yellow surfaces, electric pink, cyan and purple accents, and sharp
  /// corners create a futuristic look.
  ///
  /// Border: thin (1 px). Radii: boxes sharp (0 px),
  /// fields sharp (0 px), selectors sharp (0 px). Size base: 4 px for both groups.
  static const DaisyThemeModel cyberpunk = DaisyThemeModel(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    description:
        'Vivid yellow surfaces, electric pink, cyan and purple accents, and '
        'sharp corners create a futuristic look.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.9451, 0.179, 104.32),
        contentOklch: DaisyThemeColorPalette.black,
        base200Oklch: RayOklch.fromComponents(0.9151, 0.179, 104.32),
        base300Oklch: RayOklch.fromComponents(0.8551, 0.179, 104.32),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7422, 0.209, 6.35),
        contentOklch: RayOklch.fromComponents(0.14844, 0.041, 6.35),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8333, 0.184, 204.72),
        contentOklch: RayOklch.fromComponents(0.16666, 0.036, 204.72),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7186, 0.217, 310.43),
        contentOklch: RayOklch.fromComponents(0.14372, 0.043, 310.43),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2304, 0.065, 269.31),
        contentOklch: RayOklch.fromComponents(0.9451, 0.179, 104.32),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.648, 0.15, 160),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.sharp,
      fields: DaisyThemeRadiusPreset.sharp,
      selectors: DaisyThemeRadiusPreset.sharp,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI valentine theme.
  ///
  /// Blush surfaces, rich pink, purple and sky blue accents, and rounded controls
  /// create a romantic, playful style.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields full (32 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel valentine = DaisyThemeModel(
    id: 'valentine',
    name: 'Valentine',
    description:
        'Blush surfaces, rich pink, purple and sky blue accents, and rounded '
        'controls create a romantic, playful style.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.pink50,
        contentOklch: DaisyThemeColorPalette.pink700,
        base200Oklch: DaisyThemeColorPalette.pink100,
        base300Oklch: DaisyThemeColorPalette.pink200,
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.pink500,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.purple500,
        contentOklch: DaisyThemeColorPalette.purple50,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky300,
        contentOklch: DaisyThemeColorPalette.sky900,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.pink900,
        contentOklch: DaisyThemeColorPalette.pink200,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.cyan300,
        contentOklch: DaisyThemeColorPalette.sky800,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.emerald300,
        contentOklch: DaisyThemeColorPalette.emerald800,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red500,
        contentOklch: DaisyThemeColorPalette.red50,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.orange400,
        contentOklch: DaisyThemeColorPalette.orange950,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red500,
        contentOklch: DaisyThemeColorPalette.red50,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI halloween theme.
  ///
  /// Charcoal surfaces with pumpkin orange, purple and vivid green accents give
  /// the interface a bold, spooky character.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel halloween = DaisyThemeModel(
    id: 'halloween',
    name: 'Halloween',
    description:
        'Charcoal surfaces with pumpkin orange, purple and vivid green '
        'accents give the interface a bold, spooky character.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.stone900,
        contentOklch: RayOklch.fromComponents(0.84955, 0, 0),
        base200Oklch: DaisyThemeColorPalette.stone950,
        base300Oklch: DaisyThemeColorPalette.black,
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7748, 0.204, 60.62),
        contentOklch: RayOklch.fromComponents(0.19693, 0.004, 196.779),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.4598, 0.248, 305.03),
        contentOklch: RayOklch.fromComponents(0.89196, 0.049, 305.03),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.648, 0.223, 136.073),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.24371, 0.046, 65.681),
        contentOklch: RayOklch.fromComponents(0.84874, 0.009, 65.681),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.54615, 0.215, 262.88),
        contentOklch: RayOklch.fromComponents(0.90923, 0.043, 262.88),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.62705, 0.169, 149.213),
        contentOklch: RayOklch.fromComponents(0.12541, 0.033, 149.213),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6572, 0.199, 27.33),
        contentOklch: RayOklch.fromComponents(0.13144, 0.039, 27.33),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.66584, 0.157, 58.318),
        contentOklch: RayOklch.fromComponents(0.13316, 0.031, 58.318),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6572, 0.199, 27.33),
        contentOklch: RayOklch.fromComponents(0.13144, 0.039, 27.33),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI garden theme.
  ///
  /// Pale gray surfaces with berry pink and muted green accents bring a floral,
  /// botanical character to the interface.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel garden = DaisyThemeModel(
    id: 'garden',
    name: 'Garden',
    description:
        'Pale gray surfaces with berry pink and muted green accents bring a '
        'floral, botanical character to the interface.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.92951, 0.002, 17.197),
        contentOklch: RayOklch.fromComponents(0.16961, 0.001, 17.32),
        base200Oklch: RayOklch.fromComponents(0.86445, 0.002, 17.197),
        base300Oklch: RayOklch.fromComponents(0.79938, 0.001, 17.197),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6245, 0.278, 3.836),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.48495, 0.11, 355.095),
        contentOklch: RayOklch.fromComponents(0.89699, 0.022, 355.095),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.56273, 0.054, 154.39),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.24155, 0.049, 89.07),
        contentOklch: RayOklch.fromComponents(0.92951, 0.002, 17.197),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.648, 0.15, 160),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI forest theme.
  ///
  /// Dark surfaces with leaf green, mint and teal accents create a rich palette
  /// inspired by woodland foliage.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields full (32 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel forest = DaisyThemeModel(
    id: 'forest',
    name: 'Forest',
    description:
        'Dark surfaces with leaf green, mint and teal accents create a rich '
        'palette inspired by woodland foliage.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2084, 0.008, 17.911),
        contentOklch: RayOklch.fromComponents(0.83768, 0.001, 17.911),
        base200Oklch: RayOklch.fromComponents(0.18522, 0.007, 17.911),
        base300Oklch: RayOklch.fromComponents(0.16203, 0.007, 17.911),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.68628, 0.185, 148.958),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.69776, 0.135, 168.327),
        contentOklch: RayOklch.fromComponents(0.13955, 0.027, 168.327),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.70628, 0.119, 185.713),
        contentOklch: RayOklch.fromComponents(0.14125, 0.023, 185.713),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.30698, 0.039, 171.364),
        contentOklch: RayOklch.fromComponents(0.86139, 0.007, 171.364),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.648, 0.15, 160),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI aqua theme.
  ///
  /// Deep blue surfaces with bright cyan, violet and pale yellow accents create a
  /// vibrant aquatic palette.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel aqua = DaisyThemeModel(
    id: 'aqua',
    name: 'Aqua',
    description:
        'Deep blue surfaces with bright cyan, violet and pale yellow accents '
        'create a vibrant aquatic palette.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.blue900,
        contentOklch: DaisyThemeColorPalette.sky200,
        base200Oklch: DaisyThemeColorPalette.blue950,
        base300Oklch: RayOklch.fromComponents(0.22, 0.091, 267.935),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.85661, 0.144, 198.645),
        contentOklch: RayOklch.fromComponents(0.40124, 0.068, 197.603),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.60682, 0.108, 309.782),
        contentOklch: DaisyThemeColorPalette.violet50,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.93426, 0.102, 94.555),
        contentOklch: RayOklch.fromComponents(0.18685, 0.02, 94.555),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.27, 0.146, 265.522),
        contentOklch: RayOklch.fromComponents(0.8, 0.146, 265.522),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.54615, 0.215, 262.88),
        contentOklch: RayOklch.fromComponents(0.90923, 0.043, 262.88),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.62705, 0.169, 149.213),
        contentOklch: RayOklch.fromComponents(0.12541, 0.033, 149.213),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7395, 0.19, 27.33),
        contentOklch: RayOklch.fromComponents(0.1479, 0.038, 27.33),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.66584, 0.157, 58.318),
        contentOklch: DaisyThemeColorPalette.amber950,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7395, 0.19, 27.33),
        contentOklch: RayOklch.fromComponents(0.1479, 0.038, 27.33),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI lofi theme.
  ///
  /// White and gray surfaces with near black accents and simple borders keep the
  /// interface quiet and minimal.
  ///
  /// Border: thin (1 px). Radii: boxes medium (8 px),
  /// fields soft (4 px), selectors full (32 px). Size base: 4 px for both groups.
  static const DaisyThemeModel lofi = DaisyThemeModel(
    id: 'lofi',
    name: 'Lofi',
    description:
        'White and gray surfaces with near black accents and simple borders '
        'keep the interface quiet and minimal.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: DaisyThemeColorPalette.black,
        base200Oklch: DaisyThemeColorPalette.neutral100,
        base300Oklch: RayOklch.fromComponents(0.94, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.15906, 0, 0),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.21455, 0.001, 17.278),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.26861, 0, 0),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.black,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7954, 0.103, 205.9),
        contentOklch: RayOklch.fromComponents(0.15908, 0.02, 205.9),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.9013, 0.153, 164.14),
        contentOklch: RayOklch.fromComponents(0.18026, 0.03, 164.14),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7866, 0.15, 28.47),
        contentOklch: RayOklch.fromComponents(0.15732, 0.03, 28.47),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8837, 0.135, 79.94),
        contentOklch: RayOklch.fromComponents(0.17674, 0.027, 79.94),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7866, 0.15, 28.47),
        contentOklch: RayOklch.fromComponents(0.15732, 0.03, 28.47),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI pastel theme.
  ///
  /// White surfaces with soft lavender, rose and mint accents and pill shaped
  /// controls create a gentle, airy style.
  ///
  /// Border: thick (2 px). Radii: boxes large (16 px),
  /// fields full (32 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel pastel = DaisyThemeModel(
    id: 'pastel',
    name: 'Pastel',
    description:
        'White surfaces with soft lavender, rose and mint accents and pill '
        'shaped controls create a gentle, airy style.',
    border: DaisyThemeBorderWidthPreset.thick,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: DaisyThemeColorPalette.neutral900,
        base200Oklch: RayOklch.fromComponents(0.98462, 0.001, 247.838),
        base300Oklch: RayOklch.fromComponents(0.92462, 0.001, 247.838),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.purple200,
        contentOklch: DaisyThemeColorPalette.purple700,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.rose200,
        contentOklch: DaisyThemeColorPalette.rose700,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.emerald200,
        contentOklch: DaisyThemeColorPalette.emerald700,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.slate500,
        contentOklch: DaisyThemeColorPalette.slate200,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.cyan300,
        contentOklch: DaisyThemeColorPalette.cyan700,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.green300,
        contentOklch: DaisyThemeColorPalette.green700,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red300,
        contentOklch: DaisyThemeColorPalette.red700,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.orange300,
        contentOklch: DaisyThemeColorPalette.orange700,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red300,
        contentOklch: DaisyThemeColorPalette.red700,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI fantasy theme.
  ///
  /// White surfaces with rich magenta, blue and warm orange accents give the
  /// interface a colorful storybook character.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel fantasy = DaisyThemeModel(
    id: 'fantasy',
    name: 'Fantasy',
    description:
        'White surfaces with rich magenta, blue and warm orange accents give '
        'the interface a colorful storybook character.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: RayOklch.fromComponents(0.27807, 0.029, 256.847),
        base200Oklch: RayOklch.fromComponents(0.93, 0, 0),
        base300Oklch: RayOklch.fromComponents(0.86, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.3745, 0.189, 325.02),
        contentOklch: RayOklch.fromComponents(0.8749, 0.037, 325.02),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.5392, 0.162, 241.36),
        contentOklch: RayOklch.fromComponents(0.90784, 0.032, 241.36),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7598, 0.204, 56.72),
        contentOklch: RayOklch.fromComponents(0.15196, 0.04, 56.72),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.27807, 0.029, 256.847),
        contentOklch: RayOklch.fromComponents(0.85561, 0.005, 256.847),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.648, 0.15, 160),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        contentOklch: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI wireframe theme.
  ///
  /// White surfaces, neutral gray accents and minimal rounding create a simple
  /// sketchlike style for prototypes.
  ///
  /// Border: thin (1 px). Radii: boxes soft (4 px),
  /// fields soft (4 px), selectors sharp (0 px). Size base: 4 px for both groups.
  static const DaisyThemeModel wireframe = DaisyThemeModel(
    id: 'wireframe',
    name: 'Wireframe',
    description:
        'White surfaces, neutral gray accents and minimal rounding create a '
        'simple sketchlike style for prototypes.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: DaisyThemeColorPalette.neutral900,
        base200Oklch: DaisyThemeColorPalette.neutral100,
        base300Oklch: RayOklch.fromComponents(0.94, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.neutral300,
        contentOklch: DaisyThemeColorPalette.neutral800,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.neutral300,
        contentOklch: DaisyThemeColorPalette.neutral800,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.neutral300,
        contentOklch: DaisyThemeColorPalette.neutral800,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.neutral300,
        contentOklch: DaisyThemeColorPalette.neutral800,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky800,
        contentOklch: DaisyThemeColorPalette.sky200,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.emerald800,
        contentOklch: DaisyThemeColorPalette.emerald200,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red800,
        contentOklch: DaisyThemeColorPalette.red200,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.amber800,
        contentOklch: DaisyThemeColorPalette.amber200,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red800,
        contentOklch: DaisyThemeColorPalette.red200,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.soft,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.sharp,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI black theme.
  ///
  /// Pure black surfaces with charcoal controls and gray foregrounds create a
  /// stark, monochrome dark interface.
  ///
  /// Border: thin (1 px). Radii: boxes sharp (0 px),
  /// fields sharp (0 px), selectors sharp (0 px). Size base: 4 px for both groups.
  static const DaisyThemeModel black = DaisyThemeModel(
    id: 'black',
    name: 'Black',
    description:
        'Pure black surfaces with charcoal controls and gray foregrounds '
        'create a stark, monochrome dark interface.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.black,
        contentOklch: RayOklch.fromComponents(0.87609, 0, 0),
        base200Oklch: RayOklch.fromComponents(0.19, 0, 0),
        base300Oklch: RayOklch.fromComponents(0.22, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.35, 0, 0),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.35, 0, 0),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.35, 0, 0),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.35, 0, 0),
        contentOklch: DaisyThemeColorPalette.white,
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.45201, 0.313, 264.052),
        contentOklch: RayOklch.fromComponents(0.8904, 0.062, 264.052),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.51975, 0.176, 142.495),
        contentOklch: RayOklch.fromComponents(0.90395, 0.035, 142.495),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.62795, 0.257, 29.233),
        contentOklch: RayOklch.fromComponents(0.12559, 0.051, 29.233),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.96798, 0.211, 109.769),
        contentOklch: RayOklch.fromComponents(0.19359, 0.042, 109.769),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.62795, 0.257, 29.233),
        contentOklch: RayOklch.fromComponents(0.12559, 0.051, 29.233),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.sharp,
      fields: DaisyThemeRadiusPreset.sharp,
      selectors: DaisyThemeRadiusPreset.sharp,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI luxury theme.
  ///
  /// Near black surfaces with white, midnight blue and plum accents create a
  /// refined, dramatic atmosphere.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel luxury = DaisyThemeModel(
    id: 'luxury',
    name: 'Luxury',
    description:
        'Near black surfaces with white, midnight blue and plum accents '
        'create a refined, dramatic atmosphere.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.14076, 0.004, 285.822),
        contentOklch: RayOklch.fromComponents(0.75687, 0.123, 76.89),
        base200Oklch: RayOklch.fromComponents(0.20219, 0.004, 308.229),
        base300Oklch: RayOklch.fromComponents(0.23219, 0.004, 308.229),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: DaisyThemeColorPalette.neutral900,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.27581, 0.064, 261.069),
        contentOklch: RayOklch.fromComponents(0.85516, 0.012, 261.069),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.36674, 0.051, 338.825),
        contentOklch: RayOklch.fromComponents(0.87334, 0.01, 338.825),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2427, 0.057, 59.825),
        contentOklch: RayOklch.fromComponents(0.93203, 0.089, 90.861),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.79061, 0.121, 237.133),
        contentOklch: RayOklch.fromComponents(0.15812, 0.024, 237.133),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.78119, 0.192, 132.154),
        contentOklch: RayOklch.fromComponents(0.15623, 0.038, 132.154),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.71753, 0.176, 22.568),
        contentOklch: RayOklch.fromComponents(0.1435, 0.035, 22.568),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.86127, 0.136, 102.891),
        contentOklch: RayOklch.fromComponents(0.17225, 0.027, 102.891),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.71753, 0.176, 22.568),
        contentOklch: RayOklch.fromComponents(0.1435, 0.035, 22.568),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI dracula theme.
  ///
  /// Deep violet gray surfaces with bright pink, lavender and warm orange accents
  /// create a colorful gothic style.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel dracula = DaisyThemeModel(
    id: 'dracula',
    name: 'Dracula',
    description:
        'Deep violet gray surfaces with bright pink, lavender and warm orange '
        'accents create a colorful gothic style.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.28822, 0.022, 277.508),
        contentOklch: RayOklch.fromComponents(0.97747, 0.007, 106.545),
        base200Oklch: RayOklch.fromComponents(0.26805, 0.02, 277.508),
        base300Oklch: RayOklch.fromComponents(0.24787, 0.019, 277.508),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.75461, 0.183, 346.812),
        contentOklch: RayOklch.fromComponents(0.15092, 0.036, 346.812),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.74202, 0.148, 301.883),
        contentOklch: RayOklch.fromComponents(0.1484, 0.029, 301.883),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.83392, 0.124, 66.558),
        contentOklch: RayOklch.fromComponents(0.16678, 0.024, 66.558),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.39445, 0.032, 275.524),
        contentOklch: RayOklch.fromComponents(0.87889, 0.006, 275.524),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.88263, 0.093, 212.846),
        contentOklch: RayOklch.fromComponents(0.17652, 0.018, 212.846),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.87099, 0.219, 148.024),
        contentOklch: RayOklch.fromComponents(0.17419, 0.043, 148.024),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6822, 0.206, 24.43),
        contentOklch: RayOklch.fromComponents(0.13644, 0.041, 24.43),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.95533, 0.134, 112.757),
        contentOklch: RayOklch.fromComponents(0.19106, 0.026, 112.757),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6822, 0.206, 24.43),
        contentOklch: RayOklch.fromComponents(0.13644, 0.041, 24.43),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI cmyk theme.
  ///
  /// White surfaces with saturated cyan, magenta, yellow and black accents
  /// celebrate the bold palette of print design.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel cmyk = DaisyThemeModel(
    id: 'cmyk',
    name: 'Cmyk',
    description:
        'White surfaces with saturated cyan, magenta, yellow and black '
        'accents celebrate the bold palette of print design.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: DaisyThemeColorPalette.neutral900,
        base200Oklch: RayOklch.fromComponents(0.95, 0, 0),
        base300Oklch: RayOklch.fromComponents(0.9, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.71772, 0.133, 239.443),
        contentOklch: RayOklch.fromComponents(0.14354, 0.026, 239.443),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.64476, 0.202, 359.339),
        contentOklch: RayOklch.fromComponents(0.12895, 0.04, 359.339),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.94228, 0.189, 105.306),
        contentOklch: RayOklch.fromComponents(0.18845, 0.037, 105.306),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.21778, 0, 0),
        contentOklch: RayOklch.fromComponents(0.84355, 0, 0),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.68475, 0.094, 217.284),
        contentOklch: RayOklch.fromComponents(0.13695, 0.018, 217.284),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.46949, 0.162, 321.406),
        contentOklch: RayOklch.fromComponents(0.89389, 0.032, 321.406),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.62013, 0.208, 28.717),
        contentOklch: RayOklch.fromComponents(0.12402, 0.041, 28.717),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.71236, 0.159, 52.023),
        contentOklch: RayOklch.fromComponents(0.14247, 0.031, 52.023),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.62013, 0.208, 28.717),
        contentOklch: RayOklch.fromComponents(0.12402, 0.041, 28.717),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI autumn theme.
  ///
  /// Pale neutral surfaces with burgundy, rust and warm amber accents evoke the
  /// earthy colors of autumn.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel autumn = DaisyThemeModel(
    id: 'autumn',
    name: 'Autumn',
    description:
        'Pale neutral surfaces with burgundy, rust and warm amber accents '
        'evoke the earthy colors of autumn.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.95814, 0, 0),
        contentOklch: RayOklch.fromComponents(0.19162, 0, 0),
        base200Oklch: RayOklch.fromComponents(0.89107, 0, 0),
        base300Oklch: RayOklch.fromComponents(0.824, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.40723, 0.161, 17.53),
        contentOklch: RayOklch.fromComponents(0.88144, 0.032, 17.53),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.61676, 0.169, 23.865),
        contentOklch: RayOklch.fromComponents(0.12335, 0.033, 23.865),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.73425, 0.094, 60.729),
        contentOklch: RayOklch.fromComponents(0.14685, 0.018, 60.729),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.54367, 0.037, 51.902),
        contentOklch: RayOklch.fromComponents(0.90873, 0.007, 51.902),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.69224, 0.097, 207.284),
        contentOklch: RayOklch.fromComponents(0.13844, 0.019, 207.284),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.60995, 0.08, 174.616),
        contentOklch: RayOklch.fromComponents(0.12199, 0.016, 174.616),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.5307, 0.241, 24.16),
        contentOklch: RayOklch.fromComponents(0.90614, 0.048, 24.16),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.70081, 0.164, 56.844),
        contentOklch: RayOklch.fromComponents(0.14016, 0.032, 56.844),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.5307, 0.241, 24.16),
        contentOklch: RayOklch.fromComponents(0.90614, 0.048, 24.16),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI business theme.
  ///
  /// Charcoal surfaces, muted blue and slate accents, and restrained orange
  /// highlights give dashboards a composed look.
  ///
  /// Border: thin (1 px). Radii: boxes soft (4 px),
  /// fields soft (4 px), selectors sharp (0 px). Size base: 4 px for both groups.
  static const DaisyThemeModel business = DaisyThemeModel(
    id: 'business',
    name: 'Business',
    description:
        'Charcoal surfaces, muted blue and slate accents, and restrained '
        'orange highlights give dashboards a composed look.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.24353, 0, 0),
        contentOklch: RayOklch.fromComponents(0.8487, 0, 0),
        base200Oklch: RayOklch.fromComponents(0.22648, 0, 0),
        base300Oklch: RayOklch.fromComponents(0.20944, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.41703, 0.099, 251.473),
        contentOklch: RayOklch.fromComponents(0.8834, 0.019, 251.473),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.64092, 0.027, 229.389),
        contentOklch: RayOklch.fromComponents(0.12818, 0.005, 229.389),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.67271, 0.167, 35.791),
        contentOklch: RayOklch.fromComponents(0.13454, 0.033, 35.791),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.27441, 0.013, 253.041),
        contentOklch: RayOklch.fromComponents(0.85488, 0.002, 253.041),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.62616, 0.143, 240.033),
        contentOklch: RayOklch.fromComponents(0.12523, 0.028, 240.033),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.70226, 0.094, 156.596),
        contentOklch: RayOklch.fromComponents(0.14045, 0.018, 156.596),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.5161, 0.146, 29.674),
        contentOklch: RayOklch.fromComponents(0.90322, 0.029, 29.674),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.77482, 0.115, 81.519),
        contentOklch: RayOklch.fromComponents(0.15496, 0.023, 81.519),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.5161, 0.146, 29.674),
        contentOklch: RayOklch.fromComponents(0.90322, 0.029, 29.674),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.soft,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.sharp,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI acid theme.
  ///
  /// Light surfaces with intense fuchsia, orange and lime accents create a bold,
  /// psychedelic palette.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields large (16 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel acid = DaisyThemeModel(
    id: 'acid',
    name: 'Acid',
    description:
        'Light surfaces with intense fuchsia, orange and lime accents create '
        'a bold, psychedelic palette.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.zinc50,
        contentOklch: DaisyThemeColorPalette.black,
        base200Oklch: RayOklch.fromComponents(0.95, 0, 0),
        base300Oklch: RayOklch.fromComponents(0.91, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.719, 0.357, 330.759),
        contentOklch: RayOklch.fromComponents(0.1438, 0.071, 330.759),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7337, 0.224, 48.25),
        contentOklch: RayOklch.fromComponents(0.14674, 0.044, 48.25),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.9278, 0.264, 122.962),
        contentOklch: RayOklch.fromComponents(0.18556, 0.052, 122.962),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2131, 0.128, 278.68),
        contentOklch: RayOklch.fromComponents(0.84262, 0.025, 278.68),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6072, 0.227, 252.05),
        contentOklch: RayOklch.fromComponents(0.12144, 0.045, 252.05),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8572, 0.266, 158.53),
        contentOklch: RayOklch.fromComponents(0.17144, 0.053, 158.53),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6484, 0.293, 29.349),
        contentOklch: RayOklch.fromComponents(0.12968, 0.058, 29.349),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.9101, 0.212, 100.5),
        contentOklch: RayOklch.fromComponents(0.18202, 0.042, 100.5),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6484, 0.293, 29.349),
        contentOklch: RayOklch.fromComponents(0.12968, 0.058, 29.349),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.large,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI lemonade theme.
  ///
  /// Pale citrus surfaces with leafy green, yellow green and lemon accents create
  /// a fresh, sunny palette.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel lemonade = DaisyThemeModel(
    id: 'lemonade',
    name: 'Lemonade',
    description:
        'Pale citrus surfaces with leafy green, yellow green and lemon '
        'accents create a fresh, sunny palette.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.9871, 0.02, 123.72),
        contentOklch: RayOklch.fromComponents(0.19742, 0.004, 123.72),
        base200Oklch: RayOklch.fromComponents(0.918, 0.018, 123.72),
        base300Oklch: RayOklch.fromComponents(0.8489, 0.017, 123.72),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.5892, 0.199, 134.6),
        contentOklch: RayOklch.fromComponents(0.11784, 0.039, 134.6),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7775, 0.196, 111.09),
        contentOklch: RayOklch.fromComponents(0.1555, 0.039, 111.09),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8539, 0.201, 100.73),
        contentOklch: RayOklch.fromComponents(0.17078, 0.04, 100.73),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.3098, 0.075, 108.6),
        contentOklch: RayOklch.fromComponents(0.86196, 0.015, 108.6),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8619, 0.047, 224.14),
        contentOklch: RayOklch.fromComponents(0.17238, 0.009, 224.14),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8619, 0.047, 157.85),
        contentOklch: RayOklch.fromComponents(0.17238, 0.009, 157.85),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8619, 0.047, 25.85),
        contentOklch: RayOklch.fromComponents(0.17238, 0.009, 25.85),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8619, 0.047, 102.15),
        contentOklch: RayOklch.fromComponents(0.17238, 0.009, 102.15),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8619, 0.047, 25.85),
        contentOklch: RayOklch.fromComponents(0.17238, 0.009, 25.85),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI night theme.
  ///
  /// Deep navy surfaces with bright sky blue, periwinkle and pink accents create
  /// a crisp, colorful night palette.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel night = DaisyThemeModel(
    id: 'night',
    name: 'Night',
    description:
        'Deep navy surfaces with bright sky blue, periwinkle and pink accents '
        'create a crisp, colorful night palette.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.20768, 0.039, 265.754),
        contentOklch: RayOklch.fromComponents(0.84153, 0.007, 265.754),
        base200Oklch: RayOklch.fromComponents(0.19314, 0.037, 265.754),
        base300Oklch: RayOklch.fromComponents(0.1786, 0.034, 265.754),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.75351, 0.138, 232.661),
        contentOklch: RayOklch.fromComponents(0.1507, 0.027, 232.661),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.68011, 0.158, 276.934),
        contentOklch: RayOklch.fromComponents(0.13602, 0.031, 276.934),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7236, 0.176, 350.048),
        contentOklch: RayOklch.fromComponents(0.14472, 0.035, 350.048),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.27949, 0.036, 260.03),
        contentOklch: RayOklch.fromComponents(0.85589, 0.007, 260.03),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.68455, 0.148, 237.251),
        contentOklch: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.78452, 0.132, 181.911),
        contentOklch: RayOklch.fromComponents(0.1569, 0.026, 181.911),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.71785, 0.17, 13.118),
        contentOklch: RayOklch.fromComponents(0.14357, 0.034, 13.118),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.83242, 0.139, 82.95),
        contentOklch: RayOklch.fromComponents(0.16648, 0.027, 82.95),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.71785, 0.17, 13.118),
        contentOklch: RayOklch.fromComponents(0.14357, 0.034, 13.118),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI coffee theme.
  ///
  /// Dark plum brown surfaces with caramel, muted teal and blue accents create a
  /// warm, intimate cafe atmosphere.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel coffee = DaisyThemeModel(
    id: 'coffee',
    name: 'Coffee',
    description:
        'Dark plum brown surfaces with caramel, muted teal and blue accents '
        'create a warm, intimate cafe atmosphere.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.24, 0.023, 329.708),
        contentOklch: RayOklch.fromComponents(0.72354, 0.092, 79.129),
        base200Oklch: RayOklch.fromComponents(0.21, 0.021, 329.708),
        base300Oklch: RayOklch.fromComponents(0.16, 0.019, 329.708),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.71996, 0.123, 62.756),
        contentOklch: RayOklch.fromComponents(0.14399, 0.024, 62.756),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.34465, 0.029, 199.194),
        contentOklch: RayOklch.fromComponents(0.86893, 0.005, 199.194),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.42621, 0.074, 224.389),
        contentOklch: RayOklch.fromComponents(0.88524, 0.014, 224.389),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.1651, 0.015, 326.261),
        contentOklch: RayOklch.fromComponents(0.83302, 0.003, 326.261),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.7949, 0.063, 184.558),
        contentOklch: RayOklch.fromComponents(0.15898, 0.012, 184.558),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.74722, 0.072, 131.116),
        contentOklch: RayOklch.fromComponents(0.14944, 0.014, 131.116),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.77318, 0.128, 31.871),
        contentOklch: RayOklch.fromComponents(0.15463, 0.025, 31.871),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8815, 0.14, 87.722),
        contentOklch: RayOklch.fromComponents(0.1763, 0.028, 87.722),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.77318, 0.128, 31.871),
        contentOklch: RayOklch.fromComponents(0.15463, 0.025, 31.871),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI winter theme.
  ///
  /// Crisp white surfaces with icy blue, deep indigo and magenta accents create a
  /// bright, cool seasonal palette.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel winter = DaisyThemeModel(
    id: 'winter',
    name: 'Winter',
    description:
        'Crisp white surfaces with icy blue, deep indigo and magenta accents '
        'create a bright, cool seasonal palette.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.white,
        contentOklch: RayOklch.fromComponents(0.41886, 0.053, 255.824),
        base200Oklch: RayOklch.fromComponents(0.97466, 0.011, 259.822),
        base300Oklch: RayOklch.fromComponents(0.93268, 0.016, 262.751),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.5686, 0.255, 257.57),
        contentOklch: RayOklch.fromComponents(0.91372, 0.051, 257.57),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.42551, 0.161, 282.339),
        contentOklch: RayOklch.fromComponents(0.8851, 0.032, 282.339),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.59939, 0.191, 335.171),
        contentOklch: RayOklch.fromComponents(0.11988, 0.038, 335.171),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.19616, 0.063, 257.651),
        contentOklch: RayOklch.fromComponents(0.83923, 0.012, 257.651),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.88127, 0.085, 214.515),
        contentOklch: RayOklch.fromComponents(0.17625, 0.017, 214.515),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.80494, 0.077, 197.823),
        contentOklch: RayOklch.fromComponents(0.16098, 0.015, 197.823),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.73092, 0.11, 20.076),
        contentOklch: RayOklch.fromComponents(0.14618, 0.022, 20.076),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.89172, 0.045, 71.47),
        contentOklch: RayOklch.fromComponents(0.17834, 0.009, 71.47),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.73092, 0.11, 20.076),
        contentOklch: RayOklch.fromComponents(0.14618, 0.022, 20.076),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI dim theme.
  ///
  /// Soft blue gray surfaces with lime, coral and lavender accents create a
  /// subdued alternative to a black background.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel dim = DaisyThemeModel(
    id: 'dim',
    name: 'Dim',
    description:
        'Soft blue gray surfaces with lime, coral and lavender accents create '
        'a subdued alternative to a black background.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.30857, 0.023, 264.149),
        contentOklch: RayOklch.fromComponents(0.82901, 0.031, 222.959),
        base200Oklch: RayOklch.fromComponents(0.28036, 0.019, 264.182),
        base300Oklch: RayOklch.fromComponents(0.26346, 0.018, 262.177),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.86133, 0.141, 139.549),
        contentOklch: RayOklch.fromComponents(0.17226, 0.028, 139.549),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.73375, 0.165, 35.353),
        contentOklch: RayOklch.fromComponents(0.14675, 0.033, 35.353),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.74229, 0.133, 311.379),
        contentOklch: RayOklch.fromComponents(0.14845, 0.026, 311.379),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.24731, 0.02, 264.094),
        contentOklch: RayOklch.fromComponents(0.82901, 0.031, 222.959),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.86078, 0.142, 206.182),
        contentOklch: RayOklch.fromComponents(0.17215, 0.028, 206.182),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.86171, 0.142, 166.534),
        contentOklch: RayOklch.fromComponents(0.17234, 0.028, 166.534),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.82418, 0.099, 33.756),
        contentOklch: RayOklch.fromComponents(0.16483, 0.019, 33.756),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.86163, 0.142, 94.818),
        contentOklch: RayOklch.fromComponents(0.17232, 0.028, 94.818),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.82418, 0.099, 33.756),
        contentOklch: RayOklch.fromComponents(0.16483, 0.019, 33.756),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI nord theme.
  ///
  /// Pale blue gray surfaces with muted steel blue and icy cyan accents create a
  /// calm, Nordic inspired palette.
  ///
  /// Border: thin (1 px). Radii: boxes medium (8 px),
  /// fields soft (4 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel nord = DaisyThemeModel(
    id: 'nord',
    name: 'Nord',
    description:
        'Pale blue gray surfaces with muted steel blue and icy cyan accents '
        'create a calm, Nordic inspired palette.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.95127, 0.007, 260.731),
        contentOklch: RayOklch.fromComponents(0.32437, 0.022, 264.182),
        base200Oklch: RayOklch.fromComponents(0.93299, 0.01, 261.788),
        base300Oklch: RayOklch.fromComponents(0.89925, 0.016, 262.749),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.59435, 0.077, 254.027),
        contentOklch: RayOklch.fromComponents(0.11887, 0.015, 254.027),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.69651, 0.059, 248.687),
        contentOklch: RayOklch.fromComponents(0.1393, 0.011, 248.687),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.77464, 0.062, 217.469),
        contentOklch: RayOklch.fromComponents(0.15492, 0.012, 217.469),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.45229, 0.035, 264.131),
        contentOklch: RayOklch.fromComponents(0.89925, 0.016, 262.749),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.69207, 0.062, 332.664),
        contentOklch: RayOklch.fromComponents(0.13841, 0.012, 332.664),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.76827, 0.074, 131.063),
        contentOklch: RayOklch.fromComponents(0.15365, 0.014, 131.063),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6061, 0.12, 15.341),
        contentOklch: RayOklch.fromComponents(0.12122, 0.024, 15.341),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.85486, 0.089, 84.093),
        contentOklch: RayOklch.fromComponents(0.17097, 0.017, 84.093),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.6061, 0.12, 15.341),
        contentOklch: RayOklch.fromComponents(0.12122, 0.024, 15.341),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI sunset theme.
  ///
  /// Dark blue gray surfaces with coral, rose and violet accents reflect the rich
  /// colors of an evening sky.
  ///
  /// Border: thin (1 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors large (16 px). Size base: 4 px for both groups.
  static const DaisyThemeModel sunset = DaisyThemeModel(
    id: 'sunset',
    name: 'Sunset',
    description:
        'Dark blue gray surfaces with coral, rose and violet accents reflect '
        'the rich colors of an evening sky.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.22, 0.019, 237.69),
        contentOklch: RayOklch.fromComponents(0.77383, 0.043, 245.096),
        base200Oklch: RayOklch.fromComponents(0.2, 0.019, 237.69),
        base300Oklch: RayOklch.fromComponents(0.18, 0.019, 237.69),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.74703, 0.158, 39.947),
        contentOklch: RayOklch.fromComponents(0.1494, 0.031, 39.947),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.72537, 0.177, 2.72),
        contentOklch: RayOklch.fromComponents(0.14507, 0.035, 2.72),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.71294, 0.166, 299.844),
        contentOklch: RayOklch.fromComponents(0.14258, 0.033, 299.844),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.26, 0.019, 237.69),
        contentOklch: RayOklch.fromComponents(0.7, 0.019, 237.69),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.85559, 0.085, 206.015),
        contentOklch: RayOklch.fromComponents(0.17111, 0.017, 206.015),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8556, 0.085, 144.778),
        contentOklch: RayOklch.fromComponents(0.17112, 0.017, 144.778),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.85511, 0.078, 16.886),
        contentOklch: RayOklch.fromComponents(0.17102, 0.015, 16.886),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.85569, 0.084, 74.427),
        contentOklch: RayOklch.fromComponents(0.17113, 0.016, 74.427),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.85511, 0.078, 16.886),
        contentOklch: RayOklch.fromComponents(0.17102, 0.015, 16.886),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI caramellatte theme.
  ///
  /// Warm cream surfaces with black, espresso and caramel accents and rounded
  /// corners evoke a cozy coffee shop.
  ///
  /// Border: thick (2 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors full (32 px). Size base: 4 px for both groups.
  static const DaisyThemeModel caramellatte = DaisyThemeModel(
    id: 'caramellatte',
    name: 'Caramellatte',
    description:
        'Warm cream surfaces with black, espresso and caramel accents and '
        'rounded corners evoke a cozy coffee shop.',
    border: DaisyThemeBorderWidthPreset.thick,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.orange50,
        contentOklch: DaisyThemeColorPalette.orange900,
        base200Oklch: DaisyThemeColorPalette.orange100,
        base300Oklch: DaisyThemeColorPalette.orange200,
      ),
      primary: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.black,
        contentOklch: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2245, 0.075, 37.85),
        contentOklch: DaisyThemeColorPalette.orange200,
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.4644, 0.111, 37.85),
        contentOklch: DaisyThemeColorPalette.orange200,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.orange700,
        contentOklch: DaisyThemeColorPalette.orange50,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.blue800,
        contentOklch: DaisyThemeColorPalette.orange200,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.emerald800,
        contentOklch: DaisyThemeColorPalette.orange200,
      ),
      error: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red400,
        contentOklch: DaisyThemeColorPalette.red900,
      ),
      warning: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.amber400,
        contentOklch: DaisyThemeColorPalette.amber900,
      ),
      danger: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.red400,
        contentOklch: DaisyThemeColorPalette.red900,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI abyss theme.
  ///
  /// Deep ocean teal surfaces with electric lime, pale lavender and gray accents
  /// create an unusual, dramatic dark palette.
  ///
  /// Border: thin (1 px). Radii: boxes medium (8 px),
  /// fields soft (4 px), selectors full (32 px). Size base: 4 px for both groups.
  static const DaisyThemeModel abyss = DaisyThemeModel(
    id: 'abyss',
    name: 'Abyss',
    description:
        'Deep ocean teal surfaces with electric lime, pale lavender and gray '
        'accents create an unusual, dramatic dark palette.',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2, 0.08, 209),
        contentOklch: DaisyThemeColorPalette.orange200,
        base200Oklch: RayOklch.fromComponents(0.15, 0.08, 209),
        base300Oklch: RayOklch.fromComponents(0.1, 0.08, 209),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.92, 0.2653, 125),
        contentOklch: RayOklch.fromComponents(0.5, 0.2653, 125),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8327, 0.0764, 298.3),
        contentOklch: RayOklch.fromComponents(0.4327, 0.0764, 298.3),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.neutral600,
        contentOklch: DaisyThemeColorPalette.zinc50,
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.3, 0.08, 209),
        contentOklch: DaisyThemeColorPalette.orange200,
      ),
      info: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.sky400,
        contentOklch: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.green400,
        contentOklch: DaisyThemeColorPalette.green950,
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.65, 0.1985, 24.22),
        contentOklch: RayOklch.fromComponents(0.27, 0.1985, 24.22),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.848, 0.1962, 84.62),
        contentOklch: RayOklch.fromComponents(0.448, 0.1962, 84.62),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.65, 0.1985, 24.22),
        contentOklch: RayOklch.fromComponents(0.27, 0.1985, 24.22),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );

  /// DaisyUI silk theme.
  ///
  /// Warm ivory surfaces with subtle violet charcoal accents and rounded corners
  /// create a soft, understated elegance.
  ///
  /// Border: thick (2 px). Radii: boxes large (16 px),
  /// fields medium (8 px), selectors full (32 px). Size base: 4 px for both groups.
  static const DaisyThemeModel silk = DaisyThemeModel(
    id: 'silk',
    name: 'Silk',
    description:
        'Warm ivory surfaces with subtle violet charcoal accents and rounded '
        'corners create a soft, understated elegance.',
    border: DaisyThemeBorderWidthPreset.thick,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.97, 0.0035, 67.78),
        contentOklch: RayOklch.fromComponents(0.4, 0.0081, 61.42),
        base200Oklch: RayOklch.fromComponents(0.95, 0.0081, 61.42),
        base300Oklch: RayOklch.fromComponents(0.9, 0.0081, 61.42),
      ),
      primary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2327, 0.0249, 284.3),
        contentOklch: RayOklch.fromComponents(0.9422, 0.2505, 117.44),
      ),
      secondary: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2327, 0.0249, 284.3),
        contentOklch: RayOklch.fromComponents(0.7392, 0.2135, 50.94),
      ),
      accent: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.2327, 0.0249, 284.3),
        contentOklch: RayOklch.fromComponents(0.8892, 0.2061, 189.9),
      ),
      neutral: DaisyThemeColorPair(
        baseOklch: DaisyThemeColorPalette.neutral900,
        contentOklch: RayOklch.fromComponents(0.8, 0.0081, 61.42),
      ),
      info: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8039, 0.1148, 241.68),
        contentOklch: RayOklch.fromComponents(0.3039, 0.1148, 241.68),
      ),
      success: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8392, 0.0901, 136.87),
        contentOklch: RayOklch.fromComponents(0.2392, 0.0901, 136.87),
      ),
      error: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.751, 0.1814, 22.37),
        contentOklch: RayOklch.fromComponents(0.351, 0.1814, 22.37),
      ),
      warning: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.8392, 0.1085, 80),
        contentOklch: RayOklch.fromComponents(0.4392, 0.1085, 80),
      ),
      danger: DaisyThemeColorPair(
        baseOklch: RayOklch.fromComponents(0.751, 0.1814, 22.37),
        contentOklch: RayOklch.fromComponents(0.351, 0.1814, 22.37),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizePresets(base: 4),
      selectors: DaisyThemeSizePresets(base: 4),
    ),
  );
}

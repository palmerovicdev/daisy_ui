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
  static const DaisyThemeModel light = DaisyThemeModel(
    id: 'light',
    name: 'Light',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: DaisyThemeColorPalette.zinc900,
        base200: DaisyThemeColorPalette.zinc50,
        base300: RayOklch.fromComponents(0.95, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.indigo700,
        content: DaisyThemeColorPalette.indigo100,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink500,
        content: DaisyThemeColorPalette.pink100,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.teal400,
        content: DaisyThemeColorPalette.teal900,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.zinc950,
        content: DaisyThemeColorPalette.zinc200,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky400,
        content: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald400,
        content: DaisyThemeColorPalette.emerald900,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose400,
        content: DaisyThemeColorPalette.rose950,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.amber400,
        content: DaisyThemeColorPalette.amber900,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose400,
        content: DaisyThemeColorPalette.rose950,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.medium,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// Dark theme with custom dark-blue bases; accent roles reuse the
  /// Tailwind palette.
  static const DaisyThemeModel dark = DaisyThemeModel(
    id: 'dark',
    name: 'Dark',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2533, 0.016, 252.42),
        content: RayOklch.fromComponents(
          0.97807,
          0.029,
          256.847,
        ),
        base200: RayOklch.fromComponents(0.2326, 0.014, 253.1),
        base300: RayOklch.fromComponents(0.2115, 0.012, 254.09),
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.indigo500,
        content: DaisyThemeColorPalette.indigo50,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink500,
        content: DaisyThemeColorPalette.pink100,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.teal400,
        content: DaisyThemeColorPalette.teal900,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.zinc950,
        content: DaisyThemeColorPalette.zinc200,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky400,
        content: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald400,
        content: DaisyThemeColorPalette.emerald900,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose400,
        content: DaisyThemeColorPalette.rose950,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.amber400,
        content: DaisyThemeColorPalette.amber900,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose400,
        content: DaisyThemeColorPalette.rose950,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.medium,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI cupcake theme.
  static const DaisyThemeModel cupcake = DaisyThemeModel(
    id: 'cupcake',
    name: 'Cupcake',
    description: '',
    border: DaisyThemeBorderWidthPreset.thick,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.97788, 0.004, 56.375),
        content: RayOklch.fromComponents(0.23574, 0.066, 313.189),
        base200: RayOklch.fromComponents(0.93982, 0.007, 61.449),
        base300: RayOklch.fromComponents(0.91586, 0.006, 53.44),
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.teal300,
        content: DaisyThemeColorPalette.teal800,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink200,
        content: DaisyThemeColorPalette.pink800,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.orange200,
        content: DaisyThemeColorPalette.orange800,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.zinc800,
        content: DaisyThemeColorPalette.zinc200,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky500,
        content: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald500,
        content: DaisyThemeColorPalette.emerald950,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose500,
        content: DaisyThemeColorPalette.rose950,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.yellow500,
        content: DaisyThemeColorPalette.yellow950,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose500,
        content: DaisyThemeColorPalette.rose950,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI bumblebee theme.
  static const DaisyThemeModel bumblebee = DaisyThemeModel(
    id: 'bumblebee',
    name: 'Bumblebee',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: DaisyThemeColorPalette.neutral900,
        base200: DaisyThemeColorPalette.neutral100,
        base300: DaisyThemeColorPalette.neutral200,
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.yellow400,
        content: DaisyThemeColorPalette.yellow900,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.orange400,
        content: DaisyThemeColorPalette.orange900,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.black,
        content: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.stone700,
        content: DaisyThemeColorPalette.stone200,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky400,
        content: DaisyThemeColorPalette.sky900,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald400,
        content: DaisyThemeColorPalette.emerald900,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red400,
        content: DaisyThemeColorPalette.red900,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.amber400,
        content: DaisyThemeColorPalette.amber900,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red400,
        content: DaisyThemeColorPalette.red900,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI emerald theme.
  static const DaisyThemeModel emerald = DaisyThemeModel(
    id: 'emerald',
    name: 'Emerald',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: RayOklch.fromComponents(0.35519, 0.032, 262.988),
        base200: RayOklch.fromComponents(0.93, 0, 0),
        base300: RayOklch.fromComponents(0.86, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.76662, 0.135, 153.45),
        content: RayOklch.fromComponents(0.33387, 0.04, 162.24),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.61302, 0.202, 261.294),
        content: DaisyThemeColorPalette.white,
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.72772, 0.149, 33.2),
        content: DaisyThemeColorPalette.black,
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.35519, 0.032, 262.988),
        content: RayOklch.fromComponents(0.98462, 0.001, 247.838),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        content: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.648, 0.15, 160),
        content: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        content: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI corporate theme.
  static const DaisyThemeModel corporate = DaisyThemeModel(
    id: 'corporate',
    name: 'Corporate',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: RayOklch.fromComponents(0.22389, 0.031, 278.072),
        base200: RayOklch.fromComponents(0.93, 0, 0),
        base300: RayOklch.fromComponents(0.86, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky600,
        content: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.slate500,
        content: DaisyThemeColorPalette.white,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.teal600,
        content: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.black,
        content: DaisyThemeColorPalette.white,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.cyan600,
        content: DaisyThemeColorPalette.white,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.green600,
        content: DaisyThemeColorPalette.white,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red400,
        content: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.yellow400,
        content: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red400,
        content: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.soft,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.soft,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI synthwave theme.
  static const DaisyThemeModel synthwave = DaisyThemeModel(
    id: 'synthwave',
    name: 'Synthwave',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.15, 0.09, 281.288),
        content: DaisyThemeColorPalette.indigo300,
        base200: RayOklch.fromComponents(0.2, 0.09, 281.288),
        base300: DaisyThemeColorPalette.indigo950,
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink400,
        content: DaisyThemeColorPalette.pink950,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky300,
        content: DaisyThemeColorPalette.sky950,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.orange400,
        content: DaisyThemeColorPalette.orange950,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.indigo700,
        content: DaisyThemeColorPalette.indigo200,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky400,
        content: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.teal400,
        content: DaisyThemeColorPalette.teal950,
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.737, 0.121, 32.639),
        content: RayOklch.fromComponents(0.23501, 0.096, 290.329),
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.yellow300,
        content: DaisyThemeColorPalette.yellow900,
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.737, 0.121, 32.639),
        content: RayOklch.fromComponents(0.23501, 0.096, 290.329),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI retro theme.
  static const DaisyThemeModel retro = DaisyThemeModel(
    id: 'retro',
    name: 'Retro',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.91637, 0.034, 90.515),
        content: DaisyThemeColorPalette.amber900,
        base200: RayOklch.fromComponents(0.88272, 0.049, 91.774),
        base300: RayOklch.fromComponents(0.84133, 0.065, 90.856),
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red300,
        content: DaisyThemeColorPalette.red900,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.green200,
        content: DaisyThemeColorPalette.green800,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.yellow600,
        content: DaisyThemeColorPalette.amber900,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.stone600,
        content: DaisyThemeColorPalette.stone300,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky600,
        content: DaisyThemeColorPalette.amber100,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.teal700,
        content: DaisyThemeColorPalette.amber100,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red400,
        content: DaisyThemeColorPalette.orange900,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.orange600,
        content: DaisyThemeColorPalette.amber100,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red400,
        content: DaisyThemeColorPalette.orange900,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.soft,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI cyberpunk theme.
  static const DaisyThemeModel cyberpunk = DaisyThemeModel(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.9451, 0.179, 104.32),
        content: DaisyThemeColorPalette.black,
        base200: RayOklch.fromComponents(0.9151, 0.179, 104.32),
        base300: RayOklch.fromComponents(0.8551, 0.179, 104.32),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7422, 0.209, 6.35),
        content: RayOklch.fromComponents(0.14844, 0.041, 6.35),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8333, 0.184, 204.72),
        content: RayOklch.fromComponents(0.16666, 0.036, 204.72),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7186, 0.217, 310.43),
        content: RayOklch.fromComponents(0.14372, 0.043, 310.43),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2304, 0.065, 269.31),
        content: RayOklch.fromComponents(0.9451, 0.179, 104.32),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        content: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.648, 0.15, 160),
        content: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        content: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.sharp,
      fields: DaisyThemeRadiusPreset.sharp,
      selectors: DaisyThemeRadiusPreset.sharp,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI valentine theme.
  static const DaisyThemeModel valentine = DaisyThemeModel(
    id: 'valentine',
    name: 'Valentine',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink50,
        content: DaisyThemeColorPalette.pink700,
        base200: DaisyThemeColorPalette.pink100,
        base300: DaisyThemeColorPalette.pink200,
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink500,
        content: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.purple500,
        content: DaisyThemeColorPalette.purple50,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky300,
        content: DaisyThemeColorPalette.sky900,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink900,
        content: DaisyThemeColorPalette.pink200,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.cyan300,
        content: DaisyThemeColorPalette.sky800,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald300,
        content: DaisyThemeColorPalette.emerald800,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red500,
        content: DaisyThemeColorPalette.red50,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.orange400,
        content: DaisyThemeColorPalette.orange950,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red500,
        content: DaisyThemeColorPalette.red50,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI halloween theme.
  static const DaisyThemeModel halloween = DaisyThemeModel(
    id: 'halloween',
    name: 'Halloween',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.stone900,
        content: RayOklch.fromComponents(0.84955, 0, 0),
        base200: DaisyThemeColorPalette.stone950,
        base300: DaisyThemeColorPalette.black,
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7748, 0.204, 60.62),
        content: RayOklch.fromComponents(0.19693, 0.004, 196.779),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.4598, 0.248, 305.03),
        content: RayOklch.fromComponents(0.89196, 0.049, 305.03),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.648, 0.223, 136.073),
        content: DaisyThemeColorPalette.black,
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.24371, 0.046, 65.681),
        content: RayOklch.fromComponents(0.84874, 0.009, 65.681),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.54615, 0.215, 262.88),
        content: RayOklch.fromComponents(0.90923, 0.043, 262.88),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.62705, 0.169, 149.213),
        content: RayOklch.fromComponents(0.12541, 0.033, 149.213),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6572, 0.199, 27.33),
        content: RayOklch.fromComponents(0.13144, 0.039, 27.33),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.66584, 0.157, 58.318),
        content: RayOklch.fromComponents(0.13316, 0.031, 58.318),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6572, 0.199, 27.33),
        content: RayOklch.fromComponents(0.13144, 0.039, 27.33),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI garden theme.
  static const DaisyThemeModel garden = DaisyThemeModel(
    id: 'garden',
    name: 'Garden',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.92951, 0.002, 17.197),
        content: RayOklch.fromComponents(0.16961, 0.001, 17.32),
        base200: RayOklch.fromComponents(0.86445, 0.002, 17.197),
        base300: RayOklch.fromComponents(0.79938, 0.001, 17.197),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6245, 0.278, 3.836),
        content: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.48495, 0.11, 355.095),
        content: RayOklch.fromComponents(0.89699, 0.022, 355.095),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.56273, 0.054, 154.39),
        content: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.24155, 0.049, 89.07),
        content: RayOklch.fromComponents(0.92951, 0.002, 17.197),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        content: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.648, 0.15, 160),
        content: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        content: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI forest theme.
  static const DaisyThemeModel forest = DaisyThemeModel(
    id: 'forest',
    name: 'Forest',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2084, 0.008, 17.911),
        content: RayOklch.fromComponents(0.83768, 0.001, 17.911),
        base200: RayOklch.fromComponents(0.18522, 0.007, 17.911),
        base300: RayOklch.fromComponents(0.16203, 0.007, 17.911),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.68628, 0.185, 148.958),
        content: DaisyThemeColorPalette.black,
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.69776, 0.135, 168.327),
        content: RayOklch.fromComponents(0.13955, 0.027, 168.327),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.70628, 0.119, 185.713),
        content: RayOklch.fromComponents(0.14125, 0.023, 185.713),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.30698, 0.039, 171.364),
        content: RayOklch.fromComponents(0.86139, 0.007, 171.364),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        content: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.648, 0.15, 160),
        content: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        content: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI aqua theme.
  static const DaisyThemeModel aqua = DaisyThemeModel(
    id: 'aqua',
    name: 'Aqua',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.blue900,
        content: DaisyThemeColorPalette.sky200,
        base200: DaisyThemeColorPalette.blue950,
        base300: RayOklch.fromComponents(0.22, 0.091, 267.935),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.85661, 0.144, 198.645),
        content: RayOklch.fromComponents(0.40124, 0.068, 197.603),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.60682, 0.108, 309.782),
        content: DaisyThemeColorPalette.violet50,
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.93426, 0.102, 94.555),
        content: RayOklch.fromComponents(0.18685, 0.02, 94.555),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.27, 0.146, 265.522),
        content: RayOklch.fromComponents(0.8, 0.146, 265.522),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.54615, 0.215, 262.88),
        content: RayOklch.fromComponents(0.90923, 0.043, 262.88),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.62705, 0.169, 149.213),
        content: RayOklch.fromComponents(0.12541, 0.033, 149.213),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7395, 0.19, 27.33),
        content: RayOklch.fromComponents(0.1479, 0.038, 27.33),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.66584, 0.157, 58.318),
        content: DaisyThemeColorPalette.amber950,
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7395, 0.19, 27.33),
        content: RayOklch.fromComponents(0.1479, 0.038, 27.33),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI lofi theme.
  static const DaisyThemeModel lofi = DaisyThemeModel(
    id: 'lofi',
    name: 'Lofi',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: DaisyThemeColorPalette.black,
        base200: DaisyThemeColorPalette.neutral100,
        base300: RayOklch.fromComponents(0.94, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.15906, 0, 0),
        content: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.21455, 0.001, 17.278),
        content: DaisyThemeColorPalette.white,
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.26861, 0, 0),
        content: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.black,
        content: DaisyThemeColorPalette.white,
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7954, 0.103, 205.9),
        content: RayOklch.fromComponents(0.15908, 0.02, 205.9),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.9013, 0.153, 164.14),
        content: RayOklch.fromComponents(0.18026, 0.03, 164.14),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7866, 0.15, 28.47),
        content: RayOklch.fromComponents(0.15732, 0.03, 28.47),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8837, 0.135, 79.94),
        content: RayOklch.fromComponents(0.17674, 0.027, 79.94),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7866, 0.15, 28.47),
        content: RayOklch.fromComponents(0.15732, 0.03, 28.47),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI pastel theme.
  static const DaisyThemeModel pastel = DaisyThemeModel(
    id: 'pastel',
    name: 'Pastel',
    description: '',
    border: DaisyThemeBorderWidthPreset.thick,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: DaisyThemeColorPalette.neutral900,
        base200: RayOklch.fromComponents(0.98462, 0.001, 247.838),
        base300: RayOklch.fromComponents(0.92462, 0.001, 247.838),
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.purple200,
        content: DaisyThemeColorPalette.purple700,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose200,
        content: DaisyThemeColorPalette.rose700,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald200,
        content: DaisyThemeColorPalette.emerald700,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.slate500,
        content: DaisyThemeColorPalette.slate200,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.cyan300,
        content: DaisyThemeColorPalette.cyan700,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.green300,
        content: DaisyThemeColorPalette.green700,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red300,
        content: DaisyThemeColorPalette.red700,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.orange300,
        content: DaisyThemeColorPalette.orange700,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red300,
        content: DaisyThemeColorPalette.red700,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI fantasy theme.
  static const DaisyThemeModel fantasy = DaisyThemeModel(
    id: 'fantasy',
    name: 'Fantasy',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: RayOklch.fromComponents(0.27807, 0.029, 256.847),
        base200: RayOklch.fromComponents(0.93, 0, 0),
        base300: RayOklch.fromComponents(0.86, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.3745, 0.189, 325.02),
        content: RayOklch.fromComponents(0.8749, 0.037, 325.02),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.5392, 0.162, 241.36),
        content: RayOklch.fromComponents(0.90784, 0.032, 241.36),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7598, 0.204, 56.72),
        content: RayOklch.fromComponents(0.15196, 0.04, 56.72),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.27807, 0.029, 256.847),
        content: RayOklch.fromComponents(0.85561, 0.005, 256.847),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7206, 0.191, 231.6),
        content: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.648, 0.15, 160),
        content: DaisyThemeColorPalette.black,
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8471, 0.199, 83.87),
        content: DaisyThemeColorPalette.black,
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7176, 0.221, 22.18),
        content: DaisyThemeColorPalette.black,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI wireframe theme.
  static const DaisyThemeModel wireframe = DaisyThemeModel(
    id: 'wireframe',
    name: 'Wireframe',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: DaisyThemeColorPalette.neutral900,
        base200: DaisyThemeColorPalette.neutral100,
        base300: RayOklch.fromComponents(0.94, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.neutral300,
        content: DaisyThemeColorPalette.neutral800,
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.neutral300,
        content: DaisyThemeColorPalette.neutral800,
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.neutral300,
        content: DaisyThemeColorPalette.neutral800,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.neutral300,
        content: DaisyThemeColorPalette.neutral800,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky800,
        content: DaisyThemeColorPalette.sky200,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald800,
        content: DaisyThemeColorPalette.emerald200,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red800,
        content: DaisyThemeColorPalette.red200,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.amber800,
        content: DaisyThemeColorPalette.amber200,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red800,
        content: DaisyThemeColorPalette.red200,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.soft,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.sharp,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI black theme.
  static const DaisyThemeModel black = DaisyThemeModel(
    id: 'black',
    name: 'Black',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.black,
        content: RayOklch.fromComponents(0.87609, 0, 0),
        base200: RayOklch.fromComponents(0.19, 0, 0),
        base300: RayOklch.fromComponents(0.22, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.35, 0, 0),
        content: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.35, 0, 0),
        content: DaisyThemeColorPalette.white,
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.35, 0, 0),
        content: DaisyThemeColorPalette.white,
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.35, 0, 0),
        content: DaisyThemeColorPalette.white,
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.45201, 0.313, 264.052),
        content: RayOklch.fromComponents(0.8904, 0.062, 264.052),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.51975, 0.176, 142.495),
        content: RayOklch.fromComponents(0.90395, 0.035, 142.495),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.62795, 0.257, 29.233),
        content: RayOklch.fromComponents(0.12559, 0.051, 29.233),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.96798, 0.211, 109.769),
        content: RayOklch.fromComponents(0.19359, 0.042, 109.769),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.62795, 0.257, 29.233),
        content: RayOklch.fromComponents(0.12559, 0.051, 29.233),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.sharp,
      fields: DaisyThemeRadiusPreset.sharp,
      selectors: DaisyThemeRadiusPreset.sharp,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI luxury theme.
  static const DaisyThemeModel luxury = DaisyThemeModel(
    id: 'luxury',
    name: 'Luxury',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.14076, 0.004, 285.822),
        content: RayOklch.fromComponents(0.75687, 0.123, 76.89),
        base200: RayOklch.fromComponents(0.20219, 0.004, 308.229),
        base300: RayOklch.fromComponents(0.23219, 0.004, 308.229),
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: DaisyThemeColorPalette.neutral900,
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.27581, 0.064, 261.069),
        content: RayOklch.fromComponents(0.85516, 0.012, 261.069),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.36674, 0.051, 338.825),
        content: RayOklch.fromComponents(0.87334, 0.01, 338.825),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2427, 0.057, 59.825),
        content: RayOklch.fromComponents(0.93203, 0.089, 90.861),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.79061, 0.121, 237.133),
        content: RayOklch.fromComponents(0.15812, 0.024, 237.133),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.78119, 0.192, 132.154),
        content: RayOklch.fromComponents(0.15623, 0.038, 132.154),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.71753, 0.176, 22.568),
        content: RayOklch.fromComponents(0.1435, 0.035, 22.568),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.86127, 0.136, 102.891),
        content: RayOklch.fromComponents(0.17225, 0.027, 102.891),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.71753, 0.176, 22.568),
        content: RayOklch.fromComponents(0.1435, 0.035, 22.568),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI dracula theme.
  static const DaisyThemeModel dracula = DaisyThemeModel(
    id: 'dracula',
    name: 'Dracula',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.28822, 0.022, 277.508),
        content: RayOklch.fromComponents(0.97747, 0.007, 106.545),
        base200: RayOklch.fromComponents(0.26805, 0.02, 277.508),
        base300: RayOklch.fromComponents(0.24787, 0.019, 277.508),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.75461, 0.183, 346.812),
        content: RayOklch.fromComponents(0.15092, 0.036, 346.812),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.74202, 0.148, 301.883),
        content: RayOklch.fromComponents(0.1484, 0.029, 301.883),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.83392, 0.124, 66.558),
        content: RayOklch.fromComponents(0.16678, 0.024, 66.558),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.39445, 0.032, 275.524),
        content: RayOklch.fromComponents(0.87889, 0.006, 275.524),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.88263, 0.093, 212.846),
        content: RayOklch.fromComponents(0.17652, 0.018, 212.846),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.87099, 0.219, 148.024),
        content: RayOklch.fromComponents(0.17419, 0.043, 148.024),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6822, 0.206, 24.43),
        content: RayOklch.fromComponents(0.13644, 0.041, 24.43),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.95533, 0.134, 112.757),
        content: RayOklch.fromComponents(0.19106, 0.026, 112.757),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6822, 0.206, 24.43),
        content: RayOklch.fromComponents(0.13644, 0.041, 24.43),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI cmyk theme.
  static const DaisyThemeModel cmyk = DaisyThemeModel(
    id: 'cmyk',
    name: 'Cmyk',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: DaisyThemeColorPalette.neutral900,
        base200: RayOklch.fromComponents(0.95, 0, 0),
        base300: RayOklch.fromComponents(0.9, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.71772, 0.133, 239.443),
        content: RayOklch.fromComponents(0.14354, 0.026, 239.443),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.64476, 0.202, 359.339),
        content: RayOklch.fromComponents(0.12895, 0.04, 359.339),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.94228, 0.189, 105.306),
        content: RayOklch.fromComponents(0.18845, 0.037, 105.306),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.21778, 0, 0),
        content: RayOklch.fromComponents(0.84355, 0, 0),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.68475, 0.094, 217.284),
        content: RayOklch.fromComponents(0.13695, 0.018, 217.284),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.46949, 0.162, 321.406),
        content: RayOklch.fromComponents(0.89389, 0.032, 321.406),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.62013, 0.208, 28.717),
        content: RayOklch.fromComponents(0.12402, 0.041, 28.717),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.71236, 0.159, 52.023),
        content: RayOklch.fromComponents(0.14247, 0.031, 52.023),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.62013, 0.208, 28.717),
        content: RayOklch.fromComponents(0.12402, 0.041, 28.717),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI autumn theme.
  static const DaisyThemeModel autumn = DaisyThemeModel(
    id: 'autumn',
    name: 'Autumn',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.95814, 0, 0),
        content: RayOklch.fromComponents(0.19162, 0, 0),
        base200: RayOklch.fromComponents(0.89107, 0, 0),
        base300: RayOklch.fromComponents(0.824, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.40723, 0.161, 17.53),
        content: RayOklch.fromComponents(0.88144, 0.032, 17.53),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.61676, 0.169, 23.865),
        content: RayOklch.fromComponents(0.12335, 0.033, 23.865),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.73425, 0.094, 60.729),
        content: RayOklch.fromComponents(0.14685, 0.018, 60.729),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.54367, 0.037, 51.902),
        content: RayOklch.fromComponents(0.90873, 0.007, 51.902),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.69224, 0.097, 207.284),
        content: RayOklch.fromComponents(0.13844, 0.019, 207.284),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.60995, 0.08, 174.616),
        content: RayOklch.fromComponents(0.12199, 0.016, 174.616),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.5307, 0.241, 24.16),
        content: RayOklch.fromComponents(0.90614, 0.048, 24.16),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.70081, 0.164, 56.844),
        content: RayOklch.fromComponents(0.14016, 0.032, 56.844),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.5307, 0.241, 24.16),
        content: RayOklch.fromComponents(0.90614, 0.048, 24.16),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI business theme.
  static const DaisyThemeModel business = DaisyThemeModel(
    id: 'business',
    name: 'Business',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.24353, 0, 0),
        content: RayOklch.fromComponents(0.8487, 0, 0),
        base200: RayOklch.fromComponents(0.22648, 0, 0),
        base300: RayOklch.fromComponents(0.20944, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.41703, 0.099, 251.473),
        content: RayOklch.fromComponents(0.8834, 0.019, 251.473),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.64092, 0.027, 229.389),
        content: RayOklch.fromComponents(0.12818, 0.005, 229.389),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.67271, 0.167, 35.791),
        content: RayOklch.fromComponents(0.13454, 0.033, 35.791),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.27441, 0.013, 253.041),
        content: RayOklch.fromComponents(0.85488, 0.002, 253.041),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.62616, 0.143, 240.033),
        content: RayOklch.fromComponents(0.12523, 0.028, 240.033),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.70226, 0.094, 156.596),
        content: RayOklch.fromComponents(0.14045, 0.018, 156.596),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.5161, 0.146, 29.674),
        content: RayOklch.fromComponents(0.90322, 0.029, 29.674),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.77482, 0.115, 81.519),
        content: RayOklch.fromComponents(0.15496, 0.023, 81.519),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.5161, 0.146, 29.674),
        content: RayOklch.fromComponents(0.90322, 0.029, 29.674),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.soft,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.sharp,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI acid theme.
  static const DaisyThemeModel acid = DaisyThemeModel(
    id: 'acid',
    name: 'Acid',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.zinc50,
        content: DaisyThemeColorPalette.black,
        base200: RayOklch.fromComponents(0.95, 0, 0),
        base300: RayOklch.fromComponents(0.91, 0, 0),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.719, 0.357, 330.759),
        content: RayOklch.fromComponents(0.1438, 0.071, 330.759),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7337, 0.224, 48.25),
        content: RayOklch.fromComponents(0.14674, 0.044, 48.25),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.9278, 0.264, 122.962),
        content: RayOklch.fromComponents(0.18556, 0.052, 122.962),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2131, 0.128, 278.68),
        content: RayOklch.fromComponents(0.84262, 0.025, 278.68),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6072, 0.227, 252.05),
        content: RayOklch.fromComponents(0.12144, 0.045, 252.05),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8572, 0.266, 158.53),
        content: RayOklch.fromComponents(0.17144, 0.053, 158.53),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6484, 0.293, 29.349),
        content: RayOklch.fromComponents(0.12968, 0.058, 29.349),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.9101, 0.212, 100.5),
        content: RayOklch.fromComponents(0.18202, 0.042, 100.5),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6484, 0.293, 29.349),
        content: RayOklch.fromComponents(0.12968, 0.058, 29.349),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.large,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI lemonade theme.
  static const DaisyThemeModel lemonade = DaisyThemeModel(
    id: 'lemonade',
    name: 'Lemonade',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.9871, 0.02, 123.72),
        content: RayOklch.fromComponents(0.19742, 0.004, 123.72),
        base200: RayOklch.fromComponents(0.918, 0.018, 123.72),
        base300: RayOklch.fromComponents(0.8489, 0.017, 123.72),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.5892, 0.199, 134.6),
        content: RayOklch.fromComponents(0.11784, 0.039, 134.6),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7775, 0.196, 111.09),
        content: RayOklch.fromComponents(0.1555, 0.039, 111.09),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8539, 0.201, 100.73),
        content: RayOklch.fromComponents(0.17078, 0.04, 100.73),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.3098, 0.075, 108.6),
        content: RayOklch.fromComponents(0.86196, 0.015, 108.6),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8619, 0.047, 224.14),
        content: RayOklch.fromComponents(0.17238, 0.009, 224.14),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8619, 0.047, 157.85),
        content: RayOklch.fromComponents(0.17238, 0.009, 157.85),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8619, 0.047, 25.85),
        content: RayOklch.fromComponents(0.17238, 0.009, 25.85),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8619, 0.047, 102.15),
        content: RayOklch.fromComponents(0.17238, 0.009, 102.15),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8619, 0.047, 25.85),
        content: RayOklch.fromComponents(0.17238, 0.009, 25.85),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI night theme.
  static const DaisyThemeModel night = DaisyThemeModel(
    id: 'night',
    name: 'Night',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.20768, 0.039, 265.754),
        content: RayOklch.fromComponents(0.84153, 0.007, 265.754),
        base200: RayOklch.fromComponents(0.19314, 0.037, 265.754),
        base300: RayOklch.fromComponents(0.1786, 0.034, 265.754),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.75351, 0.138, 232.661),
        content: RayOklch.fromComponents(0.1507, 0.027, 232.661),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.68011, 0.158, 276.934),
        content: RayOklch.fromComponents(0.13602, 0.031, 276.934),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7236, 0.176, 350.048),
        content: RayOklch.fromComponents(0.14472, 0.035, 350.048),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.27949, 0.036, 260.03),
        content: RayOklch.fromComponents(0.85589, 0.007, 260.03),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.68455, 0.148, 237.251),
        content: DaisyThemeColorPalette.black,
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.78452, 0.132, 181.911),
        content: RayOklch.fromComponents(0.1569, 0.026, 181.911),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.71785, 0.17, 13.118),
        content: RayOklch.fromComponents(0.14357, 0.034, 13.118),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.83242, 0.139, 82.95),
        content: RayOklch.fromComponents(0.16648, 0.027, 82.95),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.71785, 0.17, 13.118),
        content: RayOklch.fromComponents(0.14357, 0.034, 13.118),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI coffee theme.
  static const DaisyThemeModel coffee = DaisyThemeModel(
    id: 'coffee',
    name: 'Coffee',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.24, 0.023, 329.708),
        content: RayOklch.fromComponents(0.72354, 0.092, 79.129),
        base200: RayOklch.fromComponents(0.21, 0.021, 329.708),
        base300: RayOklch.fromComponents(0.16, 0.019, 329.708),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.71996, 0.123, 62.756),
        content: RayOklch.fromComponents(0.14399, 0.024, 62.756),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.34465, 0.029, 199.194),
        content: RayOklch.fromComponents(0.86893, 0.005, 199.194),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.42621, 0.074, 224.389),
        content: RayOklch.fromComponents(0.88524, 0.014, 224.389),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.1651, 0.015, 326.261),
        content: RayOklch.fromComponents(0.83302, 0.003, 326.261),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.7949, 0.063, 184.558),
        content: RayOklch.fromComponents(0.15898, 0.012, 184.558),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.74722, 0.072, 131.116),
        content: RayOklch.fromComponents(0.14944, 0.014, 131.116),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.77318, 0.128, 31.871),
        content: RayOklch.fromComponents(0.15463, 0.025, 31.871),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8815, 0.14, 87.722),
        content: RayOklch.fromComponents(0.1763, 0.028, 87.722),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.77318, 0.128, 31.871),
        content: RayOklch.fromComponents(0.15463, 0.025, 31.871),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI winter theme.
  static const DaisyThemeModel winter = DaisyThemeModel(
    id: 'winter',
    name: 'Winter',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white,
        content: RayOklch.fromComponents(0.41886, 0.053, 255.824),
        base200: RayOklch.fromComponents(0.97466, 0.011, 259.822),
        base300: RayOklch.fromComponents(0.93268, 0.016, 262.751),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.5686, 0.255, 257.57),
        content: RayOklch.fromComponents(0.91372, 0.051, 257.57),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.42551, 0.161, 282.339),
        content: RayOklch.fromComponents(0.8851, 0.032, 282.339),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.59939, 0.191, 335.171),
        content: RayOklch.fromComponents(0.11988, 0.038, 335.171),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.19616, 0.063, 257.651),
        content: RayOklch.fromComponents(0.83923, 0.012, 257.651),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.88127, 0.085, 214.515),
        content: RayOklch.fromComponents(0.17625, 0.017, 214.515),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.80494, 0.077, 197.823),
        content: RayOklch.fromComponents(0.16098, 0.015, 197.823),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.73092, 0.11, 20.076),
        content: RayOklch.fromComponents(0.14618, 0.022, 20.076),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.89172, 0.045, 71.47),
        content: RayOklch.fromComponents(0.17834, 0.009, 71.47),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.73092, 0.11, 20.076),
        content: RayOklch.fromComponents(0.14618, 0.022, 20.076),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI dim theme.
  static const DaisyThemeModel dim = DaisyThemeModel(
    id: 'dim',
    name: 'Dim',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.30857, 0.023, 264.149),
        content: RayOklch.fromComponents(0.82901, 0.031, 222.959),
        base200: RayOklch.fromComponents(0.28036, 0.019, 264.182),
        base300: RayOklch.fromComponents(0.26346, 0.018, 262.177),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.86133, 0.141, 139.549),
        content: RayOklch.fromComponents(0.17226, 0.028, 139.549),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.73375, 0.165, 35.353),
        content: RayOklch.fromComponents(0.14675, 0.033, 35.353),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.74229, 0.133, 311.379),
        content: RayOklch.fromComponents(0.14845, 0.026, 311.379),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.24731, 0.02, 264.094),
        content: RayOklch.fromComponents(0.82901, 0.031, 222.959),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.86078, 0.142, 206.182),
        content: RayOklch.fromComponents(0.17215, 0.028, 206.182),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.86171, 0.142, 166.534),
        content: RayOklch.fromComponents(0.17234, 0.028, 166.534),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.82418, 0.099, 33.756),
        content: RayOklch.fromComponents(0.16483, 0.019, 33.756),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.86163, 0.142, 94.818),
        content: RayOklch.fromComponents(0.17232, 0.028, 94.818),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.82418, 0.099, 33.756),
        content: RayOklch.fromComponents(0.16483, 0.019, 33.756),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI nord theme.
  static const DaisyThemeModel nord = DaisyThemeModel(
    id: 'nord',
    name: 'Nord',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.95127, 0.007, 260.731),
        content: RayOklch.fromComponents(0.32437, 0.022, 264.182),
        base200: RayOklch.fromComponents(0.93299, 0.01, 261.788),
        base300: RayOklch.fromComponents(0.89925, 0.016, 262.749),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.59435, 0.077, 254.027),
        content: RayOklch.fromComponents(0.11887, 0.015, 254.027),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.69651, 0.059, 248.687),
        content: RayOklch.fromComponents(0.1393, 0.011, 248.687),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.77464, 0.062, 217.469),
        content: RayOklch.fromComponents(0.15492, 0.012, 217.469),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.45229, 0.035, 264.131),
        content: RayOklch.fromComponents(0.89925, 0.016, 262.749),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.69207, 0.062, 332.664),
        content: RayOklch.fromComponents(0.13841, 0.012, 332.664),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.76827, 0.074, 131.063),
        content: RayOklch.fromComponents(0.15365, 0.014, 131.063),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6061, 0.12, 15.341),
        content: RayOklch.fromComponents(0.12122, 0.024, 15.341),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.85486, 0.089, 84.093),
        content: RayOklch.fromComponents(0.17097, 0.017, 84.093),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.6061, 0.12, 15.341),
        content: RayOklch.fromComponents(0.12122, 0.024, 15.341),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI sunset theme.
  static const DaisyThemeModel sunset = DaisyThemeModel(
    id: 'sunset',
    name: 'Sunset',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.22, 0.019, 237.69),
        content: RayOklch.fromComponents(0.77383, 0.043, 245.096),
        base200: RayOklch.fromComponents(0.2, 0.019, 237.69),
        base300: RayOklch.fromComponents(0.18, 0.019, 237.69),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.74703, 0.158, 39.947),
        content: RayOklch.fromComponents(0.1494, 0.031, 39.947),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.72537, 0.177, 2.72),
        content: RayOklch.fromComponents(0.14507, 0.035, 2.72),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.71294, 0.166, 299.844),
        content: RayOklch.fromComponents(0.14258, 0.033, 299.844),
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.26, 0.019, 237.69),
        content: RayOklch.fromComponents(0.7, 0.019, 237.69),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.85559, 0.085, 206.015),
        content: RayOklch.fromComponents(0.17111, 0.017, 206.015),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8556, 0.085, 144.778),
        content: RayOklch.fromComponents(0.17112, 0.017, 144.778),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.85511, 0.078, 16.886),
        content: RayOklch.fromComponents(0.17102, 0.015, 16.886),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.85569, 0.084, 74.427),
        content: RayOklch.fromComponents(0.17113, 0.016, 74.427),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.85511, 0.078, 16.886),
        content: RayOklch.fromComponents(0.17102, 0.015, 16.886),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.large,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI caramellatte theme.
  static const DaisyThemeModel caramellatte = DaisyThemeModel(
    id: 'caramellatte',
    name: 'Caramellatte',
    description: '',
    border: DaisyThemeBorderWidthPreset.thick,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.orange50,
        content: DaisyThemeColorPalette.orange900,
        base200: DaisyThemeColorPalette.orange100,
        base300: DaisyThemeColorPalette.orange200,
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.black,
        content: DaisyThemeColorPalette.white,
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2245, 0.075, 37.85),
        content: DaisyThemeColorPalette.orange200,
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.4644, 0.111, 37.85),
        content: DaisyThemeColorPalette.orange200,
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.orange700,
        content: DaisyThemeColorPalette.orange50,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.blue800,
        content: DaisyThemeColorPalette.orange200,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald800,
        content: DaisyThemeColorPalette.orange200,
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red400,
        content: DaisyThemeColorPalette.red900,
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.amber400,
        content: DaisyThemeColorPalette.amber900,
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.red400,
        content: DaisyThemeColorPalette.red900,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI abyss theme.
  static const DaisyThemeModel abyss = DaisyThemeModel(
    id: 'abyss',
    name: 'Abyss',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2, 0.08, 209),
        content: DaisyThemeColorPalette.orange200,
        base200: RayOklch.fromComponents(0.15, 0.08, 209),
        base300: RayOklch.fromComponents(0.1, 0.08, 209),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.92, 0.2653, 125),
        content: RayOklch.fromComponents(0.5, 0.2653, 125),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8327, 0.0764, 298.3),
        content: RayOklch.fromComponents(0.4327, 0.0764, 298.3),
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.neutral600,
        content: DaisyThemeColorPalette.zinc50,
      ),
      neutral: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.3, 0.08, 209),
        content: DaisyThemeColorPalette.orange200,
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky400,
        content: DaisyThemeColorPalette.sky950,
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.green400,
        content: DaisyThemeColorPalette.green950,
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.65, 0.1985, 24.22),
        content: RayOklch.fromComponents(0.27, 0.1985, 24.22),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.848, 0.1962, 84.62),
        content: RayOklch.fromComponents(0.448, 0.1962, 84.62),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.65, 0.1985, 24.22),
        content: RayOklch.fromComponents(0.27, 0.1985, 24.22),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium,
      fields: DaisyThemeRadiusPreset.soft,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

  /// DaisyUI silk theme.
  static const DaisyThemeModel silk = DaisyThemeModel(
    id: 'silk',
    name: 'Silk',
    description: '',
    border: DaisyThemeBorderWidthPreset.thick,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.97, 0.0035, 67.78),
        content: RayOklch.fromComponents(0.4, 0.0081, 61.42),
        base200: RayOklch.fromComponents(0.95, 0.0081, 61.42),
        base300: RayOklch.fromComponents(0.9, 0.0081, 61.42),
      ),
      primary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2327, 0.0249, 284.3),
        content: RayOklch.fromComponents(0.9422, 0.2505, 117.44),
      ),
      secondary: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2327, 0.0249, 284.3),
        content: RayOklch.fromComponents(0.7392, 0.2135, 50.94),
      ),
      accent: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2327, 0.0249, 284.3),
        content: RayOklch.fromComponents(0.8892, 0.2061, 189.9),
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.neutral900,
        content: RayOklch.fromComponents(0.8, 0.0081, 61.42),
      ),
      info: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8039, 0.1148, 241.68),
        content: RayOklch.fromComponents(0.3039, 0.1148, 241.68),
      ),
      success: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8392, 0.0901, 136.87),
        content: RayOklch.fromComponents(0.2392, 0.0901, 136.87),
      ),
      error: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.751, 0.1814, 22.37),
        content: RayOklch.fromComponents(0.351, 0.1814, 22.37),
      ),
      warning: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.8392, 0.1085, 80),
        content: RayOklch.fromComponents(0.4392, 0.1085, 80),
      ),
      danger: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.751, 0.1814, 22.37),
        content: RayOklch.fromComponents(0.351, 0.1814, 22.37),
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.large,
      fields: DaisyThemeRadiusPreset.medium,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );
}

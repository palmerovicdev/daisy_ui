import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:daisy_ui/themes/domain/theme_border.dart';
import 'package:daisy_ui/themes/domain/theme_color.dart';
import 'package:daisy_ui/themes/domain/theme_radius.dart';
import 'package:daisy_ui/themes/domain/theme_size.dart';
import 'package:prism_flutter/prism_flutter.dart';

/// Prebuilt themes, ready to use.
///
/// [light] and [dark] mirror the DaisyUI theme editor selections: same
/// OKLCH color roles, radius, size and border.
abstract final class DaisyThemes {
  /// Light theme with white/zinc bases.
  static const DaisyThemeModel light = DaisyThemeModel(
    id: 'light',
    name: 'Light',
    description: '',
    border: DaisyThemeBorderWidthPreset.thin,
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.white, // base-100 (b1)
        content: DaisyThemeColorPalette.zinc900, // base-content (bc)
        base200: DaisyThemeColorPalette.zinc50, // base-200 (b2)
        base300: DaisyThemeColorPalette.zinc100, // base-300 (b3)
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.indigo700, // primary (p)
        content: DaisyThemeColorPalette.indigo100, // primary-content (pc)
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink500, // secondary (s)
        content: DaisyThemeColorPalette.pink100, // secondary-content (sc)
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.teal400, // accent (a)
        content: DaisyThemeColorPalette.teal900, // accent-content (ac)
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.zinc950, // neutral (n)
        content: DaisyThemeColorPalette.zinc200, // neutral-content (nc)
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky400, // info (in)
        content: DaisyThemeColorPalette.sky950, // info-content (inc)
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald400, // success (su)
        content: DaisyThemeColorPalette.emerald900, // success-content (suc)
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose400, // error (er)
        content: DaisyThemeColorPalette.rose950, // error-content (erc)
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.amber400, // warning (wa)
        content: DaisyThemeColorPalette.amber900, // warning-content (wac)
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose400, // danger (da)
        content: DaisyThemeColorPalette.rose950, // danger-content (dac)
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
    border: DaisyThemeBorderWidthPreset.thin, // 1px
    colors: DaisyThemeColor(
      base: DaisyThemeColorPair(
        base: RayOklch.fromComponents(0.2533, 0.016, 252.42), // base-100
        content: RayOklch.fromComponents(0.97807, 0.029, 256.847), // base-content
        base200: RayOklch.fromComponents(0.2326, 0.014, 253.1), // base-200
        base300: RayOklch.fromComponents(0.2115, 0.012, 254.09), // base-300
      ),
      primary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.indigo500, // primary
        content: DaisyThemeColorPalette.indigo50, // primary-content
      ),
      secondary: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.pink500, // secondary
        content: DaisyThemeColorPalette.pink100, // secondary-content
      ),
      accent: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.teal400, // accent
        content: DaisyThemeColorPalette.teal900, // accent-content
      ),
      neutral: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.zinc950, // neutral
        content: DaisyThemeColorPalette.zinc200, // neutral-content
      ),
      info: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.sky400, // info
        content: DaisyThemeColorPalette.sky950, // info-content
      ),
      success: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.emerald400, // success
        content: DaisyThemeColorPalette.emerald900, // success-content
      ),
      error: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose400, // error
        content: DaisyThemeColorPalette.rose950, // error-content
      ),
      warning: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.amber400, // warning
        content: DaisyThemeColorPalette.amber900, // warning-content
      ),
      danger: DaisyThemeColorPair(
        base: DaisyThemeColorPalette.rose400,
        content: DaisyThemeColorPalette.rose950,
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.medium, // 0.5rem
      fields: DaisyThemeRadiusPreset.soft, // 0.25rem
      selectors: DaisyThemeRadiusPreset.medium, // 0.5rem
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );

}

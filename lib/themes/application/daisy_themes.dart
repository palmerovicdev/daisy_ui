import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:daisy_ui/themes/domain/theme_border.dart';
import 'package:daisy_ui/themes/domain/theme_color.dart';
import 'package:daisy_ui/themes/domain/theme_radius.dart';
import 'package:daisy_ui/themes/domain/theme_size.dart';

abstract final class DaisyThemes {
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
}

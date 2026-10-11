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
        primary: '',
        accent: '',
        secondary: '',
        tertiary: '',
      ),
      primary: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
      secondary: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
      accent: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
      neutral: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
      info: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
      success: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
      error: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
      warning: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
      danger: DaisyThemeColorPair(
        primary: '',
        accent: '',
      ),
    ),
    radius: DaisyThemeRadius(
      boxes: DaisyThemeRadiusPreset.full,
      fields: DaisyThemeRadiusPreset.full,
      selectors: DaisyThemeRadiusPreset.full,
    ),
    size: DaisyThemeSize(
      fields: DaisyThemeSizeConfig(base: 4),
      selectors: DaisyThemeSizeConfig(base: 4),
    ),
  );
}

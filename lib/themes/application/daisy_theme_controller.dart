import 'package:daisy_ui/themes/domain/daisy_themes.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/foundation.dart';

final class DaisyThemeController {
  DaisyThemeController({
    DaisyThemeModel initialTheme = DaisyThemes.light,
  }) : _palette = ValueNotifier<DaisyThemeModel>(initialTheme);

  final ValueNotifier<DaisyThemeModel> _palette;

  ValueListenable<DaisyThemeModel> get theme => _palette;

  void setTheme(DaisyThemeModel theme) => _palette.value = theme;

  void dispose() => _palette.dispose();
}

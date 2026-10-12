import 'package:daisy_ui/themes/domain/daisy_themes.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../domain/theme.dart';

abstract final class DaisyThemeService {
  static final _palette = signal<DaisyThemeModel>(
    DaisyThemes.light,
  );

  static final theme = computed<DaisyThemeModel>(
    () => _palette.value,
  );

  static void setTheme(DaisyThemeModel theme) {
    _palette.value = theme;
  }
}
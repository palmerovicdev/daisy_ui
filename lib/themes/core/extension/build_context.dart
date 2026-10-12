import 'package:daisy_ui/themes/application/daisy_theme_scope.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/material.dart';

extension DaisyThemeContext on BuildContext {
  DaisyThemeModel get daisyTheme => DaisyThemeScope.of(this);
}

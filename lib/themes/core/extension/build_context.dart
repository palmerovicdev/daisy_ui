import 'package:daisy_ui/themes/application/daisy_theme_scope.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/material.dart';

/// Convenient access to the nearest [DaisyThemeScope].
extension DaisyThemeContext on BuildContext {
  /// The current theme; registers a dependency and throws if no scope exists.
  DaisyThemeModel get daisyTheme => DaisyThemeScope.of(this);
}

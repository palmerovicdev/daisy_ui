import 'package:daisy_ui/themes/application/daisy_theme_controller.dart';
import 'package:flutter/foundation.dart';

import '../domain/theme.dart';

/// The default theme shared by scopes without an explicit controller.
abstract final class DaisyThemeService {
  static final _controller = DaisyThemeController();

  static ValueListenable<DaisyThemeModel> get theme => _controller.theme;

  static void setTheme(DaisyThemeModel theme) {
    _controller.setTheme(theme);
  }
}

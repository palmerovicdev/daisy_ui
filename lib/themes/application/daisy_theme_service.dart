import 'package:daisy_ui/themes/application/daisy_theme_controller.dart';
import 'package:flutter/foundation.dart';

import '../domain/theme.dart';

abstract final class DaisyThemeService {
  static final _controller = DaisyThemeController();

  static ValueListenable<DaisyThemeModel> get theme => _controller.theme;

  static void setTheme(DaisyThemeModel theme) {
    _controller.setTheme(theme);
  }
}

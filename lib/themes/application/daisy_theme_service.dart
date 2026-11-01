import 'package:daisy_ui/themes/application/daisy_theme_controller.dart';
import 'package:flutter/foundation.dart';

import '../domain/theme.dart';

/// Shared theme used by scopes without an independent controller.
///
/// Its initial value is `DaisyThemes.light`; update it with [setTheme].
abstract final class DaisyThemeService {
  static final _controller = DaisyThemeController();

  /// Read-only global theme and change notifications.
  static ValueListenable<DaisyThemeModel> get theme => _controller.theme;

  /// Replaces the global theme observed by scopes using this service.
  static void setTheme(DaisyThemeModel theme) {
    _controller.setTheme(theme);
  }
}

import 'package:daisy_ui/themes/application/daisy_theme_controller.dart';
import 'package:daisy_ui/themes/application/daisy_theme_service.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Rebuilds descendants when the nearest scope's theme changes.
///
/// Without a controller, uses [DaisyThemeService]. An explicit controller is
/// borrowed: its owner must create it once and dispose it after use.
class DaisyThemeScope
    extends InheritedNotifier<ValueListenable<DaisyThemeModel>> {
  DaisyThemeScope({
    super.key,
    required super.child,
    DaisyThemeController? controller,
  }) : super(notifier: controller?.theme ?? DaisyThemeService.theme);

  /// Watches the nearest theme from `build` or `State.didChangeDependencies`.
  ///
  /// Throws if this context has no [DaisyThemeScope] ancestor.
  static DaisyThemeModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>();

    if (scope == null) {
      throw FlutterError(
        'Coloca DaisyThemeScope por encima de este widget.',
      );
    }

    return scope.notifier!.value;
  }
}

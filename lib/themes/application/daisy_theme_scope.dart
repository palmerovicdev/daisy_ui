import 'package:daisy_ui/themes/application/daisy_theme_controller.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'daisy_theme_service.dart';

/// Makes a theme available to descendants and rebuilds dependent widgets when
/// it changes. Nested scopes use the nearest ancestor.
///
/// Read it with `context.daisyTheme` or [DaisyThemeScope.of]. The context must
/// belong to a descendant of this scope.
class DaisyThemeScope
    extends InheritedNotifier<ValueListenable<DaisyThemeModel>> {
  /// Observes [controller], or the global [DaisyThemeService] if omitted.
  ///
  /// Initialize the global service before using it. The owner of a supplied
  /// controller must dispose it after this scope unmounts.
  DaisyThemeScope({
    super.key,
    required super.child,
    DaisyThemeController? controller,
  }) : super(notifier: controller?.theme ?? DaisyThemeService.theme);

  /// Returns the nearest theme and registers a dependency on its scope.
  ///
  /// Throws a [FlutterError] if no [DaisyThemeScope] is an ancestor.
  static DaisyThemeModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>();

    if (scope == null) {
      throw FlutterError('Coloca DaisyThemeScope por encima de este widget.');
    }

    return scope.notifier!.value;
  }
}

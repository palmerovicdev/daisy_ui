import 'package:daisy_ui/themes/application/daisy_theme_controller.dart';
import 'package:daisy_ui/themes/application/daisy_theme_service.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Makes a theme available to descendants and rebuilds dependent widgets when
/// it changes. Nested scopes use the nearest ancestor.
///
/// Read it with `context.daisyTheme` or [DaisyThemeScope.of]. The context must
/// belong to a descendant of this scope.
class DaisyThemeScope
    extends InheritedNotifier<ValueListenable<DaisyThemeModel>> {
  /// Uses [controller] when supplied; otherwise observes the global service.
  /// The caller retains ownership of [controller] and must dispose it.
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

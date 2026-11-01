import 'package:daisy_ui/themes/application/daisy_theme_controller.dart';
import 'package:daisy_ui/themes/application/daisy_theme_service.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class DaisyThemeScope
    extends InheritedNotifier<ValueListenable<DaisyThemeModel>> {
  DaisyThemeScope({
    super.key,
    required super.child,
    DaisyThemeController? controller,
  }) : super(notifier: controller?.theme ?? DaisyThemeService.theme);

  static DaisyThemeModel of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>();

    if (scope == null) {
      throw FlutterError('Coloca DaisyThemeScope por encima de este widget.');
    }

    return scope.notifier!.value;
  }
}

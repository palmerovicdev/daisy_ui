import 'package:daisy_ui/themes/domain/daisy_themes.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Owns one independently changeable theme.
///
/// Create the controller once, for example in `State.initState`, and dispose it
/// when its owner is disposed. A `DaisyThemeScope` only borrows the controller.
final class DaisyThemeController {
  DaisyThemeController({DaisyThemeModel initialTheme = DaisyThemes.light})
    : _palette = signal<DaisyThemeModel>(initialTheme);

  final FlutterSignal<DaisyThemeModel> _palette;
  late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(
    _palette,
  );

  /// The current theme and its notifications, without signal mutation or disposal.
  ValueListenable<DaisyThemeModel> get theme => _theme;

  void setTheme(DaisyThemeModel theme) {
    _palette.value = theme;
  }

  /// Releases this controller's signal. The controller must no longer be in use.
  void dispose() {
    _palette.dispose();
  }
}

final class _ThemeListenable implements ValueListenable<DaisyThemeModel> {
  const _ThemeListenable(this._source);

  final ValueListenable<DaisyThemeModel> _source;

  @override
  DaisyThemeModel get value => _source.value;

  @override
  void addListener(VoidCallback listener) => _source.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _source.removeListener(listener);
}

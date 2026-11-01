import 'package:daisy_ui/themes/domain/daisy_themes.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class DaisyThemeController {
  DaisyThemeController({
    DaisyThemeModel initialTheme = DaisyThemes.light,
  }) : _palette = FlutterSignal<DaisyThemeModel>(initialTheme);

  final FlutterSignal<DaisyThemeModel> _palette;

  late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(
    _palette,
  );

  ValueListenable<DaisyThemeModel> get theme => _theme;

  void setTheme(DaisyThemeModel theme) => _palette.value = theme;

  void dispose() => _palette.dispose();
}

final class _ThemeListenable implements ValueListenable<DaisyThemeModel> {
  _ThemeListenable(this._source);

  final FlutterSignal<DaisyThemeModel> _source;

  @override
  DaisyThemeModel get value => _source.value;

  @override
  void addListener(VoidCallback listener) {
    _source.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _source.removeListener(listener);
  }
}

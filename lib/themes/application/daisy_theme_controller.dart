import 'package:daisy_ui/themes/application/daisy_themes.dart';
import 'package:daisy_ui/themes/domain/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';

/// Owns the current theme for an independent widget subtree.
///
/// Create it once in the owning state, pass it to a `DaisyThemeScope`, and call
/// [dispose] when that owner is disposed. A scope borrows the controller.
final class DaisyThemeController {
  /// Creates a controller starting with [initialTheme] (light by default).
  DaisyThemeController({
    DaisyThemeModel initialTheme = DaisyThemes.light,
  }) : _palette = FlutterSignal<DaisyThemeModel>(initialTheme);

  final FlutterSignal<DaisyThemeModel> _palette;
  void Function()? _subscriptionCanceler;

  late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(
    _palette,
  );

  /// Read-only current theme and change notifications.
  ///
  /// Use `theme.value` for a snapshot or a `ValueListenableBuilder` to listen.
  ValueListenable<DaisyThemeModel> get theme => _theme;

  /// Replaces the current theme and notifies listeners when it changes.
  void setTheme(DaisyThemeModel theme) => _palette.value = theme;

  /// Releases the owned signal. Do not use this controller afterwards.
  void dispose() {
    _subscriptionCanceler?.call();
    _subscriptionCanceler = null;
    _palette.dispose();
  }

  /// Starts this controller's theme-change subscription.
  ///
  /// Repeated calls do not add another subscription. The subscription is
  /// cancelled by [dispose]. Saving and restoring themes is not implemented.
  void initialize() {
    _subscriptionCanceler ??= _palette.subscribe((theme) {
      // TODO 2026-11-2, victorpalmero: save the theme.
    });
  }

  // TODO 2026-11-2, victorpalmero: Add default function to save the theme.
  // TODO 2026-11-2, victorpalmero: Add default function to get the saved theme.
  // TODO 2026-11-2, victorpalmero: Add optional callback to save the theme (with an id buider).
  // TODO 2026-11-2, victorpalmero: Add optional callback to get the saved theme (with an id buider).
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

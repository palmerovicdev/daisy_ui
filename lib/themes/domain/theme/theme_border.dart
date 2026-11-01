/// Global border-width presets, in logical pixels.
///
/// Mirrors DaisyUI's `--border` scale (default 1px). Assign one to
/// [DaisyThemeModel.border].
abstract final class DaisyThemeBorderWidthPreset {
  /// 0.5 logical pixels, for dividers and hairline outlines.
  static const double hairline = 0.5;

  /// 1 logical pixel, the standard border width.
  static const double thin = 1;

  /// 1.5 logical pixels, for an emphasized border.
  static const double medium = 1.5;

  /// 2 logical pixels, for a heavier border.
  static const double thick = 2;
}

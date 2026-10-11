/// Global border-width presets, in logical pixels.
///
/// Mirrors DaisyUI's `--border` scale (default 1px). Assign one to
/// [DaisyThemeModel.border].
abstract final class DaisyThemeBorderWidthPreset {
  /// Sub-pixel hairline for dividers and hairline outlines.
  static const double hairline = 0.5;

  /// Default 1px border used by most components.
  static const double thin = 1;

  /// Emphasized 1.5px border.
  static const double medium = 1.5;

  /// Heavy 2px border.
  static const double thick = 2;
}
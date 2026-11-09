/// Control size step for a [DaisyButton].
///
/// Maps onto [DaisyThemeSize.fields] (`theme.size.fields.<step>`).
/// With the default `base: 4` scale those steps are 24, 32, 40, 48 and
/// 56 logical pixels (xs → xl). The button applies that token as its minimum height or square dimension.
///
/// Default in [DaisyButtonTheme] is [md].
enum DaisyButtonSize {
  /// Extra-small — densest controls (`theme.size.fields.xs`), 24 px with the default scale.
  xs,

  /// Small (`theme.size.fields.sm`), 32 px with the default scale.
  sm,

  /// Medium — default comfortable size (`theme.size.fields.md`), 40 px with the default scale.
  md,

  /// Large (`theme.size.fields.lg`), 48 px with the default scale.
  lg,

  /// Extra-large — most prominent controls (`theme.size.fields.xl`), 56 px with the default scale.
  xl;

  /// Multiplier used by the default field-size scale, not a pixel value.
  double get value => switch (this) {
    xs => 6,
    sm => 8,
    md => 10,
    lg => 12,
    xl => 14,
  };
}

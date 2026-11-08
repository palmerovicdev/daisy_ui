/// Control size step for a [DaisyButton].
///
/// Maps onto [DaisyThemeSize.fields] (`theme.size.fields.<step>`).
/// With the default `base: 4` scale those steps are 24, 32, 40, 48 and
/// 56 logical pixels (xs → xl). The widget must apply the token
/// explicitly; this enum only selects which step.
///
/// Default in [DaisyButtonTheme] is [md].
enum DaisyButtonSize {
  /// Extra-small — densest controls (`theme.size.fields.xs`), 6 px.
  xs,

  /// Small (`theme.size.fields.sm`), 8 px.
  sm,

  /// Medium — default comfortable size (`theme.size.fields.md`), 10 px.
  md,

  /// Large (`theme.size.fields.lg`), 12 px.
  lg,

  /// Extra-large — most prominent controls (`theme.size.fields.xl`), 14 px.
  xl;

  double get value => switch (this) {
    xs => 6,
    sm => 8,
    md => 10,
    lg => 12,
    xl => 14,
  };
}

/// Semantic color role applied to a [DaisyButton].
///
/// Orthogonal to [DaisyButtonType]: the style chooses which theme color
/// (primary, error…) the type recipe consumes.
///
/// Each value maps to the matching role on [DaisyThemeModel.colors]
/// (e.g. `theme.colors.primary`), the same roles DaisyUI exposes as
/// `btn-primary`, `btn-error`, etc.
enum DaisyButtonStyle {
  /// Neutral / base role — default chrome, lowest emphasis.
  neutral,

  /// Brand primary action color.
  primary,

  /// Brand secondary action color.
  secondary,

  /// Accent highlight, distinct from primary/secondary.
  accent,

  /// Informational state (hints, help, neutral notices).
  info,

  /// Positive / success state.
  success,

  /// Caution / warning state.
  warning,

  /// Destructive / error state.
  error,
}

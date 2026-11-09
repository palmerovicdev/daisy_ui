/// Visual treatment of a [DaisyButton] (how it is drawn).
///
/// Orthogonal to [DaisyButtonStyle]: the type is the surface recipe
/// (fill, border, ghost…); the style picks which semantic color role
/// feeds that recipe.
///
/// Mirrors DaisyUI's `btn` variants (`btn-outline`, `btn-dash`,
/// `btn-soft`, `btn-ghost`, `btn-link`). The default DaisyUI button
/// maps to [filled].
enum DaisyButtonType {
  /// Solid fill using the selected style color (default DaisyUI `btn`).
  filled,

  /// Transparent fill with a solid border in the style color (`btn-outline`).
  outlined,

  /// Transparent fill with a dashed border in the style color (`btn-dash`).
  dashed,

  /// Soft / muted fill derived from the style color (`btn-soft`).
  soft,

  /// No fill or border until interaction; text uses the style color (`btn-ghost`).
  ghost,

  /// Text-link appearance using the style color (`btn-link`).
  link,
}

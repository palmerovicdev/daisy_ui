/// Layout / shape modifier layered on top of type, style and size.
///
/// Does not change color or size tokens; it only reshapes padding or
/// geometry (DaisyUI `btn-wide`, `btn-block`, `btn-square`, `btn-circle`).
/// Default in [DaisyButtonTheme] is [wide].
enum DaisyButtonModifier {
  /// No extra layout or shape change.
  none,

  /// Extra horizontal padding so the button reads wider (`btn-wide`).
  wide,

  /// Stretch to the full width of the parent (`btn-block`).
  block,

  /// Equal width and height, square corners from the field radius (`btn-square`).
  square,

  /// Equal width and height with a circular clip (`btn-circle`).
  circle,
}

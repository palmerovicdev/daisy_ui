import 'package:daisy_ui/themes/domain/theme/theme_color.dart';
import 'package:daisy_ui/themes/domain/theme/theme_radius.dart';
import 'package:daisy_ui/themes/domain/theme/theme_size.dart';
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme.freezed.dart';

part 'generated/theme.g.dart';

/// An immutable collection of semantic colors, radii, sizes and border width.
///
/// Use a `DaisyThemes` preset or create a variation with `copyWith`.
@Freezed(equal: false, toStringOverride: true)
abstract class DaisyThemeModel with _$DaisyThemeModel, Equatable {
  const DaisyThemeModel._();

  /// A complete DaisyUI theme.
  ///
  /// Groups every design token of one theme ([colors], [radius], [size],
  /// [border]) under a stable [id] plus a human-readable [name] and
  /// [description]. Prebuilt instances live in `DaisyThemes`
  /// (`light`, `dark`).
  const factory DaisyThemeModel({
    /// Stable identifier, e.g. `'light'` or `'dark'`.
    required String id,

    /// Human-readable name shown in pickers, e.g. `'Light'`.
    required String name,

    /// Short description of the theme; may be empty.
    required String description,

    /// Semantic color roles (base, primary, …) with their content colors.
    required DaisyThemeColor colors,

    /// Corner radii for boxes, fields and selectors, in logical pixels.
    required DaisyThemeRadius radius,

    /// Control sizes derived from a base step, for fields and selectors.
    required DaisyThemeSize size,

    /// Global border width in logical pixels,
    /// see [DaisyThemeBorderWidthPreset].
    required double border,
  }) = _DaisyThemeModel;

  factory DaisyThemeModel.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeModelFromJson(json);

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    colors,
    radius,
    size,
    border,
  ];
}

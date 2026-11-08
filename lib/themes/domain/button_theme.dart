import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'button/button_modifier.dart';
import 'button/button_size.dart';
import 'button/button_style.dart';
import 'button/button_type.dart';

part 'generated/button_theme.freezed.dart';

part 'generated/button_theme.g.dart';

/// Theme knobs for a [DaisyButton].
///
/// Four independent axes plus elevation:
/// - [type] — surface recipe (filled, outline, ghost…)
/// - [style] — semantic color role (primary, error…)
/// - [size] — step on `theme.size.fields`
/// - [modifier] — layout/shape (wide, block, square, circle)
/// - [elevation] / [hoverElevation] / [pressedElevation] — Material elevation
///   at rest, on hover and while pressed
@Freezed(equal: false, toStringOverride: true)
abstract class DaisyButtonTheme with _$DaisyButtonTheme, Equatable {
  const factory DaisyButtonTheme({
    /// How the button surface is drawn. See [DaisyButtonType].
    @Default(DaisyButtonType.filled) DaisyButtonType type,

    /// Which semantic color role feeds [type]. See [DaisyButtonStyle].
    @Default(DaisyButtonStyle.neutral) DaisyButtonStyle style,

    /// Size step on the theme field scale. See [DaisyButtonSize].
    @Default(DaisyButtonSize.md) DaisyButtonSize size,

    /// Layout or shape overlay. See [DaisyButtonModifier].
    @Default(DaisyButtonModifier.none) DaisyButtonModifier modifier,

    /// Resting Material elevation.
    @Default(0) double elevation,

    /// Elevation while the pointer hovers the button.
    @Default(1) double hoverElevation,

    /// Elevation while the button is pressed.
    @Default(0) double pressedElevation,
  }) = _DaisyButtonTheme;

  const DaisyButtonTheme._();

  @override
  List<Object?> get props => [
    type,
    style,
    size,
    modifier,
    elevation,
    hoverElevation,
    pressedElevation,
  ];

  factory DaisyButtonTheme.fromJson(Map<String, dynamic> json) =>
      _$DaisyButtonThemeFromJson(json);
}

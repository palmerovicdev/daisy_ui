import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'button/button_modifier.dart';
import 'button/button_size.dart';
import 'button/button_style.dart';
import 'button/button_type.dart';

part 'generated/button_theme.freezed.dart';

part 'generated/button_theme.g.dart';

@Freezed(equal: false, toStringOverride: true)
abstract class DaisyButtonTheme with _$DaisyButtonTheme, Equatable {
  const factory DaisyButtonTheme({
    @Default(DaisyButtonType.filled) DaisyButtonType type,
    @Default(DaisyButtonStyle.neutral) DaisyButtonStyle style,
    @Default(DaisyButtonSize.md) DaisyButtonSize size,
    @Default(DaisyButtonModifier.none) DaisyButtonModifier modifier,
    @Default(0) double elevation,
    @Default(4) double hoverElevation,
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

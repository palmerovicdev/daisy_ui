// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../button_theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DaisyButtonTheme _$DaisyButtonThemeFromJson(Map<String, dynamic> json) =>
    _DaisyButtonTheme(
      type:
          $enumDecodeNullable(_$DaisyButtonTypeEnumMap, json['type']) ??
          DaisyButtonType.filled,
      style:
          $enumDecodeNullable(_$DaisyButtonStyleEnumMap, json['style']) ??
          DaisyButtonStyle.neutral,
      size:
          $enumDecodeNullable(_$DaisyButtonSizeEnumMap, json['size']) ??
          DaisyButtonSize.md,
      modifier:
          $enumDecodeNullable(_$DaisyButtonModifierEnumMap, json['modifier']) ??
          DaisyButtonModifier.none,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 0,
      hoverElevation: (json['hoverElevation'] as num?)?.toDouble() ?? 4,
      pressedElevation: (json['pressedElevation'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$DaisyButtonThemeToJson(_DaisyButtonTheme instance) =>
    <String, dynamic>{
      'type': _$DaisyButtonTypeEnumMap[instance.type]!,
      'style': _$DaisyButtonStyleEnumMap[instance.style]!,
      'size': _$DaisyButtonSizeEnumMap[instance.size]!,
      'modifier': _$DaisyButtonModifierEnumMap[instance.modifier]!,
      'elevation': instance.elevation,
      'hoverElevation': instance.hoverElevation,
      'pressedElevation': instance.pressedElevation,
    };

const _$DaisyButtonTypeEnumMap = {
  DaisyButtonType.filled: 'filled',
  DaisyButtonType.outlined: 'outlined',
  DaisyButtonType.dashed: 'dashed',
  DaisyButtonType.soft: 'soft',
  DaisyButtonType.ghost: 'ghost',
  DaisyButtonType.link: 'link',
};

const _$DaisyButtonStyleEnumMap = {
  DaisyButtonStyle.neutral: 'neutral',
  DaisyButtonStyle.primary: 'primary',
  DaisyButtonStyle.secondary: 'secondary',
  DaisyButtonStyle.accent: 'accent',
  DaisyButtonStyle.info: 'info',
  DaisyButtonStyle.success: 'success',
  DaisyButtonStyle.warning: 'warning',
  DaisyButtonStyle.error: 'error',
};

const _$DaisyButtonSizeEnumMap = {
  DaisyButtonSize.xs: 'xs',
  DaisyButtonSize.sm: 'sm',
  DaisyButtonSize.md: 'md',
  DaisyButtonSize.lg: 'lg',
  DaisyButtonSize.xl: 'xl',
};

const _$DaisyButtonModifierEnumMap = {
  DaisyButtonModifier.none: 'none',
  DaisyButtonModifier.wide: 'wide',
  DaisyButtonModifier.block: 'block',
  DaisyButtonModifier.square: 'square',
  DaisyButtonModifier.circle: 'circle',
};

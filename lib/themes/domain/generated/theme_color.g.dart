// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../theme_color.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DaisyThemeColor _$DaisyThemeColorFromJson(
  Map<String, dynamic> json,
) => _DaisyThemeColor(
  base: DaisyThemeColorPair.fromJson(json['base'] as Map<String, dynamic>),
  primary: DaisyThemeColorPair.fromJson(
    json['primary'] as Map<String, dynamic>,
  ),
  secondary: DaisyThemeColorPair.fromJson(
    json['secondary'] as Map<String, dynamic>,
  ),
  accent: DaisyThemeColorPair.fromJson(json['accent'] as Map<String, dynamic>),
  neutral: DaisyThemeColorPair.fromJson(
    json['neutral'] as Map<String, dynamic>,
  ),
  info: DaisyThemeColorPair.fromJson(json['info'] as Map<String, dynamic>),
  success: DaisyThemeColorPair.fromJson(
    json['success'] as Map<String, dynamic>,
  ),
  error: DaisyThemeColorPair.fromJson(json['error'] as Map<String, dynamic>),
  warning: DaisyThemeColorPair.fromJson(
    json['warning'] as Map<String, dynamic>,
  ),
  danger: DaisyThemeColorPair.fromJson(json['danger'] as Map<String, dynamic>),
);

Map<String, dynamic> _$DaisyThemeColorToJson(_DaisyThemeColor instance) =>
    <String, dynamic>{
      'base': instance.base.toJson(),
      'primary': instance.primary.toJson(),
      'secondary': instance.secondary.toJson(),
      'accent': instance.accent.toJson(),
      'neutral': instance.neutral.toJson(),
      'info': instance.info.toJson(),
      'success': instance.success.toJson(),
      'error': instance.error.toJson(),
      'warning': instance.warning.toJson(),
      'danger': instance.danger.toJson(),
    };

_DaisyThemeColorPair _$DaisyThemeColorPairFromJson(Map<String, dynamic> json) =>
    _DaisyThemeColorPair(
      base: RayOklch.fromJson(json['base'] as Map<String, dynamic>),
      content: RayOklch.fromJson(json['content'] as Map<String, dynamic>),
      base200: json['base200'] == null
          ? null
          : RayOklch.fromJson(json['base200'] as Map<String, dynamic>),
      base300: json['base300'] == null
          ? null
          : RayOklch.fromJson(json['base300'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DaisyThemeColorPairToJson(
  _DaisyThemeColorPair instance,
) => <String, dynamic>{
  'base': instance.base.toJson(),
  'content': instance.content.toJson(),
  'base200': instance.base200?.toJson(),
  'base300': instance.base300?.toJson(),
};

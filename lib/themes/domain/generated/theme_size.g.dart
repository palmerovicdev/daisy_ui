// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../theme_size.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DaisyThemeSize _$DaisyThemeSizeFromJson(Map<String, dynamic> json) =>
    _DaisyThemeSize(
      fields: DaisyThemeSizeConfig.fromJson(
        json['fields'] as Map<String, dynamic>,
      ),
      selectors: DaisyThemeSizeConfig.fromJson(
        json['selectors'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$DaisyThemeSizeToJson(_DaisyThemeSize instance) =>
    <String, dynamic>{
      'fields': instance.fields.toJson(),
      'selectors': instance.selectors.toJson(),
    };

_DaisyThemeSizeConfig _$DaisyThemeSizeConfigFromJson(
  Map<String, dynamic> json,
) => _DaisyThemeSizeConfig(base: (json['base'] as num).toInt());

Map<String, dynamic> _$DaisyThemeSizeConfigToJson(
  _DaisyThemeSizeConfig instance,
) => <String, dynamic>{'base': instance.base};

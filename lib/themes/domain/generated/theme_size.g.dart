// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../theme_size.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DaisyThemeSize _$DaisyThemeSizeFromJson(Map<String, dynamic> json) =>
    _DaisyThemeSize(
      fields: DaisyThemeSizePresets.fromJson(
        json['fields'] as Map<String, dynamic>,
      ),
      selectors: DaisyThemeSizePresets.fromJson(
        json['selectors'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$DaisyThemeSizeToJson(_DaisyThemeSize instance) =>
    <String, dynamic>{
      'fields': instance.fields.toJson(),
      'selectors': instance.selectors.toJson(),
    };

_DaisyThemeSizePresets _$DaisyThemeSizePresetsFromJson(
  Map<String, dynamic> json,
) => _DaisyThemeSizePresets(base: (json['base'] as num).toInt());

Map<String, dynamic> _$DaisyThemeSizePresetsToJson(
  _DaisyThemeSizePresets instance,
) => <String, dynamic>{'base': instance.base};

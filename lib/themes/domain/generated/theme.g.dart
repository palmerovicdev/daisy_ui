// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../theme.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DaisyThemeModel _$DaisyThemeModelFromJson(Map<String, dynamic> json) =>
    _DaisyThemeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      colors: DaisyThemeColor.fromJson(json['colors'] as Map<String, dynamic>),
      radius: DaisyThemeRadius.fromJson(json['radius'] as Map<String, dynamic>),
      size: DaisyThemeSize.fromJson(json['size'] as Map<String, dynamic>),
      border: (json['border'] as num).toDouble(),
    );

Map<String, dynamic> _$DaisyThemeModelToJson(_DaisyThemeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'colors': instance.colors.toJson(),
      'radius': instance.radius.toJson(),
      'size': instance.size.toJson(),
      'border': instance.border,
    };

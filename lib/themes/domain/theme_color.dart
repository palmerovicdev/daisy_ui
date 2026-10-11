import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme_color.freezed.dart';

part 'generated/theme_color.g.dart';

@freezed
abstract class DaisyThemeColor with _$DaisyThemeColor {
  const factory DaisyThemeColor({
    required DaisyThemeColorPair base,
    required DaisyThemeColorPair primary,
    required DaisyThemeColorPair secondary,
    required DaisyThemeColorPair accent,
    required DaisyThemeColorPair neutral,
    required DaisyThemeColorPair info,
    required DaisyThemeColorPair success,
    required DaisyThemeColorPair error,
    required DaisyThemeColorPair warning,
    required DaisyThemeColorPair danger,
  }) = _DaisyThemeColor;

  factory DaisyThemeColor.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeColorFromJson(json);
}

@freezed
abstract class DaisyThemeColorPair with _$DaisyThemeColorPair {
  const factory DaisyThemeColorPair({
    required String primary,
    required String accent,
    String? secondary,
    String? tertiary,
  }) = _DaisyThemeColorPair;

  factory DaisyThemeColorPair.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeColorPairFromJson(json);
}

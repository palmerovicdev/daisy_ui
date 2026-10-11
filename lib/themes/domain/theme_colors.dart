import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme_colors.freezed.dart';
part 'generated/theme_colors.g.dart';

@freezed
abstract class DaisyThemeColors with _$DaisyThemeColors {
  const factory DaisyThemeColors({
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
  }) = _DaisyThemeColors;

  factory DaisyThemeColors.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeColorsFromJson(json);
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

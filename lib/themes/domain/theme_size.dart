import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme_size.freezed.dart';

part 'generated/theme_size.g.dart';

@freezed
abstract class DaisyThemeSize with _$DaisyThemeSize {
  const factory DaisyThemeSize({
    /// button, input, select, tab
    required DaisyThemeSizeConfig fields,

    /// checkbox, toggle, badge
    required DaisyThemeSizeConfig selectors,
  }) = _DaisyThemeSize;

  factory DaisyThemeSize.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeSizeFromJson(json);
}

@freezed
abstract class DaisyThemeSizeConfig with _$DaisyThemeSizeConfig {
  const DaisyThemeSizeConfig._();

  const factory DaisyThemeSizeConfig({
    required int base,
  }) = _DaisyThemeSizeConfig;

  int get xs => base * 6;

  int get sm => base * 8;

  int get md => base * 10;

  int get lg => base * 12;

  int get xl => base * 14;

  factory DaisyThemeSizeConfig.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeSizeConfigFromJson(json);
}

import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme_size.freezed.dart';

part 'generated/theme_size.g.dart';

@Freezed(equal: false, toStringOverride: true)
abstract class DaisyThemeSize with _$DaisyThemeSize, Equatable {
  const DaisyThemeSize._();

  /// Control sizes of a theme.
  ///
  /// Both groups share the [DaisyThemeSizeConfig] scale and only differ
  /// in their [DaisyThemeSizeConfig.base] step.
  const factory DaisyThemeSize({
    /// Buttons, inputs, selects, tabs.
    required DaisyThemeSizeConfig fields,

    /// Checkboxes, toggles, badges.
    required DaisyThemeSizeConfig selectors,
  }) = _DaisyThemeSize;

  factory DaisyThemeSize.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeSizeFromJson(json);

  @override
  List<Object?> get props => [fields, selectors];
}

@Freezed(equal: false, toStringOverride: true)
abstract class DaisyThemeSizeConfig with _$DaisyThemeSizeConfig, Equatable {
  /// Size scale derived from a single [base] step in logical pixels.
  ///
  /// Each t-shirt size multiplies [base] by a fixed factor, so bumping
  /// [base] rescales the whole group (e.g. `base: 4` yields
  /// xs 24, sm 32, md 40, lg 48, xl 56).
  const DaisyThemeSizeConfig._();

  const factory DaisyThemeSizeConfig({
    /// Base step in logical pixels; every size below derives from it.
    required int base,
  }) = _DaisyThemeSizeConfig;

  /// Extra-small: `base * 6`.
  int get xs => base * 6;

  /// Small: `base * 8`.
  int get sm => base * 8;

  /// Medium: `base * 10`.
  int get md => base * 10;

  /// Large: `base * 12`.
  int get lg => base * 12;

  /// Extra-large: `base * 14`.
  int get xl => base * 14;

  factory DaisyThemeSizeConfig.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeSizeConfigFromJson(json);

  @override
  List<Object?> get props => [base];
}

import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme_size.freezed.dart';

part 'generated/theme_size.g.dart';

/// Sizes for two groups of controls, expressed in logical pixels.
///
/// Read a step such as `theme.size.fields.md` when sizing a widget.
@Freezed(equal: false, toStringOverride: true)
abstract class DaisyThemeSize with _$DaisyThemeSize, Equatable {
  const DaisyThemeSize._();

  /// Control sizes of a theme.
  ///
  /// Both groups share the [DaisyThemeSizePresets] scale and only differ
  /// in their [DaisyThemeSizePresets.base] step.
  const factory DaisyThemeSize({
    /// Buttons, inputs, selects, tabs.
    required DaisyThemeSizePresets fields,

    /// Checkboxes, toggles, badges.
    required DaisyThemeSizePresets selectors,
  }) = _DaisyThemeSize;

  factory DaisyThemeSize.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeSizeFromJson(json);

  @override
  List<Object?> get props => [fields, selectors];
}

/// A five-step scale computed from [base], in logical pixels.
///
/// For `base: 4`, the steps xs through xl are 24, 32, 40, 48 and 56.
/// These values are tokens; widgets must apply them explicitly.
@Freezed(equal: false, toStringOverride: true)
abstract class DaisyThemeSizePresets with _$DaisyThemeSizePresets, Equatable {
  /// Size scale derived from a single [base] step in logical pixels.
  ///
  /// Each t-shirt size multiplies [base] by a fixed factor, so bumping
  /// [base] rescales the whole group (e.g. `base: 4` yields
  /// xs 24, sm 32, md 40, lg 48, xl 56).
  const DaisyThemeSizePresets._();

  const factory DaisyThemeSizePresets({
    /// Base step in logical pixels; every size below derives from it.
    required int base,
  }) = _DaisyThemeSizePresets;

  /// Extra-small: `base * 6` (24 logical pixels when base is 4).
  int get xs => base * 6;

  /// Small: `base * 8` (32 logical pixels when base is 4).
  int get sm => base * 8;

  /// Medium: `base * 10` (40 logical pixels when base is 4).
  int get md => base * 10;

  /// Large: `base * 12` (48 logical pixels when base is 4).
  int get lg => base * 12;

  /// Extra-large: `base * 14` (56 logical pixels when base is 4).
  int get xl => base * 14;

  factory DaisyThemeSizePresets.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeSizePresetsFromJson(json);

  @override
  List<Object?> get props => [base];
}

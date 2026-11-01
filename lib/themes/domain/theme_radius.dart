import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme_radius.freezed.dart';
part 'generated/theme_radius.g.dart';

/// Daisy Theme Radius
///
/// Preset:
/// - sharp: 0rem -> 0px
/// - soft: 0.25rem -> 4px
/// - medium: 0.5rem -> 8px
/// - large: 1rem -> 16px
/// - full: 2rem -> 32px
@Freezed(equal: false, toStringOverride: true)
abstract class DaisyThemeRadius with _$DaisyThemeRadius, Equatable {
  const DaisyThemeRadius._();

  /// Corner radii of a theme, in logical pixels.
  ///
  /// Mirrors DaisyUI's `--radius-box`, `--radius-field` and
  /// `--radius-selector` tokens (1rem = 16px). Pick values from
  /// [DaisyThemeRadiusPreset].
  const factory DaisyThemeRadius({
    /// Cards, modals, alerts.
    required int boxes,

    /// Buttons, inputs, selects, tabs.
    required int fields,

    /// Checkboxes, toggles, badges.
    required int selectors,
  }) = _DaisyThemeRadius;

  factory DaisyThemeRadius.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeRadiusFromJson(json);

  @override
  List<Object?> get props => [boxes, fields, selectors];
}

/// Fixed radius steps matching DaisyUI's radius scale (1rem = 16px).
abstract class DaisyThemeRadiusPreset {
  /// sharp 0rem -> 0px
  static const int sharp = 0;

  /// soft 0.25rem -> 4px
  static const int soft = 4;

  /// medium 0.5rem -> 8px
  static const int medium = 8;

  /// large 1rem -> 16px
  static const int large = 16;

  /// full 2rem -> 32px
  static const int full = 32;
}

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
@freezed
abstract class DaisyThemeRadius with _$DaisyThemeRadius {
  const factory DaisyThemeRadius({
    /// card, modal, alert
    required int boxes,

    /// button, input, select, tab
    required int fields,

    /// checkbox, toggle, badge
    required int selectors,
  }) = _DaisyThemeRadius;

  factory DaisyThemeRadius.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeRadiusFromJson(json);
}

/// Daisy Theme Radius Preset
///
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

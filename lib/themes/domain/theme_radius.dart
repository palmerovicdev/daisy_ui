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
enum DaisyThemeRadiusPreset {
  sharp(value: 0), // 0rem -> 0px
  soft(value: 4), // 0.25rem -> 4px
  medium(value: 8), // 0.5rem -> 8px
  large(value: 16), // 1rem -> 16px
  full(value: 32); // 2rem -> 32px

  final int value;

  const DaisyThemeRadiusPreset({
    required this.value,
  });
}
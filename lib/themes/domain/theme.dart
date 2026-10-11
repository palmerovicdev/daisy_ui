import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:daisy_ui/themes/domain/theme_colors.dart';
import 'package:daisy_ui/themes/domain/theme_radius.dart';

part 'generated/theme.freezed.dart';
part 'generated/theme.g.dart';

@freezed
abstract class DaisyThemeModel with _$DaisyThemeModel {
  const factory DaisyThemeModel({
    required String id,
    required String name,
    required String description,
    required DaisyThemeColors colors,
    required DaisyThemeRadius radius,
  }) = _DaisyThemeModel;

  factory DaisyThemeModel.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeModelFromJson(json);
}

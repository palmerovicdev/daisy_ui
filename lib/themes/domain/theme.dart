import 'package:daisy_ui/themes/domain/theme_color.dart';
import 'package:daisy_ui/themes/domain/theme_radius.dart';
import 'package:daisy_ui/themes/domain/theme_size.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme.freezed.dart';

part 'generated/theme.g.dart';

@freezed
abstract class DaisyThemeModel with _$DaisyThemeModel {
  const factory DaisyThemeModel({
    required String id,
    required String name,
    required String description,
    required DaisyThemeColor colors,
    required DaisyThemeRadius radius,
    required DaisyThemeSize size,
    required double border,
  }) = _DaisyThemeModel;

  factory DaisyThemeModel.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeModelFromJson(json);
}

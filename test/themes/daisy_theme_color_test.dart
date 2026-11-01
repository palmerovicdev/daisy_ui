import 'dart:ui';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const _pair = DaisyThemeColorPair(
  baseOklch: RayOklch.fromComponents(0.5, 0.1, 120, 0.6),
  contentOklch: RayOklch.fromComponents(0.9, 0.01, 120),
  base200Oklch: RayOklch.fromComponents(0.8, 0.02, 120),
);
const _theme = DaisyThemes.light;

void main() {
  test('Const OKLCH tokens expose Flutter colors and preserve nulls', () {
    final Color background = _pair.base;
    final Color foreground = _pair.content;

    expect(background, _pair.baseOklch.toColor());
    expect(foreground, _pair.contentOklch.toColor());
    expect(_pair.base200, _pair.base200Oklch!.toColor());
    expect(_pair.base300, isNull);
    expect(
      _theme.colors.primary.base,
      DaisyThemeColorPalette.indigo700.toColor(),
    );
  });

  test('Previously serialized OKLCH color pairs retain their JSON format', () {
    final json = <String, dynamic>{
      'base': {'l': 0.5, 'c': 0.1, 'h': 120.0, 'o': 0.6},
      'content': {'l': 0.9, 'c': 0.01, 'h': 120.0},
      'base200': {'l': 0.8, 'c': 0.02, 'h': 120.0},
      'base300': null,
    };

    expect(DaisyThemeColorPair.fromJson(json), _pair);
    expect(_pair.toJson(), json);
  });
}

import 'dart:convert';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const _themes = <DaisyThemeModel>[
  DaisyThemes.light,
  DaisyThemes.dark,
  DaisyThemes.cupcake,
  DaisyThemes.bumblebee,
  DaisyThemes.emerald,
  DaisyThemes.corporate,
  DaisyThemes.synthwave,
  DaisyThemes.retro,
  DaisyThemes.cyberpunk,
  DaisyThemes.valentine,
  DaisyThemes.halloween,
  DaisyThemes.garden,
  DaisyThemes.forest,
  DaisyThemes.aqua,
  DaisyThemes.lofi,
  DaisyThemes.pastel,
  DaisyThemes.fantasy,
  DaisyThemes.wireframe,
  DaisyThemes.black,
  DaisyThemes.luxury,
  DaisyThemes.dracula,
  DaisyThemes.cmyk,
  DaisyThemes.autumn,
  DaisyThemes.business,
  DaisyThemes.acid,
  DaisyThemes.lemonade,
  DaisyThemes.night,
  DaisyThemes.coffee,
  DaisyThemes.winter,
  DaisyThemes.dim,
  DaisyThemes.nord,
  DaisyThemes.sunset,
  DaisyThemes.caramellatte,
  DaisyThemes.abyss,
  DaisyThemes.silk,
];

void main() {
  test(
    'Every built-in theme produces a JSON-only map and round trips directly',
    () {
      for (final theme in _themes) {
        final json = theme.toJson();
        _expectJsonValue(json);
        expect(DaisyThemeModel.fromJson(json), theme, reason: theme.id);
      }
    },
  );

  test('Text JSON round trips preserve every built-in theme', () {
    for (final theme in _themes) {
      final encoded = jsonEncode(theme);
      expect(jsonEncode(theme.toJson()), encoded, reason: theme.id);
      expect(
        DaisyThemeModel.fromJson(jsonDecode(encoded) as Map<String, dynamic>),
        theme,
        reason: theme.id,
      );
    }
  });

  test(
    'Nested tokens preserve nullable surfaces, opacity and fractional borders',
    () {
      final theme = DaisyThemes.light.copyWith(
        border: 1.5,
        colors: DaisyThemes.light.colors.copyWith(
          primary: const DaisyThemeColorPair(
            base: RayOklch.fromComponents(0.5, 0.1, 120, 0.6),
            content: RayOklch.fromComponents(0.9, 0.01, 120),
          ),
        ),
      );
      final json = theme.toJson();
      _expectJsonValue(json);
      expect(DaisyThemeModel.fromJson(json), theme);
    },
  );
}

void _expectJsonValue(Object? value) {
  if (value is Map) {
    for (final entry in value.entries) {
      expect(entry.key, isA<String>());
      _expectJsonValue(entry.value);
    }
  } else if (value is List) {
    for (final item in value) {
      _expectJsonValue(item);
    }
  } else {
    expect(value, anyOf(isNull, isA<String>(), isA<num>(), isA<bool>()));
  }
}

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Equivalent theme copies are equal but not identical', () {
    final original = DaisyThemes.light;
    final equivalent = original.copyWith();

    expect(identical(original, equivalent), isFalse);
    expect(original, equivalent);
    expect(original.hashCode, equivalent.hashCode);
  });

  test('A changed token makes the theme and its ancestors different', () {
    final original = DaisyThemes.light;
    final changedBorder = original.copyWith(border: 2.0);
    final changedColor = original.copyWith(
      colors: original.colors.copyWith(
        primary: const DaisyThemeColorPair(
          baseOklch: RayOklch.fromComponents(0.5, 0.1, 120),
          contentOklch: RayOklch.fromComponents(0.9, 0.01, 120),
        ),
      ),
    );

    expect(original, isNot(changedBorder));
    expect(original, isNot(changedColor));
    expect(original.colors, isNot(changedColor.colors));
    expect(original.hashCode, isNot(changedBorder.hashCode));
  });

  test('Equality covers every theme token model', () {
    final original = DaisyThemes.light;

    expect(original.colors, original.colors.copyWith());
    expect(original.colors.base, original.colors.base.copyWith());
    expect(original.radius, original.radius.copyWith());
    expect(original.size, original.size.copyWith());
    expect(original.size.fields, original.size.fields.copyWith());

    expect(
      original.colors.base,
      isNot(
        original.colors.base.copyWith(
          baseOklch: RayOklch.fromComponents(0.4, 0.1, 120),
        ),
      ),
    );
    expect(original.radius, isNot(original.radius.copyWith(boxes: 1)));
    expect(original.size.fields, isNot(original.size.fields.copyWith(base: 5)));
  });

  test('Equal themes collapse in a Set and are found by an equivalent', () {
    final original = DaisyThemes.light;
    final equivalent = original.copyWith();
    final changed = original.copyWith(border: 2.0);
    final themes = <DaisyThemeModel>{original, equivalent, changed};

    expect(themes, hasLength(2));
    expect(themes.contains(equivalent), isTrue);
  });

  test('Generated toString keeps the readable theme representation', () {
    expect(DaisyThemes.light.toString(), contains('id: light'));
    expect(DaisyThemes.light.toString(), contains('border: 1.0'));
  });
}

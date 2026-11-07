import 'package:daisy_ui/themes/application/daisy_themes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('values contains all built-in themes in declaration order', () {
    expect(DaisyThemes.values, [
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
    ]);
  });
}

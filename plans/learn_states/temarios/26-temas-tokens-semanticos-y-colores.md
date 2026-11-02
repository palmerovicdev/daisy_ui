# 26. Temas, tokens semánticos y colores

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 25](25-scopes-anidados-e-independencia.md) · **Estado:** pendiente

## Qué vas a aprender

Hasta ahora hemos seguido el viaje de un tema: quién lo guarda, quién avisa y quién se reconstruye. Del tema en sí solo hemos mirado `name` y poco más. Ahora abrimos la caja. Cuando un botón pide `theme.colors.primary.base`, ¿qué está pidiendo? ¿Por qué no pide «indigo»? ¿Por qué `colors.base.base` repite la palabra? ¿Y por qué el fondo de la aplicación no cambia solo aunque cambie el tema?

Al terminar podrás elegir el token adecuado para cada parte de un widget y calcular `md` a partir de `base`. También sabrás convertir un `RayOklch` a `Color` y distinguir los datos que guarda DaisyUI de su aplicación, que siempre es explícita, a widgets o a `ThemeData`.

Los programas sin dependencias se pueden ejecutar en [DartPad](https://dartpad.dev/) en modo **Dart**. Las pruebas son archivos completos: copia **una cada vez** a `test/estudio_tokens_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_tokens_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–5 en otra y terminar con 6–7 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8 y `prism_flutter` 2.1.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas.

## 1. Un token es un nombre en lugar de un valor

Imagina una tarjeta escrita para el tema claro: fondo blanco, texto negro, esquinas de 8. Si el valor está escrito en el widget, cambiar de tema no le afecta. Si el widget pide «el fondo» y «el texto» al tema, el mismo código sirve para cualquier tema:

```dart
class TemaMini {
  const TemaMini({
    required this.fondo,
    required this.texto,
    required this.radio,
  });

  final String fondo;
  final String texto;
  final int radio;
}

void tarjetaFija() {
  print('Fija: fondo blanco, texto negro, radio 8');
}

void tarjeta(TemaMini tema) {
  print('Tokens: fondo ${tema.fondo}, texto ${tema.texto}, radio ${tema.radio}');
}

void main() {
  const claro = TemaMini(fondo: 'blanco', texto: 'negro', radio: 8);
  const oscuro = TemaMini(fondo: 'azul noche', texto: 'blanco', radio: 16);

  tarjetaFija();
  tarjeta(claro);
  tarjeta(oscuro);
}
```

La salida es:

```text
Fija: fondo blanco, texto negro, radio 8
Tokens: fondo blanco, texto negro, radio 8
Tokens: fondo azul noche, texto blanco, radio 16
```

`fondo`, `texto` y `radio` son **tokens de diseño**: nombres estables para decisiones visuales. El widget conoce el nombre; el tema aporta el valor. Eso es lo que permite que 35 temas compartan el mismo código de widgets.

Un token sigue siendo un dato. Este programa no pinta nada: solo muestra el dato en un texto. Dónde y cómo se usa lo decide quien lo lee, y volveremos a ello en el apartado 7.

### Practica 1

Añades un tercer tema, `const rosa = TemaMini(fondo: 'rosa', texto: 'negro', radio: 32);`. ¿Qué tendrías que cambiar en `tarjeta` para mostrarlo? ¿Y en `tarjetaFija`?

<details>
<summary>Ver respuesta</summary>

En `tarjeta`, nada: basta con llamar a `tarjeta(rosa)`. `tarjetaFija` no recibe ningún tema, así que habría que escribir otra función o añadir parámetros, es decir, reinventar los tokens.

</details>

## 2. Roles semánticos: qué significa, no de qué color es

Un nombre como `indigo` describe el aspecto. Un nombre como `primary` describe la **función**: la acción o el color de marca principal. Ese tipo de nombre se llama **rol semántico**. Mira qué ocurre al preguntar por el mismo rol en temas diferentes:

```dart
import 'dart:ui';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

String hex(Color color) => color.toARGB32().toRadixString(16);

void main() {
  test('el mismo rol tiene un valor distinto en cada tema', () {
    for (final tema in [DaisyThemes.light, DaisyThemes.dark]) {
      print('${tema.name} primary: ${hex(tema.colors.primary.base)}');
      print('${tema.name} base: ${hex(tema.colors.base.base)}');
    }

    print('danger == error: ${DaisyThemes.light.colors.danger == DaisyThemes.light.colors.error}');
  });
}
```

La salida incluye:

```text
Light primary: ff422ad5
Light base: ffffffff
Dark primary: ff605dff
Dark base: ff1d232a
danger == error: true
```

`dart:ui` aporta el tipo `Color`. `toARGB32()` devuelve el color como un entero con sus cuatro canales, y `toRadixString(16)` lo escribe en hexadecimal: `ff` es la opacidad y `422ad5`, el rojo, el verde y el azul. Solo lo usamos para poder leer el resultado. El código que pide `primary` es siempre el mismo; lo que cambia es el tema del que lee.

[`DaisyThemeColor`](../../../lib/themes/domain/theme/theme_color.dart) agrupa diez roles:

| Rol | Para qué sirve |
|-----|----------------|
| `base` | Superficie por defecto: fondo de la aplicación, tarjetas |
| `primary`, `secondary`, `accent` | Colores de marca y de énfasis |
| `neutral` | Superficies de poco énfasis |
| `info`, `success`, `warning`, `error` | Estados que se comunican a la persona usuaria |
| `danger` | Acciones destructivas |

Que `danger` valga igual que `error` en `light` no es casualidad. El [catálogo](../../../lib/themes/application/daisy_themes.dart) lo documenta: *«`danger` reuses `error`, which is the destructive role in DaisyUI»*. Aun así son dos roles: un botón «Eliminar» debe pedir `danger`, y si un tema propio decide distinguirlos, el botón se adapta sin tocar su código.

### Practica 2

Elige un rol para cada elemento: (a) el fondo de una pantalla; (b) un aviso de «Guardado correctamente»; (c) el botón «Borrar cuenta»; (d) un botón «Continuar», la acción principal. ¿Qué pasaría en el tema `dark` si para (a) hubieras escrito `Color(0xffffffff)`?

<details>
<summary>Ver respuesta</summary>

(a) `base`; (b) `success`; (c) `danger`; (d) `primary`. Con `Color(0xffffffff)`, la pantalla seguiría blanca en `dark`, mientras los textos que usen `base.content` pasarían a ser claros: texto casi blanco sobre blanco. Es exactamente el fallo que evitan los roles.

</details>

## 3. Superficie y contenido: por qué existen los pares

Un color de texto no es bueno o malo por sí mismo: depende de lo que tenga debajo. Por eso los colores se agrupan de dos en dos. La **superficie** es lo que se pinta de fondo. El **contenido** es lo que se dibuja encima: texto o iconos. [`DaisyThemeColorPair`](../../../lib/themes/domain/theme/theme_color.dart) guarda esa pareja:

```dart
import 'dart:ui';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

String hex(Color color) => color.toARGB32().toRadixString(16);

void main() {
  test('pares de superficie y contenido', () {
    final colores = DaisyThemes.light.colors;

    print('primary: ${hex(colores.primary.base)} / ${hex(colores.primary.content)}');
    print('warning: ${hex(colores.warning.base)} / ${hex(colores.warning.content)}');
    print('base.base200: ${colores.base.base200 == null ? 'null' : hex(colores.base.base200!)}');
    print('base.base300: ${colores.base.base300 == null ? 'null' : hex(colores.base.base300!)}');
    print('primary.base200: ${colores.primary.base200}');
  });
}
```

La salida incluye:

```text
primary: ff422ad5 / ffe0e7ff
warning: fffdb700 / ff793104
base.base200: fff9f9f9
base.base300: ffefefef
primary.base200: null
```

`primary` es un fondo oscuro con contenido claro; `warning`, un fondo claro con contenido oscuro. Si usaras `primary.content` sobre `warning.base`, pondrías texto claro sobre fondo claro. La regla es sencilla: **usa el contenido del mismo par que la superficie**.

Aquí se aclara por fin la repetición de `colors.base.base`. Son dos niveles con la misma palabra:

```text
theme.colors.base.base
             │    └── del par: la superficie principal
             └─────── el rol: la superficie por defecto de la aplicación
```

También existe `theme.colors.primary.base`: la superficie del rol `primary`. Leído de izquierda a derecha es «del tema, los colores, el rol, la parte del par».

`base200` y `base300` son superficies escalonadas, útiles para distinguir una tarjeta del fondo que tiene debajo. Son **opcionales**: su tipo es `Color?`, y en los temas incluidos solo las tiene el rol `base`. Por eso `primary.base200` es `null`. Los operadores `?.` y `??` de la unidad 23 sirven aquí:

```dart
// Fragmento: usa la superficie escalonada si existe; si no, la principal.
final fondo = theme.colors.primary.base200 ?? theme.colors.primary.base;
```

### Practica 3

Un `Chip` tiene fondo `theme.colors.accent.base`. ¿Qué token usarías para su texto? ¿Compila `Color fondo = theme.colors.base.base200;`? ¿Por qué no compila, si en los temas incluidos ese valor siempre existe?

<details>
<summary>Ver respuesta</summary>

`theme.colors.accent.content`, del mismo par. La línea no compila porque el tipo de `base200` es `Color?`, y Dart comprueba los **tipos**, no el valor que tendrá al ejecutarse (unidades 3 y 23). Además, un tema propio podría omitirlo. Lo correcto es decidir qué hacer si falta, por ejemplo con `?? theme.colors.base.base`.

</details>

## 4. De `RayOklch` a `Color`

Si miras cómo se define un par, verás que no guarda `Color`:

```dart
// Fragmento de lib/themes/domain/theme/theme_color.dart.
const factory DaisyThemeColorPair({
  @JsonKey(name: 'base') required RayOklch baseOklch,
  @JsonKey(name: 'content') required RayOklch contentOklch,
  @JsonKey(name: 'base200') RayOklch? base200Oklch,
  @JsonKey(name: 'base300') RayOklch? base300Oklch,
}) = _DaisyThemeColorPair;

Color get base => baseOklch.toColor();
Color get content => contentOklch.toColor();
```

La sintaxis de `const factory` y `@JsonKey` la veremos en las unidades 27 y 28. Lo que importa ahora es la forma: el dato guardado es un `RayOklch`, y `base` es un **getter** que lo convierte cuando se lee.

`RayOklch`, del paquete `prism_flutter`, representa un color en el espacio OKLCH con tres componentes y una opacidad opcional. L es la claridad, C es la intensidad del color y H es el tono, en grados. Aquí basta con eso: los detalles de OKLCH, la conversión a RGB, los límites de representación y el contraste forman una profundización aparte, como indica el plan.

```dart
import 'dart:ui';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

String hex(Color color) => color.toARGB32().toRadixString(16);

void main() {
  test('convertir un RayOklch a Color', () {
    const oklch = RayOklch.fromComponents(0.45, 0.24, 277.023);
    const translucido = RayOklch.fromComponents(0.5, 0.1, 120, 0.6);

    print(oklch);
    print(hex(oklch.toColor()));
    print(translucido.opacity);
    print(translucido.toColor().a);

    final primera = DaisyThemes.light.colors.primary.base;
    final segunda = DaisyThemes.light.colors.primary.base;
    print('Mismo objeto: ${identical(primera, segunda)}');
    print('Iguales: ${primera == segunda}');
  });
}
```

La salida incluye:

```text
RayOklch(lightness: 0.450, chroma: 0.240, hue: 277.0°, opacity: 1.000)
ff422ad5
0.6
0.6
Mismo objeto: false
Iguales: true
```

1. `RayOklch.fromComponents` es un constructor `const`, así que `oklch` puede ser una constante de compilación.
2. `toColor()` hace una conversión con cálculos, y por tanto solo puede ejecutarse en tiempo de ejecución. El método viene de la extensión `RayToFlutterColor` (unidad 24), y `daisy_ui.dart` la vuelve a exportar: no necesitas importar `prism_flutter`.
3. Cada lectura de `base` ejecuta el getter y crea un `Color` nuevo: objetos distintos, pero iguales con `==` (unidad 8).

¿Por qué esta separación? Porque así `DaisyThemes.light` puede ser `const`, algo que no permitiría llamar a `toColor()` en su definición. El tema guarda datos constantes y el widget obtiene el `Color` de Flutter al leerlos.

### Practica 4

¿Qué imprime `DaisyThemeColorPalette.white.toColor().a`? Si un widget lee `theme.colors.primary.base` dos veces en su `build`, ¿se guarda el resultado de la primera conversión? ¿Es un problema?

<details>
<summary>Ver respuesta</summary>

Imprime `1.0`: `white` no indica opacidad, y `fromComponents` usa `1.0` por defecto. No se guarda: el getter convierte en cada lectura y el tema no conserva ninguna caché. Normalmente no es un problema; si un cálculo se repitiera muchas veces en un bucle, podrías guardarlo en una variable local dentro de ese `build`.

</details>

## 5. Radios, tamaños, grosor de borde y unidades

Además de colores, cada tema decide formas y medidas. Todas se expresan en **píxeles lógicos**, la unidad de Flutter que no depende de la densidad de la pantalla. Lo único que los diferencia es su forma de almacenarse:

| Token | Dónde | Tipo | Para qué |
|-------|-------|------|----------|
| `radius.boxes` | [`DaisyThemeRadius`](../../../lib/themes/domain/theme/theme_radius.dart) | `int` | Tarjetas, modales, alertas |
| `radius.fields` | | `int` | Botones, campos, pestañas |
| `radius.selectors` | | `int` | Casillas, interruptores, insignias |
| `size.fields`, `size.selectors` | [`DaisyThemeSize`](../../../lib/themes/domain/theme/theme_size.dart) | `DaisyThemeSizePresets` | Escala de medidas de cada grupo |
| `border` | [`DaisyThemeModel`](../../../lib/themes/domain/theme.dart) | `double` | Grosor de borde global |

Los radios y los bordes suelen tomar sus valores de unas constantes con nombre, como `DaisyThemeRadiusPreset.medium` (8) o [`DaisyThemeBorderWidthPreset.thin`](../../../lib/themes/domain/theme/theme_border.dart) (1). Son una ayuda para escribir temas: el modelo solo guarda el número.

La escala de tamaños funciona de otra manera, porque **solo guarda un número**, `base`, y calcula el resto:

```dart
// Fragmento de lib/themes/domain/theme/theme_size.dart.
const factory DaisyThemeSizePresets({
  required int base,
}) = _DaisyThemeSizePresets;

int get xs => base * 6;
int get sm => base * 8;
int get md => base * 10;
int get lg => base * 12;
int get xl => base * 14;
```

Es el mismo razonamiento de la unidad 11: guardar un dato y derivar los demás evita que se contradigan. No existe forma de tener `base: 4` con `md: 50`. Vamos a comprobarlo:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('medidas de dos temas', () {
    for (final tema in [DaisyThemes.light, DaisyThemes.cupcake]) {
      print(tema.name);
      print('  radio de campos: ${tema.radius.fields}');
      print('  radio de cajas: ${tema.radius.boxes}');
      print('  md: ${tema.size.fields.md}');
      print('  borde: ${tema.border}');
    }

    const presets = DaisyThemeSizePresets(base: 5);
    print('base 5, md: ${presets.md}');
    print('Guardado: ${presets.toJson()}');
  });
}
```

La salida incluye:

```text
Light
  radio de campos: 4
  radio de cajas: 8
  md: 40
  borde: 1.0
Cupcake
  radio de campos: 32
  radio de cajas: 16
  md: 40
  borde: 2.0
base 5, md: 50
Guardado: {base: 5}
```

Cupcake redondea mucho más y usa un borde más grueso; su `md` coincide porque los 35 temas incluidos usan `base: 4`. La última línea muestra que el dato guardado es `base`: `md` no existe como dato. Volveremos a `toJson` en la unidad 28.

Fíjate en los tipos. `radius.fields` es un `int`, y `BorderRadius.circular` pide un `double`, por eso el código real escribe `.toDouble()`:

```dart
// Fragmento de lib/themes/presentation/action/button.dart.
borderRadius: BorderRadius.circular(th.radius.fields.toDouble()),
```

`md` también es `int`, y `SizedBox(height: ...)` espera un `double?`, así que hará falta la misma conversión.

### Practica 5

Calcula a mano, sin ejecutar: para `base: 6`, ¿cuánto valen `xs`, `md` y `xl`? Si `size.selectors` tiene `base: 3` y `size.fields` tiene `base: 4`, ¿cuál es el `sm` de cada grupo? ¿Por qué no compila `SizedBox(height: theme.size.fields.md)`?

<details>
<summary>Ver respuesta</summary>

`xs` = 36, `md` = 60 y `xl` = 84. `selectors.sm` = 24 y `fields.sm` = 32: cada grupo tiene su propia base. No compila porque `md` es `int` y `height` es `double?`; Dart no convierte automáticamente un `int` no literal en `double`. Se escribe `theme.size.fields.md.toDouble()`.

</details>

## 6. Localizar los tokens en el código

Vamos a leer código con esta guía en la mano. Primero, la vista previa que se reproduce en el [apartado 8 de la unidad 25](25-scopes-anidados-e-independencia.md#8-el-ejemplo-anterior-completo):

```dart
// Fragmento de _ThemePreview, versión anterior del ejemplo.
final theme = context.daisyTheme;

return Container(
  padding: const EdgeInsets.all(24),
  color: theme.colors.base.base,
  child: Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        'Preview: ${theme.name}',
        style: TextStyle(color: theme.colors.base.content),
      ),
```

El contenedor usa la superficie del rol `base`, y el texto, el contenido del **mismo par**. `padding` es un valor fijo: no todas las medidas de un widget tienen que ser tokens, y el modelo no incluye ninguno para el espaciado.

Ahora el [ejemplo actual](../../../example/lib/main.dart), que ya no tiene vista previa. Dentro de `_ButtonContent`:

```dart
// Fragmento de example/lib/main.dart.
Ink(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
  decoration: BoxDecoration(
    color: const Color(0xfff4f4f4),
    border: Border.all(color: const Color(0xffe2e2e2)),
    borderRadius: BorderRadius.circular(
      context.daisyTheme.radius.fields.toDouble(),
    ),
  ),
```

Solo el radio es un token: `radius.fields`, el grupo de botones y campos. Esa línea crea la dependencia con el scope, de modo que `_ButtonContent` se reconstruye si cambia el tema. Sin embargo, el fondo del botón y su borde son `Color` fijos.

### Practica 6

Imagina que el ejemplo actual cambia de `light` a `cupcake`. ¿Qué cambiaría en el botón del ejemplo: el color de fondo, el grosor del borde, las esquinas? ¿Y si cambiara de `light` a `dark`? Consulta los valores del apartado 5.

<details>
<summary>Ver respuesta</summary>

Con `cupcake`, solo las esquinas: `radius.fields` pasa de 4 a 32. El fondo y el color del borde son fijos, y `Border.all` no recibe `theme.border`, así que usa su grosor predeterminado. Con `dark`, en cambio, no se vería ninguna diferencia: tiene el mismo `radius.fields` (4), según documenta el catálogo, y el resto es fijo. El widget se reconstruiría porque el tema ha cambiado, pero con el mismo resultado visual.

</details>

## 7. Los tokens no se aplican solos

`DaisyThemeScope` hace llegar un dato a los widgets. No configura Flutter: en `lib/` no aparece `ThemeData` ni `ColorScheme`. Por tanto, un widget de Material que no lea el token explícitamente no se entera:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el scope no modifica ThemeData', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    late BuildContext lector;

    await tester.pumpWidget(
      DaisyThemeScope(
        controller: controller,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              lector = context;
              context.daisyTheme;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );

    final material = Theme.of(lector).colorScheme.primary;
    expect(lector.daisyTheme.colors.primary.base, isNot(material));

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();

    expect(lector.daisyTheme.name, 'Dark');
    expect(Theme.of(lector).colorScheme.primary, material);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

La prueba demuestra que el color primario de `Theme.of` y el de DaisyUI son datos independientes, y que cambiar el tema de DaisyUI no toca el de Material. Por eso un `ElevatedButton` sin más configuración conserva los colores de Material.

Si queremos que los widgets de Material sigan al tema, hay que **traducirlo** por encima de `MaterialApp`. Esa traducción no forma parte del paquete: la escribe la aplicación.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

ThemeData traducir(DaisyThemeModel tema, Brightness brillo) {
  final colores = tema.colors;

  return ThemeData(
    scaffoldBackgroundColor: colores.base.base,
    colorScheme: ColorScheme(
      brightness: brillo,
      primary: colores.primary.base,
      onPrimary: colores.primary.content,
      secondary: colores.secondary.base,
      onSecondary: colores.secondary.content,
      error: colores.error.base,
      onError: colores.error.content,
      surface: colores.base.base,
      onSurface: colores.base.content,
    ),
  );
}

void main() {
  testWidgets('una traducción explícita a ThemeData', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    late BuildContext lector;

    await tester.pumpWidget(
      DaisyThemeScope(
        controller: controller,
        child: Builder(
          builder: (context) {
            final tema = context.daisyTheme;

            return MaterialApp(
              theme: traducir(
                tema,
                tema.id == 'dark' ? Brightness.dark : Brightness.light,
              ),
              home: Builder(
                builder: (context) {
                  lector = context;
                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
      ),
    );

    expect(
      Theme.of(lector).colorScheme.primary,
      DaisyThemes.light.colors.primary.base,
    );

    controller.setTheme(DaisyThemes.dark);
    await tester.pumpAndSettle();

    expect(
      Theme.of(lector).colorScheme.primary,
      DaisyThemes.dark.colors.primary.base,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Las piezas son las de siempre, en otro orden:

1. El `Builder` exterior lee `context.daisyTheme` y registra la dependencia (unidad 21). Debe estar **debajo** del scope (unidad 20).
2. Al cambiar el tema, ese `Builder` se reconstruye y crea otro `ThemeData`.
3. `MaterialApp` recibe el nuevo `theme`.

La prueba usa `pumpAndSettle`, y no `pump`, porque `MaterialApp` anima los cambios de `ThemeData` durante un breve intervalo. Con un solo `pump`, `Theme.of` todavía devolvería el tema anterior. Esta prueba solo comprueba los colores que hemos traducido; no demuestra el aspecto final de ningún widget de Material.

Fíjate en `brillo`: hay que decidirlo por separado, porque el modelo no guarda ese dato. El [catálogo](../../../lib/themes/application/daisy_themes.dart) lo advierte: *«The model does not represent color-scheme, depth or noise tokens»*. La comparación `tema.id == 'dark'` solo acierta con este ejemplo: `cupcake` es claro, pero `dracula` es oscuro y recibiría `Brightness.light`. Una aplicación real necesitaría guardar esa decisión aparte.

### Practica 7

En la primera prueba, ¿por qué sí cambia `lector.daisyTheme.name` y no `Theme.of(lector)`? En la segunda, ¿qué pasaría si el `Builder` exterior no existiera y escribiéramos `MaterialApp(theme: traducir(DaisyThemes.light, Brightness.light), ...)` directamente?

<details>
<summary>Ver respuesta</summary>

`daisyTheme` lee del scope, cuyo controlador ha cambiado. `Theme.of` lee el `ThemeData` que `MaterialApp` ya tenía, y nadie lo ha sustituido. En el segundo caso, `traducir` se llamaría con un valor fijo una sola vez: el `ThemeData` quedaría con los colores de `light` para siempre, ya que nada lee el tema actual ni registra una dependencia.

</details>

## Ejercicio final: una tarjeta que solo usa tokens

Escribe una prueba con un widget `Aviso` que reciba un `DaisyThemeColorPair` llamado `rol` y un texto:

1. Su fondo es la superficie de `rol`, y el texto, el contenido de `rol`.
2. Las esquinas usan el radio de las cajas; el borde, el grosor global con el contenido de `rol`; su altura mínima es `size.fields.lg`.
3. Lo muestra un `Builder` que lee el tema y le pasa `theme.colors.warning`.

Después, cambia de `light` a `cupcake`. Antes de escribir los `expect`, predice para cada tema: el radio, el grosor del borde y la altura. Responde también: ¿qué token usarías si la tarjeta fuera una insignia en lugar de una tarjeta? ¿Y qué le pasaría a la tarjeta si no recibiera `rol`, sino que tuviera su propia constante `DaisyThemes.light.colors.warning`?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Aviso extends StatelessWidget {
  const Aviso({super.key, required this.rol, required this.texto});

  final DaisyThemeColorPair rol;
  final String texto;

  @override
  Widget build(BuildContext context) {
    final theme = context.daisyTheme;

    return Container(
      constraints: BoxConstraints(
        minHeight: theme.size.fields.lg.toDouble(),
      ),
      decoration: BoxDecoration(
        color: rol.base,
        border: Border.all(color: rol.content, width: theme.border),
        borderRadius: BorderRadius.circular(theme.radius.boxes.toDouble()),
      ),
      child: Text(texto, style: TextStyle(color: rol.content)),
    );
  }
}

void main() {
  testWidgets('el aviso sigue al tema', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: Align(
            child: Builder(
              builder: (context) => Aviso(
                rol: context.daisyTheme.colors.warning,
                texto: 'Atención',
              ),
            ),
          ),
        ),
      ),
    );

    BoxDecoration decoracion() =>
        tester.widget<Container>(find.byType(Container)).decoration!
            as BoxDecoration;
    Color colorTexto() =>
        tester.widget<Text>(find.text('Atención')).style!.color!;

    expect(decoracion().color, DaisyThemes.light.colors.warning.base);
    expect(colorTexto(), DaisyThemes.light.colors.warning.content);
    expect(decoracion().borderRadius, BorderRadius.circular(8));
    expect(decoracion().border, Border.all(
      color: DaisyThemes.light.colors.warning.content,
      width: 1,
    ));
    expect(tester.getSize(find.byType(Aviso)).height, greaterThanOrEqualTo(48));

    controller.setTheme(DaisyThemes.cupcake);
    await tester.pump();

    expect(decoracion().color, DaisyThemes.cupcake.colors.warning.base);
    expect(colorTexto(), DaisyThemes.cupcake.colors.warning.content);
    expect(decoracion().borderRadius, BorderRadius.circular(16));
    expect(decoracion().border, Border.all(
      color: DaisyThemes.cupcake.colors.warning.content,
      width: 2,
    ));
    expect(tester.getSize(find.byType(Aviso)).height, greaterThanOrEqualTo(48));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Con `light`, el radio es 8, el borde 1 y la altura mínima 48 (`4 * 12`). Con `cupcake`, el radio es 16 y el borde 2, mientras que la altura sigue siendo 48, ya que también tiene `base: 4`.

La tarjeta se actualiza por dos caminos que conviene distinguir. El `Builder` depende del scope y crea otro `Aviso` con el nuevo `rol`, y el propio `Aviso` también depende del scope, porque lee `context.daisyTheme` para las medidas. Si `Aviso` no leyera el tema, seguiría funcionando con lo que recibe por parámetro.

Para una insignia, el radio sería `radius.selectors`, el grupo de casillas, interruptores e insignias, y su tamaño, `size.selectors`. Con una constante `DaisyThemes.light.colors.warning`, los colores quedarían fijos al cambiar de tema: las medidas seguirían al scope, y los colores, no. Es el mismo fallo del apartado 1, aunque esté escrito con nombres de tokens: leer un token de un tema concreto no es lo mismo que leerlo del tema actual.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué es un token de diseño? ¿Qué aporta el widget y qué aporta el tema? **Apartado 1.**
2. ¿Por qué se llama `primary` y no `indigo`? ¿Por qué un botón destructivo debería pedir `danger` si vale igual que `error`? **Apartado 2.**
3. ¿Qué dos colores forman un par, y cuál es la regla para combinarlos? **Apartado 3.**
4. ¿Qué significa cada palabra de `theme.colors.base.base`? ¿Por qué `base200` es `Color?`? **Apartado 3.**
5. ¿Qué guarda el par y qué devuelve su getter `base`? ¿Por qué esa separación permite un tema `const`? **Apartado 4.**
6. ¿Cuánto vale `md` si `base` es 5? ¿Por qué no se guarda? **Apartado 5.**
7. ¿Por qué hace falta `.toDouble()` con `radius.fields`? **Apartado 5.**
8. En el ejemplo actual, ¿qué partes del botón dependen de un token? **Apartado 6.**
9. ¿Qué tendría que hacer una aplicación para que un `ElevatedButton` siga al tema? ¿Por qué no basta con `DaisyThemeScope`? **Apartado 7.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y elijas cada token por su función, sin mirar el valor. La siguiente unidad estudia cómo se definen estos modelos: qué escribimos nosotros, qué produce Freezed y cómo se crea un tema nuevo sin modificar el anterior.

## Para consultar si necesitas reforzar

- [Colores de daisyUI](https://daisyui.com/docs/colors/): de dónde proceden los roles y los nombres `base`, `content` y compañía. Es documentación de la biblioteca CSS: los nombres coinciden, no el código.
- [`prism_flutter`](https://pub.dev/packages/prism_flutter): el paquete que aporta `RayOklch` y `toColor()`.
- [`ThemeData`](https://api.flutter.dev/flutter/material/ThemeData-class.html) y [`ColorScheme`](https://api.flutter.dev/flutter/material/ColorScheme-class.html): el destino de una traducción explícita.
- [Colores y pares](../../../lib/themes/domain/theme/theme_color.dart), [radios](../../../lib/themes/domain/theme/theme_radius.dart), [tamaños](../../../lib/themes/domain/theme/theme_size.dart), [bordes](../../../lib/themes/domain/theme/theme_border.dart) y [catálogo de temas](../../../lib/themes/application/daisy_themes.dart): los datos reales de DaisyUI.

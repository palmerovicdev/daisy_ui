# 27. Modelos inmutables y Freezed

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 26](26-temas-tokens-semanticos-y-colores.md) · **Estado:** pendiente

## Qué vas a aprender

Quieres un tema igual que `light`, pero con el borde más grueso. No puedes escribir `theme.border = 2`: no compila. Debes crear otro tema con `copyWith`. Sin embargo, si miras [theme.dart](../../../lib/themes/domain/theme.dart), no encontrarás ningún método `copyWith`, ningún campo `border` y tampoco una clase que se pueda instanciar. ¿Dónde está todo eso?

Al terminar sabrás leer la definición de un modelo línea por línea y decir qué escribimos nosotros y qué produce Freezed. Podrás crear copias, también de datos anidados, y comprobar que el original se conserva. Y podrás explicar cómo se relacionan inmutabilidad, igualdad y cambio de estado, incluida una trampa real: en DaisyUI, **la igualdad no la genera Freezed**.

Los programas sin dependencias se pueden ejecutar en [DartPad](https://dartpad.dev/) en modo **Dart**. Las pruebas son archivos completos: copia **una cada vez** a `test/estudio_modelos_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_modelos_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–5 en otra y terminar con 6–7 y el ejercicio final.

Esta unidad usa los modelos ya generados. Cómo se generan y cómo se configura esa generación se estudia en la unidad 29. Los ejemplos se contrastaron con Flutter 3.47.8, `freezed` 4.0.3 y `equatable` 3.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas.

## 1. Lo que costaría escribirlo a mano

Un **modelo** es una clase cuyo trabajo es representar datos. Empecemos por el modelo más pequeño del proyecto, los radios, escrito sin ayuda y con solo dos campos:

```dart
class Radios {
  const Radios({required this.cajas, required this.campos});

  final int cajas;
  final int campos;

  Radios copyWith({int? cajas, int? campos}) {
    return Radios(
      cajas: cajas ?? this.cajas,
      campos: campos ?? this.campos,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Radios && cajas == other.cajas && campos == other.campos;

  @override
  int get hashCode => Object.hash(cajas, campos);

  @override
  String toString() => 'Radios(cajas: $cajas, campos: $campos)';
}

void main() {
  const original = Radios(cajas: 8, campos: 4);
  final copia = original.copyWith(campos: 32);

  print(original);
  print(copia);
  print(original == original.copyWith());
}
```

La salida es:

```text
Radios(cajas: 8, campos: 4)
Radios(cajas: 8, campos: 32)
true
```

Ya conoces cada pieza por la unidad 8. `copyWith` es el `conBorde` de aquel ejercicio, generalizado: recibe parámetros opcionales, y `??` usa el valor actual para los que no se indican.

Con dos campos es asumible. El problema es que **cada campo se repite en varios sitios**: declaración, constructor, `copyWith`, `==`, `hashCode` y `toString`. Cuando añades un campo y olvidas uno de esos sitios, el programa compila y falla en silencio. `DaisyThemeModel` tiene siete campos, y `DaisyThemeColor`, diez. Ese código repetitivo es lo que [Freezed](https://pub.dev/packages/freezed) escribe por nosotros.

### Practica 1

Añade un campo `final int selectores;` al modelo, pero olvida añadirlo a `==`. Después, compara `Radios(cajas: 8, campos: 4, selectores: 1)` con `Radios(cajas: 8, campos: 4, selectores: 2)`. ¿Qué resultado da? ¿Avisaría el compilador?

<details>
<summary>Ver respuesta</summary>

Da `true`: la regla no mira `selectores`, así que los considera iguales. El compilador no avisa, porque el `==` sigue siendo Dart válido. Recuerda la unidad 8: un `ValueNotifier` que reciba el segundo valor no avisaría a nadie. Volveremos a esta trampa en el apartado 6.

</details>

## 2. Tres piezas de sintaxis antes de leer un modelo

Un modelo de Freezed usa tres piezas de Dart que no hemos necesitado hasta ahora. Veámoslas por separado.

Una **anotación** es una marca que empieza por `@` y añade información sobre una declaración, sin cambiar lo que hace. Ya conoces `@override`. Otras herramientas pueden leer estas marcas: `@Freezed(...)` por sí sola no hace nada, pero el generador la busca para saber qué clases debe procesar.

Un **mixin** es un conjunto de miembros que una clase incorpora con `with`, sin necesidad de heredar de él. Una **fábrica** (`factory`) es un constructor que no está obligado a crear una instancia de su propia clase: puede devolver una de otra, siempre que encaje con el tipo.

```dart
mixin Descriptible {
  String get nombre;

  String describir() => 'Soy $nombre';
}

abstract class Tema with Descriptible {
  const Tema();

  factory Tema.oscuro() => const _TemaOscuro();
}

class _TemaOscuro extends Tema {
  const _TemaOscuro();

  @override
  String get nombre => 'oscuro';
}

void main() {
  final tema = Tema.oscuro();

  print(tema.describir());
  print(tema.runtimeType);
  print(tema is Tema);
}
```

La salida es:

```text
Soy oscuro
_TemaOscuro
true
```

1. `mixin Descriptible` aporta `describir()`, y pide que exista un getter `nombre`.
2. `abstract class Tema` no se puede instanciar con su constructor generativo, y `with Descriptible` le añade el método. No tiene por qué implementar `nombre`, porque es abstracta.
3. `factory Tema.oscuro()` parece crear un `Tema`, pero devuelve un `_TemaOscuro`. Quien llama solo conoce `Tema`.
4. `_TemaOscuro` es la clase concreta, oculta por el `_` (unidad 15).

Hay una forma abreviada para una fábrica que solo reenvía a otro constructor. Se llama **constructor de redirección** y se escribe con `=`:

```dart
// Fragmento: las dos fábricas equivalen. La segunda redirige, y además admite const.
factory Tema.oscuro() => const _TemaOscuro();
const factory Tema.oscuro() = _TemaOscuro;
```

### Practica 2

En el programa, ¿qué pasa si escribes `final t = Tema();`? ¿Y si `_TemaOscuro` no define `nombre`? ¿Por qué la fábrica es un buen lugar para esconder `_TemaOscuro`?

<details>
<summary>Ver respuesta</summary>

`Tema()` no compila: `Tema` es abstracta y no se puede instanciar directamente. Si `_TemaOscuro` no define `nombre`, tampoco compila, porque es una clase concreta y debe cumplir lo que pide el mixin. La fábrica deja que quien llama use `Tema` sin conocer la clase real, que puede cambiar sin afectarle: es el mismo reparto de contrato e implementación de la unidad 3.

</details>

## 3. Anatomía de un modelo real

Con eso podemos leer el modelo más corto del proyecto, [`DaisyThemeRadius`](../../../lib/themes/domain/theme/theme_radius.dart). Este fragmento omite sus comentarios:

```dart
// Fragmento de lib/themes/domain/theme/theme_radius.dart.
import 'package:equatable/equatable.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/theme_radius.freezed.dart';
part 'generated/theme_radius.g.dart';

@Freezed(equal: false, toStringOverride: true)
abstract class DaisyThemeRadius with _$DaisyThemeRadius, Equatable {
  const DaisyThemeRadius._();

  const factory DaisyThemeRadius({
    required int boxes,
    required int fields,
    required int selectors,
  }) = _DaisyThemeRadius;

  factory DaisyThemeRadius.fromJson(Map<String, Object?> json) =>
      _$DaisyThemeRadiusFromJson(json);

  @override
  List<Object?> get props => [boxes, fields, selectors];
}
```

Línea por línea:

| Línea | Qué hace |
|-------|----------|
| `part '…'` | Une estos archivos generados a esta biblioteca. Unidad 29. |
| `@Freezed(…)` | Pide a Freezed que procese esta clase. Sus opciones, en el apartado 6. |
| `abstract class … with _$DaisyThemeRadius, Equatable` | Clase pública no instanciable. Incorpora dos mixins: `_$DaisyThemeRadius`, que **genera Freezed**, y `Equatable`, de un **paquete aparte**. |
| `const DaisyThemeRadius._()` | Constructor privado y `const`. Lo vemos a continuación. |
| `const factory DaisyThemeRadius({…}) = _DaisyThemeRadius` | La **lista de campos** y el constructor público, que redirige a `_DaisyThemeRadius`, una clase generada. Por eso `required int boxes` declara un campo sin escribir `final int boxes;`. |
| `factory ….fromJson(…)` | Reenvía a una función generada. Unidad 28. |
| `props` | La lista de campos que compara Equatable. **La escribimos a mano.** |

¿Y qué genera Freezed? Esto es una versión muy reducida de [theme_radius.freezed.dart](../../../lib/themes/domain/theme/generated/theme_radius.freezed.dart):

```dart
// Fragmento simplificado del archivo generado. No se edita a mano.
mixin _$DaisyThemeRadius {
  int get boxes;
  int get fields;
  int get selectors;
  // ...y el getter copyWith, toJson y toString.
}

class _DaisyThemeRadius extends DaisyThemeRadius {
  const _DaisyThemeRadius({
    required this.boxes,
    required this.fields,
    required this.selectors,
  }) : super._();

  @override final int boxes;
  @override final int fields;
  @override final int selectors;
  // ...copyWith, toJson y toString.
}
```

Aquí está lo que no encontrabas: los campos `final` están en `_DaisyThemeRadius`. Por eso el constructor privado es necesario. `_DaisyThemeRadius` **hereda** de `DaisyThemeRadius` y llama a `super._()`, y también por eso `props`, o los getters `md` y `base` de la unidad 26, se pueden escribir en la clase pública: el objeto real es una subclase que los hereda.

Vamos a comprobar el objeto real:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el objeto real es de la clase generada', () {
    const radios = DaisyThemeRadius(boxes: 8, fields: 4, selectors: 8);

    print(radios.runtimeType);
    print(radios is DaisyThemeRadius);
    print(radios);
    print(identical(DaisyThemes.light, DaisyThemes.light));
  });
}
```

La salida incluye:

```text
_DaisyThemeRadius
true
DaisyThemeRadius(boxes: 8, fields: 4, selectors: 8)
true
```

Observa `const DaisyThemeRadius(...)`: la fábrica admite `const` porque es un `const factory` que redirige a un constructor `const`. Es lo que permite que `DaisyThemes.light` sea una constante y, por tanto, el mismo objeto en todo el programa.

### Practica 3

Abre [`DaisyThemeSizePresets`](../../../lib/themes/domain/theme/theme_size.dart). ¿Dónde declaran los campos? ¿`md` es un campo o un getter? Si quitases la línea `const DaisyThemeSizePresets._();`, ¿qué crees que dejaría de funcionar, y por qué?

<details>
<summary>Ver respuesta</summary>

Su único campo, `base`, se declara en el `const factory`. `md` es un getter de la clase pública, y calcula `base * 10`. Sin el constructor privado, la clase generada no tendría a qué constructor llamar con `super._()`, y por tanto no podría heredar de la clase pública para conservar `md`, `xs` y los demás. Es el motivo por el que Freezed exige ese constructor cuando un modelo declara sus propios miembros.

</details>

## 4. `copyWith`: crear otro sin tocar el original

Este es el comportamiento del que dependen las unidades 8 y 14. Predice cada línea:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith no modifica el original', () {
    final original = DaisyThemes.light;
    final grueso = original.copyWith(border: 2.0);
    final equivalente = original.copyWith();

    print('Original: ${original.border}');
    print('Grueso: ${grueso.border}');
    print('Mismo nombre: ${grueso.name}');

    print('Copia exacta, ¿idéntica? ${identical(original, equivalente)}');
    print('Copia exacta, ¿igual? ${original == equivalente}');
    print('Otro borde, ¿igual? ${original == grueso}');

    print('¿Comparten colors? ${identical(original.colors, grueso.colors)}');
  });
}
```

La salida incluye:

```text
Original: 1.0
Grueso: 2.0
Mismo nombre: Light
Copia exacta, ¿idéntica? false
Copia exacta, ¿igual? true
Otro borde, ¿igual? false
¿Comparten colors? true
```

La última línea merece atención. `copyWith` es una **copia superficial**: crea un `DaisyThemeModel` nuevo, y sus demás campos apuntan a los mismos objetos. Si `colors` se pudiera modificar, esto sería peligroso: lo vimos con listas en la unidad 8. Aquí no lo es, porque todo el árbol es inmutable. Compartir ahorra memoria y no tiene ningún riesgo.

¿Y si queremos cambiar algo profundo, como el color primario? `border` está en el primer nivel, pero `primary` está dos niveles por debajo. Hay dos formas equivalentes:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const verde = RayOklch.fromComponents(0.5, 0.1, 120);

void main() {
  test('copias de datos anidados', () {
    final original = DaisyThemes.light;

    final porNiveles = original.copyWith(
      colors: original.colors.copyWith(
        primary: original.colors.primary.copyWith(baseOklch: verde),
      ),
    );

    final encadenada = original.copyWith.colors.primary(baseOklch: verde);

    print('Iguales entre sí: ${porNiveles == encadenada}');
    print('Original intacto: ${original.colors.primary.baseOklch == verde}');
    print('Copia cambiada: ${encadenada.colors.primary.baseOklch == verde}');
    print('¿Comparten secondary? ${identical(original.colors.secondary, encadenada.colors.secondary)}');
    print('¿Comparten colors? ${identical(original.colors, encadenada.colors)}');
    print('¿Comparten radius? ${identical(original.radius, encadenada.radius)}');
  });
}
```

La salida incluye:

```text
Iguales entre sí: true
Original intacto: false
Copia cambiada: true
¿Comparten secondary? true
¿Comparten colors? false
¿Comparten radius? true
```

Para cambiar una hoja se crean copias **de todo el camino hasta ella**: un par nuevo, un `DaisyThemeColor` nuevo y un tema nuevo. Lo que queda fuera de ese camino se comparte. La segunda forma es un atajo que genera Freezed para los campos que también son modelos Freezed, y hace lo mismo que la primera.

Queda un detalle que la versión a mano del apartado 1 no resolvía. Con `cajas ?? this.cajas`, pasar `null` y no pasar nada son lo mismo, de modo que un campo opcional nunca podría volver a `null`. Freezed sí los distingue:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith distingue null de no indicar', () {
    final base = DaisyThemes.light.colors.base;

    print(base.base200Oklch == null);
    print(base.copyWith().base200Oklch == null);
    print(base.copyWith(base200Oklch: null).base200Oklch == null);
  });
}
```

La salida incluye:

```text
false
false
true
```

### Practica 4

Tienes `final t = DaisyThemes.light.copyWith.radius(fields: 32);`. ¿Cuánto vale `DaisyThemes.light.radius.fields`? ¿Es `identical(t.colors, DaisyThemes.light.colors)`? ¿Y `identical(t.radius, DaisyThemes.light.radius)`? ¿Qué error da `t.radius.fields = 8;`, y cuándo aparece?

<details>
<summary>Ver respuesta</summary>

`DaisyThemes.light.radius.fields` sigue siendo 4. `t.colors` es idéntico, porque está fuera del camino del cambio; `t.radius` no lo es, porque es una copia nueva. `t.radius.fields = 8;` da un **error de compilación**: `fields` solo tiene getter, no existe el setter. No hace falta ejecutar nada para detectarlo.

</details>

## 5. Por qué este árbol puede ser `const`

Inmutable y constante no son lo mismo (unidad 8). Un objeto **inmutable** no cambia después de crearse. Un valor `const` además se conoce **al compilar**. `copyWith` crea objetos inmutables, pero no constantes, porque se ejecuta en tiempo de ejecución.

Los 35 temas son `const` porque todo lo que contienen también lo es. Este es un fragmento de [daisy_themes.dart](../../../lib/themes/application/daisy_themes.dart):

```dart
// Fragmento de lib/themes/application/daisy_themes.dart.
static const DaisyThemeModel light = DaisyThemeModel(
  id: 'light',
  // ...
  border: DaisyThemeBorderWidthPreset.thin,
  colors: DaisyThemeColor(
    base: DaisyThemeColorPair(
      baseOklch: DaisyThemeColorPalette.white,
      contentOklch: DaisyThemeColorPalette.zinc900,
```

Por toda la cadena hay constructores `const`, hasta llegar a `RayOklch.fromComponents`. Ahora se entiende mejor la decisión de la unidad 26: si `DaisyThemeColorPair` exigiera un `Color` calculado con `toColor()`, la cadena se rompería. Guardar `RayOklch` y convertir en un getter la mantiene.

Y como Dart reutiliza las constantes con los mismos datos, dos valores `const` iguales son el mismo objeto:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('constantes canónicas', () {
    const a = DaisyThemeSizePresets(base: 4);
    const b = DaisyThemeSizePresets(base: 4);
    final c = a.copyWith();

    print('a y b: ${identical(a, b)}');
    print('a y c: ${identical(a, c)}');
    print('a == c: ${a == c}');
    print('En dos temas: ${identical(DaisyThemes.light.size.fields, DaisyThemes.dark.size.fields)}');
  });
}
```

La salida incluye:

```text
a y b: true
a y c: false
a == c: true
En dos temas: true
```

Esto recuerda por qué nunca debes razonar con `identical` para decidir si un tema «ha cambiado»: dos valores con los mismos datos pueden ser o no el mismo objeto, según cómo se hayan creado. La pregunta útil es la de `==`.

Una última precisión: estos modelos son inmutables **a fondo** porque sus campos son `String`, números y otros objetos inmutables. No hay listas ni mapas. Si un modelo tuviera un campo `List`, `final` por sí solo no bastaría (unidad 8); Freezed lo envuelve por defecto en una vista no modificable, según su opción `makeCollectionsUnmodifiable`.

### Practica 5

¿Compila `const tema = DaisyThemes.light.copyWith(border: 2.0);`? ¿Y `const pareja = [DaisyThemes.light, DaisyThemes.dark];`? ¿Es `DaisyThemes.light.copyWith()` idéntico a `DaisyThemes.light`?

<details>
<summary>Ver respuesta</summary>

La primera no compila: `copyWith` es una llamada a método y un valor `const` debe conocerse al compilar. La segunda sí: los dos elementos ya son constantes. Y no es idéntico: `copyWith()` crea otro objeto en tiempo de ejecución, aunque tenga los mismos datos y compare igual, como comprobó la unidad 8.

</details>

## 6. Quién decide la igualdad: Equatable

Freezed sabe generar `==` y `hashCode`, y es lo que hace en muchos proyectos. Aquí no: fíjate de nuevo en la anotación.

```dart
// Fragmento de lib/themes/domain/theme/theme_radius.dart.
@Freezed(equal: false, toStringOverride: true)
abstract class DaisyThemeRadius with _$DaisyThemeRadius, Equatable {
  // ...
  @override
  List<Object?> get props => [boxes, fields, selectors];
}
```

- **`equal: false`** le dice a Freezed que no genere `==` ni `hashCode`. Los archivos `.freezed.dart` de los temas no contienen ningún `operator ==`.
- **`Equatable`** aporta esa regla. Su `==` comprueba que los dos objetos sean de la misma clase y que coincidan sus `props`, uno a uno; su `hashCode` también se calcula a partir de `props`. Ambos quedan coherentes entre sí, como exige la unidad 8.
- **`toStringOverride: true`** fuerza a Freezed a generar `toString`. Sin esa opción no lo hace, porque Equatable ya define uno. En una prueba, el mensaje cambiaría de `DaisyThemeRadius(boxes: 8, fields: 4, selectors: 8)` a `_DaisyThemeRadius(8, 4, 8)`. La prueba `Generated toString keeps the readable theme representation` de [daisy_theme_equality_test.dart](../../../test/themes/daisy_theme_equality_test.dart) lo protege.

La igualdad anidada funciona por recursión: `DaisyThemeModel.props` incluye `colors`, cuyo `==` compara sus `props`, que incluyen `primary`, y así hasta `RayOklch`. Ese último tiene su propia regla, del paquete `prism`: compara los componentes con una pequeña tolerancia en lugar de exigir que coincidan todos sus bits.

Esto tiene una consecuencia importante: **`props` lo escribimos a mano, y ningún generador lo comprueba**. La trampa de la Practica 1 sigue aquí. Veámosla con un modelo pequeño, sin Freezed:

```dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class Tema with Equatable {
  const Tema({required this.nombre, required this.borde});

  final String nombre;
  final double borde;

  @override
  List<Object?> get props => [nombre];
}

void main() {
  test('un campo olvidado en props', () {
    const fino = Tema(nombre: 'claro', borde: 1);
    const grueso = Tema(nombre: 'claro', borde: 2);
    final fuente = ValueNotifier<Tema>(fino);
    var avisos = 0;
    fuente.addListener(() => avisos++);

    print('Iguales: ${fino == grueso}');

    fuente.value = grueso;

    print('Avisos: $avisos');
    print('Borde guardado: ${fuente.value.borde}');

    fuente.dispose();
  });
}
```

La salida incluye:

```text
Iguales: true
Avisos: 0
Borde guardado: 1.0
```

Sigue la cadena: el campo olvidado hace que `==` devuelva `true`, por lo que el setter de `ValueNotifier` descarta el valor (unidad 7), nadie recibe un aviso y **la interfaz no cambia**, sin ningún error. Al añadir `borde` a `props`, se obtiene `false`, un aviso y un borde de `2.0`. Las señales del controlador deciden con la misma regla.

### Practica 6

Si alguien quitara `border` de `DaisyThemeModel.props`, ¿qué imprimiría `DaisyThemes.light == DaisyThemes.light.copyWith(border: 2.0)`? ¿Cambiaría `copyWith`? ¿Y `toJson`? ¿Qué prueba del proyecto fallaría?

<details>
<summary>Ver respuesta</summary>

Imprimiría `true`. `copyWith` seguiría creando un tema con borde `2.0`, y `toJson` lo seguiría incluyendo, ya que son código generado que no usa `props`. Fallaría `A changed token makes the theme and its ancestors different`, de `daisy_theme_equality_test.dart`, en su comprobación `expect(original, isNot(changedBorder))`. Un modelo correcto para Freezed podría estar mal para Equatable, y por eso esa prueba existe.

</details>

## 7. Inmutabilidad, igualdad y cambio de estado

Ya podemos juntar las piezas que usa el controlador. Antes de ver los `expect`, predice cuántos avisos habrá y qué valor quedará guardado tras cada `setTheme`:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el modelo decide si hay cambio', () {
    final original = DaisyThemes.light;
    final controller = DaisyThemeController(initialTheme: original);
    addTearDown(controller.dispose);
    var avisos = 0;
    void escuchar() => avisos++;
    controller.theme.addListener(escuchar);
    addTearDown(() => controller.theme.removeListener(escuchar));

    controller.setTheme(original.copyWith());
    expect(avisos, 0);
    expect(identical(controller.theme.value, original), isTrue);

    final grueso = original.copyWith(border: 2.0);
    controller.setTheme(grueso);
    expect(avisos, 1);
    expect(controller.theme.value.border, 2.0);

    final otroPrimario = grueso.copyWith.colors.primary(
      contentOklch: const RayOklch.fromComponents(0.9, 0.01, 120),
    );
    controller.setTheme(otroPrimario);
    expect(avisos, 2);

    expect(original.border, 1.0);
    expect(grueso.colors.primary, original.colors.primary);
  });
}
```

Cada pieza responde a una pregunta diferente:

1. **Inmutabilidad:** como un tema no se puede modificar, la única forma de cambiar el estado es **sustituirlo** por otro con `setTheme`. Por eso la señal siempre se entera: no hay ninguna forma de cambiar un token por debajo de ella. Con un modelo mutable, `tema.border = 2` no pasaría por el setter y no avisaría a nadie. Fue el problema de la lista de la unidad 7.
2. **Igualdad:** al recibir el nuevo tema, la señal pregunta `==`. Una copia equivalente se descarta, y se conserva `original`. Es lo que evita reconstrucciones sin motivo.
3. **Notificación:** si la propuesta es distinta, se guarda y se avisa. Un cambio profundo también cuenta, porque la igualdad es recursiva.
4. Lo que queda de cada tema sigue intacto: `original` y `grueso` pueden seguir usándose, compararse o volver a seleccionarse.

La prueba comprueba valores y avisos. No demuestra ninguna reconstrucción: esa parte depende de un scope montado y la demostraron las unidades 22 y 25.

### Practica 7

Al final de la prueba, añades `controller.setTheme(original);`. ¿Hay aviso? ¿Y si después vuelves a llamar `controller.setTheme(DaisyThemes.light);`? ¿Por qué un modelo inmutable hace que guardar un historial de temas para «deshacer» sea tan sencillo?

<details>
<summary>Ver respuesta</summary>

Con `original` hay un tercer aviso, porque el valor actual es `otroPrimario`, que es distinto. Con `DaisyThemes.light` no hay ninguno más: `original` es ese mismo objeto y `==` devuelve `true`. El historial es sencillo porque basta con guardar referencias a los temas anteriores: como nadie puede modificarlos, siguen teniendo exactamente los datos con que se guardaron, sin necesidad de copiarlos.

</details>

## Ejercicio final: una variante de tema

Escribe una prueba que parta de `DaisyThemes.dark` y:

1. Cree `redondo`, con `radius.fields` en 32 y `radius.boxes` en 16, usando la forma encadenada de `copyWith`.
2. Cree `redondoIgual`, otra vez con esos dos valores, pero con `copyWith` por niveles.
3. Cree `alerta`, a partir de `redondo`, con el `danger` de un `RayOklch` propio. Y `sinExtra`, a partir de `dark`, quitando su `base300Oklch` del rol `base`.
4. Guarde `dark`, `redondo`, `redondoIgual` y `alerta` en un `Set`.
5. Pase por un controlador, en este orden, `redondo`, `redondoIgual`, `alerta`, `sinExtra` y `dark`, contando los avisos.

Predice antes de ejecutar: el tamaño del conjunto, los avisos en cada paso, si `redondo` y `dark` comparten `colors`, si `alerta` y `redondo` comparten `radius`, y qué conservan `dark` y `dark.colors.base.base300`. Responde además: ¿qué pasaría con el conjunto y con los avisos si alguien quitara `danger` de `DaisyThemeColor.props`?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const rojo = RayOklch.fromComponents(0.6, 0.2, 25);

void main() {
  test('una variante de tema', () {
    final dark = DaisyThemes.dark;

    final redondo = dark.copyWith.radius(fields: 32, boxes: 16);
    final redondoIgual = dark.copyWith(
      radius: dark.radius.copyWith(fields: 32, boxes: 16),
    );
    final alerta = redondo.copyWith.colors.danger(baseOklch: rojo);
    final sinExtra = dark.copyWith.colors.base(base300Oklch: null);

    final conjunto = <DaisyThemeModel>{dark, redondo, redondoIgual, alerta};
    expect(conjunto, hasLength(3));

    expect(identical(redondo, redondoIgual), isFalse);
    expect(redondo, redondoIgual);
    expect(identical(redondo.colors, dark.colors), isTrue);
    expect(identical(alerta.radius, redondo.radius), isTrue);

    final controller = DaisyThemeController(initialTheme: dark);
    addTearDown(controller.dispose);
    var avisos = 0;
    void escuchar() => avisos++;
    controller.theme.addListener(escuchar);
    addTearDown(() => controller.theme.removeListener(escuchar));

    controller.setTheme(redondo);
    expect(avisos, 1);

    controller.setTheme(redondoIgual);
    expect(avisos, 1);
    expect(identical(controller.theme.value, redondo), isTrue);

    controller.setTheme(alerta);
    expect(avisos, 2);

    controller.setTheme(sinExtra);
    expect(avisos, 3);
    expect(controller.theme.value.colors.base.base300, isNull);

    controller.setTheme(dark);
    expect(avisos, 4);

    expect(dark.radius.fields, 4);
    expect(dark.colors.base.base300, isNotNull);
  });
}
```

El conjunto tiene tres elementos: `redondo` y `redondoIgual` comparan igual, de modo que solo se conserva el primero, y quedan `dark`, `redondo` y `alerta`.

Los avisos son 1, 1, 2, 3 y 4. `redondoIgual` no avisa y se conserva el objeto `redondo`. En cambio, `sinExtra` sí avisa, porque `base300Oklch` está en los `props` del par, y un `null` frente a un valor es una diferencia.

`redondo` y `dark` comparten `colors`, porque solo cambió `radius`. `alerta` y `redondo` comparten `radius`, porque solo cambió `colors`. Y `dark` sigue con su radio original y su `base300`, porque ningún `copyWith` modifica un objeto existente.

Sin `danger` en `DaisyThemeColor.props`, `alerta` compararía igual que `redondo`: el conjunto tendría dos elementos, `setTheme(alerta)` no avisaría y el controlador conservaría `redondo`. La copia tendría el rojo, pero el cambio nunca llegaría a la interfaz.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué código repetitivo evita Freezed, y qué riesgo tiene escribirlo a mano? **Apartado 1.**
2. ¿Qué son una anotación, un mixin y un constructor `factory`? ¿Qué significa el `=` de una redirección? **Apartado 2.**
3. En `DaisyThemeRadius`, ¿qué líneas escribimos y qué aporta Freezed? ¿Dónde están realmente los campos? **Apartado 3.**
4. ¿Por qué hace falta `const DaisyThemeRadius._()`? **Apartado 3.**
5. ¿Qué significa que `copyWith` es una copia superficial, y por qué aquí no es peligroso? **Apartado 4.**
6. ¿Qué objetos nuevos se crean al cambiar `colors.primary.baseOklch`? **Apartado 4.**
7. ¿En qué se diferencia inmutable de `const`? ¿Por qué se pueden definir los temas como constantes? **Apartado 5.**
8. ¿Quién genera `==` en estos modelos, y qué hacen `equal: false` y `toStringOverride: true`? **Apartado 6.**
9. ¿Qué ocurre si olvidas un campo en `props`? ¿Quién te avisaría? **Apartado 6.**
10. Explica la relación entre inmutabilidad, igualdad y notificación en `setTheme`. **Apartado 7.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques por qué cada aviso se produce o no. La siguiente unidad estudia el resto de lo que aporta la generación: cómo convertir estos modelos en JSON y recuperarlos.

## Para consultar si necesitas reforzar

- [Freezed](https://pub.dev/packages/freezed): `copyWith`, constructores privados y opciones de `@Freezed`. Compara con la versión instalada.
- [Equatable](https://pub.dev/packages/equatable): `props` y uso como mixin.
- [Mixins](https://dart.dev/language/mixins) y [constructores](https://dart.dev/language/constructors) en Dart: `with`, `factory` y constructores de redirección.
- [Metadatos](https://dart.dev/language/metadata): qué son las anotaciones.
- [Modelo de tema](../../../lib/themes/domain/theme.dart) y [pruebas de igualdad](../../../test/themes/daisy_theme_equality_test.dart): comportamiento actual de DaisyUI.

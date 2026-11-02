# 29. Generación de código y configuración

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 28](28-mapas-json-y-serializacion-anidada.md) · **Estado:** pendiente

## Qué vas a aprender

Quieres que el JSON de un tema use `border_width` en lugar de `border`. Abres [theme.g.dart](../../../lib/themes/domain/generated/theme.g.dart), encuentras `'border': instance.border` y lo cambias. Funciona… hasta que alguien vuelve a generar el código y tu cambio desaparece. ¿Qué archivo había que tocar? ¿Y quién escribe esos archivos?

Al terminar podrás seguir una propiedad desde el modelo hasta su salida generada y explicar qué aporta cada pieza: `build_runner`, Freezed, `json_serializable`, los archivos `part` y [build.yaml](../../../build.yaml). También podrás decidir qué archivo fuente cambiar para modificar un resultado, ejecutar la generación y reconocer lo que **ningún generador** comprueba por ti.

Vas a modificar modelos y configuración, así que trabajarás en una **copia de práctica**, nunca en el proyecto de estudio. Desde la raíz del proyecto:

```shell
rsync -a --exclude build --exclude .git ./ ../daisy_ui_practica/
cd ../daisy_ui_practica
flutter pub get
```

Todos los comandos siguientes se ejecutan dentro de `daisy_ui_practica`, donde los `diff` comparan con el proyecto original, `../daisy_ui`. Si tu carpeta tiene otro nombre, ajústalos. Si usas FVM, antepón `fvm` a `flutter` y a `dart`, como indica el [README](../../../README.md). Al terminar, puedes borrar la copia con `rm -rf ../daisy_ui_practica`.

Predice cada resultado antes de ejecutar. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–5 en otra y terminar con 6–7 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, Dart 3.13.7, `build_runner` 2.17.1, `freezed` 4.0.3, `json_serializable` 6.15.2 y `source_gen` 4.x; consulta [pubspec.lock](../../../pubspec.lock). La salida de `build_runner` cambia entre versiones, por lo que las de esta guía orientan, no son un contrato.

## 1. Un programa que escribe código

En la unidad 27 vimos cuánto se repite un modelo escrito a mano. Una alternativa es que **un programa lea la definición y escriba esa parte por nosotros**. Eso es la generación de código:

```text
Lo que escribimos       Lo que se ejecuta       Lo que se produce
theme.dart          →   build_runner        →   generated/theme.freezed.dart
build.yaml              freezed                 generated/theme.g.dart
                        json_serializable
```

Conviene entender cuándo ocurre: **mientras desarrollas, no mientras la aplicación se ejecuta**. Una persona lanza un comando, se escriben archivos `.dart` normales y estos se compilan con el resto. La aplicación final no contiene ningún generador: por eso `freezed`, `json_serializable` y `build_runner` son `dev_dependencies` en [pubspec.yaml](../../../pubspec.yaml), mientras que `freezed_annotation`, `json_annotation` y `equatable` son `dependencies`, porque el código compilado sí los usa.

Cada herramienta tiene un trabajo:

| Pieza | Su trabajo |
|-------|------------|
| `build_runner` | El **organizador**: decide qué generadores ejecutar y en qué archivos, y escribe el resultado. No sabe nada de temas. |
| `freezed` | Un **generador**: lee `@Freezed` y escribe `.freezed.dart`, con la clase `_DaisyThemeModel`, los campos y `copyWith`. |
| `json_serializable` | Otro **generador**: escribe las funciones `_$…FromJson` y `_$…ToJson`. |
| `source_gen:combining_builder` | Reúne la salida de `json_serializable` en el archivo `.g.dart`. |
| `build.yaml` | La **configuración**: dónde escribir, qué archivos procesar y con qué opciones. |

La analogía de una plantilla ayuda, con un límite: un generador no solo rellena huecos, sino que **analiza** tu código Dart con sus tipos. Si un campo es un modelo con `toJson`, lo detecta y llama a ese método.

### Practica 1

Clasifica cada cosa según ocurra al desarrollar o al ejecutar la aplicación: (a) se escribe `theme.g.dart`; (b) se llama a `_$DaisyThemeModelToJson`; (c) se lee `explicit_to_json`; (d) se comprueba `json['border'] as num`. ¿Por qué `json_annotation` es una dependencia normal y `json_serializable` no?

<details>
<summary>Ver respuesta</summary>

Al desarrollar: (a) y (c). Al ejecutar: (b) y (d), que forman parte del código ya compilado. `json_annotation` aporta las marcas, como `@JsonKey`, que tu propio código fuente importa, por lo que debe estar disponible al compilar el paquete. `json_serializable` es la herramienta que las lee y solo se necesita para generar: ni la aplicación ni quien use el paquete tienen que ejecutarla.

</details>

## 2. `part`: dos archivos, una biblioteca

La unidad 15 explicó que `_` limita un nombre a su **biblioteca**. Sin embargo, `_$DaisyThemeModelToJson` está en otro archivo, y el modelo la usa. Lo que los une es `part`. Crea estos dos archivos en la copia de práctica, en una carpeta `part_demo/`:

```dart
// part_demo/tema.dart
part 'tema.codigo.dart';

class Tema {
  const Tema(this._nombre);

  final String _nombre;

  String describir() => _$describir(this);
}

void main() => print(const Tema('claro').describir());
```

```dart
// part_demo/tema.codigo.dart
part of 'tema.dart';

String _$describir(Tema tema) => 'Tema ${tema._nombre}';
```

```shell
dart run part_demo/tema.dart
```

La salida es:

```text
Tema claro
```

`part` y `part of` declaran que los dos archivos forman **una sola biblioteca**, como si estuvieran escritos uno a continuación del otro. Por eso `tema.codigo.dart` puede leer el campo privado `_nombre`, y `tema.dart` puede llamar a `_$describir`.

La relación está escrita en ambos lados. El modelo la declara al principio:

```dart
// Fragmento de lib/themes/domain/theme.dart.
part 'generated/theme.freezed.dart';

part 'generated/theme.g.dart';
```

Y el generado responde, en sus primeras líneas:

```dart
// Fragmento de lib/themes/domain/generated/theme.g.dart.
// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../theme.dart';
```

Un detalle que suele desconcertar: el archivo no existe la primera vez que escribes el `part`, de modo que el analizador lo marca como error hasta que generas. Es normal: esa línea es lo que **pide** el archivo.

### Practica 2

En la copia, en `part_demo/tema.codigo.dart`, cambia `tema._nombre` para que un tercer archivo `otro.dart`, sin `part`, intente leer `const Tema('x')._nombre`. ¿Compila ese tercer archivo, aunque importe `tema.dart`? ¿Y si quitas la línea `part of` de `tema.codigo.dart`?

<details>
<summary>Ver respuesta</summary>

`otro.dart` no compila: importar una biblioteca da acceso a sus nombres públicos, y `_nombre` es privado de la biblioteca `tema.dart`. Sin `part of`, `tema.codigo.dart` deja de ser una parte de esa biblioteca: el `part` de `tema.dart` da error, porque el archivo al que apunta no se declara como parte suya.

</details>

## 3. Seguir una propiedad hasta su salida

Sigamos `border` desde la única línea que escribimos:

```dart
// Fragmento de lib/themes/domain/theme.dart.
required double border,
```

Freezed la convierte en varias cosas dentro de [theme.freezed.dart](../../../lib/themes/domain/generated/theme.freezed.dart). Este fragmento simplifica su formato:

```dart
// Fragmento simplificado de theme.freezed.dart.
mixin _$DaisyThemeModel {
  double get border;                             // El getter del contrato.
}

@JsonSerializable()
class _DaisyThemeModel extends DaisyThemeModel {
  @override final double border;                 // El campo real.
  // String toString() => '... border: $border)';
}
// copyWith: un parámetro border, que usa el valor actual si no se indica.
```

Observa la anotación `@JsonSerializable()` sobre `_DaisyThemeModel`. No la escribimos nosotros: **la añade Freezed**, porque el modelo tiene una fábrica `fromJson`. Así `json_serializable`, que se ejecuta después, encuentra una clase normal con campos que puede procesar y produce el `.g.dart`:

```dart
// Fragmentos de lib/themes/domain/generated/theme.g.dart.
border: (json['border'] as num).toDouble(),      // En _$DaisyThemeModelFromJson.
'border': instance.border,                       // En _$DaisyThemeModelToJson.
```

| Lo escrito | Lo generado | Quién lo genera |
|------------|-------------|-----------------|
| `required double border` | Campo, getter, parámetro de `copyWith`, parte de `toString` | Freezed |
| | Lectura y escritura de la clave `border` | `json_serializable` |
| `props => [..., border]` | Nada: lo usa Equatable al ejecutar | **Nadie**, se escribe a mano |

El orden importa, y se ve al generar: primero `freezed`, después `json_serializable` y al final `combining_builder`.

¿Qué pasa con un modelo sin `fromJson`? Freezed no le añade `@JsonSerializable()`, de modo que tampoco se genera `toJson`. Por eso `fromJson` es la señal que activa toda la parte JSON, y por eso cada modelo del árbol necesita la suya.

### Practica 3

Sigue `baseOklch` en [theme_color.dart](../../../lib/themes/domain/theme/theme_color.dart): `@JsonKey(name: 'base') required RayOklch baseOklch`. ¿Qué clave usa en [theme_color.g.dart](../../../lib/themes/domain/theme/generated/theme_color.g.dart)? ¿Cómo se llama el parámetro de `copyWith`? ¿Por qué `toJson` escribe `instance.baseOklch.toJson()`, y quién escribió ese `toJson`? Búscalo antes de responder.

<details>
<summary>Ver respuesta</summary>

La clave es `base`, por `@JsonKey`. El parámetro de `copyWith` sigue siendo `baseOklch`: `@JsonKey` solo afecta al JSON. Se llama a `.toJson()` porque `explicit_to_json` está activo, como veremos, y lo escribieron los autores de `prism`: `RayOklch` no es un modelo generado en este proyecto, pero tiene `fromJson` y `toJson`, que es lo único que `json_serializable` necesita encontrar.

</details>

## 4. `build.yaml`, línea por línea

Este es el archivo completo de [build.yaml](../../../build.yaml):

```yaml
targets:
  $default:
    sources:
      exclude:
        - example/**
    builders:
      freezed:
        options:
          build_extensions:
            '^{{dir}}/{{file}}.dart': '{{dir}}/generated/{{file}}.freezed.dart'
      source_gen:combining_builder:
        options:
          build_extensions:
            '^{{dir}}/{{file}}.dart': '{{dir}}/generated/{{file}}.g.dart'
      json_serializable:
        options:
          explicit_to_json: true
```

- **`targets.$default`**: la configuración del paquete actual.
- **`sources.exclude`**: no procesar `example/`, que es otro paquete, con su propio `pubspec.yaml`.
- **`build_extensions`** de `freezed`: dónde escribir. Por defecto, el archivo quedaría junto al modelo. Esta regla dice que, para `{{dir}}/{{file}}.dart`, la salida vaya a `{{dir}}/generated/{{file}}.freezed.dart`. Con `lib/themes/domain/theme.dart`, se obtiene `lib/themes/domain/generated/theme.freezed.dart`.
- **`build_extensions`** de `combining_builder`: lo mismo para `.g.dart`.
- **`explicit_to_json: true`**: la opción de la unidad 28, que hace que cada modelo anidado llame a `toJson()`.

La ruta aparece en dos sitios: en `build.yaml`, donde se **escribe**, y en la línea `part`, donde se **lee**. Tienen que coincidir. Si quitas el `part` de `.g.dart` de un modelo y generas, la herramienta avisa, y a continuación el análisis falla porque `_$DaisyThemeModelFromJson` no existe:

```text
W source_gen:combining_builder on lib/themes/domain/theme.dart:
  generated/theme.g.dart must be included as a part directive in the input library with:
      part 'generated/theme.g.dart';
```

### Practica 4

Para `lib/themes/domain/theme/theme_size.dart`, ¿dónde se escribe cada archivo generado? ¿Qué líneas `part` debe tener ese modelo? Si cambiaras `generated` por `gen` solo en `build.yaml`, ¿qué fallaría?

<details>
<summary>Ver respuesta</summary>

En `lib/themes/domain/theme/generated/theme_size.freezed.dart` y `.../theme_size.g.dart`, con `part 'generated/theme_size.freezed.dart';` y `part 'generated/theme_size.g.dart';`. Con ese cambio, los generadores escribirían en `gen/` y las líneas `part` seguirían apuntando a `generated/`. Las dos carpetas deben cambiar a la vez.

</details>

## 5. Ejecutar la generación

Lanza la generación dentro de la copia:

```shell
dart run build_runner build
```

La parte final de la salida es parecida a esta. El número de archivos escritos puede ser distinto la primera vez:

```text
  2s json_serializable on 48 inputs: 19 skipped, 5 output, 24 no-op; spent 2s analyzing
  0s source_gen:combining_builder on 48 inputs: 19 skipped, 5 output, 24 no-op
  Built with build_runner/aot in 16s; wrote 15 outputs.
```

Compara con el proyecto original y vuelve a ejecutarlo:

```shell
diff -rq lib ../daisy_ui/lib
dart run build_runner build
```

`diff` no debería mostrar nada: la generación es **determinista**. A partir de las mismas fuentes, se obtiene el mismo código. Por eso el proyecto puede guardar los archivos generados en Git, como indica el [README](../../../README.md), y aun así quien los regenere no verá cambios. La segunda ejecución termina en un instante:

```text
  0s source_gen:combining_builder on 48 inputs: 48 skipped
  Built with build_runner/aot in 0s; wrote 0 outputs.
```

`build_runner` recuerda lo que ya hizo y solo vuelve a procesar lo que ha cambiado. Hay otros dos comandos que conviene conocer:

- **`dart run build_runner watch`** se queda ejecutándose y regenera cada vez que guardas un archivo.
- **`dart run build_runner clean`** borra la caché de la herramienta, **no** los archivos generados de `lib/`. La siguiente ejecución es completa, y lo que hayas generado sigue en su sitio.

### Practica 5

Sin ejecutar: si mañana `git pull` trae un cambio en un comentario de `theme_radius.dart`, ¿crees que `build` procesará algo? ¿Y si traes un cambio en `build.yaml`? ¿Y si cambias un archivo sin anotaciones, como `daisy_theme_controller.dart`? Después pruébalo con el primero y el tercero.

<details>
<summary>Ver respuesta</summary>

Procesará los tres casos en cierta medida: la herramienta detecta el cambio de entrada y vuelve a evaluar, pero no siempre escribe. El comentario de documentación puede copiarse en la salida; un `//` normal no cambia el resultado, y la salida sigue siendo la misma. Un cambio en `build.yaml` provoca un trabajo más amplio, porque afecta a todos. El controlador no tiene anotaciones, así que los generadores se ejecutan sin producir ninguna salida para él. La forma de razonarlo: una entrada cambiada obliga a mirar, pero solo las entradas relevantes cambian los archivos.

</details>

## 6. Tres experimentos: qué archivo cambiar

**Experimento 1: editar un archivo generado.** En la copia, abre `lib/themes/domain/generated/theme.g.dart` y cambia `'border': instance.border` por `'borde': instance.border`. Ejecuta `dart run build_runner build`.

```text
  0s source_gen:combining_builder on 48 inputs: 47 skipped, 1 fixed
  Built with build_runner/aot in 0s; wrote 1 output.
```

Tu cambio ha desaparecido: la herramienta detecta que la salida no es la que produjo y la restaura. Incluso sin esta comprobación, se perdería en cuanto alguien cambiara el modelo. Es lo que advierte la primera línea del archivo: `GENERATED CODE - DO NOT MODIFY BY HAND`.

**Experimento 2: cambiar la clave en el lugar correcto.** Lo que querías al empezar la unidad se escribe en la fuente:

```dart
// Modificación en la copia, en lib/themes/domain/theme.dart.
@JsonKey(name: 'border_width') required double border,
```

Genera y compara:

```shell
dart run build_runner build
diff lib/themes/domain/generated/theme.g.dart ../daisy_ui/lib/themes/domain/generated/theme.g.dart
```

```text
17c17
<       border: (json['border_width'] as num).toDouble(),
---
>       border: (json['border'] as num).toDouble(),
28c28
<       'border_width': instance.border,
---
>       'border': instance.border,
```

Ha cambiado el formato de los datos y el campo sigue siendo `border`. Hay que tener cuidado: un JSON guardado antes con `border` ya no se podría leer. Deshaz el cambio con `cp ../daisy_ui/lib/themes/domain/theme.dart lib/themes/domain/theme.dart`, y genera de nuevo.

**Experimento 3: quitar `explicit_to_json`.** Elimina las dos últimas líneas de `build.yaml` (`json_serializable:` y `options:` deben irse con `explicit_to_json`), genera y compara:

```shell
dart run build_runner build
diff lib/themes/domain/generated/theme.g.dart ../daisy_ui/lib/themes/domain/generated/theme.g.dart
flutter test --no-pub test/themes/daisy_theme_json_test.dart
```

```text
25,27c25,27
<       'colors': instance.colors,
<       'radius': instance.radius,
<       'size': instance.size,
---
>       'colors': instance.colors.toJson(),
>       'radius': instance.radius.toJson(),
>       'size': instance.size.toJson(),
```

Es el fallo que escribimos a mano en el apartado 3 de la unidad 28, ahora producido por el generador. Las pruebas lo confirman:

```text
Every built-in theme produces a JSON-only map and round trips directly [E]
Text JSON round trips preserve every built-in theme                    (pasa)
Nested tokens preserve nullable surfaces, opacity and fractional borders [E]
```

Fallan dos de tres. La de texto pasa, porque `jsonEncode` llama a `toJson` en cada nivel. Antes de seguir, restaura la configuración con `cp ../daisy_ui/build.yaml build.yaml` y genera de nuevo.

Con esto ya se puede decidir qué archivo cambiar:

| Quiero… | Cambio… | ¿Hay que generar? |
|---------|---------|-------------------|
| Añadir o quitar un campo | El `const factory` del modelo, y sus `props` | Sí |
| Cambiar una clave JSON | `@JsonKey` en el modelo | Sí |
| Que los anidados se conviertan | `explicit_to_json` en `build.yaml` | Sí |
| Mover los archivos generados | `build.yaml` **y** las líneas `part` | Sí |
| Cambiar la regla de igualdad | `props` en el modelo | No |
| Cambiar cuánto vale `md` | El getter en el modelo | No |
| Cambiar un tema concreto | [daisy_themes.dart](../../../lib/themes/application/daisy_themes.dart) | No |
| Lo que sea | **Nunca** `.freezed.dart` ni `.g.dart` | |

La pregunta útil es: «¿este dato lo lee un generador?». `props` y los getters son código normal que se compila tal cual, de modo que basta con guardar el archivo.

### Practica 6

Decide qué archivo cambiarías y si hay que generar: (a) `toString` debe mostrar `boxes` con otro formato; (b) `sm` debe ser `base * 9`; (c) `description` debe ser opcional, con un texto vacío por defecto; (d) quieres que los archivos de `example/` también se procesen.

<details>
<summary>Ver respuesta</summary>

(a) Escribir tu propio `toString` en la clase pública y **quitar** `toStringOverride: true` de la anotación, para que Freezed no genere otro; hay que generar. (b) El getter `sm` de `theme_size.dart`; no hay que generar, porque no aparece en ningún archivo generado. (c) En `theme.dart`, cambiar `required String description` por `@Default('') String description`; hay que generar. `@Default` lo usa `DaisyButtonTheme`. (d) `sources` en `build.yaml`, aunque `example/` es un paquete propio y en realidad tendría que tener su propia configuración.

</details>

## 7. Lo que un generador no comprueba

Añadamos un campo, paso a paso, para ver dónde se detiene cada herramienta. En la copia, en el `const factory` de `lib/themes/domain/theme.dart`, añade a continuación de `border`:

```dart
// Modificación en la copia.
@Default(0) int depth,
```

**Paso 1: sin generar.** `flutter analyze --no-pub lib` informa de un error en `}) = _DaisyThemeModel;`. El `const factory` promete un parámetro `depth`, pero la clase generada todavía no lo tiene: la fuente y lo generado no coinciden.

**Paso 2: generar.** Tras `dart run build_runner build`, el error desaparece y `theme.g.dart` contiene:

```dart
// Fragmentos de lib/themes/domain/generated/theme.g.dart, en la copia.
depth: (json['depth'] as num?)?.toInt() ?? 0,
'depth': instance.depth,
```

Observa `num?` y `?? 0`: como el campo tiene valor predeterminado, un JSON guardado antes de existir `depth` se sigue pudiendo leer. Compila todo. Ahora copia esta prueba a `test/estudio_generacion_test.dart`:

```dart
// Prueba para la copia de práctica: solo compila después de añadir depth.
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el nuevo campo y la igualdad', () {
    final original = DaisyThemes.light;
    final conProfundidad = original.copyWith(depth: 3);
    final controller = DaisyThemeController(initialTheme: original);
    addTearDown(controller.dispose);
    var avisos = 0;
    void escuchar() => avisos++;
    controller.theme.addListener(escuchar);
    addTearDown(() => controller.theme.removeListener(escuchar));

    print('Copia: ${conProfundidad.depth}');
    print('Iguales: ${original == conProfundidad}');

    controller.setTheme(conProfundidad);

    print('Avisos: $avisos');
    print('Guardado: ${controller.theme.value.depth}');
  });
}
```

```shell
flutter test --no-pub test/estudio_generacion_test.dart
```

La salida incluye:

```text
Copia: 3
Iguales: true
Avisos: 0
Guardado: 0
```

**Paso 3: el fallo.** Freezed ha hecho su parte: la copia tiene `depth: 3`. `json_serializable` también. Pero nadie añadió el campo a `props`, de modo que Equatable no lo compara. `setTheme` descarta el cambio sin ningún aviso: el tema no se actualiza, y **compila sin advertencias**. Es la trampa de la unidad 27 llegando desde otro lado.

**Paso 4: arreglarlo.** Añade `depth` a `props`. Ejecuta la prueba **sin generar**, porque `props` es código normal. Ahora la salida es:

```text
Copia: 3
Iguales: false
Avisos: 1
Guardado: 3
```

Si el campo hubiera sido `required int depth`, sin valor predeterminado, el compilador te habría ayudado de otra manera: `flutter analyze --no-pub lib` informa de **35 errores** en `daisy_themes.dart`, uno por tema, y un JSON antiguo fallaría con un `TypeError`. Elegir entre `required` y `@Default` es elegir entre obligarte a decidir el valor en cada tema o aceptar que los datos anteriores usen uno predeterminado.

Deshaz los cambios antes de seguir:

```shell
cp ../daisy_ui/lib/themes/domain/theme.dart lib/themes/domain/theme.dart
rm test/estudio_generacion_test.dart
dart run build_runner build
diff -rq lib ../daisy_ui/lib
```

Las pruebas de [igualdad](../../../test/themes/daisy_theme_equality_test.dart) no detectarían este olvido por sí solas, ya que no conocen un campo nuevo: habría que añadir un caso para él.

### Practica 7

Ordena los pasos para añadir un campo obligatorio `theme.name2`: generar, añadir a `props`, añadir a `const factory`, dar valor en los 35 temas, añadir un caso de prueba. ¿Qué paso te recuerda el compilador, y cuál no?

<details>
<summary>Ver respuesta</summary>

Un orden razonable: añadir al `const factory`, generar, añadir a `props`, dar valor en los 35 temas y añadir un caso de prueba de igualdad y de JSON. El compilador te recuerda generar, pues hay un error en la redirección, y los 35 temas. **No** te recuerda `props` ni la prueba. Por eso conviene hacer de `props` un hábito, al escribir el campo.

</details>

## Ejercicio final: un radio nuevo

En la copia, añade a `DaisyThemeRadius` un radio `pills` para las insignias con forma de píldora:

1. Es opcional y vale por defecto `DaisyThemeRadiusPreset.full`. En JSON se debe llamar `pill`, no `pills`.
2. Debe distinguir temas: dos radios con distinto `pills` no pueden ser iguales.

Antes de tocar nada, responde: ¿qué archivos cambiarás a mano? ¿Cuáles cambiará el generador? ¿Qué línea exacta esperas en `theme_radius.g.dart` para leer y para escribir? ¿Hay que cambiar `daisy_themes.dart`? ¿Se seguirá pudiendo leer un JSON antiguo sin `pill`? ¿Cuál será el `md` de un tema? ¿Qué parte del `size` del JSON de un tema cambiará?

Después hazlo y escribe una prueba `test/estudio_pills_test.dart` que compruebe el valor predeterminado, el ciclo de ida y vuelta, la lectura de un JSON sin la clave, la clave `pill` y la desigualdad. Ejecuta además todas las pruebas del paquete y restaura la copia al terminar.

<details>
<summary>Ver una posible solución</summary>

A mano solo cambia [theme_radius.dart](../../../lib/themes/domain/theme/theme_radius.dart), en el `const factory` y en `props`. El generador cambia `theme_radius.freezed.dart` y `theme_radius.g.dart`. `daisy_themes.dart` no cambia, porque el campo tiene un valor predeterminado. `md` no cambia, y el `size` del JSON tampoco: `pills` pertenece a `radius`.

```dart
// Fragmento modificado en la copia, lib/themes/domain/theme/theme_radius.dart.
const factory DaisyThemeRadius({
  required int boxes,
  required int fields,
  required int selectors,

  @Default(DaisyThemeRadiusPreset.full)
  @JsonKey(name: 'pill')
  int pills,
}) = _DaisyThemeRadius;

// ...

@override
List<Object?> get props => [boxes, fields, selectors, pills];
```

```shell
dart run build_runner build
diff lib/themes/domain/theme/generated/theme_radius.g.dart ../daisy_ui/lib/themes/domain/theme/generated/theme_radius.g.dart
```

El `diff` muestra estas líneas añadidas, junto con las existentes:

```text
<   pills: (json['pill'] as num?)?.toInt() ?? DaisyThemeRadiusPreset.full,
<       'pill': instance.pills,
```

La prueba, que solo compila en la copia modificada:

```dart
// Prueba para la copia de práctica: solo compila después de añadir pills.
import 'dart:convert';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('el radio pills', () {
    final radio = DaisyThemes.light.radius;

    expect(radio.pills, 32);
    expect(radio.toJson()['pill'], 32);
    expect(radio.toJson().containsKey('pills'), isFalse);

    expect(radio.copyWith(pills: 16), isNot(radio));
    expect(radio.copyWith(pills: 32), radio);

    final antiguo = {'boxes': 8, 'fields': 4, 'selectors': 8};
    expect(DaisyThemeRadius.fromJson(antiguo).pills, 32);

    final tema = DaisyThemes.light.copyWith.radius(pills: 16);
    final recuperado = DaisyThemeModel.fromJson(
      jsonDecode(jsonEncode(tema)) as Map<String, dynamic>,
    );
    expect(recuperado, tema);
    expect(recuperado.radius.pills, 16);
  });
}
```

```shell
flutter test --no-pub test/estudio_pills_test.dart
flutter test --no-pub
```

Pasan las dos órdenes. Los 35 temas siguen funcionando porque `pills` toma su valor predeterminado. Los JSON antiguos se pueden leer gracias a `?? DaisyThemeRadiusPreset.full`.

Sin `pills` en `props`, la línea `expect(radio.copyWith(pills: 16), isNot(radio))` fallaría, y sería la única que lo detectara: el ciclo de ida y vuelta seguiría pasando, porque un `==` que no mira `pills` no puede notar que se ha perdido. Fíjate también en que el primer `expect` del ciclo es más débil que el último: por eso se añade `expect(recuperado.radius.pills, 16)`.

Para restaurar la copia:

```shell
cp ../daisy_ui/lib/themes/domain/theme/theme_radius.dart lib/themes/domain/theme/theme_radius.dart
rm test/estudio_pills_test.dart
dart run build_runner build
diff -rq lib ../daisy_ui/lib
```

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Cuándo se ejecuta un generador: al desarrollar o al ejecutar la aplicación? ¿Qué consecuencia tiene en `pubspec.yaml`? **Apartado 1.**
2. ¿Qué hace cada pieza: `build_runner`, `freezed`, `json_serializable` y `build.yaml`? **Apartado 1.**
3. ¿Qué significa `part`? ¿Por qué un archivo generado puede usar nombres privados del modelo? **Apartado 2.**
4. Sigue `border` desde la fuente hasta la clave JSON. ¿Quién añade `@JsonSerializable()`? **Apartado 3.**
5. ¿Por qué tiene que coincidir la ruta de `build.yaml` con la línea `part`? **Apartado 4.**
6. ¿Qué borra `build_runner clean`, y qué no? ¿Por qué `diff` no muestra diferencias tras generar? **Apartado 5.**
7. ¿Qué le pasa a un cambio hecho a mano en `theme.g.dart`? **Apartado 6.**
8. Para cambiar una clave JSON, ¿qué archivo tocas? ¿Y para cambiar `md`? ¿En cuál hace falta generar? **Apartado 6.**
9. ¿Por qué `explicit_to_json` no afecta a la prueba de texto? **Apartado 6.**
10. Al añadir un campo, ¿qué te recuerda el compilador y qué no? **Apartado 7.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y, antes de ejecutarlo, sepas qué archivo cambiar y qué líneas generadas esperar. Con esto termina el Bloque 6: ya sabes qué contiene un tema, cómo se define, cómo se convierte en JSON y de dónde sale el código que lo permite. El Bloque 7 empieza en la unidad 30, que estudia cómo escoger la prueba que demuestra cada afirmación.

## Para consultar si necesitas reforzar

- [`build_runner`](https://pub.dev/packages/build_runner): comandos `build`, `watch` y `clean`.
- [Freezed](https://pub.dev/packages/freezed) y [`json_serializable`](https://pub.dev/packages/json_serializable): opciones, como `explicit_to_json`.
- [`build_config`](https://pub.dev/packages/build_config): el formato de `build.yaml`.
- [`part` y bibliotecas en Dart](https://dart.dev/tools/pub/create-packages#organizing-a-package): cómo se organiza un paquete.
- [build.yaml](../../../build.yaml), [pubspec.yaml](../../../pubspec.yaml), la sección *Code generation* del [README](../../../README.md) y los [modelos](../../../lib/themes/domain/theme.dart): configuración actual de DaisyUI.

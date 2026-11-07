# 32. Imports, exports y límites del paquete

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 31](31-ejercicio-final-explicar-todo-el-flujo.md) · **Estado:** pendiente

## Qué vas a aprender

Alguien de tu equipo quiere usar DaisyUI en otra aplicación. Añade el paquete, escribe `import 'package:daisy_ui/daisy_ui.dart';` y empieza a trabajar: `DaisyThemeScope` funciona, `DaisyThemes.dark` también… pero `DaisyButton` da un error de clase no definida, aunque el archivo exista. ¿Por qué ese import da unas cosas y no otras? ¿Y qué más se puede tocar de tu código desde fuera?

Al terminar podrás explicar cómo otra aplicación consume `package:daisy_ui/daisy_ui.dart`, por qué publicar una API no requiere exponer toda la implementación, qué límites protegen de verdad al código y cuáles son solo una convención, y para qué está cada dependencia de [pubspec.yaml](../../../pubspec.yaml).

Es un complemento: no hace falta para explicar el flujo de temas, pero sí para que otra persona pueda utilizarlo. Vas a crear una pequeña **aplicación consumidora** fuera del proyecto, de modo que no modificarás DaisyUI hasta el ejercicio final, que se hace en una copia. Desde la raíz del proyecto:

```shell
mkdir -p ../consumidor/lib
cd ../consumidor
```

Crea `../consumidor/pubspec.yaml`:

```yaml
name: consumidor
publish_to: none

environment:
  sdk: ^3.13.5
  flutter: '>=3.47.7'

dependencies:
  flutter:
    sdk: flutter
  daisy_ui:
    path: ../daisy_ui

dev_dependencies:
  flutter_lints: ^6.0.0
  flutter_test:
    sdk: flutter
```

Crea también `../consumidor/analysis_options.yaml`, con esta línea:

```yaml
include: package:flutter_lints/flutter.yaml
```

Y resuelve las dependencias:

```shell
flutter pub get
```

Si tu carpeta del proyecto tiene otro nombre, ajusta `path`. Si usas FVM, antepón `fvm` a `flutter`, y a `dart` en las órdenes que lo usen. Todos los comandos siguientes se ejecutan dentro de `consumidor`, salvo que se indique otra cosa. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar con el 7 y el ejercicio final.

Los resultados se observaron con Flutter 3.47.8 y Dart 3.13.7.

## 1. Biblioteca, paquete y plugin

Tres palabras que se suelen mezclar:

- Una **biblioteca** (*library*) es la unidad de código de Dart: normalmente un archivo `.dart`, junto con sus archivos `part` si los tiene. Los nombres que empiezan por `_` son privados de la biblioteca, no de la clase (unidades 15 y 29).
- Un **paquete** es un directorio con un `pubspec.yaml`, que agrupa bibliotecas para compartirlas. Lo que está en `lib/` se puede importar desde otros paquetes.
- Un **plugin** es un paquete de Flutter que, además, incluye código nativo para cada plataforma y lo registra.

DaisyUI es un paquete Flutter, no un plugin. Puedes comprobarlo de tres formas. En [.metadata](../../../.metadata) pone `project_type: package`; el [pubspec.yaml](../../../pubspec.yaml) no tiene ninguna sección `flutter: plugin:`; y el [README](../../../README.md) lo dice: «a Flutter package with no native plugin registration or platform-specific implementation». Depende de Flutter, y por eso es un paquete *Flutter*; no llama a código de Android ni de iOS.

### Practica 1

[theme.dart](../../../lib/themes/domain/theme.dart) tiene dos líneas `part`, a `generated/theme.freezed.dart` y `generated/theme.g.dart`. ¿Cuántas bibliotecas son esos tres archivos? ¿Puede `theme.g.dart` usar un nombre privado de `theme.dart`?

<details>
<summary>Ver respuesta</summary>

Una sola biblioteca, repartida en tres archivos. Sí puede: `_` significa «privado de la biblioteca», y los tres pertenecen a la misma. Así es como el código generado llega a `_$DaisyThemeModelFromJson` y los demás nombres privados (unidad 29).

</details>

## 2. `import`: traer nombres a esta biblioteca

Un `import` hace visibles en un archivo los nombres públicos de otra biblioteca. Este programa de Dart es completo. Guárdalo como `lib/importar.dart` y ejecútalo con `dart run lib/importar.dart`:

```dart
import 'dart:math' show max;
import 'dart:math' as mates;

void main() {
  print(max(2, 7));
  print(mates.min(2, 7));
  print(mates.pi > 3);
}
```

La salida es:

```text
7
2
true
```

Borra el archivo al acabar este apartado, para que no aparezca en los análisis siguientes. Línea a línea:

1. `show max` trae **solo** `max`. Si usaras `min` sin prefijo, sería un error de compilación. También existe lo contrario: `hide` lo trae todo menos lo indicado.
2. `as mates` trae los nombres bajo un **prefijo**. Evita choques entre dos bibliotecas que tengan el mismo nombre.
3. Importar la misma biblioteca dos veces no crea dos copias: es una sola biblioteca.

Hay tres tipos de dirección. Las tres aparecen en el proyecto:

| Forma | Significado | Ejemplo real |
|---|---|---|
| `dart:...` | Biblioteca del SDK de Dart | `dart:ui`, en [theme_color.dart](../../../lib/themes/domain/theme/theme_color.dart) |
| `package:nombre/ruta.dart` | `lib/ruta.dart` del paquete `nombre` | `package:daisy_ui/themes/domain/theme.dart` |
| Relativa | Otro archivo, respecto a este | `'daisy_theme_service.dart'`, en [daisy_theme_scope.dart](../../../lib/themes/application/daisy_theme_scope.dart) |

Observa que `package:daisy_ui/themes/domain/theme.dart` no menciona `lib/`: la forma `package:` ya apunta dentro de `lib/`. Y `example/` y `test/` no son importables desde otros paquetes.

### Practica 2

El programa de arriba, ¿compilaría si `print(max(2, 7))` fuera `print(mates.max(2, 7))`? ¿Y si escribieras `print(min(2, 7))`?

<details>
<summary>Ver respuesta</summary>

`mates.max` sí compila: el prefijo trae todos los nombres públicos. `min` sin prefijo no compila: la primera línea solo trajo `max`, y la segunda solo trae nombres con el prefijo `mates`. El error es que `min` no está definido.

</details>

## 3. `export`: decidir qué ofrece el paquete

`export` hace lo contrario de lo que parece. No trae nada a este archivo: **añade nombres a lo que reciben quienes importan este archivo**. Este es [lib/daisy_ui.dart](../../../lib/daisy_ui.dart), completo:

```dart
/// DaisyUI themes and design tokens for Flutter.
library;

export 'package:prism_flutter/prism_flutter.dart'
    show RayOklch, RayToFlutterColor;

export 'themes/application/daisy_theme_controller.dart';
export 'themes/application/daisy_theme_scope.dart';
export 'themes/application/daisy_theme_service.dart';
export 'themes/core/extension/build_context.dart';
export 'themes/application/daisy_themes.dart';
export 'themes/domain/theme.dart';
export 'themes/domain/theme/theme_border.dart';
export 'themes/domain/theme/theme_color.dart';
export 'themes/domain/theme/theme_radius.dart';
export 'themes/domain/theme/theme_size.dart';
```

El archivo no contiene ninguna clase. No tiene ni un `import`, y por tanto él mismo no podría usar ninguno de esos nombres. Es solo una **lista de lo que se ofrece**: la **API pública** del paquete. `package:daisy_ui/daisy_ui.dart` es el archivo con el mismo nombre que el paquete, el que se espera que importe cualquiera.

Dos detalles:

1. **`export … show` filtra.** DaisyUI usa `prism_flutter` para los colores, pero solo ofrece `RayOklch` y la extensión `RayToFlutterColor`, que aporta `.toColor()`. El resto de Prism, por ejemplo `RayHsl`, se queda fuera. Se ofrecen porque el consumidor los necesita: `DaisyThemeColorPair` recibe un `RayOklch` en su constructor, y así se puede crear uno sin depender directamente de Prism.
2. **Lo que no está en la lista no se ofrece.** `DaisyButton`, en `themes/presentation/action/button.dart`, no aparece, y tampoco `DaisyButtonTheme`.

Esto responde a la pregunta inicial. Pruébalo: crea `lib/publica.dart` en `consumidor`:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';

Color colorDePrueba() {
  final controller = DaisyThemeController(initialTheme: DaisyThemes.dark);
  controller.setTheme(DaisyThemes.light.copyWith(border: 2));
  controller.dispose();
  return const RayOklch.fromComponents(0.5, 0.1, 120).toColor();
}
```

Ejecuta `flutter analyze --no-pub`. El analizador no encuentra ningún problema en ese archivo: todo eso está en la API pública.

### Practica 3

Sin mirar `daisy_ui.dart`: ¿qué archivo tendrías que añadir a la lista para que `DaisyButtonTheme` fuera público? ¿Y `DaisyButtonModifier`? Busca dónde están.

<details>
<summary>Ver respuesta</summary>

`DaisyButtonTheme` está en `themes/domain/button_theme.dart`, y `DaisyButtonModifier` en `themes/domain/button/button_modifier.dart`. Exportar `button_theme.dart` **no** exporta lo que ese archivo importa: un `import` no se transmite. Cada archivo cuyos nombres quieras ofrecer necesita su propio `export`.

</details>

## 4. Lo que el consumidor no puede hacer

Veamos los límites en acción. Crea `lib/limites.dart`. **Antes de analizarlo, predice qué líneas fallan y por qué**:

```dart
import 'package:daisy_ui/daisy_ui.dart';

DaisyButton? boton;
FlutterSignal<int>? senal;
RayHsl? otroColor;

class MiControlador extends DaisyThemeController {}

final servicio = DaisyThemeService();

final oculto = DaisyThemeController()._palette;

void escribir(DaisyThemeController controller) {
  controller.theme.value = DaisyThemes.dark;
}
```

Ejecuta `flutter analyze --no-pub`. Las siete líneas dan error, cada una por una razón diferente:

| Línea | Error del analizador (resumido) | Qué límite actúa |
|---|---|---|
| `DaisyButton? boton` | `Undefined class 'DaisyButton'` | No está en los `export` |
| `FlutterSignal<int>? senal` | `Undefined class 'FlutterSignal'` | La implementación usa señales, pero no las ofrece |
| `RayHsl? otroColor` | `Undefined class 'RayHsl'` | `show` lo dejó fuera |
| `extends DaisyThemeController` | `can't be extended outside of its library because it's a final class` | `final class` |
| `DaisyThemeService()` | `Abstract classes can't be instantiated` | `abstract final class` |
| `._palette` | `The getter '_palette' isn't defined` | `_`: privado de su biblioteca |
| `theme.value = ...` | `There isn't a setter named 'value' in class 'ValueListenable'` | El tipo público no tiene escritura |

Fíjate en lo que falta en la API pública: **ningún tipo de `signals_flutter`**. `controller.theme` devuelve un `ValueListenable`, que es un tipo de Flutter, y la señal es un detalle privado. Eso significa que el proyecto podría sustituir `FlutterSignal` por otra implementación sin cambiar el código de quien lo consume. Justamente eso ocurrió cuando el controlador pasó de `ValueNotifier` a `FlutterSignal`.

### Practica 4

Borra `lib/limites.dart`. Si en `consumidor` se quiere usar un `SignalBuilder` que observe `controller.theme.value`, como en la unidad 10, ¿qué hay que añadir a su `pubspec.yaml`? ¿Sirve de algo que `daisy_ui` ya dependa de `signals_flutter`?

<details>
<summary>Ver respuesta</summary>

Hay que declarar su propia dependencia, `signals_flutter`, e importarla. Como `daisy_ui` no exporta ese paquete, `package:daisy_ui/daisy_ui.dart` no ofrece `SignalBuilder`. El siguiente apartado muestra que el paquete está disponible indirectamente y que el import compilaría igual; el lint `depend_on_referenced_packages` avisa porque eso sería depender de un detalle que `daisy_ui` podría cambiar.

</details>

## 5. Límites reales y límites por convención

¿Se puede usar `DaisyButton` de todos modos? Crea `lib/directo.dart`. **Predice qué líneas dan problemas**:

```dart
import 'package:daisy_ui/themes/application/daisy_theme_controller.dart';
import 'package:daisy_ui/themes/presentation/action/button.dart';
import 'package:signals_flutter/signals_flutter.dart';

Type boton = DaisyButton;
Type senal = FlutterSignal<int>;

Object oculto(DaisyThemeController controller) => controller._palette;
```

`flutter analyze --no-pub` responde:

```text
   info • The imported package 'signals_flutter' isn't a dependency of the importing package • lib/directo.dart:3:8 • depend_on_referenced_packages
  error • The getter '_palette' isn't defined for the type 'DaisyThemeController' • lib/directo.dart:8:62 • undefined_getter
```

El texto está recortado, pero hay un único error, sobre `_palette`, y un aviso informativo. **`DaisyButton` compila**. Esto nos da la distinción más importante de la unidad:

- **Límites que impone el lenguaje.** `_`, `final class`, `abstract final class` y el tipo `ValueListenable` sin setter. Importar el archivo directamente no cambia nada: `_palette` sigue siendo inaccesible. El adaptador `_ThemeListenable` es otro objeto, así que un cast tampoco llega a la señal (unidad 16).
- **Límites por convención.** La lista de `export`. Decide qué recibe quien importa `daisy_ui.dart`, pero **no impide** importar otro archivo de `lib/`. Todo lo que hay en `lib/` es accesible con `package:`.

Fíjate en que el analizador no ha dicho nada sobre `themes/presentation/action/button.dart`. En Dart existe una convención para esto: la implementación privada del paquete va en `lib/src/`, y el lint `implementation_imports` avisa a quien importe `src/` de otro paquete. DaisyUI no tiene `lib/src/`, sino `lib/themes/`, de modo que ese lint no se aplica.

El propio proyecto lo usa. El [ejemplo](../../../example/lib/main.dart) y [su prueba](../../../example/test/widget_test.dart), que son otro paquete, hacen esto:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:daisy_ui/themes/presentation/action/button.dart';
```

Este es un fragmento. El botón está en desarrollo y no forma parte de la API pública. La consecuencia es práctica: si alguien usa esa ruta y un día se mueve `button.dart`, su código deja de compilar, aunque nadie haya cambiado nada de la «API pública». Quien importa una ruta interna acepta ese riesgo.

### Practica 5

Vas a mover [daisy_theme_controller.dart](../../../lib/themes/application/daisy_theme_controller.dart) a otra carpeta, y actualizas el `export` de `daisy_ui.dart`. ¿A quién le afecta y a quién no? ¿Qué diferencia supondría que se llamara `lib/src/...`?

<details>
<summary>Ver respuesta</summary>

A quien importa `package:daisy_ui/daisy_ui.dart` no le afecta: recibe los mismos nombres. Sí afecta a quien usara la ruta completa, como `package:daisy_ui/themes/application/daisy_theme_controller.dart`, y su código deja de compilar. Si estuviera en `lib/src/`, seguiría siendo importable, pero el lint `implementation_imports` le habría avisado a esa persona de que no contara con esa ruta.

</details>

## 6. Dependencias de ejecución y de desarrollo

[pubspec.yaml](../../../pubspec.yaml) separa dos listas. Se diferencian en **a quién afectan**:

| Dependencia | Lista | Para qué está en DaisyUI |
|---|---|---|
| `flutter` | `dependencies` | Widgets, `InheritedNotifier`, `ValueListenable` |
| `signals_flutter` | `dependencies` | La señal del controlador; solo la importa [daisy_theme_controller.dart](../../../lib/themes/application/daisy_theme_controller.dart) |
| `prism_flutter` | `dependencies` | `RayOklch` y la conversión a `Color` |
| `equatable` | `dependencies` | El `==` de los modelos |
| `freezed_annotation` | `dependencies` | `@freezed`, y reexporta `json_annotation` |
| `json_annotation` | `dependencies` | `@JsonKey` y compañía |
| `freezed` | `dev_dependencies` | Generar `.freezed.dart` |
| `json_serializable` | `dev_dependencies` | Generar `.g.dart` |
| `build_runner`, `source_gen` | `dev_dependencies` | Ejecutar y combinar generadores |
| `flutter_test` | `dev_dependencies` | Pruebas |
| `flutter_lints` | `dev_dependencies` | Reglas del analizador |

Compruébalo desde el punto de vista del consumidor:

```shell
flutter pub deps --style=compact --no-dev
```

La salida incluye, entre otras, estas líneas, recortadas:

```text
dependencies:
- daisy_ui 0.0.1 [flutter freezed_annotation json_annotation prism_flutter signals_flutter equatable]
- flutter 0.0.0 [...]

transitive dependencies:
- equatable 3.0.0 [...]
- freezed_annotation 3.1.0 [...]
- prism_flutter 2.1.0 [...]
- signals_core 7.0.0 [...]
- signals_flutter 7.1.0 [...]
```

Aparecen las `dependencies` de DaisyUI, como **dependencias transitivas**, es decir, dependencias de una dependencia. **No aparecen `freezed`, `build_runner` ni `json_serializable`**: las `dev_dependencies` de un paquete solo se instalan cuando se trabaja en ese paquete. Los consumidores reciben ya los `.freezed.dart` y `.g.dart` generados, y no tienen que generar nada (unidad 29).

Hay un caso curioso: `json_annotation`. Ninguna biblioteca de `lib/` lo importa directamente, ya que `freezed_annotation` lo reexporta. ¿Sobra? No: si lo quitas, `build_runner` se niega a generar y dice `You are missing a required dependency on json_annotation`. Lo pide `json_serializable`.

Otra diferencia importante: **`pubspec.lock` no viaja con el paquete**. El [pubspec.yaml](../../../pubspec.yaml) dice `signals_flutter: ^7.1.0`, que es un rango: es la versión que tiene que resolver cada aplicación, y `consumidor` tiene su propio `pubspec.lock`. Aquí el de la raíz está incluso ignorado en `.gitignore`, mientras que [example/pubspec.lock](../../../example/pubspec.lock) sí se versiona, porque el ejemplo es una aplicación. Por eso, las unidades indican con qué versión se contrastó cada comportamiento: los detalles internos de Signals, como el `putIfAbsent` de la unidad 30, podrían cambiar dentro de ese rango.

También verás una dependencia sobrante, que conviene saber reconocer: [example/pubspec.yaml](../../../example/pubspec.yaml) declara `material_ui`, pero ningún archivo de `example/lib` ni de `example/test` lo importa desde que el ejemplo cambió. Declararla no lo rompe, aunque tampoco la usa.

Por último, `environment` también limita: `consumidor` necesita un SDK y un Flutter dentro de esos rangos, y por eso los has copiado en su `pubspec.yaml`.

### Practica 6

Decides que el controlador usará `ValueNotifier` otra vez y borras el único `import` de `signals_flutter`. ¿Qué harías en `pubspec.yaml`? ¿Necesitaría cambiar algo quien consume el paquete, si solo importa `daisy_ui.dart`? ¿Y si usa `SignalBuilder` sobre `controller.theme.value`?

<details>
<summary>Ver respuesta</summary>

Quitarías `signals_flutter` de `dependencies`. Quien solo use la API pública no cambia nada, porque ningún tipo de Signals aparecía en ella: es el beneficio de la encapsulación. En cambio, el `SignalBuilder` compilaría si tiene su propia dependencia, pero **dejaría de actualizarse**, ya que el valor ya no procede de una señal (unidad 10). Compilar no prueba que el comportamiento se conserve, y por eso existe *A SignalBuilder can observe a theme controller directly* en [las pruebas de scopes](../../../test/themes/daisy_theme_scope_test.dart).

</details>

## 7. Una aplicación que consume el paquete

Junta todo esto en una aplicación pequeña. Borra los archivos anteriores de `lib/` y crea `lib/main.dart`:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  DaisyThemeService.initialize();
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(child: const MaterialApp(home: Portada()));
  }
}

class Portada extends StatelessWidget {
  const Portada({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = context.daisyTheme;
    final base = tema.colors.base;

    return Scaffold(
      backgroundColor: base.base,
      body: Center(
        child: TextButton(
          onPressed: () => DaisyThemeService.setTheme(
            tema.id == DaisyThemes.dark.id
                ? DaisyThemes.cupcake
                : DaisyThemes.dark,
          ),
          child: Text(tema.name, style: TextStyle(color: base.content)),
        ),
      ),
    );
  }
}
```

Y una prueba, en `test/portada_test.dart`:

```dart
import 'package:consumidor/main.dart';
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('la portada cambia de tema usando solo la API pública', (
    tester,
  ) async {
    await tester.pumpWidget(const MiAplicacion());
    expect(find.text('Light'), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    expect(find.text('Dark'), findsOneWidget);
    expect(
      tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
      DaisyThemes.dark.colors.base.base,
    );
  });
}
```

Comprueba las dos cosas, desde `consumidor`:

```shell
flutter analyze --no-pub
flutter test --no-pub
```

El análisis no encuentra problemas, y la prueba pasa. Esto demuestra que todo el flujo funciona **solo con un `import` y los nombres públicos**. Para verla, necesitas una plataforma, que puedes añadir con `flutter create . --platforms=macos` (o la tuya) antes de `flutter run`. Esa orden conserva tu `lib/main.dart`, pero añade `test/widget_test.dart`, una prueba de plantilla que no corresponde a esta aplicación, así que bórrala. La prueba de arriba no ejecuta `main`, tal como explicó la unidad 30.

Observa lo que la aplicación no ha necesitado saber: nada sobre `FlutterSignal`, `_ThemeListenable`, Freezed o Prism.

`path:` es solo una de las formas de declarar una dependencia. Si estuviera publicado en pub.dev, sería `daisy_ui: ^0.0.1`; y se puede apuntar a un repositorio con `git:`. El resto no cambia. Para publicar, `dart pub publish --dry-run` valida el paquete sin enviar nada: en la versión actual, solo sugiere rellenar el campo `homepage` o `repository`, que está vacío.

### Practica 7

Alguien crea un controlador propio en `Portada`, dentro de `build`, para una vista previa. Con lo aprendido en todo el plan, ¿qué le dirías? ¿Algún límite de esta unidad impide ese error?

<details>
<summary>Ver respuesta</summary>

Que lo cree en el `initState` de un `State` y lo libere en `dispose` (unidad 19). Crearlo en `build` produciría un controlador nuevo en cada reconstrucción, perdería el tema elegido y nunca se liberaría. **Ningún límite de esta unidad lo impide**: `DaisyThemeController` es público y su constructor también. La API controla qué se puede nombrar, pero no cómo se usa. Para eso están la documentación, como el comentario de la clase del controlador, y las pruebas.

</details>

## Ejercicio final: hacer público `DaisyButton`

Decides ofrecer el botón en la API pública, de modo que `consumidor` no necesite una ruta interna. Haz esto en una **copia de práctica**, como en la unidad 29. Desde la raíz del proyecto:

```shell
rsync -a --exclude build --exclude .git ./ ../daisy_ui_practica/
```

Cambia el `path` de `consumidor` a `../daisy_ui_practica`, y ejecuta `flutter pub get` en `consumidor`.

1. Añade a [lib/daisy_ui.dart](../../../lib/daisy_ui.dart) el `export` mínimo para que este archivo de `consumidor`, `lib/boton.dart`, compile:

   ```dart
   import 'package:daisy_ui/daisy_ui.dart';
   import 'package:flutter/widgets.dart';

   Widget boton() => DaisyButton(onPressed: () {}, child: const Text('Hola'));
   ```

2. **Antes de ejecutar**, predice: si después quiere pasarle `theme: const DaisyButtonTheme(elevation: 2)`, ¿compilará con ese `export`? ¿Y `DaisyButtonModifier.circle`? Decide qué más hay que exportar.
3. El ejemplo y su prueba ya no necesitarán `import 'package:daisy_ui/themes/presentation/action/button.dart';`. ¿Se pueden quitar sin más? Compruébalo.
4. Añadir esto a la API pública es sencillo. ¿Qué compromiso adquieres con el nombre `DaisyButton`? ¿Es igual añadir un `export` que quitarlo más tarde?

<details>
<summary>Ver solución</summary>

**1.** Basta con esta línea en `daisy_ui.dart`:

```dart
export 'themes/presentation/action/button.dart';
```

Este es un fragmento. `flutter analyze --no-pub` no da errores en `lib/boton.dart`: `DaisyButton` es público y sus parámetros obligatorios no requieren nombrar otros tipos de DaisyUI. `theme` tiene un valor predeterminado, `const DaisyButtonTheme()`, que se aplica sin que el consumidor lo escriba.

**2.** No compila. El analizador dice `The name 'DaisyButtonTheme' isn't a class` y `Undefined name 'DaisyButtonModifier'`, porque `button.dart` los **importa** pero no los **exporta**. Es el problema clásico de una API a medias: el constructor público acepta un tipo que el consumidor no puede nombrar. Para que quede completo, hacen falta las líneas:

```dart
export 'themes/domain/button_theme.dart';
export 'themes/domain/button/button_modifier.dart';
export 'themes/domain/button/button_size.dart';
export 'themes/domain/button/button_style.dart';
export 'themes/domain/button/button_type.dart';
```

Este es otro fragmento. Los cuatro enums son parámetros del tema del botón, de modo que si se ofrece el tema, también deberían ofrecerse ellos.

**3.** Sí se pueden quitar. `daisy_ui.dart` ya da `DaisyButton`, y `flutter test --no-pub` dentro de `example`, en la copia, sigue dando 3 pruebas correctas. Dejarlo no es un error, aunque `flutter analyze` lo señala con el aviso `unnecessary_import`, una vez en cada archivo.

**4.** A partir de ahí, `DaisyButton` y lo que acepta forman parte del contrato: el riesgo de la práctica 5 ya no es solo de quien usaba una ruta interna. Añadir es compatible: nadie se rompe por recibir un nombre más, salvo una colisión con uno propio. Quitar o renombrar **sí rompe** a quien lo use, y requiere una versión que lo anuncie. Por eso, publicar menos al principio y ampliar cuando el diseño esté estable es la opción más barata, y el botón todavía está en desarrollo.

Al terminar, puedes borrar las dos carpetas de práctica, salvo que quieras conservar algo de ellas. El proyecto real no se ha modificado. Desde `consumidor`:

```shell
cd ..
rm -rf consumidor daisy_ui_practica
```

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué diferencia hay entre biblioteca, paquete y plugin? ¿Qué es DaisyUI, y cómo lo compruebas? **Apartado 1.**
2. ¿Qué hacen `show`, `hide` y `as`? ¿A qué apunta `package:daisy_ui/x.dart`? **Apartado 2.**
3. ¿En qué se diferencia `export` de `import`? ¿Exportar un archivo exporta lo que este importa? **Apartados 3 y Practica 3.**
4. ¿Por qué se exportan `RayOklch` y `RayToFlutterColor`, y no todo Prism? **Apartado 3.**
5. Di cuatro cosas que un consumidor no puede hacer, y qué lo impide en cada caso. **Apartado 4.**
6. ¿Qué límites impone el lenguaje, y cuáles son por convención? ¿Por qué compila el import directo de `button.dart`? **Apartado 5.**
7. ¿Por qué no aparece `freezed` en las dependencias del consumidor? ¿Y por qué sigue haciendo falta `json_annotation`? **Apartado 6.**
8. ¿Qué `pubspec.lock` se aplica en una aplicación consumidora? ¿Qué implica eso sobre las versiones? **Apartado 6.**
9. ¿Qué aporta no exponer ningún tipo de Signals? **Apartados 4 y 6.**
10. ¿Por qué es más fácil añadir algo a la API pública que quitarlo? **Ejercicio final.**

Puedes dar la unidad por comprendida cuando expliques cómo otra aplicación utiliza los temas a través de la API pública y qué límites de encapsulación ofrecen realmente los tipos expuestos. Con esta unidad termina el plan de estudio.

## Para consultar si necesitas reforzar

- [Bibliotecas e imports](https://dart.dev/language/libraries): `show`, `hide`, `as` y privacidad con `_`.
- [Crear paquetes](https://dart.dev/tools/pub/create-packages): `lib/`, `lib/src/` y qué exportar.
- [Convenciones de un paquete](https://dart.dev/tools/pub/package-layout): dónde va cada carpeta.
- [Dependencias](https://dart.dev/tools/pub/dependencies): tipos de dependencias, rangos y `dev_dependencies`.
- [Modificadores de clase](https://dart.dev/language/class-modifiers): `final`, `abstract` y qué se permite fuera de la biblioteca.
- [`implementation_imports`](https://dart.dev/tools/linter-rules/implementation_imports) y [`depend_on_referenced_packages`](https://dart.dev/tools/linter-rules/depend_on_referenced_packages): los dos lints que aparecen en esta unidad.
- [lib/daisy_ui.dart](../../../lib/daisy_ui.dart), [pubspec.yaml](../../../pubspec.yaml) y [README](../../../README.md): la API y las dependencias actuales de DaisyUI.

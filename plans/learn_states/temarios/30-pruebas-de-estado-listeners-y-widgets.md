# 30. Pruebas de estado, listeners y widgets

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 29](29-generacion-de-codigo-y-configuracion.md) · **Estado:** pendiente

## Qué vas a aprender

Imagina este cambio en [daisy_theme_scope.dart](../../../lib/themes/application/daisy_theme_scope.dart): alguien sustituye `dependOnInheritedWidgetOfExactType` por `getInheritedWidgetOfExactType`, porque «total, las dos encuentran el scope». Ejecuta las pruebas del controlador y **todas pasan**. Sin embargo, la pantalla ya no cambia de tema. ¿Las pruebas estaban mal? No: demostraban otra cosa.

Esa es la idea de esta unidad. Una prueba verde solo demuestra lo que comprueba. Al terminar podrás escribir una prueba de listeners, una de scopes independientes y una de serialización; sabrás preparar y limpiar el estado para que una prueba no contamine a otra, y podrás escoger la prueba que demuestra lo que estás afirmando, incluido lo que solo se ve ejecutando la aplicación.

Los ejemplos completos son archivos de prueba independientes. Copia **uno cada vez** a `test/estudio_pruebas_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_pruebas_test.dart
```

Si usas FVM, antepón `fvm`. Necesitas las dependencias ya resueltas. Al acabar, borra ese archivo: no forma parte del proyecto. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar con 7–8 y el ejercicio final.

Los ejemplos se ejecutaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0.

## 1. Una prueba es un programa que afirma algo

Hasta ahora comprobabas una salida mirándola: imprimías un valor y lo comparabas con lo que esperabas. Una **prueba** hace esa comparación por ti, de modo que se puede repetir cada vez que cambia el código.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un controlador nuevo empieza con el tema claro', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    expect(controller.theme.value, DaisyThemes.light);
  });
}
```

El resultado termina así:

```text
00:00 +1: All tests passed!
```

Las piezas nuevas son pocas:

1. `flutter_test` es el paquete que aporta `test`, `expect` y las herramientas de widgets. Está en `dev_dependencies` porque solo lo necesita quien desarrolla el paquete.
2. `main` no ejecuta las pruebas directamente: `test(...)` **registra** una descripción y una función. Después, el ejecutor las llama una a una.
3. `expect(real, esperado)` compara. Si no coinciden, lanza un error y esa prueba se marca como fallida. Aquí la comparación usa el `==` del modelo, el de Equatable (unidad 27).
4. `addTearDown(controller.dispose)` entrega la función que liberará el controlador cuando termine la prueba. Es la unidad 2 otra vez: entregamos `dispose`, no lo ejecutamos. Lo explicaremos en el apartado 3.

Una prueba que usa `test` y no monta widgets se llama **prueba unitaria**: ejercita un objeto directamente, sin árbol de widgets.

`expect` admite también **matchers**, objetos que describen una condición en lugar de un valor exacto. Los verás en el código real: `isTrue`, `isA<TypeError>()`, `isNot(...)`, `throwsA(...)` y `returnsNormally`.

### Practica 1

Cambia `DaisyThemes.light` por `DaisyThemes.dark` en el `expect`. ¿Qué ocurre? ¿Por qué el mensaje es tan largo? ¿Qué `expect` daría un mensaje más corto, y qué se perdería?

<details>
<summary>Ver respuesta</summary>

La prueba falla, y `Expected:` y `Actual:` escriben dos temas completos, porque el mensaje usa el `toString` del modelo, con todos sus colores. Con `expect(controller.theme.value.id, 'dark')` el mensaje sería de una línea, pero comprobarías menos: dos temas con el mismo `id` y distintos colores pasarían. Comparar el modelo entero es más estricto; comparar el `id` es más legible. Puedes usar `reason: tema.id`, como hace [la prueba de JSON](../../../test/themes/daisy_theme_json_test.dart), para saber qué tema falló.

</details>

## 2. Probar una notificación

Lo que afirmamos en las unidades 4–9 es concreto: un listener se ejecuta cuando cambia el valor, no se ejecuta si el valor es igual y deja de ejecutarse al retirarlo. Todo eso se puede contar sin Flutter.

**Antes de mirar los `expect`**, predice el valor de `avisos` en cada uno:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la vista avisa de cambios reales y deja de avisar al retirar', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var avisos = 0;
    void escuchar() => avisos++;

    controller.theme.addListener(escuchar);
    expect(avisos, 0);

    controller.setTheme(DaisyThemes.light.copyWith());
    expect(avisos, 0);

    controller.setTheme(DaisyThemes.dark);
    expect(avisos, 1);
    expect(controller.theme.value, DaisyThemes.dark);

    controller.theme.removeListener(escuchar);
    controller.setTheme(DaisyThemes.cupcake);
    expect(avisos, 1);
    expect(controller.theme.value, DaisyThemes.cupcake);
  });
}
```

Pasa, y cada línea demuestra algo distinto:

1. Registrar no avisa: `avisos` sigue en 0.
2. `copyWith()` sin argumentos crea un tema igual según `==`, así que no hay aviso (unidades 8 y 27).
3. Un tema distinto sí avisa. Como la notificación es síncrona, `avisos` ya vale 1 en la línea siguiente, sin esperar a nada.
4. Tras retirar, el valor sigue cambiando, pero el aviso no llega. Por eso comprobamos las dos cosas: `avisos` y `value`.

Esta prueba es muy parecida a *Theme views notify on changes* en [daisy_theme_controller_test.dart](../../../test/themes/daisy_theme_controller_test.dart).

¿Qué **no** demuestra? No hay ningún widget. No sabemos si alguien reconstruye una pantalla con ese aviso: eso es el apartado 5.

### Registrar dos veces un callback

¿Cuántos avisos produce esto? Es fácil dar por hecho la respuesta, así que predice cada caso:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ValueNotifier: la misma función, dos veces', () {
    final notifier = ValueNotifier<int>(0);
    addTearDown(notifier.dispose);
    var avisos = 0;
    void escuchar() => avisos++;

    notifier.addListener(escuchar);
    notifier.addListener(escuchar);
    notifier.value = 1;
    expect(avisos, 2);

    notifier.removeListener(escuchar);
    notifier.value = 2;
    expect(avisos, 3);
  });

  test('vista del controlador: la misma función, dos veces', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var avisos = 0;
    void escuchar() => avisos++;

    controller.theme.addListener(escuchar);
    controller.theme.addListener(escuchar);
    controller.setTheme(DaisyThemes.dark);
    expect(avisos, 1);

    controller.theme.removeListener(escuchar);
    controller.setTheme(DaisyThemes.cupcake);
    expect(avisos, 1);
  });

  test('vista del controlador: dos funciones anónimas', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var avisos = 0;

    controller.theme.addListener(() => avisos++);
    controller.theme.addListener(() => avisos++);
    controller.setTheme(DaisyThemes.dark);
    expect(avisos, 2);
  });
}
```

Las tres pasan, y sus números no coinciden:

- **`ValueNotifier`** guarda sus listeners en una lista. La misma función queda dos veces, avisa dos veces, y cada `removeListener` retira solo una.
- **La vista del controlador** delega en `FlutterSignal`, cuyo `addListener` guarda los listeners en un mapa cuya clave es la función. El segundo registro no añade nada, y una sola retirada basta.
- **Dos funciones anónimas** son dos objetos distintos, aunque se escriban igual (unidad 2). Se registran dos veces en cualquiera de las dos implementaciones.

Por tanto, si una prueba espera `avisos == 1` tras un doble registro, pasará sobre `controller.theme` y fallará sobre un `ValueNotifier`. Es un detalle de la versión instalada, no una promesa del contrato `Listenable`: las pruebas permiten comprobarlo en lugar de suponerlo.

### Practica 2

En la prueba de las funciones anónimas, intenta retirar los listeners con `controller.theme.removeListener(() => avisos++);`. ¿Cuántos avisos llegan después con otro `setTheme`? ¿Cómo lo arreglarías?

<details>
<summary>Ver respuesta</summary>

Siguen llegando dos: el `removeListener` recibe una tercera función, que no está registrada, y no retira nada ni da error. Para poder retirarla, guarda la función en una variable, como `escuchar`, y entrega esa misma referencia al registrar y al retirar. Es el mismo problema de la unidad 2, y una prueba que cuenta avisos es justo lo que lo descubre.

</details>

## 3. Preparación y limpieza

Muchas pruebas necesitan el mismo punto de partida y dejar las cosas como estaban. Para eso están `setUp`, `tearDown` y compañía. **Predice el orden de las líneas** antes de mirar la salida:

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => print('setUpAll'));
  tearDownAll(() => print('tearDownAll'));
  setUp(() => print('setUp'));
  tearDown(() => print('tearDown'));

  test('a', () {
    print('prueba a');
    addTearDown(() => print('addTearDown 1'));
    addTearDown(() => print('addTearDown 2'));
  });

  test('b', () {
    print('prueba b');
  });
}
```

Las líneas que imprime, sin las del ejecutor, son:

```text
setUpAll
setUp
prueba a
addTearDown 2
addTearDown 1
tearDown
setUp
prueba b
tearDown
tearDownAll
```

Léelas así:

| Función | Cuándo se ejecuta | Para qué se usa |
|---|---|---|
| `setUpAll` | Una vez, antes de la primera prueba | Preparar algo costoso o que solo se hace una vez, como `DaisyThemeService.initialize` en [la prueba del ejemplo](../../../example/test/widget_test.dart) |
| `setUp` | Antes de cada prueba | Dejar el punto de partida conocido |
| `addTearDown` | Al terminar la prueba que lo registró, del último al primero | Limpiar lo creado dentro de esa prueba |
| `tearDown` | Después de cada prueba, tras los `addTearDown` | Limpiar lo común a todas |
| `tearDownAll` | Una vez, tras la última prueba | Deshacer `setUpAll` |

`addTearDown` tiene una ventaja: está al lado de lo que limpia, y se ejecuta **aunque la prueba falle** a medio camino. Si escribes `controller.dispose()` en la última línea y un `expect` anterior falla, esa línea no llega a ejecutarse.

El orden inverso también tiene sentido: lo último que creaste suele depender de lo anterior, así que se limpia primero.

### Practica 3

Omite `addTearDown(controller.dispose)` en la prueba del apartado 1. ¿Falla? ¿Significa eso que se puede omitir?

<details>
<summary>Ver respuesta</summary>

No falla: ninguna comprobación se fija en si se liberó. Tampoco está bien omitirlo, ya que la prueba dejaría de seguir la regla que enseña la unidad 13: quien crea el recurso lo libera. Una prueba verde no demuestra que el código no tenga fugas si nadie las comprueba, y aquí nadie lo hace.

</details>

## 4. Aislamiento: el estado que sobrevive

`DaisyThemeService` guarda su controlador en un campo `static`, de modo que dura todo el programa (unidad 17). Dentro de un archivo de pruebas, todas las pruebas comparten ese programa. **Predice qué ocurre** al ejecutar este archivo:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('la primera deja el tema oscuro', () {
    DaisyThemeService.setTheme(DaisyThemes.dark);
    expect(DaisyThemeService.theme.value.id, 'dark');
  });

  test('la segunda espera el tema claro', () {
    expect(DaisyThemeService.theme.value.id, 'light');
  });
}
```

Esta vez **debe fallar**, y falla la segunda prueba:

```text
  Expected: 'light'
    Actual: 'dark'
     Which: is different.
            Expected: light
              Actual: dark
                      ^
00:00 +1 -1: Some tests failed.
```

Son las líneas relevantes de la salida, que también incluye el nombre de la prueba y el lugar del fallo.

La segunda prueba no tiene ningún error por sí misma. Si la ejecutas sola, pasa:

```shell
flutter test --no-pub test/estudio_pruebas_test.dart --plain-name 'la segunda'
```

Eso es lo traicionero de una limpieza omitida: **falla otra prueba distinta**, o pasa o falla según el orden. La solución es la que usan las pruebas del proyecto. Añade estas dos líneas al principio de `main`:

```dart
setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));
```

Este es un fragmento. Con él, las dos pruebas pasan. En principio bastaría con `setUp`, pero `tearDown` asegura que nada se quede sin restablecer al terminar.

Hay otro límite, más amplio: `flutter test` ejecuta cada **archivo** de pruebas en un proceso separado. Si otro archivo comprobara el tema global tras este, empezaría en `light` aunque aquí se quedara en `dark`. Los campos `static` sobreviven entre pruebas de un archivo, pero no entre archivos.

Para encontrar dependencias de orden, Flutter puede barajar las pruebas de cada archivo:

```shell
flutter test --no-pub --test-randomize-ordering-seed=random
```

La salida indica la semilla usada, por si necesitas repetir un fallo con el mismo orden.

### Practica 4

Mira el `setUp` de [daisy_theme_controller_test.dart](../../../test/themes/daisy_theme_controller_test.dart). ¿Por qué restablece el servicio global, pero no hace nada parecido con los controladores que crea cada prueba?

<details>
<summary>Ver respuesta</summary>

Cada controlador local es un objeto nuevo creado dentro de su prueba: ninguna otra puede verlo, y su `addTearDown` lo libera. El servicio es un único objeto `static` que comparten todas. No se libera, porque su controlador dura todo el programa, así que lo único que se puede hacer es devolverlo al valor conocido.

</details>

## 5. Probar una reconstrucción: `testWidgets`, `pumpWidget` y `pump`

Una **prueba de widget** monta un árbol real en un entorno de pruebas, sin dispositivo ni pantalla. El tiempo y los frames no avanzan solos: los controlas tú.

**Predice los dos `expect` que siguen a `setTheme`:** ¿qué texto hay antes del `pump`?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el cambio llega a la pantalla en el siguiente frame', (
    tester,
  ) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var builds = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: Builder(
            builder: (context) {
              builds++;
              return Text(context.daisyTheme.name);
            },
          ),
        ),
      ),
    );
    expect(find.text('Light'), findsOneWidget);
    expect(builds, 1);

    controller.setTheme(DaisyThemes.dark);
    expect(controller.theme.value, DaisyThemes.dark);
    expect(find.text('Light'), findsOneWidget);
    expect(builds, 1);

    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, 2);
  });
}
```

Pasa. Lo nuevo, paso a paso:

1. `testWidgets` registra una prueba que recibe un `WidgetTester`, normalmente llamado `tester`. Es `async` porque producir frames devuelve un `Future` que hay que esperar con `await`.
2. `pumpWidget` monta ese árbol y produce un frame. `Text` necesita saber la dirección del texto, y por eso aparece `Directionality`; en una aplicación la aporta `MaterialApp`.
3. `find.text('Light')` es un **finder**: describe qué buscar en el árbol. `findsOneWidget` es el matcher que exige exactamente una coincidencia.
4. Tras `setTheme`, el dato ya cambió, pero la pantalla no. El aviso marcó trabajo pendiente (unidad 22), y este espera a un frame.
5. `pump` produce ese frame. Ahora sí: `build` se ejecuta otra vez y lee el tema nuevo.

Esta prueba distingue dos afirmaciones que suelen confundirse: «el valor cambió» y «la interfaz se actualizó». Si olvidas el `await tester.pump()`, el siguiente `expect` falla aunque el código sea correcto. El error está en la prueba.

Un `pump` produce un frame. Cuando hay animaciones, se usa `pump(duracion)` para avanzar el reloj, o `pumpAndSettle`, que repite frames hasta que no quede ninguno programado. Lo verás en [la prueba del ejemplo](../../../example/test/widget_test.dart), porque `DaisyButton` anima su elevación.

¿Qué demuestra esta prueba? Que el aviso llega hasta `build` y que el `Text` contiene el nombre nuevo. ¿Qué no demuestra? Que se vea bien: no hay colores comprobados, ni tamaños, ni píxeles.

### Practica 5

Llama a `setTheme` tres veces seguidas (`dark`, `cupcake`, `corporate`) antes de un único `pump`. ¿Cuánto vale `builds`, y qué texto aparece?

<details>
<summary>Ver respuesta</summary>

`builds` vale 2 y aparece `Corporate`. Los tres cambios producen tres avisos, pero cada uno solo marca el scope como pendiente. En el frame hay una única reconstrucción, que lee el valor actual: es la agrupación de la unidad 22. Si contaras avisos con un listener, habría 3. Un contador de avisos y uno de `build` miden cosas distintas.

</details>

## 6. Probar la independencia de dos scopes

Para demostrar que dos scopes son independientes no basta con ver el texto: un consumidor podría reconstruirse sin motivo y mostrar lo mismo. Por eso contamos también las llamadas a `build`.

**Predice el mapa `builds`** después de cada cambio:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cada scope actualiza solo a sus consumidores', (tester) async {
    final izquierda = DaisyThemeController();
    final derecha = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(izquierda.dispose);
    addTearDown(derecha.dispose);
    final builds = <String, int>{'izquierda': 0, 'derecha': 0};

    Widget consumidor(String nombre) => Builder(
      builder: (context) {
        builds[nombre] = builds[nombre]! + 1;
        return Text('$nombre:${context.daisyTheme.id}');
      },
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            DaisyThemeScope(
              controller: izquierda,
              child: consumidor('izquierda'),
            ),
            DaisyThemeScope(controller: derecha, child: consumidor('derecha')),
          ],
        ),
      ),
    );
    expect(builds, {'izquierda': 1, 'derecha': 1});

    izquierda.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(find.text('izquierda:cupcake'), findsOneWidget);
    expect(find.text('derecha:dark'), findsOneWidget);
    expect(builds, {'izquierda': 2, 'derecha': 1});

    derecha.setTheme(DaisyThemes.light);
    await tester.pump();
    expect(find.text('izquierda:cupcake'), findsOneWidget);
    expect(find.text('derecha:light'), findsOneWidget);
    expect(builds, {'izquierda': 2, 'derecha': 2});
  });
}
```

Pasa. La línea `expect(builds, {'izquierda': 2, 'derecha': 1})` es la clave. Los textos solo muestran que `derecha` conserva su valor; el contador muestra que su `build` **ni siquiera se ejecutó**. Compara esta prueba con *Nested scopes update only their own theme consumers* en [daisy_theme_scope_test.dart](../../../test/themes/daisy_theme_scope_test.dart), que hace lo mismo con tres niveles anidados.

Observa que aquí nadie llama a `pumpWidget` otra vez. Si reconstruyeras el árbol completo entre cambios, el contador subiría por esa otra razón, como vimos con `const` en la unidad 25.

### Practica 6

¿Por qué es necesario el `addTearDown` de los dos controladores si el árbol se desmonta solo al terminar la prueba?

<details>
<summary>Ver respuesta</summary>

Desmontar el scope solo retira su escucha, ya que el controlador le está prestado (unidades 13 y 25). Liberarlo le corresponde a quien lo creó, que aquí es la propia prueba. Por eso lo libera ella.

</details>

## 7. Probar datos y errores

La serialización no necesita ni listeners ni widgets: entra un tema y sale un tema. Es el tipo de prueba más sencillo de todos.

```dart
import 'dart:convert';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('un tema sobrevive al viaje por texto JSON', () {
    final tema = DaisyThemes.cupcake.copyWith(border: 1.5);

    final texto = jsonEncode(tema);
    final mapa = jsonDecode(texto) as Map<String, dynamic>;
    final recuperado = DaisyThemeModel.fromJson(mapa);

    expect(recuperado, tema);
    expect(recuperado.border, 1.5);
  });

  testWidgets('leer sin scope informa del ancestro que falta', (tester) async {
    await tester.pumpWidget(
      Builder(builder: (context) => Text(context.daisyTheme.name)),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('DaisyThemeScope'));
  });
}
```

Las dos pasan.

**La primera** recorre tema → texto → mapa → tema (unidad 28). `expect(recuperado, tema)` depende del `==` de Equatable. Si un campo faltara en `props`, esa comparación no vería su pérdida (unidad 29). Por eso, cuando un dato importa, se añade también una comprobación directa, como `recuperado.border`.

**La segunda** prueba un error. Si `build` lanza una excepción, Flutter la captura y `testWidgets` la **guarda**. Hay que recogerla con `tester.takeException()`; si no, la prueba falla al terminar, informando de una excepción sin atender.

Fuera de un `build`, una excepción se comprueba de otra forma: se entrega una función a `expect`, sin ejecutarla, para que sea el matcher quien la llame.

```dart
expect(
  () => controller.setTheme(DaisyThemes.dark),
  throwsA(isA<SignalsWriteAfterDisposeError>()),
);
```

Este es un fragmento de la [unidad 25](25-scopes-anidados-e-independencia.md). Si escribieras `controller.setTheme(...)` sin `() =>`, el error se lanzaría antes de llegar a `expect`, y la prueba fallaría.

### Practica 7

En la segunda prueba, borra todo lo que hay después del `pumpWidget`: el `takeException` y los dos `expect`. ¿Pasa la prueba? ¿Por qué?

<details>
<summary>Ver respuesta</summary>

Falla, aunque no haya ningún `expect`. La excepción capturada sigue guardada al terminar y `testWidgets` la informa: nadie la atendió. Esto es útil, porque un error en `build` no puede pasar desapercibido por olvidar comprobarlo.

</details>

## 8. Escoger la prueba: qué demuestra cada una

Volvamos a la pregunta inicial. Para comprobarlo de verdad, **rompe el código a propósito** y mira qué pruebas lo detectan. Haz estos experimentos en una copia de práctica, como en la unidad 29:

```shell
rsync -a --exclude build --exclude .git ./ ../daisy_ui_practica/
cd ../daisy_ui_practica
flutter pub get
```

Aplica cada cambio por separado, ejecuta `flutter test --no-pub` y deshazlo copiando el archivo original de `../daisy_ui`. **Predice primero qué archivo de pruebas fallará**:

| Cambio en `lib/themes/application/` | Pruebas que fallan |
|---|---|
| **A.** En `daisy_theme_scope.dart`, usar `getInheritedWidgetOfExactType` | 3: dos de scopes y la de `daisy_ui_test.dart`. Ninguna de `daisy_theme_controller_test.dart` |
| **B.** En `daisy_theme_controller.dart`, dejar `setTheme` vacío: `void setTheme(DaisyThemeModel theme) {}` | 10, tanto de controlador como de scopes |
| **C.** En `daisy_theme_controller.dart`, hacer que el getter cree otro adaptador: `get theme => _ThemeListenable(_palette);` | 2: las que comprueban `identical(...)` |
| **D.** En `daisy_theme_controller.dart`, vaciar el cuerpo de `initialize` | 0 |

Son los resultados observados en la versión actual, sobre las 23 pruebas del paquete. Cada uno enseña algo:

- **A** responde a la pregunta del principio. El controlador sigue avisando bien, así que sus pruebas tienen razón al pasar. Lo que se rompió es el registro de la dependencia del consumidor, que solo una prueba de widget puede ver.
- **B** rompe la base, y por eso se entera casi todo el mundo.
- **C** no impide que el tema cambie. Lo que protegen esas dos pruebas es la identidad de la vista: una decisión de diseño de la unidad 16.
- **D** es el más importante: **nada falla**. `initialize` crea una suscripción cuyo cuerpo aún es un `TODO`, y ninguna prueba puede notar su ausencia. *Initializing repeatedly preserves updates and allows disposal* comprueba que llamarlo varias veces es seguro, no que haga algo. Las pruebas verdes no dicen que esa función funcione.

Hay otro experimento de este tipo fuera del paquete. Borra `DaisyThemeService.initialize();` de `main` en [example/lib/main.dart](../../../example/lib/main.dart) y ejecuta `flutter test --no-pub` dentro de `example`: las 3 pruebas siguen pasando. Esas pruebas montan `const MyApp()` con `pumpWidget`, así que `main()` no llega a ejecutarse, y es `setUpAll` el que llama a `initialize`. Observa también que `flutter test` en la raíz **no** ejecuta las pruebas de `example`: ese directorio es otro paquete.

Con esto se puede organizar la elección:

| Afirmas que… | Te basta con… | Lo que no demuestra |
|---|---|---|
| Un valor se guarda, se compara o se copia | Prueba unitaria | Que alguien lo muestre |
| Un listener recibe o deja de recibir avisos | Prueba unitaria contando avisos | Que la pantalla se actualice |
| Un JSON conserva los datos | Prueba unitaria del ciclo completo | Que los datos antiguos sigan siendo válidos si no los incluyes |
| Un consumidor se reconstruye, o no, tras un cambio | Prueba de widget con contador de `build` | Cómo se ve en pantalla |
| Un widget recibe el color o tamaño correcto | Prueba de widget leyendo sus propiedades, como la del ejemplo | Que el resultado se vea bien, o sea legible |
| El resultado se ve bien, `main` arranca, el contraste es correcto | **Ejecutar la aplicación** y mirarla | Otros dispositivos que no hayas probado |

La última fila no es un fallo de las pruebas. Una prueba de widget no pinta en un dispositivo real, ni usa las fuentes de tu aplicación, y no ejecuta `main`. Para esa afirmación, abre la aplicación:

```shell
cd example
flutter run
```

### Practica 8

Cada afirmación necesita una prueba. Elige: (a) «Al cerrar la vista previa, su controlador prestado sigue siendo utilizable». (b) «El modo oscuro tiene contraste suficiente». (c) «`DaisyThemes.corporate.toJson()` solo contiene valores JSON».

<details>
<summary>Ver respuesta</summary>

(a) Prueba de widget: monta el scope, desmóntalo con `pumpWidget`, usa el controlador y vuelve a montar, como *Unmounting a scope does not dispose its borrowed controller*. (c) Prueba unitaria: recorre el mapa como `_expectJsonValue` en [la prueba de JSON](../../../test/themes/daisy_theme_json_test.dart). (b) Podría ser una prueba unitaria si defines el contraste como una fórmula sobre los colores, y entonces demuestra esa fórmula; «se lee bien» requiere además mirar la aplicación. Merece la pena separar las dos afirmaciones.

</details>

## Ejercicio final: tres pruebas y una predicción

Escribe en `test/estudio_pruebas_test.dart` estas tres pruebas, sin copiar las anteriores:

1. **Listeners.** Con un controlador iniciado en `dark`, registra un listener que guarde en una lista el `id` del tema cada vez que lo avisen. Cambia a `cupcake`, vuelve a asignar un tema igual, retira el listener y cambia a `light`. Comprueba la lista y el valor final.
2. **Scopes independientes.** Monta dos scopes hermanos, uno con el servicio global y otro con un controlador propio. Cambia el servicio. Comprueba el texto de los dos y las veces que se ha reconstruido cada consumidor. Asegúrate de que la prueba deja el servicio como estaba.
3. **Serialización.** Toma `DaisyThemes.dark`, cambia su radio `fields` a 12 y comprueba el viaje por texto JSON, incluido ese radio de forma directa.

Antes de ejecutar, responde por escrito: **si omites la limpieza del servicio y añades una cuarta prueba que espera `light`, ¿cuál falla? ¿Y si registras dos veces el listener de la primera prueba?**

<details>
<summary>Ver solución</summary>

```dart
import 'dart:convert';

import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  test('el listener recibe solo los cambios reales mientras está registrado', () {
    final controller = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(controller.dispose);
    final vistos = <String>[];
    void escuchar() => vistos.add(controller.theme.value.id);

    controller.theme.addListener(escuchar);
    controller.setTheme(DaisyThemes.cupcake);
    controller.setTheme(DaisyThemes.cupcake.copyWith());
    controller.theme.removeListener(escuchar);
    controller.setTheme(DaisyThemes.light);

    expect(vistos, ['cupcake']);
    expect(controller.theme.value, DaisyThemes.light);
  });

  testWidgets('el servicio y un controlador propio no se afectan', (
    tester,
  ) async {
    final propio = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(propio.dispose);
    final builds = <String, int>{'global': 0, 'propio': 0};

    Widget consumidor(String nombre) => Builder(
      builder: (context) {
        builds[nombre] = builds[nombre]! + 1;
        return Text('$nombre:${context.daisyTheme.id}');
      },
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            DaisyThemeScope(child: consumidor('global')),
            DaisyThemeScope(controller: propio, child: consumidor('propio')),
          ],
        ),
      ),
    );

    DaisyThemeService.setTheme(DaisyThemes.cupcake);
    await tester.pump();

    expect(find.text('global:cupcake'), findsOneWidget);
    expect(find.text('propio:dark'), findsOneWidget);
    expect(builds, {'global': 2, 'propio': 1});
  });

  test('el radio modificado sobrevive al viaje por texto JSON', () {
    final tema = DaisyThemes.dark.copyWith(
      radius: DaisyThemes.dark.radius.copyWith(fields: 12),
    );

    final mapa = jsonDecode(jsonEncode(tema)) as Map<String, dynamic>;
    final recuperado = DaisyThemeModel.fromJson(mapa);

    expect(recuperado, tema);
    expect(recuperado.radius.fields, 12);
  });
}
```

Las tres pasan. Por qué cada comprobación es la adecuada:

- **Listeners.** La lista es mejor que un contador: demuestra también qué valor había cuando llegó cada aviso. El `copyWith()` no añade nada, porque es igual según `==`. `light` no aparece, porque ya se había retirado el listener; por eso se comprueba además `value`.
- **Scopes.** El contador `'propio': 1` demuestra que ese `build` no se volvió a ejecutar. El texto solo no podría demostrarlo.
- **Serialización.** `expect(recuperado, tema)` usa el `==` del modelo, mientras que `recuperado.radius.fields` no depende de `props`.

**Respuesta a la predicción.** Sin la limpieza, si la cuarta prueba se ejecuta tras la segunda, falla **la cuarta**, aunque el error esté en la falta de limpieza: el tema se quedó en `cupcake`. Si cambias el orden, puede pasar. Con el listener registrado dos veces sobre `controller.theme`, **no falla nada**: es la misma función, el mapa de `FlutterSignal` no la duplica y `vistos` sigue siendo `['cupcake']`. Con un `ValueNotifier`, la lista tendría `cupcake` dos veces y la prueba fallaría. Con dos funciones anónimas distintas, también.

Borra el archivo al terminar:

```shell
rm test/estudio_pruebas_test.dart
```

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué diferencia hay entre `test` y `testWidgets`? ¿Quién ejecuta la función que le entregas? **Apartados 1 y 5.**
2. ¿Qué demuestra una prueba que cuenta avisos? ¿Qué no puede demostrar? **Apartado 2.**
3. ¿Cuántos avisos llegan tras registrar dos veces la misma función en un `ValueNotifier`? ¿Y en `controller.theme`? ¿Y con dos funciones anónimas? **Apartado 2.**
4. ¿En qué orden se ejecutan `setUp`, `addTearDown` y `tearDown`? ¿Por qué `addTearDown` es más seguro que una última línea? **Apartado 3.**
5. ¿Por qué omitir una limpieza hace fallar a otra prueba distinta? ¿Hasta dónde llega el estado `static`? **Apartado 4.**
6. ¿Qué hace `pump` que `setTheme` no hace? ¿Qué texto hay en pantalla entre los dos? **Apartado 5.**
7. Para demostrar que un consumidor **no** se reconstruye, ¿por qué no basta con mirar su texto? **Apartado 6.**
8. ¿Qué pasa si no recoges una excepción con `takeException`? **Apartado 7.**
9. Si vacías `initialize`, ¿qué prueba falla? ¿Qué te enseña eso? **Apartado 8.**
10. ¿Qué afirmaciones solo se pueden comprobar ejecutando la aplicación? **Apartado 8.**

Puedes dar la unidad por comprendida cuando, ante cualquier afirmación sobre el tema, sepas elegir la prueba que la demuestra y decir qué se queda sin demostrar. La [unidad 31](31-ejercicio-final-explicar-todo-el-flujo.md) usa estas herramientas para seguir un cambio de tema de principio a fin.

## Para consultar si necesitas reforzar

- [Introducción a las pruebas de widgets](https://docs.flutter.dev/cookbook/testing/widget/introduction): `testWidgets`, `pumpWidget` y finders.
- [`WidgetTester`](https://api.flutter.dev/flutter/flutter_test/WidgetTester-class.html): `pump`, `pumpAndSettle`, `tap` y `takeException`.
- [`flutter_test`](https://api.flutter.dev/flutter/flutter_test/): lista de matchers, como `findsOneWidget`.
- [`package:test`](https://pub.dev/packages/test): `setUp`, `tearDown`, `addTearDown` y grupos.
- [Pruebas de controladores](../../../test/themes/daisy_theme_controller_test.dart), [scopes](../../../test/themes/daisy_theme_scope_test.dart), [JSON](../../../test/themes/daisy_theme_json_test.dart) y [ejemplo](../../../example/test/widget_test.dart): las pruebas reales de DaisyUI.

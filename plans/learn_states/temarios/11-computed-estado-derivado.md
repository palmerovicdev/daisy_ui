# 11. `computed`: estado derivado

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 10](10-dependencias-reactivas-y-contextos-de-observacion.md) · **Estado:** pendiente

## Qué vas a aprender

Hasta ahora hemos guardado un tema en una señal y observado sus cambios. Imagina que además queremos mostrar una etiqueta como `Tema: claro`. Esa etiqueta depende del tema elegido: si cambia el tema, queremos poder obtener el texto correspondiente sin mantener dos datos independientes que puedan contradecirse.

Al terminar podrás distinguir un dato almacenado de uno derivado, crear un `computed`, seguir cuándo se calcula y cuándo se reutiliza su resultado, y observar sus cambios. También compararás un cálculo puntual, un derivado reactivo y una vista de lectura. Por último veremos qué ocurre con el controlador real de DaisyUI.

Los ejemplos completos son pruebas Flutter independientes. Copia **una cada vez** a `test/estudio_computed_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_computed_test.dart
```

Necesitas las dependencias ya resueltas. Antes de mirar cada `expect`, intenta predecir el resultado; después lee la explicación paso a paso. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar después con DaisyUI y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Los detalles de evaluación y avisos se refieren a esas versiones y a las secuencias mostradas. Salvo en el apartado 9, que usa el controlador real, las señales y los `computed` de esta unidad son ejemplos independientes.

## 1. Un dato guardado y otro que se obtiene de él

Supongamos que el usuario elige el tema `'claro'`. Ese nombre es un **dato almacenado**: la aplicación conserva la selección y puede cambiarla. El texto `'Tema: claro'` es un **dato derivado**: lo podemos obtener añadiendo `'Tema: '` al nombre actual.

Este fragmento muestra la idea con una lectura puntual; no es un programa completo:

```dart
final tema = signal<String>('claro');
final texto = 'Tema: ${tema.value}';
```

`texto` contiene el resultado de esa lectura concreta. Si luego cambiamos la señal, la variable `texto` no se vuelve a calcular por sí sola. Podríamos interpolar otra vez cuando necesitemos mostrarlo, por ejemplo dentro de un builder que ya observa el tema.

También podríamos guardar el tema y la etiqueta como dos datos modificables. Pero entonces cada camino que cambia el tema tendría que acordarse de actualizar la etiqueta. Si uno lo olvida, los dos valores pueden quedar incoherentes. Una derivación expresa de dónde sale el texto en lugar de convertirlo en otra selección independiente.

Una analogía: una receta indica cómo preparar un plato a partir de ingredientes. Si cambian los ingredientes, podemos preparar el resultado correspondiente. La analogía no explica cómo se observan los cambios ni cuándo se repite el cálculo; esas son las decisiones que estudiaremos con `computed`.

### Practica 1

Si el usuario cambia el tema a `'oscuro'`, ¿qué dato se modifica directamente y cómo debería obtenerse la etiqueta `'Tema: oscuro'`?

<details>
<summary>Ver respuesta</summary>

Se modifica la señal que guarda el tema. La etiqueta se obtiene a partir del valor actual de esa fuente. El `String` que se leyó antes no cambia; para obtener el nuevo texto hace falta volver a calcularlo, ya sea de forma puntual o mediante un mecanismo derivado.

</details>

## 2. Crear y leer un `computed`

`computed` recibe una función que explica **cómo obtener** el valor derivado. El objeto que crea puede leerse mediante `.value`. Cuando la función se evalúa, Signals registra las señales que lee en ese contexto, como estudiamos para las lecturas observadas en la unidad 10.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('una etiqueta derivada del tema', () {
    final tema = signal<String>('claro');
    final FlutterComputed<String> etiqueta = computed<String>(
      () => 'Tema: ${tema.value}',
    );
    addTearDown(tema.dispose);
    addTearDown(etiqueta.dispose);

    expect(etiqueta.value, 'Tema: claro');
    tema.value = 'oscuro';
    expect(etiqueta.value, 'Tema: oscuro');
  });
}
```

Los resultados esperados son `Tema: claro` en la primera lectura y `Tema: oscuro` en la segunda.

1. `tema` referencia una señal que guarda el nombre seleccionado.
2. `computed<String>(...)` crea otro objeto, de tipo `FlutterComputed<String>`. La función `() => ...` indica cómo construir su resultado; entregarla no es lo mismo que entregar un texto ya calculado.
3. La primera lectura de `etiqueta.value` evalúa la función. Al leer `tema.value` dentro de ella, el cálculo registra esa señal como dependencia y devuelve `Tema: claro`.
4. Cambiamos la fuente a `oscuro`. En esta prueba, la siguiente lectura de `etiqueta.value` obtiene el resultado actualizado: `Tema: oscuro`.

La interfaz ordinaria de `FlutterComputed` permite leer el resultado; no ofrece un setter `value` para asignarlo como si fuera otra selección. Se cambia la fuente, `tema`. El test creó ambos objetos y registra su limpieza: en `addTearDown`, las funciones se ejecutan en orden inverso al registro, por lo que se libera el derivado antes que la señal. La propiedad de recursos se estudia en la unidad 13.

### Practica 2

¿Qué diferencia hay entre `etiqueta` y `etiqueta.value`? ¿Cuál cambiarías si el usuario elige otro tema?

<details>
<summary>Ver respuesta</summary>

`etiqueta` es el objeto que representa el cálculo derivado; `etiqueta.value` es el `String` que produce al consultarlo. Se cambia `tema.value`, porque `tema` es la fuente mutable de la que se obtiene la etiqueta.

</details>

## 3. La caché y el momento del cálculo

En las versiones instaladas, un `computed` puede conservar su último resultado para no ejecutar de nuevo la función en cada lectura. Vamos a contar las evaluaciones. El contador sirve solo para observar el ejemplo; en producción conviene que el callback de un derivado calcule su resultado sin realizar acciones externas como guardar datos o enviar peticiones.

**Antes de mirar los `expect`**, predice cuántas veces se ejecuta la función al crear el derivado, leerlo dos veces, cambiar la señal sin observadores y volver a leerlo dos veces.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('caché y lectura bajo demanda', () {
    final tema = signal('claro');
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      return 'Tema: ${tema.value}';
    });
    addTearDown(tema.dispose);
    addTearDown(etiqueta.dispose);

    expect(calculos, 0);
    expect(etiqueta.value, 'Tema: claro');
    expect(etiqueta.value, 'Tema: claro');
    expect(calculos, 1);

    tema.value = 'oscuro';
    expect(calculos, 1);
    expect(etiqueta.value, 'Tema: oscuro');
    expect(etiqueta.value, 'Tema: oscuro');
    expect(calculos, 2);
  });
}
```

El recorrido esperado es:

1. Crear `etiqueta` guarda la función; en esta prueba todavía no la ejecuta: `calculos` vale 0.
2. La primera lectura necesita el resultado, ejecuta la función y guarda `Tema: claro`; el contador pasa a 1.
3. La segunda lectura reutiliza el resultado porque la dependencia no ha cambiado; el contador sigue en 1.
4. Cambiar `tema` a `oscuro` no ejecuta inmediatamente el cálculo **en este ejemplo sin observador activo**.
5. La siguiente lectura detecta el cambio de la fuente y vuelve a calcular. Obtiene `Tema: oscuro` y el contador pasa a 2; otra lectura sin cambios reutiliza ese resultado.

No debemos convertir ese orden en una regla para todas las situaciones: registrar un observador puede necesitar un valor inicial y un observador activo puede provocar una actualización al cambiar una fuente. Lo veremos a continuación.

### Practica 3

Sin añadir listeners a la prueba anterior, ¿qué ocurre si leemos una tercera vez `etiqueta.value` después de obtener `Tema: oscuro` y no hemos vuelto a cambiar la señal?

<details>
<summary>Ver respuesta</summary>

Devuelve `Tema: oscuro` y `calculos` sigue en 2. Ya hay un resultado calculado para el valor actual de la dependencia; la nueva lectura puede reutilizarlo. El contador solo aumenta cuando se ejecuta la función del derivado.

</details>

## 4. Observar el resultado derivado

Un `FlutterComputed<T>` también implementa `ValueListenable<T>`, así que puede tener listeners. Una fuente puede cambiar y hacer que se revise el cálculo sin que cambie el **resultado**. Para verlo, derivaremos si un borde es `grueso`: consideraremos gruesos los valores de 2 o más.

**Antes de mirar los `expect`**, predice qué ocurre al registrar el listener y después de cambiar `borde` a 2, 3 y 1. ¿Cuántas evaluaciones y avisos esperas en cada paso?

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('un cambio de fuente puede conservar el resultado', () {
    final borde = signal(1);
    var calculos = 0;
    final grueso = computed(() {
      calculos++;
      return borde.value >= 2;
    });
    addTearDown(borde.dispose);
    addTearDown(grueso.dispose);
    final avisos = <bool>[];
    void escuchar() => avisos.add(grueso.value);

    grueso.addListener(escuchar);
    expect(calculos, 1);
    expect(avisos, isEmpty);
    borde.value = 2;
    expect(calculos, 2);
    expect(avisos, [true]);
    borde.value = 3;
    expect(calculos, 3);
    expect(avisos, [true]);
    borde.value = 1;
    expect(calculos, 4);
    expect(avisos, [true, false]);

    grueso.removeListener(escuchar);
    borde.value = 2;
    expect(calculos, 4);
    expect(grueso.value, isTrue);
    expect(calculos, 5);
  });
}
```

1. Al registrar el listener se necesita el valor inicial: `1 >= 2` da `false` y el contador pasa a 1. Con la opción predeterminada del puente de Flutter, esa lectura inicial no ejecuta el listener externo.
2. Con borde 2 se evalúa otra vez: el resultado cambia a `true` y el listener guarda `true`.
3. Con borde 3 se vuelve a evaluar, pero `3 >= 2` sigue siendo `true`. En esta implementación y secuencia no hay otro aviso externo porque el resultado derivado permanece igual.
4. Con borde 1 se evalúa `false` y se añade el segundo aviso. Se han realizado cuatro cálculos y recibido dos avisos.
5. Después de retirar el listener, cambiar el borde a 2 no ejecuta inmediatamente el cálculo en este ejemplo. La siguiente lectura lo actualiza: devuelve `true` y aumenta el contador a 5.

Cambiar una fuente, evaluar una función y notificar un cambio de resultado son pasos distintos. La comparación del resultado se realiza después de calcularlo; no hay que suponer un aviso por cada escritura de una fuente.

### Practica 4

Si el borde pasa de 2 a 3 mientras el listener está registrado, ¿por qué aumenta `calculos` pero no crece `avisos`?

<details>
<summary>Ver respuesta</summary>

El valor fuente cambió, por lo que el cálculo se revisó. Sin embargo, tanto `2 >= 2` como `3 >= 2` dan `true`; el resultado derivado no cambió y, en esta prueba, el listener no recibe otro aviso.

</details>

## 5. Las lecturas del cálculo son sus dependencias

Como vimos con `SignalBuilder`, importa **dónde y cuándo** se lee la señal. Si guardamos un texto antes de crear la función y el cálculo usa solo esa captura, no está leyendo la fuente dentro de su contexto:

```dart
final capturado = tema.value;
final etiqueta = computed(() => 'Tema: $capturado');
```

Es un fragmento. Cambiar después `tema` no convierte la lectura anterior en una dependencia del `computed`. La corrección, si queremos derivar el tema actual, es leer `tema.value` dentro de la función.

El cálculo también puede elegir una rama y usar señales diferentes en distintas evaluaciones:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('el cálculo usa la fuente de la rama elegida', () {
    final usarLocal = signal(true);
    final local = signal('claro');
    final global = signal('oscuro');
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      return usarLocal.value ? local.value : global.value;
    });
    addTearDown(usarLocal.dispose);
    addTearDown(local.dispose);
    addTearDown(global.dispose);
    addTearDown(etiqueta.dispose);

    expect(etiqueta.value, 'claro');
    expect(calculos, 1);
    global.value = 'bosque';
    expect(etiqueta.value, 'claro');
    expect(calculos, 1);
    usarLocal.value = false;
    expect(etiqueta.value, 'bosque');
    expect(calculos, 2);
    local.value = 'nieve';
    expect(etiqueta.value, 'bosque');
    expect(calculos, 2);
    global.value = 'sol';
    expect(etiqueta.value, 'sol');
    expect(calculos, 3);
  });
}
```

La primera evaluación lee `usarLocal` y `local`, pero no `global`. Por eso cambiar solo `global` no obliga a ejecutar otra vez la función cuando consultamos el derivado. Al cambiar `usarLocal` y leer de nuevo, se ejecuta la rama global y se obtiene el valor actual, `bosque`. Desde esa evaluación las fuentes pertinentes son `usarLocal` y `global`; cambiar solo `local` no repite el cálculo en este caso, mientras que cambiar `global` sí.

Este ejemplo consulta el derivado sin listener activo. Registrar qué fuentes se utilizaron no significa que el `computed` mantenga siempre suscripciones activas de la misma manera que cuando tiene observadores. Una lectura posterior debe comprobar si el resultado sigue vigente.

### Practica 5

Si `usarLocal` ya es `false` y el cálculo se ha vuelto a evaluar, ¿por qué `local.value = 'nieve'` no incrementa `calculos` al consultar la etiqueta en la prueba?

<details>
<summary>Ver respuesta</summary>

La última evaluación eligió la rama global y leyó `usarLocal` y `global`, no `local`. Esa modificación de la fuente que no participa en la rama vigente no exige ejecutar otra vez la función en esta secuencia. Si cambia la condición y se evalúa la otra rama, las dependencias pueden cambiar de nuevo.

</details>

## 6. Mostrar el derivado en Flutter

Calcular o avisar no dibuja por sí solo un widget. Como `FlutterComputed<String>` implementa `ValueListenable<String>`, podemos entregarlo a `ValueListenableBuilder`, el consumidor de Flutter que ya vimos en la unidad 9. El builder escucha el resultado derivado y recibe su valor para construir el texto.

**Antes de mirar los `expect`**, parte de borde 1, cambia a 2 y luego a 3, haciendo `pump` tras cada cambio. ¿Qué texto se mostrará y cuántas veces se ejecutarán el cálculo y el builder en este árbol aislado?

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('un builder muestra el resultado derivado', (tester) async {
    final borde = signal(1);
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      return borde.value >= 2 ? 'grueso' : 'fino';
    });
    addTearDown(borde.dispose);
    addTearDown(etiqueta.dispose);
    var builds = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder<String>(
          valueListenable: etiqueta,
          builder: (context, valor, child) {
            builds++;
            return Text(valor);
          },
        ),
      ),
    );
    expect(find.text('fino'), findsOneWidget);
    expect([calculos, builds], [1, 1]);
    borde.value = 2;
    await tester.pump();
    expect(find.text('grueso'), findsOneWidget);
    expect([calculos, builds], [2, 2]);
    borde.value = 3;
    await tester.pump();
    expect(find.text('grueso'), findsOneWidget);
    expect([calculos, builds], [3, 2]);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Al montar se muestra `fino`: hay un cálculo y un build. Al cambiar el borde a 2, el resultado pasa a `grueso`; el listener del builder recibe el aviso y, tras `pump`, se muestra el texto nuevo con dos cálculos y dos builds. Al cambiar a 3, el cálculo se ejecuta una tercera vez, pero devuelve otra vez `grueso`; en este montaje no hay un tercer aviso al builder y su contador permanece en 2.

El test desmonta el árbol antes de liberar el derivado y su fuente. Esas cifras describen el árbol de prueba: un widget puede reconstruirse por otras causas y otro consumidor puede observar directamente la fuente. `pump` comprueba un frame de prueba; no demuestra por sí solo un repintado observado en un dispositivo físico.

### Practica 6

En la prueba, ¿por qué tres evaluaciones del cálculo no significan necesariamente tres construcciones del builder?

<details>
<summary>Ver respuesta</summary>

La tercera evaluación devuelve el mismo texto que la anterior. El builder escucha el resultado derivado y, en esta secuencia, no recibe otro aviso por ese resultado igual. Una evaluación, un aviso y un build son eventos distintos; además, fuera de este montaje un build podría tener otras causas.

</details>

## 7. Una vista de lectura no siempre necesita un `computed`

Imagina que otra parte de la aplicación solo necesita consultar y escuchar el tema, sin recibir su setter en el tipo declarado. Puede bastar con una vista `ValueListenable` de la propia fuente:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('una vista de lectura usa la fuente existente', () {
    final tema = signal<String>('claro');
    addTearDown(tema.dispose);
    final ValueListenable<String> lectura = tema;

    expect(identical(tema, lectura), isTrue);
    tema.value = 'oscuro';
    expect(lectura.value, 'oscuro');
  });
}
```

`lectura` y `tema` apuntan al mismo objeto. El tipo `ValueListenable` permite leer y escuchar, pero no declara un setter; no crea otra señal ni impide recuperar el tipo real mediante un cast. Un adaptador separado ofrece otra frontera de API, que es lo que hace DaisyUI, como veremos en el apartado 9.

`computed(() => tema.value)` crearía **otro objeto derivado** que devuelve el mismo dato, con sus propias dependencias y vida útil. Puede tener sentido si se necesita expresamente un derivado de Signals, pero añade una capa si solo queremos entregar la fuente existente como vista de lectura. Si únicamente se necesita un texto durante un build que ya observa el tema, una interpolación puntual también puede bastar.

### Practica 7

¿En qué se diferencian `final ValueListenable<String> lectura = tema` y `final lectura = computed(() => tema.value)`?

<details>
<summary>Ver respuesta</summary>

La primera referencia usa la misma señal mediante un contrato de lectura y escucha. La segunda crea otro objeto cuyo resultado depende de la señal. Aunque ambas permitan leer el mismo texto, no tienen la misma identidad ni las mismas responsabilidades de ciclo de vida.

</details>

## 8. Agrupar cambios con `batch`

Si dos fuentes cambian por separado, un observador del derivado puede ver un resultado intermedio. `batch` agrupa las escrituras para que los observadores procesen juntos los cambios al terminar la función que recibe.

**Antes de mirar los `expect`**, predice cuántas veces se evaluará la etiqueta, contando la evaluación inicial al registrar el listener, y qué valores guardará ese listener.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('agrupar los cambios de tema y borde', () {
    final tema = signal('claro');
    final borde = signal(1);
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      final tipo = borde.value >= 2 ? 'grueso' : 'fino';
      return '${tema.value}: $tipo';
    });
    addTearDown(tema.dispose);
    addTearDown(borde.dispose);
    addTearDown(etiqueta.dispose);
    final avisos = <String>[];
    void escuchar() => avisos.add(etiqueta.value);

    etiqueta.addListener(escuchar);
    expect(calculos, 1);
    batch(() {
      borde.value = 2;
      tema.value = 'oscuro';
    });
    expect(calculos, 2);
    expect(avisos, ['oscuro: grueso']);
    etiqueta.removeListener(escuchar);
  });
}
```

1. Al registrar el listener se calcula `claro: fino`; el contador pasa a 1 y no hay aviso externo.
2. Dentro del lote las dos señales guardan sus valores nuevos, pero el observador todavía no se procesa.
3. Al terminar la función se evalúa una sola vez la etiqueta, que combina los dos valores finales. El listener guarda `oscuro: grueso` y nunca llega a ver `claro: grueso`.

Esta prueba no lee la etiqueta dentro del lote ni establece el comportamiento de todos los casos posibles de lotes.

### Practica 8

Si quitamos `batch` y hacemos las mismas dos escrituras por separado, ¿cuántos cálculos habrá y qué guardará el listener?

<details>
<summary>Ver respuesta</summary>

Habrá tres cálculos: el inicial y uno por cada escritura. El listener guardará `claro: grueso` y `oscuro: grueso`, porque sin el lote el observador procesa el resultado intermedio.

</details>

## 9. El controlador real de DaisyUI

El [controlador actual](../../../lib/themes/application/daisy_theme_controller.dart) guarda el tema en una `FlutterSignal<DaisyThemeModel>` privada y lo expone mediante un objeto `_ThemeListenable`, cuyo getter `value` lee esa señal. Su `setTheme` escribe en ella; el [scope](../../../lib/themes/application/daisy_theme_scope.dart) utiliza `InheritedNotifier` para escuchar la vista.

¿Qué pasa si escribimos un `computed` que lea `controller.theme.value`? ¿Y uno que lea un `ValueNotifier` corriente de la unidad 7? **Antes de mirar los `expect`**, predice qué devuelve cada etiqueta tras el cambio y si la copia igual del tema provoca otro cálculo.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('la vista del controlador lee una señal', () {
    final controller = DaisyThemeController();
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      return 'Tema: ${controller.theme.value.name}';
    });
    addTearDown(controller.dispose);
    addTearDown(etiqueta.dispose);
    final avisos = <String>[];
    void escuchar() => avisos.add(etiqueta.value);

    etiqueta.addListener(escuchar);
    expect(etiqueta.value, 'Tema: Light');
    expect(calculos, 1);

    controller.setTheme(DaisyThemes.dark);
    expect(etiqueta.value, 'Tema: Dark');
    expect(calculos, 2);
    expect(avisos, ['Tema: Dark']);

    controller.setTheme(DaisyThemes.dark.copyWith());
    expect(calculos, 2);
    expect(avisos, ['Tema: Dark']);
    etiqueta.removeListener(escuchar);
  });

  test('un ValueNotifier corriente no registra una dependencia', () {
    final fuente = ValueNotifier<String>('claro');
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      return 'Tema: ${fuente.value}';
    });
    addTearDown(fuente.dispose);
    addTearDown(etiqueta.dispose);

    expect(etiqueta.value, 'Tema: claro');
    fuente.value = 'oscuro';
    expect(fuente.value, 'oscuro');
    expect(etiqueta.value, 'Tema: claro');
    expect(calculos, 1);
  });
}
```

En la primera prueba, la función del derivado llama al getter de la vista y este lee la señal real. Esa lectura queda registrada aunque en el callback no se nombre ninguna señal: al cambiar a `dark`, la etiqueta se recalcula y avisa. La copia igual se descarta en la señal, antes de llegar al derivado, y no produce otro cálculo.

En la segunda prueba, `ValueNotifier` no pertenece al mecanismo de Signals. Leer su `value` no registra nada, así que el `computed` no tiene ninguna señal que invalide su caché: conserva `Tema: claro` aunque la fuente ya contenga `oscuro`. Lo que decide no es que un objeto tenga un `value` o cumpla `ValueListenable`, sino si durante el cálculo se lee realmente una señal.

El flujo real de temas no necesita este `computed`: el scope escucha la vista mediante Flutter. Si una etiqueta se usa solo dentro de un build que ya depende del tema, una interpolación también basta. El derivado cobra sentido cuando el mismo cálculo se comparte o se quiere observar por separado.

### Practica 9

Tanto `controller.theme` como un `ValueNotifier` ofrecen `.value`. ¿Por qué la etiqueta de la primera prueba se actualiza y la de la segunda conserva el resultado anterior?

<details>
<summary>Ver respuesta</summary>

El getter `value` de la vista lee una señal durante el cálculo, y esa lectura registra la dependencia. El getter de `ValueNotifier` devuelve su valor sin avisar a Signals, de modo que nada invalida la caché del derivado. Cumplir `ValueListenable` no equivale por sí solo a registrar una dependencia de Signals.

</details>

## Ejercicio final: una etiqueta con tema y borde

Escribe una prueba que:

1. Cree dos señales: `tema = 'claro'` y `borde = 1`.
2. Cree un `computed` que devuelva `'claro: fino'` si el borde es menor que 2 y `'claro: grueso'` en caso contrario. Cuenta las evaluaciones para poder seguirlas durante la prueba.
3. Registre un listener que guarde los resultados observados. Predice qué ocurre al registrar y cuál es el valor inicial.
4. Asigne borde 2, borde 3 y tema `'oscuro'` mediante escrituras separadas. Predice las evaluaciones y los avisos.
5. Retire el listener, cambie el tema a `'bosque'` y compare los contadores antes y después de leer la etiqueta.
6. Libere el derivado y las fuentes creadas por el test.

Como variación, captura `tema.value` antes de crear el callback: ¿qué dependencia dejaría de registrarse? ¿Qué pasaría si dos temas distintos produjeran la misma etiqueta visible?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('una etiqueta derivada de dos fuentes', () {
    final tema = signal('claro');
    final borde = signal(1);
    var calculos = 0;
    final etiqueta = computed(() {
      calculos++;
      final tipo = borde.value >= 2 ? 'grueso' : 'fino';
      return '${tema.value}: $tipo';
    });
    addTearDown(tema.dispose);
    addTearDown(borde.dispose);
    addTearDown(etiqueta.dispose);
    final avisos = <String>[];
    void escuchar() => avisos.add(etiqueta.value);

    etiqueta.addListener(escuchar);
    expect(etiqueta.value, 'claro: fino');
    expect(calculos, 1);
    borde.value = 2;
    borde.value = 3;
    tema.value = 'oscuro';
    expect(calculos, 4);
    expect(avisos, ['claro: grueso', 'oscuro: grueso']);

    etiqueta.removeListener(escuchar);
    tema.value = 'bosque';
    expect(calculos, 4);
    expect(etiqueta.value, 'bosque: grueso');
    expect(calculos, 5);
  });
}
```

Al registrar se calcula `claro: fino` una vez y no se llama al listener externo inicialmente. Borde 2 produce `claro: grueso` y un aviso; borde 3 provoca otro cálculo, pero la etiqueta no cambia. Tema `oscuro` produce el cuarto cálculo y el segundo aviso. Tras retirar el listener, el cambio a `bosque` no calcula inmediatamente; la siguiente lectura produce `bosque: grueso` y el quinto cálculo.

Capturar `tema.value` antes del callback elimina esa lectura rastreada del cálculo. Si dos cambios de fuente producen el mismo resultado, puede haber una evaluación sin un nuevo aviso, como vimos en el apartado 4.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué diferencia hay entre el tema almacenado y la etiqueta derivada? **Apartado 1.**
2. ¿Qué representa `FlutterComputed<String>` y qué devuelve su `.value`? **Apartado 2.**
3. Sin observadores activos, ¿cuándo se calcula y se reutiliza el resultado en la prueba? **Apartado 3.**
4. ¿Por qué registrar un listener puede causar una primera evaluación sin llamar al listener externo? **Apartado 4.**
5. ¿Por qué cambiar el borde de 2 a 3 puede recalcular sin añadir otro aviso? **Apartado 4.**
6. ¿Qué cambia entre leer una señal dentro del callback y usar una captura anterior? **Apartado 5.**
7. ¿Quién escucha el derivado en la prueba de widgets y qué papel tiene `pump`? **Apartado 6.**
8. ¿Cuándo puede bastar una vista `ValueListenable` en lugar de otro `computed`? **Apartado 7.**
9. ¿Qué cambia en lo que ve un listener del derivado si dos escrituras se agrupan con `batch`? **Apartado 8.**
10. ¿Por qué un `computed` que lee `controller.theme.value` se actualiza y uno que lee un `ValueNotifier` corriente no? **Apartado 9.**
11. ¿Quién retira los listeners y libera las fuentes y derivaciones que crean estas pruebas? **Apartados 2 y 4.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques cuándo se consulta, se calcula y se notifica un valor sin confundir esos pasos. La unidad 12 estudia acciones y efectos secundarios.

## Para consultar si necesitas reforzar

- [`FlutterComputed<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterComputed-class.html) y [documentación de Signals](https://dartsignals.dev/): derivación y dependencias. Compara `latest` con las versiones resueltas del proyecto.
- [`ValueListenable`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) y [`ValueListenableBuilder`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html): contrato de lectura y escucha, y conexión con un widget.
- [Controlador de temas](../../../lib/themes/application/daisy_theme_controller.dart), [scope](../../../lib/themes/application/daisy_theme_scope.dart) y [pruebas del controlador](../../../test/themes/daisy_theme_controller_test.dart): comportamiento actual de DaisyUI.
- [Dependencias declaradas](../../../pubspec.yaml) y [versiones resueltas](../../../pubspec.lock): comprueba qué implementación estás estudiando antes de trasladar sus detalles a otro proyecto.

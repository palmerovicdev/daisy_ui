# 10. Dependencias reactivas y contextos de observación

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 9](09-senales-signal-y-flutter-signal.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 9 creamos una señal con un tema y aprendimos a escuchar sus cambios. Ahora imagina que queremos mostrar ese
tema en un texto: ¿cómo sabe Flutter qué parte de la interfaz debe actualizar cuando cambia la señal?

Al terminar podrás distinguir una lectura puntual de una lectura que un consumidor observa. Verás cómo
`SignalBuilder` descubre las señales que lee su callback, qué cambia cuando una condición elige otra señal y por qué
importa **cuándo** se realiza la lectura. Después compararemos ese mecanismo con el scope real de DaisyUI.

Los ejemplos completos son pruebas de widgets independientes. Copia **una cada vez** a
`test/estudio_dependencias_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_dependencias_test.dart
```

Necesitas las dependencias ya resueltas del proyecto. Antes de mirar cada resultado, intenta predecirlo. Los fragmentos
identificados como tales sirven para razonar, pero no son archivos completos. Puedes estudiar los apartados 1–3 en
una sesión, 4–6 en otra y terminar después con DaisyUI y el ejercicio final.

Usaremos `pumpWidget` para montar un árbol de prueba y `pump` para procesar un frame después de cambiar una señal.
`expect` comprueba lo observado en ese árbol; no demuestra por sí solo el aspecto de una pantalla física. Los ejemplos
se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta
[pubspec.lock](../../../pubspec.lock) para las versiones resueltas. El controlador actual de DaisyUI guarda su tema en
una señal; en el apartado 8 veremos qué consecuencias tiene.

## 1. Una lectura no es una suscripción

Supongamos que una señal guarda `'claro'` y que una parte de la aplicación necesita mostrar ese nombre. Esa parte
**depende del dato** para construir su texto. Pero que una persona pueda identificar esa relación no significa que
Flutter la conozca: hace falta algún mecanismo que registre la observación.

Este fragmento realiza una lectura puntual:

```dart
final tema = signal<String>('claro');
final nombre = tema.value;
tema.value = 'oscuro';
```

No es un programa completo. Después de ejecutarlo, `nombre` conserva `'claro'` y `tema.value` devuelve `'oscuro'`, como
en la unidad 9. Leer una vez no registra por sí solo un listener que actualice `nombre` ni un widget que deba
reconstruirse.

Una analogía: puedes consultar el horario de una tienda y apuntarlo en un papel. Si la tienda cambia el horario, el
papel no se actualiza solo. Para enterarte necesitas otra relación, como una suscripción a sus avisos. La analogía no
describe cómo Flutter registra una dependencia o procesa un frame; lo veremos a continuación.

### Practica 1

Una función lee `tema.value` y guarda el texto en `nombre`. Si la señal cambia después, ¿qué más hace falta para que
un consumidor se entere del cambio?

<details>
<summary>Ver respuesta</summary>

Hace falta una observación conectada a la señal, por ejemplo un listener registrado o un consumidor reactivo que
registre la lectura. `nombre` contiene el resultado de la consulta anterior; no es una suscripción ni otra señal.

</details>

## 2. Leer dentro de `SignalBuilder`

`SignalBuilder` es un widget del paquete `signals_flutter`. Recibe un callback llamado `builder`: ese callback
describe qué widget mostrar. Durante su ejecución síncrona, el mecanismo de esta versión registra las señales leídas
para poder observarlas.

Compáralo con `Builder`, un widget de Flutter que ejecuta su propio callback para construir un hijo, pero que no
registra automáticamente una lectura de Signals. En esta prueba ambos leen la misma señal:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('lectura puntual y lectura observada', (tester) async {
    final tema = signal<String>('claro');
    addTearDown(tema.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(children: [
          Builder(builder: (_) => Text('Puntual: ${tema.value}')),
          SignalBuilder(builder: (_) => Text('Observado: ${tema.value}')),
        ]),
      ),
    );
    expect(find.text('Puntual: claro'), findsOneWidget);
    expect(find.text('Observado: claro'), findsOneWidget);

    tema.value = 'oscuro';
    await tester.pump();
    expect(find.text('Puntual: claro'), findsOneWidget);
    expect(find.text('Observado: oscuro'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El resultado esperado después de cambiar el tema y procesar el frame es:

```text
Puntual: claro
Observado: oscuro
```

Paso a paso:

1. `pumpWidget` monta el árbol. Los dos callbacks leen `'claro'` y cada uno construye un `Text`.
2. Durante el callback de `SignalBuilder`, se registra que ese consumidor ha leído `tema`. El `Builder` normal hace
   una lectura, pero no establece una observación de Signals por el mero hecho de leer.
3. `tema.value = 'oscuro'` cambia la señal. La observación del `SignalBuilder` solicita que su elemento vuelva a
   construirse; `pump` procesa el frame y el callback vuelve a leer el valor actual.
4. En este árbol aislado no hay otra causa que reconstruya el `Builder` normal, por eso su texto sigue mostrando la
   lectura anterior. Finalmente desmontamos el árbol y el test libera la señal que creó.

`Directionality` proporciona la dirección del texto que necesita este árbol de prueba. `find.text` busca un widget
`Text` y `findsOneWidget` comprueba que haya uno. Si otra causa reconstruyera más tarde el `Builder` normal, su
callback volvería a leer la señal y podría mostrar `'oscuro'`; el ejemplo no afirma que un widget sin suscripción jamás
pueda reconstruirse.

### Practica 2

Si el `Builder` normal se reconstruye más tarde porque su padre lo actualiza, ¿qué valor leerá de `tema` si sigue en
`'oscuro'`? ¿Significa eso que se había suscrito a la señal?

<details>
<summary>Ver respuesta</summary>

Leerá `'oscuro'` al ejecutar otra vez su callback. Eso no demuestra que se hubiera suscrito: la nueva lectura ocurrió
porque otra causa reconstruyó el widget. En la prueba, la reconstrucción provocada por la señal corresponde al
`SignalBuilder` que sí registró la dependencia.

</details>

## 3. El valor capturado no es la señal

Ahora moveremos la lectura **antes** del callback observado. El `SignalBuilder` recibirá un texto ya obtenido:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('usar un valor capturado antes del builder', (tester) async {
    final tema = signal<String>('claro');
    addTearDown(tema.dispose);
    final nombre = tema.value;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SignalBuilder(builder: (_) => Text(nombre)),
      ),
    );
    tema.value = 'oscuro';
    await tester.pump();

    expect(find.text('claro'), findsOneWidget);
    expect(tema.value, 'oscuro');
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Después del cambio, el texto del árbol sigue siendo `claro`, aunque la señal contiene `oscuro`:

1. `final nombre = tema.value` consulta la señal antes de montar el widget y conserva el texto `claro`.
2. El callback de `SignalBuilder` utiliza `nombre`; durante ese callback no ejecuta `tema.value`.
3. En este montaje no se registra una dependencia de `tema`, así que su cambio no provoca una nueva construcción de
   ese consumidor. La señal sigue teniendo su valor actual, que la última comprobación consulta por separado.

La diferencia no es el tipo de widget que devuelve el callback, sino dónde se hace la lectura. Si el código exterior
volviera a ejecutarse y entregara otro texto, el resultado podría cambiar por esa otra actualización.

### Practica 3

¿Qué línea cambiarías para que `SignalBuilder` observe `tema` al construir su texto?

<details>
<summary>Ver respuesta</summary>

Por ejemplo: `SignalBuilder(builder: (_) => Text(tema.value))`. La lectura ocurre ahora durante el callback que se
está observando, así que en el montaje del ejemplo cambiar la señal y hacer `pump` permite mostrar `oscuro`. Guardar
`nombre` antes del callback no establece esa misma relación.

</details>

## 4. ¿Quién registra la dependencia?

Hasta aquí usamos `SignalBuilder` sin abrir su implementación. Sigamos ahora qué hace la versión instalada cuando
construye el texto del apartado 2:

1. Flutter construye el elemento asociado al `SignalBuilder`. Mientras ejecuta su construcción, ese elemento activa
   un mecanismo temporal para detectar las lecturas de señales.
2. El callback ejecuta `tema.value`. La señal entrega su valor e informa de esa lectura al mecanismo activo.
3. Al terminar el callback, el elemento ajusta sus suscripciones a las señales que se leyeron en esa construcción.
4. Si `tema` cambia y la suscripción recibe el aviso, el elemento solicita una nueva construcción. Flutter la procesa
   cuando corresponda; en nuestras pruebas avanzamos el frame con `pump`.
5. Cuando el `SignalBuilder` se desmonta, su elemento cancela sus suscripciones. Eso no convierte al widget en
   propietario de las señales que recibió para leer.

En `signals_flutter` 7.1.0, el elemento se llama `SignalElement`; recoge las lecturas mediante `onSignalRead` y usa
`markNeedsBuild` para solicitar la construcción. Es un detalle de esa implementación, no una promesa de que todas las
versiones deban usar los mismos nombres internos. No hace falta suponer que el callback esté envuelto en un `effect`:
el mecanismo del widget y los efectos tienen responsabilidades distintas.

### Practica 4

Un `SignalBuilder` lee dos señales durante su construcción. Si una de ellas cambia, ¿quién solicita una nueva
construcción y quién ejecuta el siguiente `builder`?

<details>
<summary>Ver respuesta</summary>

En la versión estudiada, la suscripción gestionada por `SignalElement` marca ese elemento para volver a construir.
Flutter procesa el frame y ejecuta de nuevo el callback `builder`. La señal guarda y propaga el cambio, pero no dibuja
ni reconstruye directamente toda la aplicación.

</details>

## 5. Las dependencias pueden cambiar

Un callback puede elegir qué señal leer. En este ejemplo, `usarLocal` decide si mostramos el tema local o el global:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('el builder cambia de fuente', (tester) async {
    final usarLocal = signal(true);
    final local = signal('local claro');
    final global = signal('global claro');
    addTearDown(usarLocal.dispose);
    addTearDown(local.dispose);
    addTearDown(global.dispose);
    var builds = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SignalBuilder(builder: (_) {
          builds++;
          return Text(usarLocal.value ? local.value : global.value);
        }),
      ),
    );
    expect(find.text('local claro'), findsOneWidget);
    expect(builds, 1);

    global.value = 'global oscuro';
    await tester.pump();
    expect(builds, 1);

    usarLocal.value = false;
    await tester.pump();
    expect(find.text('global oscuro'), findsOneWidget);
    expect(builds, 2);

    local.value = 'local bosque';
    await tester.pump();
    expect(builds, 2);
    global.value = 'global nieve';
    await tester.pump();
    expect(find.text('global nieve'), findsOneWidget);
    expect(builds, 3);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

`builds` cuenta cuántas veces se ejecuta el callback en esta prueba. La expresión `condicion ? primero : segundo` lee
solo la rama elegida. El recorrido es:

1. Al principio `usarLocal` es `true`: el callback lee `usarLocal` y `local`, muestra `local claro` y el contador es 1.
2. Cambiar `global` no provoca un build en este paso porque esa rama aún no se leyó; el contador sigue en 1.
3. Cambiar `usarLocal` a `false` sí provoca otra construcción. Después de `pump`, el callback lee el valor actual de
   `global`, que ya es `global oscuro`, y el contador pasa a 2.
4. Tras esa construcción se observan `usarLocal` y `global`. Cambiar `local` no aumenta el contador; cambiar `global`
   produce el tercer build y muestra `global nieve`.

Las suscripciones se ajustan al terminar la nueva construcción, no en el mismo instante en que se escribe
`usarLocal`. Por eso la prueba hace `pump` antes de analizar los cambios de la nueva rama. Varios avisos antes de un
frame no implican necesariamente el mismo número de builds.

### Practica 5

Después de cambiar a la rama global y hacer `pump`, ¿por qué se muestra `global oscuro` si aquel cambio de `global` no
había provocado un build por sí solo?

<details>
<summary>Ver respuesta</summary>

El cambio anterior dejó `global oscuro` guardado en la señal. La escritura de `usarLocal` solicitó la nueva
construcción; al ejecutarse la rama global, el callback leyó el valor que `global` tenía en ese momento. Leer un valor
actual y ser la causa que solicitó el build son cosas distintas.

</details>

## 6. La lectura debe ocurrir durante el callback observado

Estar escrito dentro de un callback no garantiza que otro callback se ejecute en ese mismo momento. Aquí el
`SignalBuilder` devuelve un `Builder` hijo; Flutter construye ese hijo después y ejecuta su propio callback:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('la lectura ocurre en el hijo', (tester) async {
    final tema = signal('claro');
    addTearDown(tema.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SignalBuilder(
          builder: (_) => Builder(builder: (_) => Text(tema.value)),
        ),
      ),
    );
    tema.value = 'oscuro';
    await tester.pump();
    expect(find.text('claro'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El resultado esperado tras el cambio es que el texto siga siendo `claro` en este montaje. El callback exterior solo
crea y devuelve un `Builder`; la lectura de `tema.value` ocurre más tarde, cuando se ejecuta el callback del hijo. Esa
lectura no quedó registrada por el `SignalBuilder` exterior. De nuevo, otra causa podría reconstruir el hijo.

Una posible corrección es leer antes de devolverlo. Este es un **fragmento**, no un programa completo:

```dart
SignalBuilder(
  builder: (context) {
    final actual = tema.value;
    return Builder(builder: (_) => Text(actual));
  },
)
```

Ahora la lectura ocurre durante el callback observado y el hijo recibe el valor obtenido. Otra opción es situar un
`SignalBuilder` en el punto donde el hijo lee la señal. La misma distinción temporal importa para lecturas en un
callback de botón o una tarea diferida: no pertenecen al build anterior solo por estar escritas dentro de él.

### Practica 6

¿Por qué añadir más sangría a `Text(tema.value)` dentro del callback del hijo no cambia el resultado? ¿Qué habría que
cambiar?

<details>
<summary>Ver respuesta</summary>

La sangría no cambia cuándo se ejecuta la función del hijo. Hay que mover la lectura al callback del
`SignalBuilder` exterior o crear una observación en el lugar donde el hijo realiza la lectura. Lo decisivo es la
secuencia de ejecución, no la posición visual del código.

</details>

## 7. Una lectura que no se rastrea: `peek`

Hasta ahora leímos con `.value` durante el callback observado. Signals también ofrece `peek()` para consultar el
valor sin que **esa lectura** registre una dependencia. Comparemos dos `SignalBuilder`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('peek y dependencia explícita', (tester) async {
    final tema = signal('claro');
    addTearDown(tema.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(children: [
          SignalBuilder(builder: (_) => Text('Peek: ${tema.peek()}')),
          SignalBuilder(
            dependencies: [tema],
            builder: (_) => Text('Explícita: ${tema.peek()}'),
          ),
        ]),
      ),
    );
    tema.value = 'oscuro';
    await tester.pump();
    expect(find.text('Peek: claro'), findsOneWidget);
    expect(find.text('Explícita: oscuro'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    tema.value = 'bosque';
    expect(tema.value, 'bosque');
  });
}
```

El resultado esperado tras el primer cambio y `pump` es:

```text
Peek: claro
Explícita: oscuro
```

El primer callback consulta `tema.peek()` sin otra lectura rastreada de la señal; en este árbol, el cambio no lo marca
para construir de nuevo. El segundo incluye `tema` en `dependencies`. En la versión instalada, `SignalBuilder` lee
cada señal de esa lista durante su construcción observada, así que sí registra la dependencia; su callback vuelve a
consultar con `peek()` el valor actual.

`peek()` no elimina una dependencia registrada por otra lectura. Al desmontar el árbol se cancelan sus observaciones;
el test todavía posee la señal y puede cambiarla a `bosque` antes de que `addTearDown` la libere. Estas conclusiones
usan las opciones predeterminadas; la propiedad y `autoDispose` se estudian en la unidad 13.

### Practica 7

Si quitamos `dependencies: [tema]` del segundo builder y mantenemos solo `tema.peek()`, ¿qué texto esperamos después de
cambiar a `oscuro` en este montaje? ¿Qué cambiaría si usamos `tema.value`?

<details>
<summary>Ver respuesta</summary>

Sin la lista, esa lectura de `peek()` no registra la señal y el segundo texto también permanecería en `claro` si no
hay otra causa de build. Si leemos `tema.value` dentro de ese callback, la lectura sí queda rastreada y en este
escenario el texto puede actualizarse después del cambio y `pump`.

</details>

## 8. Dos caminos hacia el mismo tema en DaisyUI

En DaisyUI, el [controlador de temas](../../../lib/themes/application/daisy_theme_controller.dart) guarda el tema en una
`FlutterSignal<DaisyThemeModel>` y lo expone con el tipo `ValueListenable`, mediante un objeto `_ThemeListenable` cuyo
getter `value` lee esa señal. El [scope](../../../lib/themes/application/daisy_theme_scope.dart) extiende
`InheritedNotifier` y escucha esa vista. Cuando un consumidor usa `context.daisyTheme`, la
[extensión](../../../lib/themes/core/extension/build_context.dart) llama a `DaisyThemeScope.of(context)`, que busca el
scope y registra una dependencia heredada de Flutter.

Hay por tanto dos maneras de observar el mismo tema. **Antes de mirar los `expect`**, predice qué muestra cada línea de
esta prueba después de cambiar a `dark`. Usa los objetos reales del proyecto:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('dos caminos para observar el tema', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: Column(
            children: [
              Builder(
                builder: (context) => Text('Scope: ${context.daisyTheme.name}'),
              ),
              SignalBuilder(
                builder: (_) => Text('Señal: ${controller.theme.value.name}'),
              ),
              Builder(
                builder: (_) => Text('Puntual: ${controller.theme.value.name}'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('Scope: Light'), findsOneWidget);
    expect(find.text('Señal: Light'), findsOneWidget);
    expect(find.text('Puntual: Light'), findsOneWidget);

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Scope: Dark'), findsOneWidget);
    expect(find.text('Señal: Dark'), findsOneWidget);
    expect(find.text('Puntual: Light'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El resultado esperado después de cambiar el tema y procesar el frame es:

```text
Scope: Dark
Señal: Dark
Puntual: Light
```

Paso a paso:

1. El primer `Builder` llama a `context.daisyTheme`. Quien registra la dependencia es Flutter, mediante el mecanismo
   heredado: el callback no tiene ningún contexto de Signals activo.
2. El `SignalBuilder` lee `controller.theme.value`. En el callback no aparece ninguna señal, pero el getter `value` de
   `_ThemeListenable` se ejecuta durante esa construcción y lee `_source.value`. Es una lectura rastreada, como en el
   apartado 6: lo decisivo es cuándo se ejecuta, no cuántas llamadas intermedias haya.
3. El último `Builder` hace esa misma lectura, pero nadie está observando: no hay ni dependencia heredada ni contexto
   de Signals.
4. `setTheme` cambia la señal. Esta avisa al scope, que había registrado un listener, y al elemento del `SignalBuilder`.
   Cada uno solicita su actualización, y `pump` procesa el frame. El tercer texto no tiene ninguna causa para
   reconstruirse y sigue mostrando la lectura anterior.

El test desmonta el árbol y después libera el controlador que creó. Más adelante estudiaremos con detalle contextos,
ancestros e `InheritedNotifier`; por ahora basta con identificar quién registra cada relación. La aplicación de ejemplo
usa `context.daisyTheme`, y las [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart) comprueban también
la observación directa con `SignalBuilder`.

### Practica 8

`controller.theme` no es una señal, sino un `_ThemeListenable`. ¿Por qué `SignalBuilder` se actualiza al leer
`controller.theme.value`? ¿Y por qué `context.daisyTheme` no necesita un `SignalBuilder` para actualizarse?

<details>
<summary>Ver respuesta</summary>

El getter `value` de la vista lee la señal real durante el callback observado, así que esa lectura queda registrada. En
el otro camino, el scope ya escucha la vista y la consulta registra una dependencia heredada mediante Flutter; esa
relación actualiza al consumidor sin el rastreo de Signals. Son dos mecanismos distintos que parten de la misma señal.

</details>

## Ejercicio final: un panel con dos temas

Escribe una prueba de widgets que:

1. Cree `usarLocal = true`, `local = 'local claro'` y `global = 'global claro'` como señales.
2. Monte un `SignalBuilder` que muestre la fuente local o global según `usarLocal`, y cuente las construcciones.
3. Cambie `global` a `'global oscuro'` mientras se muestra local; procese un frame y compruebe el contador.
4. Cambie `local` a `'local oscuro'`; procese un frame. Después cambie `usarLocal` a `false` y procese otro.
5. Cambie otra vez `local` y finalmente `global` a `'global bosque'`, con un `pump` tras cada cambio. Compruebe qué
   texto se muestra y cuántas veces se construyó el callback.
6. Desmonte el árbol y libere las señales creadas por el test.

Predice el texto y el contador antes de abrir la solución. Como variaciones, añade `dependencies: [local, global]` y
razona qué pasaría al cambiar local cuando se muestra global; después imagina que se captura `local.value` antes de
montar el árbol. ¿Qué lectura deja de registrarse?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('un panel cambia entre dos temas', (tester) async {
    final usarLocal = signal(true);
    final local = signal('local claro');
    final global = signal('global claro');
    addTearDown(usarLocal.dispose);
    addTearDown(local.dispose);
    addTearDown(global.dispose);
    var builds = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SignalBuilder(builder: (_) {
          builds++;
          return Text(usarLocal.value ? local.value : global.value);
        }),
      ),
    );
    expect(find.text('local claro'), findsOneWidget);
    expect(builds, 1);

    global.value = 'global oscuro';
    await tester.pump();
    expect(builds, 1);
    local.value = 'local oscuro';
    await tester.pump();
    expect(find.text('local oscuro'), findsOneWidget);
    expect(builds, 2);
    usarLocal.value = false;
    await tester.pump();
    expect(find.text('global oscuro'), findsOneWidget);
    expect(builds, 3);
    local.value = 'local claro';
    await tester.pump();
    expect(builds, 3);
    global.value = 'global bosque';
    await tester.pump();
    expect(find.text('global bosque'), findsOneWidget);
    expect(builds, 4);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Al montar se observan `usarLocal` y `local`: cambiar solo `global` no provoca un build. El cambio de `local` produce el
segundo. Al pasar a la rama global, el tercero lee `global oscuro`; cambiar local después no produce otro, pero cambiar
global muestra `global bosque` en el cuarto.

Si ambas señales aparecen en `dependencies`, la lectura explícita de `local` también mantiene esa dependencia al
mostrar global; cambiar local puede marcar el builder. Si se captura el texto local antes de montar y la rama utiliza
solo esa captura, el callback deja de leer la señal local, salvo que otra lectura —por ejemplo en `dependencies`— la
registre. Si varias escrituras ocurren antes de un solo `pump`, no se puede deducir un build por cada escritura.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Por qué leer `.value` una vez no implica una suscripción? **Apartado 1.**
2. ¿Qué diferencia hubo entre `Builder` y `SignalBuilder` en el árbol de prueba? **Apartado 2.**
3. ¿Por qué usar un texto capturado antes del callback no rastrea la señal que lo produjo? **Apartado 3.**
4. ¿Quién recoge las lecturas, quién solicita un build y cuándo lo procesa Flutter? **Apartado 4.**
5. ¿Qué señales observa el panel de la rama local y cuáles después de construir la rama global? **Apartado 5.**
6. ¿Por qué una lectura en el callback de un `Builder` hijo puede quedar fuera del callback observado? **Apartado 6.**
7. ¿Qué hace `peek()` y por qué `dependencies` puede mantener una observación de esa misma señal? **Apartado 7.**
8. ¿Qué escucha el scope de DaisyUI, qué dependencia registra `context.daisyTheme` y por qué `SignalBuilder` también
   puede observar `controller.theme.value`? **Apartado 8.**
9. ¿Qué demuestran las pruebas con `pump` y qué haría falta para valorar una pantalla física? **Apartados 2 y 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques dónde ocurre cada lectura,
quién registra la observación y qué provoca la siguiente construcción. La unidad 11 estudia valores derivados con
`computed`.

## Para consultar si necesitas reforzar

- [`SignalBuilder`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/SignalBuilder-class.html):
  callback de construcción y dependencias explícitas. Compara `latest` con la versión instalada.
- [`FlutterSignal`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html):
  lectura de la señal y `peek()`.
- [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html) y
  [`dependOnInheritedWidgetOfExactType`](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html):
  escucha y dependencia heredada de Flutter.
- [Pruebas de widgets de Flutter](https://docs.flutter.dev/cookbook/testing/widget/introduction): montaje y frames de
  prueba.
- [Controlador](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart),
  [extensión de contexto](../../../lib/themes/core/extension/build_context.dart) y
  [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento del proyecto.

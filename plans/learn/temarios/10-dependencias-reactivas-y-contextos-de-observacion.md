# 10. Dependencias reactivas y contextos de observación

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 9](09-senales-signal-y-flutter-signal.md)

- **Bloque:** Signals: almacenar y relacionar estado.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 31 de octubre de 2026.

## Qué vas a conseguir

Podrás identificar **quién necesita qué dato** y cómo se establece esa relación. Compararás una lectura puntual, un
listener explícito, las lecturas rastreadas por `SignalBuilder` y la dependencia heredada de `DaisyThemeScope`.
Seguirás el cambio hasta la solicitud de reconstrucción y un frame de prueba, sin confundir almacenar, avisar,
reconstruir y repintar.

Estudiaremos además qué sucede si se mueve una lectura fuera del callback, si la lectura está en el `build` posterior
de un hijo o si una condición cambia las señales que se leen. `computed` y `effect` tienen mecanismos y unidades
propios; aquí solo los situamos dentro del mapa. Los detalles del árbol de Flutter y `InheritedNotifier` se amplían en
las unidades 18–25. Preparar la guía no marca el estudio como completado.

## Versiones y forma de practicar

Se han contrastado las dependencias resueltas: `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals`
7.0.0. La descripción interna de `SignalElement` es específica de esa combinación; los enlaces a documentación
`latest` pueden cambiar. `../../../pubspec.yaml` declara rangos y `pubspec.lock` conserva las versiones resueltas.

Los ejemplos A–E y la solución del proyecto son archivos de **pruebas de widgets completos e independientes**. Copia
uno cada vez a `test/estudio_dependencias_test.dart` y ejecuta:

```shell
flutter test --no-pub test/estudio_dependencias_test.dart
```

Requieren las dependencias ya resueltas del proyecto. No son programas independientes para DartPad. Lee cada test y
predice los resultados antes de ejecutarlo; luego elimina tu archivo temporal o consérvalo con otro nombre. Los bloques
marcados como fragmentos son para analizar y no son programas completos. `pumpWidget` monta o actualiza el árbol de
prueba y procesa un frame; `pump` procesa un frame pendiente. No sustituye una inspección en un dispositivo físico.

## Ruta y progreso

- [ ] [10.1. Qué es una dependencia](#101-qué-es-una-dependencia).
- [ ] [10.2. Leer una vez y observar](#102-leer-una-vez-y-observar).
- [ ] [10.3. `SignalBuilder` paso a paso](#103-signalbuilder-paso-a-paso).
- [ ] [10.4. Las dependencias cambian con la ejecución](#104-las-dependencias-cambian-con-la-ejecución).
- [ ] [10.5. La lectura debe suceder en el lugar observado](#105-la-lectura-debe-suceder-en-el-lugar-observado).
- [ ] [10.6. Lecturas explícitas y desmontaje](#106-lecturas-explícitas-y-desmontaje).
- [ ] [10.7. El scope real de DaisyUI](#107-el-scope-real-de-daisyui).
- [ ] [10.8. Comparar los mecanismos](#108-comparar-los-mecanismos).
- [ ] [Resolver el proyecto](#proyecto-de-la-unidad-un-panel-con-dos-fuentes).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes estudiar 10.1–10.3 en una sesión, 10.4–10.6 en otra y terminar con DaisyUI y el proyecto. Marca una casilla
cuando puedas explicar los resultados y resolver sus variaciones sin copiar las respuestas.

## 10.1. Qué es una dependencia

Una **dependencia** es una relación: un consumidor necesita una fuente para producir un resultado o reaccionar a su
cambio. Si un texto muestra el tema actual, su construcción depende de un dato de tema. Pero decir «depende» en
lenguaje cotidiano no basta para que el sistema conozca esa relación: alguien debe registrarla, de una manera y en un
momento concretos.

Una analogía: una biblioteca tiene libros y una persona que prepara una lista de novedades. Puede mirar un libro una
vez o apuntarse a un aviso sobre él. Si consulta el libro antes de inscribirse y guarda solo su título, inscribirse
más tarde con ese título no identifica automáticamente el libro. La analogía no describe los objetos internos de
Signals ni cómo Flutter programa frames: los veremos por separado.

Hay varias relaciones posibles:

- `addListener`: el código registra explícitamente un callback en una fuente y debe retirarlo cuando corresponda.
- `SignalBuilder`: el mecanismo de la versión instalada recoge señales leídas durante su construcción y mantiene
  suscripciones para ellas.
- `DaisyThemeScope.of(context)`: Flutter registra una dependencia heredada entre el contexto consumidor y el scope.

En todos los casos hay que distinguir la **fuente**, el **consumidor** y la relación de observación. No todas las
lecturas son registros, ni todos los avisos hacen que se reconstruya una pantalla.

### Comprobación

- Si lees un tema en una variable local, ¿quién conserva después esa lectura?
- ¿Qué hace falta además de leer para que una pieza de interfaz se entere de cambios?
- ¿Un `Listenable` conoce necesariamente widgets o reconstrucciones?

## 10.2. Leer una vez y observar

En A se montan tres consumidores independientes de la misma señal. El primero es un `Builder` normal: lee el valor
cuando se construye, sin registrar un listener para sí mismo. El segundo lee dentro de `SignalBuilder`. El tercero usa
un valor `capturado` **antes** de montar el árbol; esa lectura se hace fuera de un observador reactivo.

### Ejemplo A: lectura puntual, rastreada y capturada

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('lectura puntual frente a lectura rastreada', (tester) async {
    final tema = signal('claro');
    addTearDown(tema.dispose);
    final capturado = tema.value;
    var puntuales = 0;
    var rastreados = 0;
    var capturados = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: Column(children: [
        Builder(builder: (_) {
          puntuales++;
          return Text('puntual:${tema.value}');
        }),
        SignalBuilder(builder: (_) {
          rastreados++;
          return Text('rastreado:${tema.value}');
        }),
        SignalBuilder(builder: (_) {
          capturados++;
          return Text('capturado:$capturado');
        }),
      ]),
    ));
    expect([puntuales, rastreados, capturados], [1, 1, 1]);
    tema.value = 'oscuro';
    await tester.pump();
    expect(find.text('puntual:claro'), findsOneWidget);
    expect(find.text('rastreado:oscuro'), findsOneWidget);
    expect(find.text('capturado:claro'), findsOneWidget);
    expect([puntuales, rastreados, capturados], [1, 2, 1]);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

### Recorrido y comprobación

1. `tema.value` se lee en el test y se guarda `claro` en `capturado` antes del montaje.
2. En el primer frame, el `Builder` normal muestra `puntual:claro`. Su lectura aislada no instala un listener para
   reconstruirlo; `SignalBuilder` sí rastrea su propia lectura y muestra `rastreado:claro`.
3. El otro `SignalBuilder` recibe un `String` ya leído. En su callback no lee `tema`, por lo que en este ejemplo no
   establece una dependencia de esa señal.
4. Al escribir `oscuro`, el consumidor rastreado queda marcado para construir de nuevo. Después de `pump`, muestra
   `oscuro`. En este montaje estable, los otros textos permanecen con `claro` y sus contadores no aumentan.

Esa última observación es **limitada al escenario del test**. Un widget sin suscripción puede reconstruirse por otra
razón, como una actualización de su padre; el `Builder` normal volvería a leer la señal y podría mostrar `oscuro`. El
tercero seguiría mostrando el `String` capturado, salvo que el código que lo captura vuelva a ejecutarse y pase otro.
Una variable local no es una suscripción ni una referencia a una celda que consulta el valor de nuevo.

- ¿Qué observador registra `tema` y en qué ejecución?
- ¿Por qué el primer texto puede actualizarse más tarde si su padre reconstruye, aunque no haya observado la señal?
- ¿Qué líneas cambiarías para que el tercer callback lea la señal dentro de su construcción?

**Puedes avanzar cuando:** distingues una lectura antigua de una relación activa de observación.

## 10.3. `SignalBuilder` paso a paso

El [
`SignalBuilder` instalado](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/SignalBuilder-class.html)
extiende `SignalWidget`, cuyo `createElement` crea un `SignalElement`. En esta versión el registro de lecturas de
widgets **no se debe explicar simplemente diciendo que el builder crea un `effect` que envuelve su callback**. El
código usa un gancho de lectura y luego suscripciones. Simplificando solo lo necesario para el ejemplo A:

1. Al construir el elemento, `SignalElement.build` guarda el gancho anterior e instala `onSignalRead` para reunir, en
   un conjunto, las señales leídas durante esa ejecución síncrona.
2. `SignalBuilder.build` lee las señales de su lista opcional `dependencies` y ejecuta `builder(context)`.
3. Al consultar `tema.value`, el getter del núcleo informa al gancho activo; el elemento añade esa señal al conjunto.
   La lectura devuelve además el valor para construir el texto.
4. Al terminar, el elemento restaura el gancho anterior y ajusta sus suscripciones: retira las que ya no están en el
   conjunto y se suscribe a las nuevas. Durante el establecimiento suprime la solicitud inicial de reconstrucción.
5. Una escritura aceptada propaga el cambio; el callback de la suscripción del elemento llama a `markNeedsBuild`.
   Flutter planifica la construcción del elemento, y el callback vuelve a leer los datos actuales en el frame.
6. Al desmontar el elemento, este cancela sus suscripciones. La propiedad de las señales es una responsabilidad
   separada; los ejemplos usan las opciones predeterminadas y el test que las creó las libera con `addTearDown`.

El gancho se restaura en un `finally`; la lista anterior se ajusta incluso al terminar la construcción. `SignalBuilder`
no necesita que le entregues una lista para descubrir las lecturas del callback. La lista opcional `dependencies` sí
puede forzar lecturas adicionales en esa construcción, como se prueba en 10.6.

Esta explicación está basada en `signal_builder.dart`, `signal_widget.dart` y el getter `value` instalados. Es un
detalle de implementación verificable, no una promesa de que futuras versiones deban usar los mismos campos. El
mecanismo interno de dependencias de `effect` y `computed` también existe, pero se estudiará en sus propias unidades.

### Comprobación

- ¿Quién instala el gancho temporal y quién comunica que se ha leído una señal?
- ¿Quién conserva y cancela las suscripciones del widget? ¿Quién llama a `markNeedsBuild`?
- ¿Qué hace Flutter después de que el elemento sea marcado? ¿Es lo mismo que repintar inmediatamente?

## 10.4. Las dependencias cambian con la ejecución

En este test, el callback siempre lee `verA`, pero solo lee **una** de las otras dos señales en cada construcción.
Piensa qué se ejecuta realmente, no qué nombres aparecen escritos en el archivo.

### Ejemplo B: cambiar de rama

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('dependencias que cambian de rama', (tester) async {
    final verA = signal(true);
    final a = signal('A1');
    final b = signal('B1');
    addTearDown(verA.dispose);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    var builds = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SignalBuilder(builder: (_) {
        builds++;
        return Text(verA.value ? a.value : b.value);
      }),
    ));
    expect(find.text('A1'), findsOneWidget);
    b.value = 'B2';
    await tester.pump();
    expect(builds, 1);
    verA.value = false;
    await tester.pump();
    expect(find.text('B2'), findsOneWidget);
    expect(builds, 2);
    a.value = 'A2';
    await tester.pump();
    expect(builds, 2);
    b.value = 'B3';
    await tester.pump();
    expect(find.text('B3'), findsOneWidget);
    expect(builds, 3);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

### Recorrido y comprobación

- Primera construcción: `verA` es `true`, de modo que se leen `verA` y `a`; no se lee `b`. Cambiar `b` por sí
  solo no marca este builder.
- Cambiar `verA` a `false` sí lo marca. Al hacer `pump`, el callback lee `verA` y `b`, que ya contiene `B2`.
- Al concluir esa construcción, el elemento deja de observar `a` y observa `b`. Cambiar `a` no aumenta el contador;
  cambiar `b` sí reconstruye y muestra `B3`.

La retirada se establece **al terminar la construcción que tomó la nueva rama**, no en el mero instante en que se
escribió `verA`. Para razonar sobre cambios antes del siguiente frame, hay que considerar que las suscripciones de la
construcción anterior todavía pueden estar activas. En A y B hacemos `pump` entre los pasos que necesitan una nueva
construcción. Si hay varias causas antes del frame, no debe confundirse el número de avisos con el número de builds.

- ¿Qué dos señales observa el elemento después del primer `pumpWidget`?
- Después del `pump` que cambia de rama, ¿por qué modificar `a` no lo reconstruye?
- ¿Por qué aparece `B2` si el cambio a `b` no provocó la reconstrucción anterior?

## 10.5. La lectura debe suceder en el lugar observado

Tener un callback dentro de otro no significa que se ejecuten a la vez. En Flutter, el callback de un `Builder` hijo
se ejecuta cuando Flutter construye ese **otro elemento**, después de que el callback exterior haya devuelto el widget.
El contexto temporal de recogida del `SignalBuilder` ya terminó.

### Ejemplo C: un `Builder` hijo

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('la lectura del hijo ocurre fuera del builder reactivo', (tester) async {
    final tema = signal('claro');
    addTearDown(tema.dispose);
    var builds = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SignalBuilder(builder: (_) {
        builds++;
        return Builder(builder: (_) => Text(tema.value));
      }),
    ));
    tema.value = 'oscuro';
    await tester.pump();
    expect(find.text('claro'), findsOneWidget);
    expect(builds, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

En este montaje, el `SignalBuilder` exterior no lee `tema` durante su callback. Crea un `Builder` cuyo propio callback
lo lee más tarde, sin un observador reactivo que haga dependiente al elemento exterior. Cambiar `tema` y hacer `pump` no
cambia ese texto por sí solo. Esto no implica que el hijo jamás se reconstruya por otras causas.

**Fragmento para corregirlo:** la lectura ocurre ahora durante el callback reactivo, y el `Builder` hijo recibe un
valor ya obtenido:

```dart
SignalBuilder
(
builder: (context) {
final actual = tema.value;
return Builder(builder: (_) => Text(actual));
},
)
```

Otra opción es colocar `SignalBuilder` alrededor de la lectura del hijo. La ubicación efectiva de la lectura importa
más que la indentación del código. Del mismo modo, una lectura realizada después por un callback de botón, una tarea
diferida o tras un `await` no pertenece simplemente por su posición textual a la construcción síncrona anterior.

### Comprobación

- ¿Cuándo se ejecuta el callback del hijo con respecto al callback de `SignalBuilder`?
- ¿Qué ocurre si se lee `tema.value` antes de devolver el hijo? ¿Cuál de los dos elementos se observa?
- ¿Por qué una lectura en un botón no establece por sí sola la dependencia del build anterior?

## 10.6. Lecturas explícitas y desmontaje

La lista `dependencies` de `SignalBuilder` es opcional. En la versión instalada, su método `build` lee `dep.value`
para cada entrada **dentro** de la construcción rastreada; así se observan aunque el callback solo use `peek()` u otro
dato. [`peek`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html) permite
consultar sin registrar esa lectura como dependencia. En D, sin embargo, `dependencies: [tema]` ya añade la señal:
`peek()` no cancela una dependencia establecida por otra lectura.

### Ejemplo D: dependencia explícita y retirada

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('dependencies y desmontaje', (tester) async {
    final tema = signal('claro');
    addTearDown(tema.dispose);
    var builds = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SignalBuilder(
        dependencies: [tema],
        builder: (_) {
          builds++;
          return Text(tema.peek());
        },
      ),
    ));
    tema.value = 'oscuro';
    await tester.pump();
    expect(find.text('oscuro'), findsOneWidget);
    expect(builds, 2);
    await tester.pumpWidget(const SizedBox.shrink());
    tema.value = 'bosque';
    await tester.pump();
    expect(builds, 2);
    expect(tema.value, 'bosque');
    expect(tester.takeException(), isNull);
  });
}
```

`tema` cambia y la lista explícita provoca que el builder se marque; tras `pump`, `peek()` lee el valor actual y el
contador es 2. Al desmontar el builder se cancelan sus suscripciones. Cambiar la señal después sigue siendo válido en
este ejemplo porque el test posee la señal y no ha habilitado `autoDispose`; ya no hay un builder montado que aumentar.
El test libera la señal al terminar. `dependencies` no es un mecanismo de propiedad de recursos.

**Variación:** quita `dependencies: [tema]` y conserva solo `tema.peek()` en el callback. Predice si cambiar `tema`
provoca una reconstrucción. Después reemplaza `peek()` por `value` y razona cuál de las lecturas registra ahora la
señal. La solución está al final.

### Comprobación

- ¿Quién lee la señal cuando figura en `dependencies` aunque el callback solo llame a `peek()`?
- ¿Por qué `peek()` no borra la suscripción creada por otra lectura de la misma construcción?
- ¿Quién cancela la escucha al desmontar? ¿Quién libera la señal en esta práctica?

## 10.7. El scope real de DaisyUI

El flujo actual del proyecto usa otra relación. [
`context.daisyTheme`](../../../lib/themes/core/extension/build_context.dart)
llama a `DaisyThemeScope.of(context)`. Este busca el ancestro más cercano con
[
`dependOnInheritedWidgetOfExactType`](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html),
que registra una **dependencia heredada de Flutter**, y lee `scope.notifier!.value`.

Por otra parte, [`DaisyThemeScope`](../../../lib/themes/application/daisy_theme_scope.dart) extiende
[
`InheritedNotifier<ValueListenable<DaisyThemeModel>>`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html).
Su notifier es el `ValueNotifier` devuelto por `controller.theme` bajo el tipo `ValueListenable`. Son dos relaciones
complementarias: el scope escucha al notifier y el consumidor queda registrado como dependiente del scope.
`context.daisyTheme` no almacena otro tema ni registra una dependencia de Signals.

### Ejemplo E: controlador, scope y consumidor

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el scope actualiza a su consumidor', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var builds = 0;
    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        controller: controller,
        child: Builder(builder: (context) {
          builds++;
          return Text(context.daisyTheme.id);
        }),
      ),
    ));
    expect(find.text('light'), findsOneWidget);
    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('dark'), findsOneWidget);
    expect(builds, 2);
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El test crea el controlador, monta el scope y construye un hijo que consulta el tema. Al cambiar a `dark`, el
`ValueNotifier` acepta el valor, el aviso llega al `InheritedNotifier` y Flutter marca a sus dependientes.
Después de `pump`, el `Builder` consumidor se reconstruye, vuelve a consultar el scope y muestra `dark`. No hay un
`SignalBuilder` en este ejemplo.

El método `of` debe llamarse desde un contexto adecuado para registrar esa dependencia, como `build` o
`didChangeDependencies`, no desde el constructor o `initState`. Las unidades 19–23 profundizan en ciclo de vida,
ancestros y sustitución de notifier. El test desmonta el scope; el controlador se libera después por su propietario.
La prueba existente [de scopes](../../../test/themes/daisy_theme_scope_test.dart) cubre scopes anidados, reemplazo del
controlador y desmontaje de un scope con controlador prestado.

### Comprobación

- ¿Qué objeto registra el callback en la vista del controlador?
- ¿Qué llamada registra al consumidor como dependiente del scope?
- ¿Por qué la reconstrucción de E no necesita `SignalBuilder`?
- ¿Qué diferencia hay entre desmontar el scope y liberar el controlador que se le prestó?

## 10.8. Comparar los mecanismos

| Mecanismo        | Cómo se establece la relación                                                              | Qué sucede cuando cambia la fuente                                                             |
|------------------|--------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------|
| Lectura puntual  | Se consulta `.value` sin un observador activo ni registro explícito.                       | Esa lectura por sí sola no solicita un build; otra causa sí puede reconstruir y volver a leer. |
| `addListener`    | Un consumidor registra una función en un `Listenable`.                                     | La implementación llama al callback según sus reglas; el callback decide qué hacer.            |
| `SignalBuilder`  | Su elemento reúne lecturas síncronas y mantiene suscripciones; también lee `dependencies`. | Una suscripción marca ese elemento; Flutter procesa la construcción en un frame.               |
| Scope de DaisyUI | `InheritedNotifier` escucha la vista; `of(context)` registra una dependencia heredada.     | El aviso llega al scope y Flutter puede actualizar sus dependientes en un frame.               |

Un consumidor puede tener varias dependencias o recibir reconstrucciones por razones distintas a una señal. Los
resultados de los ejemplos se refieren al árbol y a la secuencia controlada de cada prueba. Una relación de observación
no es una garantía de que *ningún otro* widget se reconstruya, ni una medición de repintado.

## Materiales de estudio seleccionados

- **S1 · Signals:** [
  `SignalBuilder`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/SignalBuilder-class.html)
  y [`SignalWidget`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/SignalWidget-class.html) —
  lecturas síncronas, callback, lista explícita y desmontaje. En la caché local revisa los archivos
  `signals_flutter-7.1.0/lib/src/widgets/signal_builder.dart` y `signal_widget.dart` para los pasos concretos.
- **S2 · Signals:** [
  `FlutterSignal`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html)
  y [`signals_core`](https://pub.dev/packages/signals_core) — lectura, suscripción y `peek`. Las versiones de la
  documentación `latest` pueden cambiar.
- **F1 · Flutter:** [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html) y
  [
  `dependOnInheritedWidgetOfExactType`](https://api.flutter.dev/flutter/widgets/BuildContext/dependOnInheritedWidgetOfExactType.html)
  — escucha y dependencia heredada, incluidas las restricciones de ciclo de vida.
- **F2 · Flutter:** [introducción a pruebas de widgets](https://docs.flutter.dev/cookbook/testing/widget/introduction)
  y [`WidgetTester.pump`](https://api.flutter.dev/flutter/flutter_test/WidgetTester/pump.html) — frames de prueba.
- **P1 · DaisyUI:** [controlador](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart),
  [extensión](../../../lib/themes/core/extension/build_context.dart) y
  [pruebas de scopes](../../../test/themes/daisy_theme_scope_test.dart).
- **P2 · Versiones:** [dependencias declaradas](../../../pubspec.yaml) y [versiones resueltas](../../../pubspec.lock).

## Proyecto de la unidad: un panel con dos fuentes

Construye un `SignalBuilder` que muestre el valor de `local` o de `global` según una señal booleana `usarLocal`.
Mantén las tres señales vivas durante la prueba y cuenta las construcciones del callback. No uses el scope real en
esta práctica: estamos aislando las dependencias dinámicas de `SignalBuilder`.

### Requisitos

1. Inicializa `usarLocal` en `true`, `local` en `local claro` y `global` en `global claro`.
2. Cambia `global` mientras se muestra la fuente local y procesa un frame. Predice el texto y los builds.
3. Cambia `local` a `local oscuro` y procesa un frame. Cambia `usarLocal` a `false` y procesa otro.
4. Cambia `local` de nuevo; después cambia `global` a `global bosque`. Procesa un frame tras cada escritura y
   justifica cuándo se construye y qué muestra.
5. Desmonta el árbol antes de liberar las señales. Una solución aparece al final: intenta escribir la tuya primero.

### Variaciones

- Añade `dependencies: [local, global]`. Después de cambiar a la rama global, ¿qué ocurre al cambiar `local`?
- Captura `final nombre = local.value` antes de montar y úsalo en la rama local. ¿Qué pierde el builder?
- Si ambos valores cambian antes de un solo `pump`, ¿por qué no debes deducir dos builds solo por contar escrituras?
- Si se desmonta el panel y el test conserva las señales con configuración predeterminada, ¿quién las libera?

## Errores de comprensión que vamos a comprobar

- Suponer que cualquier lectura de `.value` se convierte en una dependencia de reconstrucción.
- Confundir un `String` capturado antes del build con la señal que lo produjo.
- Suponer que un callback de hijo, botón o tarea diferida se ejecuta durante el callback reactivo exterior.
- Creer que se observan todas las señales mencionadas en una condición, incluso la rama no ejecutada.
- Olvidar que la rama anterior sigue observada hasta que una nueva construcción reajusta suscripciones.
- Creer que `peek()` borra otra lectura rastreada o que `dependencies` transfiere propiedad de las señales.
- Atribuir al `SignalBuilder` concreto un mecanismo interno de otra versión o de `effect`/`computed`.
- Confundir la dependencia heredada de DaisyUI con una lectura rastreada por `SignalBuilder`.
- Identificar avisos, builds y repintados como el mismo evento o suponer exclusividad de reconstrucciones.

## Comprobación final

1. ¿Qué es una dependencia y por qué una lectura puntual no implica una suscripción del widget?
2. En A, ¿qué consumidor observa `tema`, qué contiene `capturado` y por qué los otros textos permanecen iguales?
3. ¿Cómo puede cambiar el texto de un `Builder` normal más tarde sin haber escuchado la señal?
4. En la versión instalada, ¿quién instala el gancho de lectura, quién informa del getter y quién mantiene las
   suscripciones del `SignalBuilder`?
5. ¿Qué paso ocurre entre la escritura aceptada y la siguiente ejecución del callback de construcción?
6. En B, ¿cuáles son las dependencias antes y después de cambiar la rama y hacer `pump`?
7. ¿Por qué `B2` aparece al cambiar la rama aunque esa escritura no reconstruyera el panel en su momento?
8. En C, ¿por qué el `Builder` hijo no transfiere su lectura al `SignalBuilder` exterior? Propón una corrección.
9. En D, ¿por qué `peek()` no impide observar `tema` y qué sucede si se elimina `dependencies`?
10. En DaisyUI, ¿quién escucha el notifier y qué llamada registra la dependencia del consumidor?
11. ¿Quién retira las suscripciones del widget y quién posee y libera las señales de los ejemplos?
12. ¿Qué demuestran los `pump` y los contadores de estas pruebas y qué no demuestran?

**Unidad dominada cuando:** puedes explicar cada relación y resolver el proyecto sin copiar las soluciones, indicando
si la lectura ocurre en una construcción observada, quién registra la dependencia y qué evento provoca la siguiente
construcción.

## Soluciones para contrastar después de practicar

### Ejemplo A

Después de cambiar a `oscuro` y hacer `pump`, los textos son `puntual:claro`, `rastreado:oscuro` y `capturado:claro`;
los contadores son `[1, 2, 1]`. El primer `Builder` puede volver a leer el valor si otra causa lo reconstruye; el
tercero
necesita que se le entregue otra captura o que lea la señal dentro del contexto observado.

### Ejemplo B

Al principio las dependencias son `verA` y `a`. Cambiar `b` no construye; al cambiar `verA` y hacer `pump`, el panel
lee el valor actual `B2` y pasa a depender de `verA` y `b`. `a` deja de producir builds en el siguiente paso; `b`
produce uno y muestra `B3`. Los contadores son 1, 2, 2 y 3 en los puntos indicados.

### Ejemplo C

El callback exterior devuelve un `Builder` y termina. Flutter ejecuta después el callback del elemento hijo; esa lectura
no fue recogida por el `SignalElement` exterior. En el montaje del test, cambiar la señal deja el texto `claro` y el
contador exterior en 1. Mover `final actual = tema.value` al callback exterior o colocar otro `SignalBuilder` en el
punto de lectura permite establecer una observación en el elemento correspondiente.

### Ejemplo D

La lista explícita causa la lectura rastreada; `peek()` consulta sin añadir otra. Hay dos builds antes del desmontaje;
después de desmontar, una nueva escritura no ejecuta el callback y el test todavía puede leer `bosque`. Sin la lista y
con solo `peek()`, no se registra esa señal y el cambio no provoca build en este montaje. Sustituir `peek()` por
`value` dentro del callback vuelve a registrar la dependencia.

### Ejemplo E

El primer build muestra `light`. La escritura a `dark` emite el aviso por la vista; el `InheritedNotifier` actualiza
la relación heredada y, tras `pump`, el consumidor se reconstruye y muestra `dark`; el contador pasa a 2. El scope toma
prestado el controlador y el test lo libera al final.

### Una solución del proyecto

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('panel que cambia de fuente', (tester) async {
    final usarLocal = signal(true);
    final local = signal('local claro');
    final global = signal('global claro');
    addTearDown(usarLocal.dispose);
    addTearDown(local.dispose);
    addTearDown(global.dispose);
    var builds = 0;

    await tester.pumpWidget(Directionality(
      textDirection: TextDirection.ltr,
      child: SignalBuilder(builder: (context) {
        builds++;
        final nombre = usarLocal.value ? local.value : global.value;
        return Text(nombre);
      }),
    ));
    expect(find.text('local claro'), findsOneWidget);
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

La rama local observa `usarLocal` y `local`, así que el primer cambio global no construye. Cambiar local produce el
segundo build. Al seleccionar global, el tercero lee `global oscuro` y sustituye la dependencia local por global.
El cambio posterior local no construye; `global bosque` causa el cuarto build. En la variación con ambas señales en
`dependencies`, cambiar local sí marca el builder aun cuando la rama seleccionada sea global: las lecturas explícitas
se suman a las del callback. Si se captura antes el valor local y ya no se lee `local` dentro, desaparece esa
observación salvo que exista otra lectura registrada, por ejemplo en `dependencies`.

### Claves de la comprobación final

1. Es la relación entre consumidor y fuente; leer sin un mecanismo de registro no conecta cambios futuros con builds.
2. Solo el segundo builder observa `tema`; `capturado` guarda `claro`; no hubo otra causa de build para los demás.
3. Su padre u otra dependencia puede causar una reconstrucción, durante la que lee de nuevo.
4. `SignalElement` instala `onSignalRead`, el getter de Signals informa de la lectura y el elemento ajusta las
   suscripciones.
5. La suscripción marca el elemento; Flutter lo construye al procesar el frame.
6. Primero `verA` y `a`; después del build de cambio de rama, `verA` y `b`.
7. El segundo build consulta el valor actual de `b`, aunque el cambio previo no hubiera provocado ese build.
8. Su callback corre al construir otro elemento, después del callback exterior. Lee en el exterior o usa un observador
   en el hijo.
9. `dependencies` ya leyó `tema`; sin esa lista y usando solo `peek()` no se registra esa fuente en el ejemplo.
10. El elemento de `InheritedNotifier` escucha la vista; `dependOnInheritedWidgetOfExactType` registra al consumidor.
11. El elemento desmontado cancela sus observaciones; el test que creó las señales las libera.
12. Demuestran los builds y textos de esos árboles y secuencias; no demuestran comportamiento en dispositivo ni
    repintado, ni que otros árboles no puedan reconstruirse por otras causas.

## Qué se ha revisado y cómo se ha comprobado

- Se contrastaron las fuentes oficiales enlazadas y el código actual del controlador, scope, extensión y pruebas.
  También se leyeron las implementaciones instaladas de `signals_flutter` 7.1.0, `signals_core` 7.0.0 y
  `preact_signals` 7.0.0 para separar el gancho del elemento del mecanismo interno de `effect`.
- El grafo rechazó indexar esta carpeta por su configuración de acceso; los archivos citados se verificaron mediante
  lectura directa.
- Pasaron los cinco ejemplos, la solución del proyecto, tres pruebas de variaciones y las cuatro pruebas existentes del
  scope: **13 pruebas de widgets**. El analizador de Dart no encontró problemas en los siete archivos temporales;
  después
  se retiraron. Se verificó que los seis ejemplos completos de la guía coinciden con los archivos ejecutados.
- Se comprobaron los enlaces locales, las anclas, los bloques de código y `git diff --check`. Las pruebas verifican
  árboles y frames controlados, no una pantalla física ni sus repintados. El estudio permanece pendiente hasta resolver
  y explicar las prácticas.

# 19. Ciclo de vida y lugar correcto para crear recursos

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 18](18-widgets-elementos-estado-y-reconstruccion.md) · **Estado:** pendiente

## Qué vas a aprender

La unidad 13 estableció que un propietario crea un recurso y lo libera cuando termina su uso. La unidad 18 mostró que un
`State` permanece mientras sus descripciones cambian. Ahora juntamos ambas ideas: si un widget necesita su propio
`DaisyThemeController`, ¿en qué línea exacta se crea, y en cuál se libera? ¿Qué ocurre si lo creamos en `build`?

Al terminar podrás recorrer el ciclo de vida de un `State`: `initState`, `didChangeDependencies`, `build`,
`didUpdateWidget`, `deactivate` y `dispose`. Sabrás colocar la creación, la actualización y la limpieza en su lugar, y
explicar el motivo con un fallo concreto. También podrás seguir el ciclo de vida de una vista previa con su propio
controlador.

Los ejemplos completos son pruebas de widgets independientes. Copia **una cada vez** a
`test/estudio_ciclo_de_vida_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_ciclo_de_vida_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como
tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar con 7–8 y el
ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0;
consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Las pruebas comprueban el orden de las
llamadas y el contenido del árbol, no el aspecto de una pantalla física.

## 1. Un `State` que cuenta su vida

La forma más directa de entender el ciclo de vida es hacer que un `State` anote cada método que Flutter le llama.
**Montar** significa insertar el elemento y su `State` en el árbol; **desmontar** significa retirarlos definitivamente.

**Antes de mirar los `expect`**, intenta ordenar las llamadas de cada bloque:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final registro = <String>[];

class Sonda extends StatefulWidget {
  const Sonda({super.key, required this.texto});

  final String texto;

  @override
  State<Sonda> createState() => _SondaState();
}

class _SondaState extends State<Sonda> {
  @override
  void initState() {
    super.initState();
    registro.add('initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registro.add('didChangeDependencies');
  }

  @override
  void didUpdateWidget(Sonda oldWidget) {
    super.didUpdateWidget(oldWidget);
    registro.add('didUpdateWidget ${oldWidget.texto} -> ${widget.texto}');
  }

  @override
  void deactivate() {
    registro.add('deactivate');
    super.deactivate();
  }

  @override
  void dispose() {
    registro.add('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    registro.add('build');
    return Text(widget.texto);
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('el orden del ciclo de vida', (tester) async {
    await tester.pumpWidget(pantalla(const Sonda(texto: 'a')));
    expect(registro, ['initState', 'didChangeDependencies', 'build']);
    registro.clear();

    await tester.pumpWidget(pantalla(const Sonda(texto: 'b')));
    expect(registro, ['didUpdateWidget a -> b', 'build']);
    registro.clear();

    await tester.pump();
    expect(registro, isEmpty);

    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
    expect(registro, ['deactivate', 'dispose']);
  });
}
```

Paso a paso:

1. **Montaje.** Flutter crea el elemento, llama a `createState` y a continuación a `initState`, `didChangeDependencies`
   y `build`. A partir de `initState`, `mounted` es `true`.
2. **Nueva descripción.** Mismo tipo y misma `key`: el `State` permanece (unidad 18). Antes de `build`, Flutter llama a
   `didUpdateWidget` con la descripción **anterior**, y `widget` ya devuelve la nueva.
3. **Un frame sin solicitudes.** Ningún método se ejecuta.
4. **Desmontaje.** `deactivate` indica que el `State` se ha retirado del árbol; `dispose`, que no volverá. Después de
   `dispose`, `mounted` es `false`.

Cada método tiene una **cuenta distinta**. `initState` y `dispose` se ejecutan una vez en toda la vida del `State`.
`build` puede ejecutarse muchas veces. Esa diferencia es la que decide dónde va cada cosa.

Observa también `super`. Se llama a `super.initState()` al principio y a `super.dispose()` al final: primero se prepara
lo que tu código puede usar, y lo último es retirarlo. Ambos llevan la anotación `@mustCallSuper`, y el analizador avisa
si los omites.

### Practica 1

Después del último bloque añadimos `await tester.pumpWidget(pantalla(const Sonda(texto: 'c')));` y borramos antes el
registro. ¿Qué lista obtendríamos? ¿Sería el mismo objeto `State` de antes?

<details>
<summary>Ver respuesta</summary>

`['initState', 'didChangeDependencies', 'build']`. El `State` anterior ya recibió `dispose` y no se reutiliza: se crea
uno nuevo. Tampoco aparece `didUpdateWidget`, porque este `State` no ha recibido ninguna descripción anterior.

</details>

## 2. Qué pasa si creamos el controlador en `build`

La tentación es escribir el controlador donde se usa. Un `StatelessWidget` ni siquiera tiene otro sitio donde ponerlo, y
el código compila. Vamos a comprobar qué sucede. La lista `creados` solo sirve para que la prueba alcance los
controladores.

**Antes de mirar los `expect`**, predice qué nombre se muestra después de reconstruir y cuántos controladores existen:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class VistaMala extends StatelessWidget {
  const VistaMala({super.key, required this.creados});

  final List<DaisyThemeController> creados;

  @override
  Widget build(BuildContext context) {
    final controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    creados.add(controller);
    return DaisyThemeScope(
      controller: controller,
      child: Builder(builder: (context) => Text(context.daisyTheme.name)),
    );
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('crear el controlador en build', (tester) async {
    final creados = <DaisyThemeController>[];
    addTearDown(() {
      for (final controller in creados) {
        controller.dispose();
      }
    });

    await tester.pumpWidget(pantalla(VistaMala(creados: creados)));
    expect(find.text('Cupcake'), findsOneWidget);

    creados.last.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);

    await tester.pumpWidget(pantalla(VistaMala(creados: creados)));
    expect(find.text('Cupcake'), findsOneWidget);
    expect(creados.length, 2);

    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
  });
}
```

Paso a paso:

1. El primer `build` crea un controlador con `cupcake`. El usuario cambia a `dark`, y funciona: si solo miras esta
   parte, parece correcto.
2. El padre entrega otra descripción, por cualquier motivo que no tiene que ver con el tema. `build` se ejecuta, y su
   primera línea crea **otro controlador**, de nuevo con `cupcake`.
3. El scope recibe esa fuente distinta y el texto vuelve a `Cupcake`. **La elección del usuario se ha perdido.**
4. El primer controlador sigue existiendo con `dark`, pero ya nadie lo conoce salvo la lista de la prueba. **Nadie
   llamará a su `dispose`**: quedaría una señal sin liberar por cada reconstrucción.

Es la consecuencia de la unidad 18: `build` debe poder repetirse sin consecuencias, y crear un recurso es una
consecuencia. No hay ningún error ni aviso; aparece más tarde y según qué reconstruya al padre, por lo que es difícil de
localizar.

### Practica 2

Si en esta prueba el padre reconstruyera `VistaMala` cinco veces más, ¿cuántos controladores habría? ¿Cuántos tendrían
un propietario que los libere? Sin la limpieza de `addTearDown`, ¿quién los liberaría?

<details>
<summary>Ver respuesta</summary>

Habría `7`: los dos anteriores y cinco nuevos. Ninguno tiene propietario en el código del widget: cada variable local
`controller` desaparece al terminar su `build`. La prueba los libera solo porque los guardó en una lista para poder
estudiarlos. Sin esa limpieza, nadie llamaría a `dispose`.

</details>

## 3. `initState` y `dispose`: una sola vez

Lo que debe existir una vez por cada `State` se crea en el método que se ejecuta una vez por cada `State`. Esta versión
solo cambia el lugar de la creación. **Antes de mirar los `expect`**, repasa la predicción anterior:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class VistaBuena extends StatefulWidget {
  const VistaBuena({super.key, required this.creados});

  final List<DaisyThemeController> creados;

  @override
  State<VistaBuena> createState() => _VistaBuenaState();
}

class _VistaBuenaState extends State<VistaBuena> {
  late final DaisyThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    widget.creados.add(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      controller: _controller,
      child: Builder(builder: (context) => Text(context.daisyTheme.name)),
    );
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('crear el controlador en initState', (tester) async {
    final creados = <DaisyThemeController>[];

    await tester.pumpWidget(pantalla(VistaBuena(creados: creados)));
    creados.single.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);

    await tester.pumpWidget(pantalla(VistaBuena(creados: creados)));
    expect(find.text('Dark'), findsOneWidget);
    expect(creados.length, 1);

    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
    expect(
      () => creados.single.setTheme(DaisyThemes.light),
      throwsA(isA<SignalsWriteAfterDisposeError>()),
    );
  });
}
```

El tema elegido sobrevive, solo existe un controlador y, al desmontar, el `State` lo libera: la última comprobación
muestra que ya rechaza escrituras, como vimos en la unidad 17. La prueba ya no necesita limpiar nada porque el
propietario es el `State`.

`late final` es la sintaxis de la unidad 16, con una diferencia: aquí no hay inicializador. `late` promete que el campo
se asignará antes de leerlo, y `final` impide asignarlo dos veces. Lo asigna `initState`, y una segunda asignación
lanzaría un error.

¿Podría escribirse como un campo con inicializador? En este caso sí:

```dart
// Fragmento alternativo dentro de _VistaBuenaState.
final _controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
```

El objeto `State` se crea una sola vez, así que su campo también. Pero un inicializador normal **no puede usar
`widget`**: si el tema inicial llegara como parámetro, necesitarías `initState`. En ese método, `widget` ya está
disponible, y por eso es el lugar habitual incluso cuando no es imprescindible.

### Practica 3

Queremos que el tema inicial llegue como `widget.temaInicial`. ¿Cómo cambia `initState`? Si el padre entrega después
otro valor de `temaInicial`, ¿qué tema tendrá el controlador si no hacemos nada más?

<details>
<summary>Ver respuesta</summary>

`_controller = DaisyThemeController(initialTheme: widget.temaInicial);`. Si el padre cambia el valor, el controlador
conserva su tema: `initState` no vuelve a ejecutarse. Si queremos reaccionar a ese cambio, necesitamos el método del
apartado 5.

</details>

## 4. `dispose`: el orden y el `State` que ya no existe

Un `State` propietario libera en `dispose` lo que creó. Pero mientras él libera, ¿no seguirán sus descendientes
escuchando? Vamos a anotar el orden con un notifier que registra sus llamadas. Sobrescribimos sus métodos con
`@override`, como en la unidad 3.

**Antes de mirar el `expect`**, predice en qué orden aparecen los dos últimos elementos:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final registro = <String>[];

class FuenteRegistrada extends ValueNotifier<int> {
  FuenteRegistrada() : super(0);

  @override
  void addListener(VoidCallback listener) {
    registro.add('addListener');
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    registro.add('removeListener');
    super.removeListener(listener);
  }

  @override
  void dispose() {
    registro.add('dispose');
    super.dispose();
  }
}

class Propietario extends StatefulWidget {
  const Propietario({super.key});

  @override
  State<Propietario> createState() => _PropietarioState();
}

class _PropietarioState extends State<Propietario> {
  final _fuente = FuenteRegistrada();

  @override
  void dispose() {
    _fuente.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _fuente,
      builder: (_, valor, _) => Text('$valor'),
    );
  }
}

void main() {
  testWidgets('el hijo deja de escuchar antes de que el padre libere', (
    tester,
  ) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Propietario(),
      ),
    );
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox.shrink(),
      ),
    );

    expect(registro, ['addListener', 'removeListener', 'dispose']);
  });
}
```

Al desmontar un subárbol, Flutter llama a `dispose` **desde los descendientes hacia arriba**. El
`ValueListenableBuilder`, que es hijo, retira primero su listener. Después el `State` propietario, que es padre, libera
la fuente. Así, cuando un recurso se libera, ya ha terminado quien lo tenía prestado. Esta es la razón por la que
`_controller.dispose()` en el propietario es seguro aunque tenga un `DaisyThemeScope` por debajo.

### Trabajo que termina después de `dispose`

El orden protege lo que está dentro del árbol, pero no lo que ocurre fuera de él. Una operación asíncrona puede terminar
cuando el widget ya no está:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Carga extends StatefulWidget {
  const Carga({super.key, required this.tarea});

  final Future<String> tarea;

  @override
  State<Carga> createState() => CargaState();
}

class CargaState extends State<Carga> {
  String texto = 'Cargando';

  @override
  void initState() {
    super.initState();
    _esperar();
  }

  Future<void> _esperar() async {
    final resultado = await widget.tarea;
    if (!mounted) return;
    setState(() => texto = resultado);
  }

  void refrescarSinComprobar() => setState(() {});

  @override
  Widget build(BuildContext context) => Text(texto);
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  test('await deja pendiente el resto de la función', () async {
    final orden = <String>[];
    Future<void> tarea() async {
      orden.add('antes');
      await Future<void>.value();
      orden.add('después');
    }

    final pendiente = tarea();
    orden.add('sigue el programa');
    await pendiente;
    expect(orden, ['antes', 'sigue el programa', 'después']);
  });

  testWidgets('la tarea termina con el widget montado', (tester) async {
    await tester.pumpWidget(pantalla(Carga(tarea: Future.value('Listo'))));
    expect(find.text('Cargando'), findsOneWidget);

    await tester.pump();
    expect(find.text('Listo'), findsOneWidget);
  });

  testWidgets('la tarea termina con el widget desmontado', (tester) async {
    await tester.pumpWidget(pantalla(Carga(tarea: Future.value('Listo'))));
    final estado = tester.state<CargaState>(find.byType(Carga));
    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
    await tester.pump();

    expect(estado.mounted, isFalse);
    expect(tester.takeException(), isNull);
    expect(estado.refrescarSinComprobar, throwsFlutterError);
  });
}
```

`await` pausa esa función hasta que la tarea termina, y entretanto el programa continúa: es lo que muestra la primera
prueba, con la palabra `Future` para un resultado que llegará más tarde. El detalle importante en `_esperar` es la línea
`if (!mounted) return;`. Mientras la función estaba en pausa, el `State` puede haber recibido `dispose`. Llamar a
`setState` en ese momento lanza un error (`setState() called after dispose()`), que la última línea provoca a propósito.

### Practica 4

Un `State` registra en `initState` un listener en un `ValueListenable` que recibió prestado y no lo retira. El `State`
se desmonta y más tarde la fuente cambia. ¿Qué ocurre? ¿Debería el `State` liberar esa fuente?

<details>
<summary>Ver respuesta</summary>

La fuente sigue conservando el listener, así que al cambiar lo ejecuta. Si este llama a `setState`, se produce el error
de `dispose` que acabamos de ver, y además la fuente mantiene viva la referencia al `State`. No debe liberar la fuente,
porque es prestada: debe retirar su listener en `dispose`. Es el reparto de la unidad 13 con un lugar concreto.

</details>

## 5. `didUpdateWidget`: cuando cambia la configuración

Un `State` que escucha una fuente recibida por parámetro tiene un problema nuevo: **el padre puede entregar otra
fuente**. Como `initState` no se repite, el listener seguiría en la anterior. `didUpdateWidget` existe para esto: recibe
la descripción antigua y permite compararla con la nueva.

**Antes de mirar los `expect`**, predice si cada cambio provoca una construcción:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class VistaFuente extends StatefulWidget {
  const VistaFuente({super.key, required this.fuente});

  final ValueListenable<int> fuente;

  @override
  State<VistaFuente> createState() => VistaFuenteState();
}

class VistaFuenteState extends State<VistaFuente> {
  int construcciones = 0;

  @override
  void initState() {
    super.initState();
    widget.fuente.addListener(_alCambiar);
  }

  @override
  void didUpdateWidget(VistaFuente oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fuente != widget.fuente) {
      oldWidget.fuente.removeListener(_alCambiar);
      widget.fuente.addListener(_alCambiar);
    }
  }

  @override
  void dispose() {
    widget.fuente.removeListener(_alCambiar);
    super.dispose();
  }

  void _alCambiar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    construcciones++;
    return Text('Valor: ${widget.fuente.value}');
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('cambiar de fuente', (tester) async {
    final a = ValueNotifier<int>(1);
    final b = ValueNotifier<int>(20);
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    await tester.pumpWidget(pantalla(VistaFuente(fuente: a)));
    final estado = tester.state<VistaFuenteState>(find.byType(VistaFuente));
    expect(estado.construcciones, 1);

    await tester.pumpWidget(pantalla(VistaFuente(fuente: b)));
    expect(find.text('Valor: 20'), findsOneWidget);
    expect(estado.construcciones, 2);

    a.value = 2;
    await tester.pump();
    expect(estado.construcciones, 2);

    b.value = 21;
    await tester.pump();
    expect(find.text('Valor: 21'), findsOneWidget);
    expect(estado.construcciones, 3);

    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
  });
}
```

Paso a paso:

1. Al entregar `b`, Flutter llama a `didUpdateWidget`. Las referencias son distintas, así que el listener pasa de una
   fuente a otra. Es el mismo método `_alCambiar`: retirarlo y registrarlo funciona porque es la misma referencia
   (unidad 2).
2. A continuación se ejecuta `build`. Flutter **siempre** lo hace después de `didUpdateWidget`, por lo que llamar allí a
   `setState` sería redundante.
3. Cambiar `a` ya no tiene efecto. Cambiar `b` provoca una construcción.

Es exactamente lo que hace `ValueListenableBuilder`, cuyo código viste en parte en la unidad 18. Y es lo que
`DaisyThemeScope` hereda de `InheritedNotifier` para su propia fuente, como veremos en la unidad 22.

La condición `if` es lo que evita trabajo inútil. `didUpdateWidget` se llama con cada descripción nueva, aunque la
fuente sea la misma: sin comparar, retiraríamos y volveríamos a registrar el listener cada vez.

### Practica 5

Imagina que borramos `didUpdateWidget` de `VistaFuente`. Después de entregar `b`: (a) ¿qué ocurre al cambiar `a`? (b) ¿Y
al cambiar `b`? (c) ¿Qué retira `dispose`, y qué problema deja?

<details>
<summary>Ver respuesta</summary>

(a) `a` conserva el listener: se solicita una construcción, que muestra el valor actual de `b`, porque `build` lee
`widget.fuente`. (b) `b` nadie la escucha: el texto no se actualiza hasta otra causa de construcción. (c) `dispose`
intenta retirar el listener de `b`, donde nunca se registró, y lo deja en `a`. Si `a` cambia después, `_alCambiar` llama
a `setState` sobre un `State` ya liberado y se produce el error del apartado 4.

</details>

## 6. `didChangeDependencies` y por qué no vale `initState`

Queda el método más extraño de la lista. En la prueba del apartado 1 se ejecutó una vez, al montar. Ahora le daremos un
motivo para repetirse: que el `State` lea `context.daisyTheme`. Sabes desde la unidad 10 que esta lectura registra una
dependencia; **cómo** lo hace se explica en las unidades 21 y 22. Por ahora basta con observar el efecto.

**Antes de mirar los `expect`**, predice qué métodos se ejecutan en cada caso:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final registro = <String>[];

class Lector extends StatefulWidget {
  const Lector({super.key, this.titulo = 'Tema'});

  final String titulo;

  @override
  State<Lector> createState() => LectorState();
}

class LectorState extends State<Lector> {
  void refrescar() => setState(() {});

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    registro.add('didChangeDependencies ${context.daisyTheme.name}');
  }

  @override
  void didUpdateWidget(Lector oldWidget) {
    super.didUpdateWidget(oldWidget);
    registro.add('didUpdateWidget');
  }

  @override
  Widget build(BuildContext context) {
    registro.add('build ${context.daisyTheme.name}');
    return Text(widget.titulo);
  }
}

void main() {
  testWidgets('quién provoca cada método', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    Widget arbol(String titulo) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        controller: controller,
        child: Lector(titulo: titulo),
      ),
    );

    await tester.pumpWidget(arbol('A'));
    expect(registro, ['didChangeDependencies Light', 'build Light']);
    registro.clear();

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(registro, ['didChangeDependencies Dark', 'build Dark']);
    registro.clear();

    await tester.pumpWidget(arbol('B'));
    expect(registro, ['didUpdateWidget', 'build Dark']);
    registro.clear();

    tester.state<LectorState>(find.byType(Lector)).refrescar();
    await tester.pump();
    expect(registro, ['build Dark']);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Cada causa provoca una secuencia distinta, y siempre termina en `build`:

| Causa                              | Métodos que se ejecutan                 |
|------------------------------------|-----------------------------------------|
| Montaje                            | `initState`, `didChangeDependencies`, `build` |
| Cambia una dependencia heredada    | `didChangeDependencies`, `build`        |
| El padre entrega otra descripción  | `didUpdateWidget`, `build`              |
| `setState`                         | `build`                                 |

`didChangeDependencies` es útil para **calcular algo a partir de una dependencia sin repetirlo en cada `build`**, o para
actualizar un recurso que dependa de ella. Si solo muestras el valor, como en la mayoría de los casos, leerlo en `build`
es suficiente.

¿Y si intentamos leer el tema en `initState`, que parece el lugar natural para preparar datos?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class LectorTemprano extends StatefulWidget {
  const LectorTemprano({super.key});

  @override
  State<LectorTemprano> createState() => _LectorTempranoState();
}

class _LectorTempranoState extends State<LectorTemprano> {
  late final String _nombre;

  @override
  void initState() {
    super.initState();
    _nombre = context.daisyTheme.name;
  }

  @override
  Widget build(BuildContext context) => Text(_nombre);
}

void main() {
  testWidgets('leer el tema en initState lanza un error', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(child: const LectorTemprano()),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('initState() completed'));
  });
}
```

`takeException` recoge el error que Flutter capturó durante la construcción. El mensaje dice que la dependencia se pidió
antes de que terminara `initState`. El motivo es el que ya conoces: si `initState` no se vuelve a ejecutar, un dato
derivado del tema se quedaría obsoleto cuando este cambiara. La solución es moverlo a `didChangeDependencies`, que
Flutter sí repite.

### Practica 6

Un `State` calcula un color costoso a partir del tema y usa el resultado en `build`. ¿Dónde calcularías cada una de
estas opciones? (a) El color, que solo depende del tema. (b) Un texto que combina el tema con `widget.titulo`. (c) El
`DaisyThemeController` que el propio `State` crea.

<details>
<summary>Ver respuesta</summary>

(a) En `didChangeDependencies`: se repite cuando cambia el tema, y no en cada `setState`. (b) En `build`: depende de
datos que pueden cambiar por dos causas, y la lectura es barata; `build` se ejecuta en ambas. (c) En `initState`, una
sola vez, con su `dispose` correspondiente. No depende del tema que hay por encima.

</details>

## 7. Dónde va cada cosa

Con todo lo anterior, la decisión se reduce a contar cuántas veces debe ocurrir algo y qué lo provoca:

| Quieres…                                                 | Lugar                   | Por qué                                 |
|----------------------------------------------------------|-------------------------|-----------------------------------------|
| Crear un recurso que posee el `State`                    | `initState`             | Una vez por `State`                     |
| Registrar un listener en un parámetro recibido           | `initState`             | Hace falta desde el principio           |
| Cambiar ese listener si llega otro parámetro             | `didUpdateWidget`       | Compara descripción anterior y nueva    |
| Derivar datos de una dependencia heredada                | `didChangeDependencies` | Se repite cuando esta cambia            |
| Describir la interfaz con los datos actuales             | `build`                 | Debe poder repetirse sin consecuencias  |
| Retirar listeners y liberar lo propio                    | `dispose`               | Una vez, al terminar                    |
| Evitar `setState` tras una espera                        | `if (!mounted) return`  | La espera puede cruzar el `dispose`     |

`deactivate` apenas se necesita, pero conviene saber por qué existe aparte de `dispose`. Un elemento con una `GlobalKey`
puede cambiar de lugar en el árbol dentro de un mismo frame, y entonces pasa por `deactivate` y sigue vivo, sin llegar a
`dispose`. Por eso los recursos se liberan en `dispose`.

### Practica 7

Clasifica estos errores según el lugar que falta o sobra: (a) el tema elegido se pierde cuando el padre se reconstruye;
(b) el widget sigue mostrando datos de una fuente antigua después de recibir otra; (c) una prueba falla con
`setState() called after dispose()` tras cerrar una pantalla.

<details>
<summary>Ver respuesta</summary>

(a) Se creó el recurso en `build`: debe ir en `initState`. (b) Falta el cambio de listener en `didUpdateWidget`. (c)
Falta retirar un listener en `dispose`, o comprobar `mounted` después de una espera. Cada síntoma señala un método
concreto: de ahí la utilidad de este esquema.

</details>

## 8. La vista previa y el botón de DaisyUI

Hasta el commit `41fe41f`, [el ejemplo](../../../example/lib/main.dart) tenía una vista previa con su propio
controlador, `_ThemePreview`, que estudiamos en las unidades 13 y 14. El ejemplo actual muestra solo el botón, pero
puedes consultar esa versión con `git show 41fe41f~1:example/lib/main.dart`. La reproducimos aquí con los mismos
métodos, cambiando `ElevatedButton` por `GestureDetector` para no necesitar `MaterialApp`:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class VistaPrevia extends StatefulWidget {
  const VistaPrevia({super.key});

  @override
  State<VistaPrevia> createState() => VistaPreviaState();
}

class VistaPreviaState extends State<VistaPrevia> {
  late final DaisyThemeController controller;

  @override
  void initState() {
    super.initState();
    controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      controller: controller,
      child: Builder(
        builder: (context) {
          final theme = context.daisyTheme;
          return GestureDetector(
            onTap: () => controller.setTheme(
              theme.id == DaisyThemes.dark.id
                  ? DaisyThemes.cupcake
                  : DaisyThemes.dark,
            ),
            child: Text('Preview: ${theme.name}'),
          );
        },
      ),
    );
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('el recorrido de la vista previa', (tester) async {
    await tester.pumpWidget(pantalla(const VistaPrevia()));
    final estado = tester.state<VistaPreviaState>(find.byType(VistaPrevia));
    final controlador = estado.controller;
    expect(find.text('Preview: Cupcake'), findsOneWidget);

    await tester.tap(find.text('Preview: Cupcake'));
    await tester.pump();
    expect(find.text('Preview: Dark'), findsOneWidget);

    await tester.pumpWidget(pantalla(const SizedBox(child: VistaPrevia())));
    expect(find.text('Preview: Cupcake'), findsOneWidget);
    expect(estado.mounted, isFalse);
    expect(identical(
      tester.state<VistaPreviaState>(find.byType(VistaPrevia)).controller,
      controlador,
    ), isFalse);

    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
  });
}
```

Recorremos la prueba:

1. **Montaje.** `initState` crea el controlador. `build` entrega el controlador al scope como recurso prestado. El
   `Builder` lee el tema y muestra `Cupcake`.
2. **Pulsación.** `onTap` llama a `setTheme`; la señal avisa y, como veremos en la unidad 22, el consumidor se
   actualiza. El `State` no llama a `setState` ni se reconstruye: quien cambia es el `Builder`.
3. **Cambio de estructura.** Al envolver la vista en un `SizedBox`, en esa posición hay otro tipo de widget. Es el caso
   de la práctica 6 de la unidad 18: el `State` anterior recibe `dispose`, libera su controlador, y se crea otro que
   empieza en `Cupcake`.

Esta última parte puede parecer un fallo del patrón, pero es coherente: la vista previa posee su tema y su vida coincide
con la de su sitio en el árbol. Si el tema debe sobrevivir, el controlador debe pertenecer a un `State` situado más
arriba. La propiedad de un recurso siempre responde a la pregunta «¿cuánto debe durar?».

### El `didUpdateWidget` del botón

El [botón real](../../../lib/themes/presentation/action/button.dart) no crea recursos, así que no necesita `initState`
ni `dispose`. Pero sí usa `didUpdateWidget`. Este es el **fragmento**:

```dart
@override
void didUpdateWidget(covariant DaisyButton oldWidget) {
  super.didUpdateWidget(oldWidget);
  if (!_isEnabled) {
    _isHovering = false;
    _isPressed = false;
  }
}
```

Si el padre desactiva el botón mientras el ratón está encima, ya no llegará el aviso de que se ha ido, porque el botón
deja de atender esos eventos. Sin este código, `_isHovering` quedaría en `true` para siempre. El método resetea los
campos sin `setState`, ya que a continuación se ejecuta `build`. `covariant` permite declarar el parámetro con el tipo
concreto `DaisyButton`; en los ejemplos anteriores no lo hemos escrito porque el tipo de `State<T>` ya lo admite.
Compruébalo:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:daisy_ui/themes/presentation/action/button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desactivar el botón limpia su estado', (tester) async {
    Widget pantalla({required bool activo}) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        child: Center(
          child: DaisyButton(
            enabled: activo,
            onPressed: () {},
            child: const Text('Botón'),
          ),
        ),
      ),
    );
    Material material() => tester.widget<Material>(
      find
          .descendant(
            of: find.byType(DaisyButton),
            matching: find.byType(Material),
          )
          .first,
    );

    await tester.pumpWidget(pantalla(activo: true));
    final raton = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await raton.addPointer(location: Offset.zero);
    await raton.moveTo(tester.getCenter(find.byType(DaisyButton)));
    await tester.pumpAndSettle();
    expect(material().elevation, 4);

    await tester.pumpWidget(pantalla(activo: false));
    await tester.pumpAndSettle();
    expect(material().elevation, 0);

    await raton.removePointer();
  });
}
```

### Practica 8

En la vista previa, ¿qué método se ejecuta primero al desmontar: el `dispose` de `VistaPreviaState` o la retirada del
listener del scope sobre `controller.theme`? ¿Qué pasaría si `VistaPrevia` recibiera el controlador por parámetro?

<details>
<summary>Ver respuesta</summary>

Primero la retirada del scope, porque es un descendiente. Después, el `dispose` del `State`, como en el apartado 4. Si
recibiera el controlador por parámetro, sería un recurso prestado: el `State` no debería liberarlo. Necesitaría
`didUpdateWidget` solo si tuviera listeners propios; en este caso, el scope ya gestiona el cambio de fuente.

</details>

## Ejercicio final: un panel con un recurso propio y uno prestado

Escribe un `StatefulWidget` llamado `Panel` con dos parámetros: `temaInicial`, de tipo `DaisyThemeModel`, y `avisos`, de
tipo `ValueListenable<int>`.

1. Su `State` crea un `DaisyThemeController` propio con `widget.temaInicial` y registra un listener en `widget.avisos`,
   que suma uno a un contador público `recibidos`. Este listener no necesita `setState`.
2. Cuando el padre entregue otro `temaInicial`, el controlador debe cambiar a ese tema. Cuando entregue otra fuente de
   `avisos`, el listener debe cambiar de fuente.
3. Su `build` entrega el controlador a un `DaisyThemeScope` y muestra el nombre del tema con `context.daisyTheme`.
4. Al terminar, libera lo que le corresponde y solo eso.

En la prueba:

1. Monta el panel con `cupcake` y una fuente `a`. Cambia `a` y comprueba `recibidos`.
2. Entrega un panel igual, otra vez con `cupcake` y `a`. ¿Cambia algo?
3. Elige `dark` desde fuera con `setTheme`, y entrega de nuevo el panel con `cupcake`. ¿Qué tema muestra? ¿Por qué?
4. Entrega el panel con `light`, y comprueba el nombre.
5. Entrega el panel con la fuente `b`. Cambia `a` y luego `b`, y comprueba `recibidos`.
6. Desmonta. Cambia `a` y `b`, y comprueba que no hay excepciones y que el contador no varía.

Predice cada resultado antes de abrir la solución. Como variaciones: ¿qué falla si creas el controlador en `build`? ¿Y
si en `dispose` también llamas a `widget.avisos.dispose()`?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Panel extends StatefulWidget {
  const Panel({super.key, required this.temaInicial, required this.avisos});

  final DaisyThemeModel temaInicial;
  final ValueListenable<int> avisos;

  @override
  State<Panel> createState() => PanelState();
}

class PanelState extends State<Panel> {
  late final DaisyThemeController controller;
  int recibidos = 0;

  @override
  void initState() {
    super.initState();
    controller = DaisyThemeController(initialTheme: widget.temaInicial);
    widget.avisos.addListener(_alAvisar);
  }

  @override
  void didUpdateWidget(Panel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.temaInicial != widget.temaInicial) {
      controller.setTheme(widget.temaInicial);
    }
    if (oldWidget.avisos != widget.avisos) {
      oldWidget.avisos.removeListener(_alAvisar);
      widget.avisos.addListener(_alAvisar);
    }
  }

  @override
  void dispose() {
    widget.avisos.removeListener(_alAvisar);
    controller.dispose();
    super.dispose();
  }

  void _alAvisar() => recibidos++;

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      controller: controller,
      child: Builder(builder: (context) => Text(context.daisyTheme.name)),
    );
  }
}

void main() {
  testWidgets('un recurso propio y uno prestado', (tester) async {
    final a = ValueNotifier<int>(0);
    final b = ValueNotifier<int>(0);
    addTearDown(a.dispose);
    addTearDown(b.dispose);

    Widget arbol(DaisyThemeModel tema, ValueListenable<int> avisos) =>
        Directionality(
          textDirection: TextDirection.ltr,
          child: Panel(temaInicial: tema, avisos: avisos),
        );

    await tester.pumpWidget(arbol(DaisyThemes.cupcake, a));
    final estado = tester.state<PanelState>(find.byType(Panel));
    a.value = 1;
    expect(estado.recibidos, 1);
    expect(find.text('Cupcake'), findsOneWidget);

    await tester.pumpWidget(arbol(DaisyThemes.cupcake, a));
    expect(estado.recibidos, 1);
    expect(find.text('Cupcake'), findsOneWidget);

    estado.controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    await tester.pumpWidget(arbol(DaisyThemes.cupcake, a));
    expect(find.text('Dark'), findsOneWidget);

    await tester.pumpWidget(arbol(DaisyThemes.light, a));
    expect(find.text('Light'), findsOneWidget);

    await tester.pumpWidget(arbol(DaisyThemes.light, b));
    a.value = 2;
    expect(estado.recibidos, 1);
    b.value = 1;
    expect(estado.recibidos, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    a.value = 3;
    b.value = 2;
    expect(tester.takeException(), isNull);
    expect(estado.recibidos, 2);
  });
}
```

El paso 2 no cambia nada: `didUpdateWidget` se ejecuta, pero ambas comparaciones son falsas.

El paso 3 es el más interesante. `temaInicial` sigue siendo `cupcake`, igual que en la descripción anterior, así que no
se ejecuta `setTheme`, y el panel conserva `Dark`. El parámetro solo interviene cuando **cambia**: es un valor inicial,
no una orden permanente. Por eso el nombre importa.

El paso 4 entrega un valor distinto: `didUpdateWidget` llama a `setTheme`. No necesitamos `setState`: la señal avisa, y
a la vez el `State` está a punto de ejecutar `build`.

El paso 5 traslada el listener: `a` ya no suma y `b` sí. En el paso 6, `dispose` retira el listener de la fuente actual,
y el listener de `a` se retiró en el paso 5. Por eso ningún cambio posterior se cuenta ni lanza un error.

Si el controlador se creara en `build`, cada descripción crearía uno nuevo con `temaInicial`, por lo que `dark` se
perdería en el paso 3, y además quedarían controladores sin liberar. Si en `dispose` llamaras a
`widget.avisos.dispose()`, liberarías un objeto prestado: la prueba, que es su propietaria, fallaría al usarlo en el
paso 6 y al liberarlo una segunda vez.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿En qué orden se ejecutan los métodos al montar, al recibir otra descripción y al desmontar? **Apartado 1.**
2. ¿Qué dos problemas concretos introduce crear un controlador en `build`? **Apartado 2.**
3. ¿Por qué `initState` es el lugar adecuado, y cuándo no basta un campo con inicializador? **Apartado 3.**
4. ¿En qué orden se desmontan hijos y padres, y por qué importa para un recurso prestado? **Apartado 4.**
5. ¿Por qué hay que comprobar `mounted` después de un `await`? **Apartado 4.**
6. ¿Qué debe hacer `didUpdateWidget` si un parámetro `Listenable` cambia? ¿Por qué no necesita `setState`? **Apartado
   5.**
7. ¿Qué causas provocan `didChangeDependencies`, y por qué no se puede leer `context.daisyTheme` en `initState`?
   **Apartado 6.**
8. ¿Dónde colocarías crear, actualizar y liberar un recurso? **Apartado 7.**
9. ¿Qué ocurre, método a método, en la vida de la vista previa? ¿Por qué el botón resetea campos en `didUpdateWidget`?
   **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques por qué cada línea está en ese
método. La unidad 20 estudia `BuildContext`: el parámetro de `build` que hasta ahora hemos usado sin explicar.

## Para consultar si necesitas reforzar

- [`State`](https://api.flutter.dev/flutter/widgets/State-class.html): la descripción oficial completa del ciclo de
  vida.
- [`initState`](https://api.flutter.dev/flutter/widgets/State/initState.html),
  [`didUpdateWidget`](https://api.flutter.dev/flutter/widgets/State/didUpdateWidget.html),
  [`didChangeDependencies`](https://api.flutter.dev/flutter/widgets/State/didChangeDependencies.html) y
  [`dispose`](https://api.flutter.dev/flutter/widgets/State/dispose.html): qué se puede hacer en cada método.
- [`mounted`](https://api.flutter.dev/flutter/widgets/State/mounted.html): cuándo es seguro llamar a `setState`.
- [Asincronía en Dart](https://dart.dev/libraries/async/async-await): `Future`, `async` y `await`, si quieres
  ampliarlos.
- [Controlador](../../../lib/themes/application/daisy_theme_controller.dart) y
  [botón](../../../lib/themes/presentation/action/button.dart): comportamiento actual de DaisyUI.

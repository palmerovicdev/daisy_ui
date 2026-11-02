# 22. `InheritedNotifier`: unir avisos y dependencias

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 21](21-inherited-widget-y-registro-de-dependencias.md) · **Estado:** pendiente

## Qué vas a aprender

Tenemos dos mitades que no se tocan. Por un lado, una señal avisa a sus listeners, pero un listener no reconstruye nada por sí mismo (unidades 4 y 9). Por otro, un `InheritedWidget` sabe qué consumidores dependen de él, pero solo los avisa si alguien entrega una descripción nueva (unidad 21). En DaisyUI, cuando llamas a `setTheme`, nadie entrega ninguna descripción. ¿Cómo llega entonces el aviso a los consumidores?

Al terminar podrás seguir, paso a paso, un aviso desde `setTheme` hasta el `build` de un consumidor, sin afirmar que el notifier reconstruye directamente la aplicación. Podrás predecir cuántas construcciones producen varios cambios antes de un frame, qué fuente se escucha tras reemplazar el notifier y qué ocurre con los listeners al desmontar.

Los ejemplos completos son pruebas de widgets independientes. Copia **una cada vez** a `test/estudio_inherited_notifier_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_inherited_notifier_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–5 en otra y terminar con 6–7 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Estas pruebas comprueban los avisos, las solicitudes y las construcciones en un árbol de prueba. En el apartado 3 leemos código interno de `InheritedNotifier`, cuyos nombres privados pueden cambiar entre versiones.

## 1. El problema: el dato vive en un notifier

Supongamos que el grosor vive en un `ValueNotifier`, fuera de los widgets, y que un `InheritedWidget` lo publica leyendo su valor. **Antes de mirar los `expect`**, predice qué muestra la caja después de cambiar el notifier:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class BordeHeredado extends InheritedWidget {
  const BordeHeredado({super.key, required this.grosor, required super.child});

  final int grosor;

  @override
  bool updateShouldNotify(BordeHeredado oldWidget) {
    return grosor != oldWidget.grosor;
  }
}

class Caja extends StatelessWidget {
  const Caja({super.key});

  @override
  Widget build(BuildContext context) {
    final borde = context.dependOnInheritedWidgetOfExactType<BordeHeredado>();
    return Text('Grosor: ${borde!.grosor}');
  }
}

void main() {
  testWidgets('un InheritedWidget no escucha a nadie', (tester) async {
    final fuente = ValueNotifier<int>(1);
    addTearDown(fuente.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: BordeHeredado(grosor: fuente.value, child: const Caja()),
      ),
    );

    fuente.value = 2;
    await tester.pump();
    expect(find.text('Grosor: 1'), findsOneWidget);
  });
}
```

La caja sigue mostrando `1`. `grosor: fuente.value` es una lectura puntual, de una vez: el campo guarda `1`. Cuando cambia el notifier, nadie está escuchándolo ni entregando otro `BordeHeredado`, de modo que el mecanismo de la unidad 21 no se activa.

Con lo que ya sabes, podrías escribir un puente: un `StatefulWidget` que escuche la fuente y entregue otra descripción. Este es un **fragmento**, sin los campos ni `createState`:

```dart
class _PuenteState extends State<Puente> {
  @override
  void initState() {
    super.initState();
    widget.fuente.addListener(_alCambiar);
  }

  @override
  void didUpdateWidget(Puente oldWidget) {
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
    return BordeHeredado(grosor: widget.fuente.value, child: widget.child);
  }
}
```

Funcionaría, y es exactamente lo que estudiamos en la unidad 19. Pero habría que repetirlo para cada dato: registrar, cambiar de fuente, retirar y reconstruir. `InheritedNotifier` es esa pieza ya escrita.

### Practica 1

En el fragmento del puente, ¿qué objeto registra el listener, quién lo llama y qué provoca `setState`? ¿Qué pasos faltan hasta que `Caja` vuelve a construirse?

<details>
<summary>Ver respuesta</summary>

Lo registra el `State` de `Puente`, y lo llama el notifier al recibir un valor distinto. `setState` marca el elemento de `Puente`. En el frame, su `build` crea otro `BordeHeredado`; `updateShouldNotify` devuelve `true` y el proveedor marca a sus dependientes, incluida `Caja`, que vuelve a construirse. Son los pasos del apartado 3 de la unidad 21 precedidos de un listener.

</details>

## 2. Un primer `InheritedNotifier`

`InheritedNotifier<T>` es un `InheritedWidget` que recibe un `Listenable`, llamado `notifier`, y lo escucha. `T` debe ser algún tipo de `Listenable` (es lo que indica `T extends Listenable` en su declaración). Solo hay que escribir el constructor y la consulta.

**Antes de mirar los `expect`**, predice los contadores después de cambiar el notifier:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final builds = <String, int>{'seccion': 0, 'caja': 0, 'ajeno': 0};

class ContadorScope extends InheritedNotifier<ValueNotifier<int>> {
  const ContadorScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ContadorScope>();
    if (scope == null) {
      throw FlutterError('Coloca ContadorScope por encima de este widget.');
    }
    return scope.notifier!.value;
  }
}

class Seccion extends StatelessWidget {
  const Seccion({super.key});

  @override
  Widget build(BuildContext context) {
    builds['seccion'] = builds['seccion']! + 1;
    return const Column(children: [Caja(), Ajeno()]);
  }
}

class Caja extends StatelessWidget {
  const Caja({super.key});

  @override
  Widget build(BuildContext context) {
    builds['caja'] = builds['caja']! + 1;
    return Text('Valor: ${ContadorScope.of(context)}');
  }
}

class Ajeno extends StatelessWidget {
  const Ajeno({super.key});

  @override
  Widget build(BuildContext context) {
    builds['ajeno'] = builds['ajeno']! + 1;
    return const Text('Ajeno');
  }
}

void main() {
  testWidgets('el scope escucha al notifier', (tester) async {
    final fuente = ValueNotifier<int>(1);
    addTearDown(fuente.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ContadorScope(notifier: fuente, child: const Seccion()),
      ),
    );
    expect(find.text('Valor: 1'), findsOneWidget);
    expect(builds, {'seccion': 1, 'caja': 1, 'ajeno': 1});

    fuente.value = 2;
    await tester.pump();
    expect(find.text('Valor: 2'), findsOneWidget);
    expect(builds, {'seccion': 1, 'caja': 2, 'ajeno': 1});

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Observa lo que **no** hay. No hay `State` ni `setState`, ni `pumpWidget` entre el cambio y el `pump`. Nadie entrega otra descripción del scope. Aun así, `Caja` se actualiza y `Seccion` y `Ajeno` no. Compara con el apartado 3 de la unidad 21: el resultado es el mismo, pero ha desaparecido la raíz con estado.

Las líneas nuevas:

- `extends InheritedNotifier<ValueNotifier<int>>` sustituye `T` por el tipo concreto, como en la unidad 3.
- `required super.notifier` reenvía el notifier al padre. No declaramos ningún campo: `notifier` lo aporta la clase padre.
- La consulta sigue siendo `dependOnInheritedWidgetOfExactType`, y lo que devuelve se lee en el notifier.
- `notifier!` es necesario porque el campo se declara como `T?`. La unidad 23 explica por qué.

Tampoco escribimos `updateShouldNotify`: lo aporta `InheritedNotifier`. Lo veremos en el apartado 5.

### Practica 2

Añadimos a `Ajeno` una consulta con `getInheritedWidgetOfExactType<ContadorScope>()` que lee el valor sin dependencia. Tras cambiar la fuente, ¿qué muestra y cómo cambia su contador? ¿Y si usa `ContadorScope.of(context)`?

<details>
<summary>Ver respuesta</summary>

Con `getInheritedWidgetOfExactType`, no figura como dependiente: `ajeno` sigue en `1`, y su texto muestra el valor antiguo. Con `of`, se registra la dependencia: `ajeno` pasa a `2`. El notifier no sabe nada de esto. Quien decide qué elementos reciben el aviso es la lista de dependientes.

</details>

## 3. Seguir el aviso hasta la construcción

Esta es la parte central de la unidad. El código de `InheritedNotifier` es corto, así que podemos leer **su implementación real** en Flutter 3.47.8. Este es un **fragmento** de [inherited_notifier.dart](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html), sin los comentarios:

```dart
abstract class InheritedNotifier<T extends Listenable> extends InheritedWidget {
  const InheritedNotifier({super.key, this.notifier, required super.child});

  final T? notifier;

  @override
  bool updateShouldNotify(InheritedNotifier<T> oldWidget) {
    return oldWidget.notifier != notifier;
  }

  @override
  InheritedElement createElement() => _InheritedNotifierElement<T>(this);
}

class _InheritedNotifierElement<T extends Listenable> extends InheritedElement {
  _InheritedNotifierElement(InheritedNotifier<T> widget) : super(widget) {
    widget.notifier?.addListener(_handleUpdate);
  }

  bool _dirty = false;

  @override
  void update(InheritedNotifier<T> newWidget) {
    final T? oldNotifier = (widget as InheritedNotifier<T>).notifier;
    final T? newNotifier = newWidget.notifier;
    if (oldNotifier != newNotifier) {
      oldNotifier?.removeListener(_handleUpdate);
      newNotifier?.addListener(_handleUpdate);
    }
    super.update(newWidget);
  }

  @override
  Widget build() {
    if (_dirty) {
      notifyClients(widget as InheritedNotifier<T>);
    }
    return super.build();
  }

  void _handleUpdate() {
    _dirty = true;
    markNeedsBuild();
  }

  @override
  void notifyClients(InheritedNotifier<T> oldWidget) {
    super.notifyClients(oldWidget);
    _dirty = false;
  }

  @override
  void unmount() {
    (widget as InheritedNotifier<T>).notifier?.removeListener(_handleUpdate);
    super.unmount();
  }
}
```

La respuesta a la pregunta inicial está aquí: **quien escucha es un elemento**. `createElement` crea un elemento especial, que registra su método `_handleUpdate` en el notifier. Ese es el listener. Sigamos un cambio de valor:

1. **Preparación.** Al montar, el elemento llama a `notifier.addListener(_handleUpdate)`. `Caja` llama a `of`, y su elemento queda en la lista de dependientes del elemento del scope (unidad 21).
2. **El dato cambia.** `fuente.value = 2`: el notifier guarda el valor y llama a sus listeners.
3. **El listener se ejecuta.** `_handleUpdate` anota `_dirty = true` y llama a `markNeedsBuild`. **Solo marca**: en este momento no se reconstruye nada. Se marca el elemento del scope, no el de `Caja`.
4. **Llega el frame.** Flutter ejecuta `build()` en el elemento marcado. `_dirty` es `true`, de modo que llama a `notifyClients`.
5. **Aviso a los dependientes.** `notifyClients` recorre la lista y llama a `didChangeDependencies` en cada uno. Esto marca el elemento de `Caja`.
6. **El scope termina.** `super.build()` devuelve el `child`, que es el mismo objeto de antes. Flutter no trabaja por debajo (unidad 18). Por eso `Seccion` y `Ajeno` no se tocan.
7. **El consumidor se reconstruye.** Dentro del mismo frame, Flutter procesa el elemento marcado de `Caja`. Su `build` llama a `of`, que lee el valor actual en el notifier: `2`.

Con esta prueba puedes observar por separado el momento del aviso y el de la construcción:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var buildsCaja = 0;

class ContadorScope extends InheritedNotifier<ValueNotifier<int>> {
  const ContadorScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ContadorScope>();
    return scope!.notifier!.value;
  }
}

class Caja extends StatelessWidget {
  const Caja({super.key});

  @override
  Widget build(BuildContext context) {
    buildsCaja++;
    return Text('Valor: ${ContadorScope.of(context)}');
  }
}

void main() {
  testWidgets('el aviso y la construcción son momentos distintos', (
    tester,
  ) async {
    final fuente = ValueNotifier<int>(1);
    addTearDown(fuente.dispose);
    var avisos = 0;
    void contarAviso() => avisos++;
    fuente.addListener(contarAviso);
    addTearDown(() => fuente.removeListener(contarAviso));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ContadorScope(notifier: fuente, child: const Caja()),
      ),
    );
    expect(tester.binding.hasScheduledFrame, isFalse);

    fuente.value = 2;
    expect(avisos, 1);
    expect(buildsCaja, 1);
    expect(find.text('Valor: 1'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isTrue);

    await tester.pump();
    expect(buildsCaja, 2);
    expect(find.text('Valor: 2'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);

    fuente.value = 2;
    expect(avisos, 1);
    expect(tester.binding.hasScheduledFrame, isFalse);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

`hasScheduledFrame` indica si hay un frame programado. Justo después de asignar, el notifier ya ha avisado (`avisos` es `1`), pero el árbol sigue mostrando `1` y `Caja` no se ha construido. Solo hay una solicitud pendiente. Si asignamos un valor igual, ni siquiera hay aviso, ni frame programado.

### Practica 3

Relaciona cada pregunta con un objeto, según los pasos anteriores: (a) ¿quién conserva el dato? (b) ¿Quién registró el listener? (c) ¿Quién sabe qué consumidores hay? (d) ¿Quién ejecuta `build` del consumidor? (e) ¿Quién decide que `Seccion` no se reconstruya?

<details>
<summary>Ver respuesta</summary>

(a) El notifier. (b) El elemento del scope, en su constructor. (c) Ese mismo elemento, que heredó la lista de dependientes de `InheritedElement`. (d) Flutter, al procesar el frame. (e) Nadie lo decide de forma explícita: `Seccion` no está marcada, y el `child` del scope es el mismo objeto de antes, de modo que Flutter no tiene motivo para trabajar en él.

</details>

## 4. Varios avisos, una construcción

`_handleUpdate` no construye nada: solo anota y marca. Marcar un elemento ya marcado no añade trabajo. Podemos predecir qué sucede si el dato cambia varias veces entre dos frames.

**Antes de mirar los `expect`**, predice `avisos` y `buildsCaja` en cada bloque, y fíjate en el segundo:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var buildsCaja = 0;

class ContadorScope extends InheritedNotifier<ValueNotifier<int>> {
  const ContadorScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ContadorScope>();
    return scope!.notifier!.value;
  }
}

class Caja extends StatelessWidget {
  const Caja({super.key});

  @override
  Widget build(BuildContext context) {
    buildsCaja++;
    return Text('Valor: ${ContadorScope.of(context)}');
  }
}

void main() {
  testWidgets('los cambios entre frames se agrupan', (tester) async {
    final fuente = ValueNotifier<int>(1);
    addTearDown(fuente.dispose);
    final avisos = <int>[];
    void anotar() => avisos.add(fuente.value);
    fuente.addListener(anotar);
    addTearDown(() => fuente.removeListener(anotar));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ContadorScope(notifier: fuente, child: const Caja()),
      ),
    );
    expect(buildsCaja, 1);

    fuente.value = 2;
    fuente.value = 3;
    fuente.value = 4;
    await tester.pump();
    expect(avisos, [2, 3, 4]);
    expect(buildsCaja, 2);
    expect(find.text('Valor: 4'), findsOneWidget);

    avisos.clear();
    fuente.value = 5;
    fuente.value = 4;
    await tester.pump();
    expect(avisos, [5, 4]);
    expect(buildsCaja, 3);
    expect(find.text('Valor: 4'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Paso a paso:

1. **Tres cambios.** Hay tres avisos, uno por cada valor, y nuestro listener los recibe todos. El elemento del scope se marca tres veces, pero sigue siendo un solo elemento pendiente. En el frame, `Caja` se construye una vez y lee el último valor. Un `build` no se corresponde con cada aviso. Los valores `2` y `3` nunca llegan a mostrarse.
2. **Ida y vuelta.** Pasar de `4` a `5` y volver a `4` genera dos avisos y una construcción, **aunque el valor final sea igual al del frame anterior**. Nada compara el valor que hay ahora con el de la última construcción. `_dirty` solo recuerda que hubo un aviso.

Si una lógica necesita ver cada cambio, como un registro de auditoría, no debe apoyarse en `build`: debe usar un listener. `build` describe el estado actual, no la historia de cómo se llegó a él. En una aplicación real, esto también significa que da igual cuántos cambios ocurran en un frame: la pantalla solo refleja el último, ya que solo ese se llega a dibujar.

### Practica 4

Con el mismo árbol, ¿qué obtendríamos en estos casos? (a) `fuente.value = 9;`, `pump`, `fuente.value = 10;`, `pump`. (b) `fuente.value` se asigna al mismo valor que tenía, tres veces, y después `pump`.

<details>
<summary>Ver respuesta</summary>

(a) Dos avisos y dos construcciones: cada `pump` procesa uno de los cambios. Agrupar requiere que los cambios ocurran entre dos frames. (b) Ningún aviso, ninguna marca y ninguna construcción: el `ValueNotifier` compara con `==` antes de avisar (unidad 7), de modo que `_handleUpdate` no se llega a ejecutar.

</details>

## 5. Reemplazar el notifier y desmontar

El listener de un scope tiene la misma dificultad que el de la unidad 19: el padre puede entregar otra fuente. Usemos un notifier que anote sus llamadas. **Antes de mirar los `expect`**, escribe el registro que esperas en cada paso:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final registro = <String>[];
var buildsCaja = 0;

class FuenteRegistrada extends ValueNotifier<int> {
  FuenteRegistrada(this.nombre, super.value);

  final String nombre;

  @override
  void addListener(VoidCallback listener) {
    registro.add('$nombre addListener');
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    registro.add('$nombre removeListener');
    super.removeListener(listener);
  }
}

class ContadorScope extends InheritedNotifier<ValueNotifier<int>> {
  const ContadorScope({
    super.key,
    required super.notifier,
    required super.child,
  });

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ContadorScope>();
    return scope!.notifier!.value;
  }
}

class Caja extends StatelessWidget {
  const Caja({super.key});

  @override
  Widget build(BuildContext context) {
    buildsCaja++;
    return Text('Valor: ${ContadorScope.of(context)}');
  }
}

void main() {
  testWidgets('la fuente que se escucha', (tester) async {
    final a = FuenteRegistrada('a', 1);
    final b = FuenteRegistrada('b', 20);
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    const hijo = Caja();

    Widget arbol(ValueNotifier<int> fuente) => Directionality(
      textDirection: TextDirection.ltr,
      child: ContadorScope(notifier: fuente, child: hijo),
    );

    await tester.pumpWidget(arbol(a));
    expect(registro, ['a addListener']);
    expect(buildsCaja, 1);
    registro.clear();

    await tester.pumpWidget(arbol(a));
    expect(registro, isEmpty);
    expect(buildsCaja, 1);

    await tester.pumpWidget(arbol(b));
    expect(registro, ['a removeListener', 'b addListener']);
    expect(find.text('Valor: 20'), findsOneWidget);
    expect(buildsCaja, 2);
    registro.clear();

    a.value = 2;
    await tester.pump();
    expect(buildsCaja, 2);

    b.value = 21;
    await tester.pump();
    expect(find.text('Valor: 21'), findsOneWidget);
    expect(buildsCaja, 3);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(registro, ['b removeListener']);

    b.value = 22;
    expect(b.value, 22);
  });
}
```

Paso a paso:

1. **Mismo notifier en otra descripción.** `arbol(a)` crea otro `ContadorScope`, pero `a` sigue siendo el mismo objeto. El método `update` no toca el listener, y `updateShouldNotify` devuelve `false`, pues compara los dos notifiers con `!=`. Como `hijo` es el mismo objeto, `Caja` no se construye.
2. **Otro notifier.** `update` retira el listener de `a` y lo registra en `b`. `updateShouldNotify` devuelve `true`, y la dependiente `Caja` se marca. Su `build` lee el valor de `b`.
3. **La fuente antigua ya no importa.** Cambiar `a` no produce nada. Cambiar `b` sí.
4. **Desmontar.** `unmount` retira el listener. **No llama a `dispose`**, porque el scope no creó el notifier: es prestado. La prueba sigue usando `b`, que es de su propiedad, y lo libera al final.

Hay por tanto dos caminos que llegan a `notifyClients`:

| Camino                 | Qué ocurre                                                 | ¿Consulta `updateShouldNotify`? |
|------------------------|------------------------------------------------------------|---------------------------------|
| El notifier avisa      | `_handleUpdate` → `build` del elemento → `notifyClients`   | No                              |
| Llega otra descripción | `update` → `updated` → `notifyClients` si procede          | Sí                              |

Observa que `updateShouldNotify` compara **los notifiers**, no sus valores. Si `b` tuviera el mismo valor que `a`, el consumidor se reconstruiría igualmente, porque la fuente es otra y no se comprueba lo que contiene.

Esto explica también por qué la unidad 16 insistía en que `controller.theme` devolviera **el mismo adaptador** en cada lectura. Si cada lectura creara uno nuevo, `oldNotifier != newNotifier` sería verdadero en cada reconstrucción del padre: el scope volvería a registrarse y avisaría a todos sus dependientes, sin que el tema hubiera cambiado. `late final` evita todo esto.

### Practica 5

`a` y `b` valen `7`. Reemplazamos `a` por `b`. ¿Se reconstruye `Caja`? ¿Qué ocurre si, antes del reemplazo, llamamos a `a.dispose()`? ¿Y si lo hacemos justo después?

<details>
<summary>Ver respuesta</summary>

`Caja` se reconstruye, porque cambia la fuente, aunque el texto sea el mismo. Si liberamos `a` antes del reemplazo, el scope todavía la usa, y al retirar su listener estaría usando un objeto liberado: el propietario debe esperar a que deje de estar prestado. Justo después, es seguro: el scope ya se ha pasado a `b`. Con un notifier como este, retirar el listener no llega a lanzar un error, pero sigue siendo un descuido del propietario: el reparto lo fijó la unidad 13.

</details>

## 6. El recorrido completo con el scope real

Ya tenemos todas las piezas para seguir un cambio de tema en DaisyUI. [El scope](../../../lib/themes/application/daisy_theme_scope.dart) es un `InheritedNotifier<ValueListenable<DaisyThemeModel>>`. Recibe `controller.theme`, el adaptador `_ThemeListenable` de la unidad 16. Estos son los eslabones desde `setTheme`:

```text
controller.setTheme(tema)
└── _palette.value = tema                 La señal compara con == y guarda el valor si es distinto
    └── se ejecutan sus listeners         Incluido _handleUpdate, registrado mediante el adaptador
        └── _handleUpdate                 _dirty = true; markNeedsBuild() en el elemento del scope
            ⋮ (siguiente frame)
            └── build() del elemento      Como _dirty es true, llama a notifyClients
                └── didChangeDependencies Marca a cada elemento dependiente
                    ⋮ (mismo frame)
                    └── build del consumidor
                        └── context.daisyTheme → DaisyThemeScope.of → notifier!.value → _palette.value
```

Para que `_handleUpdate` llegue a la señal, el adaptador reenvía la llamada. Este es el **fragmento** real del controlador:

```dart
@override
void addListener(VoidCallback listener) {
  _source.addListener(listener);
}
```

**Antes de mirar los `expect`**, predice avisos y construcciones en cada bloque:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final builds = <String, int>{'seccion': 0, 'consumidor': 0, 'ajeno': 0};

class Seccion extends StatelessWidget {
  const Seccion({super.key});

  @override
  Widget build(BuildContext context) {
    builds['seccion'] = builds['seccion']! + 1;
    return const Column(children: [Consumidor(), Ajeno()]);
  }
}

class Consumidor extends StatelessWidget {
  const Consumidor({super.key});

  @override
  Widget build(BuildContext context) {
    builds['consumidor'] = builds['consumidor']! + 1;
    return Text(context.daisyTheme.name);
  }
}

class Ajeno extends StatelessWidget {
  const Ajeno({super.key});

  @override
  Widget build(BuildContext context) {
    builds['ajeno'] = builds['ajeno']! + 1;
    return const Text('Ajeno');
  }
}

void main() {
  testWidgets('de setTheme a build', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    final avisos = <String>[];
    void anotar() => avisos.add(controller.theme.value.name);
    controller.theme.addListener(anotar);
    addTearDown(() => controller.theme.removeListener(anotar));

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(controller: controller, child: const Seccion()),
      ),
    );
    expect(builds, {'seccion': 1, 'consumidor': 1, 'ajeno': 1});

    controller.setTheme(DaisyThemes.dark);
    expect(avisos, ['Dark']);
    expect(builds['consumidor'], 1);
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, {'seccion': 1, 'consumidor': 2, 'ajeno': 1});

    avisos.clear();
    controller.setTheme(DaisyThemes.dark.copyWith());
    await tester.pump();
    expect(avisos, isEmpty);
    expect(builds['consumidor'], 2);

    controller.setTheme(DaisyThemes.cupcake);
    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(avisos, ['Cupcake', 'Dark']);
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, {'seccion': 1, 'consumidor': 3, 'ajeno': 1});

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Paso a paso:

1. **Un cambio.** La señal avisa durante la propia escritura: `avisos` ya tiene `Dark`, pero el consumidor aún no se ha construido. Tras `pump`, se construye solo él. **El notifier no reconstruye la aplicación**: su efecto llega a los elementos registrados.
2. **Un tema equivalente.** `copyWith()` crea otro objeto con los mismos datos. La señal compara con `==` (unidades 8 y
   9) y no avisa, de modo que no se ejecuta ningún eslabón posterior. El orden importa: **la igualdad se comprueba antes de la cadena**.
3. **Ida y vuelta.** `cupcake` y después `dark`: dos avisos y una construcción, como en el apartado 4.

Compara esto con la otra forma de observar el tema, la de la unidad 10:

| Pregunta                   | `context.daisyTheme`                         | `SignalBuilder` que lee `controller.theme.value` |
|----------------------------|----------------------------------------------|--------------------------------------------------|
| ¿Quién registra la lectura?| `dependOnInheritedWidgetOfExactType`         | El elemento del `SignalBuilder`, al leer         |
| ¿Qué escucha la señal?     | `_handleUpdate` del elemento del scope       | La suscripción del `SignalElement`               |
| ¿Quién marca al consumidor?| `notifyClients`, vía `didChangeDependencies` | Esa suscripción, con `markNeedsBuild`            |
| ¿Quién encuentra la fuente?| La búsqueda por el árbol                     | Tu código, que ya tiene la referencia            |

Las dos terminan igual: un elemento marcado que Flutter construye en el siguiente frame.

### Nunca cambies el tema durante `build`

Un eslabón de esta cadena tiene una consecuencia práctica. `_handleUpdate` llama a `markNeedsBuild` en el momento del aviso. Si la escritura ocurre **durante** la construcción de un descendiente, se pide reconstruir un ancestro cuando Flutter ya ha pasado por él:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('escribir durante build lanza un error', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: Builder(
            builder: (context) {
              controller.setTheme(DaisyThemes.dark);
              return Text(context.daisyTheme.name);
            },
          ),
        ),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<SignalEffectException>());
    final causa = (error as SignalEffectException).error;
    expect(causa, isA<FlutterError>());
    expect(causa.toString(), contains('called during build'));

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

La señal ejecuta sus listeners dentro de un efecto y, si uno falla, envuelve el error en `SignalEffectException`, de modo que la causa está en su campo `error`: es el `FlutterError` de Flutter (`markNeedsBuild() called during build`). `as` convierte el tipo de la referencia para poder leer ese campo.

Además de lanzar un error, tendría poco sentido: `build` describe el estado, no debe cambiarlo (unidad 18). Los cambios van en respuesta a eventos, como una pulsación. Fíjate en que, en cambio, el ejercicio final de la unidad 19 llamaba a `setTheme` dentro de `didUpdateWidget` sin problemas: ahí se ejecuta **antes** de construir el scope, que es un descendiente y aún tiene que pasar por su propia construcción.

### Practica 6

Después de `controller.setTheme(DaisyThemes.dark.copyWith())`, ¿qué eslabones del esquema se ejecutan? ¿Y si la igualdad de `DaisyThemeModel` comparara por identidad, en lugar de por contenido?

<details>
<summary>Ver respuesta</summary>

Solo la llamada a `setTheme` y la escritura en `_palette`, que no pasa de la comparación. Ninguno de los siguientes. Si comparara por identidad, la copia sería un valor «distinto», así que se ejecutaría toda la cadena: aviso, marca y construcción del consumidor, para mostrar lo mismo. Es la utilidad práctica de la igualdad por contenido que estudió la unidad 8.

</details>

## 7. Quién se encarga de qué

Antes de pasar al ejercicio, ordenemos los papeles. Es la respuesta completa a la regla del plan: identificar quién conserva el dato, quién registra la dependencia, quién avisa y quién solicita reconstruir:

| Pregunta                                  | Respuesta en DaisyUI                                             |
|-------------------------------------------|------------------------------------------------------------------|
| ¿Quién conserva el tema?                  | `_palette`, la señal del controlador                             |
| ¿Quién decide si un cambio cuenta?        | La señal, con `==`                                               |
| ¿Quién escucha la señal para la interfaz? | El elemento de `DaisyThemeScope`, con `_handleUpdate`            |
| ¿Quién registra la dependencia?           | `dependOnInheritedWidgetOfExactType`, llamado desde `of`         |
| ¿Quién marca el scope?                    | `_handleUpdate`, con `markNeedsBuild`                            |
| ¿Quién marca a los consumidores?          | `notifyClients`, durante la construcción del elemento del scope  |
| ¿Quién ejecuta los `build`?               | Flutter, en el frame                                             |
| ¿Quién retira el listener?                | El elemento, al sustituir la fuente o en `unmount`               |
| ¿Quién libera la señal?                   | El propietario del controlador, nunca el scope                   |

### Practica 7

Di si cada frase es correcta, y corrígela si no lo es: (a) «`setTheme` reconstruye los widgets que usan el tema». (b) «El scope se reconstruye con cada cambio de tema y, por eso, todo lo que tiene debajo también». (c) «`context.daisyTheme` registra un listener en la señal».

<details>
<summary>Ver respuesta</summary>

(a) No: `setTheme` solo escribe en la señal, que avisa; la reconstrucción es varios pasos después, y la ejecuta Flutter. (b) El elemento del scope sí se procesa, pero devuelve el mismo `child`, y Flutter se detiene ahí; debajo solo se reconstruyen los dependientes marcados. (c) No: registra una dependencia en el elemento del scope. El listener en la señal lo registró el propio elemento del scope al montarse, una sola vez, por muchos consumidores que tenga.

</details>

## Ejercicio final: un scope para un controlador de borde

Vamos a escribir, a pequeña escala, la misma arquitectura que DaisyUI:

1. `ControladorBorde`: guarda una `FlutterSignal<int>` privada, expone `ValueListenable<int> get borde`, y tiene `cambiar` y `dispose`. Es la misma forma de la unidad 17.
2. `BordeScope`: un `InheritedNotifier<ValueListenable<int>>` que recibe un `ControladorBorde` por parámetro, entrega `controlador.borde` al padre y tiene un método `of`.
3. `Lector`: un widget que muestra `Borde: $valor` y cuenta sus construcciones. `Ajeno`: uno que no lo lee.

En la prueba:

1. Monta el scope con un controlador `uno` (`inicial: 1`), un listener propio y un `child` constante.
2. Haz tres cambios antes del frame: `2`, `3` y `3`. Comprueba los avisos, antes y después de `pump`, y las construcciones.
3. Sustituye el controlador por `dos` (`inicial: 3`). ¿Se reconstruye `Lector`, aunque el valor sea igual?
4. Cambia `uno` y, después, `dos`, con un `pump` tras cada uno.
5. Desmonta y comprueba que puedes seguir escribiendo en `dos`.
6. Libera lo que sea tuyo.

Predice todo antes de abrir la solución. Como variaciones, ¿qué pasaría si el getter `borde` creara un adaptador nuevo en cada lectura? ¿Y si `of` usara `getInheritedWidgetOfExactType`?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class ControladorBorde {
  ControladorBorde({int inicial = 1}) : _borde = FlutterSignal<int>(inicial);

  final FlutterSignal<int> _borde;

  ValueListenable<int> get borde => _borde;

  void cambiar(int nuevo) => _borde.value = nuevo;

  void dispose() => _borde.dispose();
}

class BordeScope extends InheritedNotifier<ValueListenable<int>> {
  BordeScope({
    super.key,
    required ControladorBorde controlador,
    required super.child,
  }) : super(notifier: controlador.borde);

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<BordeScope>();
    if (scope == null) {
      throw FlutterError('Coloca BordeScope por encima de este widget.');
    }
    return scope.notifier!.value;
  }
}

var buildsLector = 0;
var buildsAjeno = 0;

class Lector extends StatelessWidget {
  const Lector({super.key});

  @override
  Widget build(BuildContext context) {
    buildsLector++;
    return Text('Borde: ${BordeScope.of(context)}');
  }
}

class Ajeno extends StatelessWidget {
  const Ajeno({super.key});

  @override
  Widget build(BuildContext context) {
    buildsAjeno++;
    return const Text('Ajeno');
  }
}

void main() {
  testWidgets('un scope para un controlador de borde', (tester) async {
    final uno = ControladorBorde();
    final dos = ControladorBorde(inicial: 3);
    addTearDown(uno.dispose);
    addTearDown(dos.dispose);
    final avisos = <int>[];
    void anotar() => avisos.add(uno.borde.value);
    uno.borde.addListener(anotar);
    addTearDown(() => uno.borde.removeListener(anotar));
    const hijo = Column(children: [Lector(), Ajeno()]);

    Widget arbol(ControladorBorde controlador) => Directionality(
      textDirection: TextDirection.ltr,
      child: BordeScope(controlador: controlador, child: hijo),
    );

    await tester.pumpWidget(arbol(uno));
    expect((buildsLector, buildsAjeno), (1, 1));

    uno.cambiar(2);
    uno.cambiar(3);
    uno.cambiar(3);
    expect(avisos, [2, 3]);
    expect(buildsLector, 1);
    await tester.pump();
    expect(find.text('Borde: 3'), findsOneWidget);
    expect((buildsLector, buildsAjeno), (2, 1));

    await tester.pumpWidget(arbol(dos));
    expect(find.text('Borde: 3'), findsOneWidget);
    expect((buildsLector, buildsAjeno), (3, 1));

    uno.cambiar(5);
    await tester.pump();
    expect(buildsLector, 3);

    dos.cambiar(6);
    await tester.pump();
    expect(find.text('Borde: 6'), findsOneWidget);
    expect((buildsLector, buildsAjeno), (4, 1));

    await tester.pumpWidget(const SizedBox.shrink());
    dos.cambiar(7);
    expect(dos.borde.value, 7);
    expect(buildsLector, 4);
  });
}
```

Los cambios `2` y `3` producen avisos. El segundo `3` es igual y no produce ninguno. Son dos avisos y una construcción, porque ambos ocurrieron antes del frame.

Al sustituir por `dos`, el valor sigue siendo `3`, pero `Lector` se reconstruye: `updateShouldNotify` compara las fuentes y no los valores. Cambiar `uno` ya no provoca nada en el árbol, aunque nuestro listener propio, registrado en `uno`, seguiría recibiendo avisos. Cambiar `dos` sí. Al desmontar, el elemento retira su listener; `dos` sigue siendo utilizable porque la prueba es su propietaria. El constructor de `BordeScope` no es `const` porque ejecuta `controlador.borde`, como pasa en DaisyUI.

Si `borde` creara un adaptador en cada lectura, cada descripción nueva de `BordeScope` llevaría una fuente distinta, de modo que el elemento cambiaría de listener y avisaría a los dependientes en cada reconstrucción del padre. Si `of` usara `getInheritedWidgetOfExactType`, `Lector` no se reconstruiría con ningún aviso: el elemento del scope seguiría escuchando, pero su lista de dependientes estaría vacía.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Por qué un `InheritedWidget` que lee `fuente.value` en su construcción no se actualiza? **Apartado 1.**
2. ¿Qué aporta `InheritedNotifier` frente a un puente manual con `State`? **Apartados 1 y 2.**
3. ¿Quién registra el listener y dónde? **Apartado 3.**
4. Enumera los pasos desde que el notifier cambia hasta el `build` del consumidor. **Apartado 3.**
5. ¿Por qué tres cambios antes de un frame producen una construcción? ¿Qué ocurre con un cambio de ida y vuelta? **Apartado 4.**
6. ¿Qué ocurre con los listeners y los dependientes al reemplazar el notifier? **Apartado 5.**
7. ¿Qué compara `updateShouldNotify` en `InheritedNotifier`, y en qué camino se consulta? **Apartado 5.**
8. ¿Qué hace el elemento al desmontarse, y por qué no libera el notifier? **Apartado 5.**
9. Recorre un cambio real desde `setTheme` hasta `context.daisyTheme`. **Apartado 6.**
10. ¿Por qué no se debe llamar a `setTheme` durante `build`? **Apartado 6.**
11. ¿Quién conserva, decide, escucha, registra, marca, construye y libera en DaisyUI? **Apartado 7.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y sigas el aviso hasta la reconstrucción sin afirmar que el notifier reconstruye directamente toda la aplicación. La unidad 23 estudia `DaisyThemeScope.of` línea a línea: la nullabilidad, los operadores `?.`, `??` y `!`, y los errores.

## Para consultar si necesitas reforzar

- [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html): la documentación oficial, con un ejemplo que usa una animación como notifier.
- [`Element.markNeedsBuild`](https://api.flutter.dev/flutter/widgets/Element/markNeedsBuild.html): qué significa marcar un elemento.
- [`InheritedElement.notifyClients`](https://api.flutter.dev/flutter/widgets/InheritedElement/notifyClients.html): el aviso a los dependientes.
- [`FlutterSignal`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html): la implementación de `addListener`. Compara `latest` con la versión instalada.
- [Scope](../../../lib/themes/application/daisy_theme_scope.dart), [controlador](../../../lib/themes/application/daisy_theme_controller.dart) y [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento actual de DaisyUI.

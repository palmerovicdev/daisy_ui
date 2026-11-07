# 31. Ejercicio final: explicar todo el flujo

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 30](30-pruebas-de-estado-listeners-y-widgets.md) · **Estado:** pendiente

## Qué vas a aprender

Alguien pulsa `Switch preview theme` y la vista previa pasa de `Cupcake` a `Dark`, mientras que el resto de la pantalla no cambia. Entre esa pulsación y el nuevo color hay una cadena de objetos y llamadas. Ya has estudiado cada eslabón por separado; aquí los unes.

Esta unidad no presenta conceptos nuevos. Al terminar podrás explicar el recorrido completo con los archivos reales delante, sin decir «ocurre automáticamente» para saltarte un paso, y podrás predecir qué cambia en seis variantes. Para cada eslabón sabrás responder a cuatro preguntas: **quién conserva el dato, quién registra la dependencia, quién avisa y quién solicita reconstruir la interfaz**.

Vas a necesitar abiertos estos archivos:

- [daisy_theme_controller.dart](../../../lib/themes/application/daisy_theme_controller.dart): controlador, señal y adaptador.
- [daisy_theme_service.dart](../../../lib/themes/application/daisy_theme_service.dart): servicio global.
- [daisy_theme_scope.dart](../../../lib/themes/application/daisy_theme_scope.dart): scope.
- [build_context.dart](../../../lib/themes/core/extension/build_context.dart): `context.daisyTheme`.
- La aplicación del [apartado 8 de la unidad 25](25-scopes-anidados-e-independencia.md#8-el-ejemplo-anterior-completo). El [ejemplo actual](../../../example/lib/main.dart) solo tiene el scope global, de modo que usamos esa versión anterior porque tiene dos temas y sus botones.

Los ejemplos completos son pruebas de widgets independientes. Copia **una cada vez** a `test/estudio_flujo_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_flujo_test.dart
```

Si usas FVM, antepón `fvm`. Borra el archivo al acabar. Los fragmentos de código real están recortados e identificados, y no se ejecutan por sí solos. Lo de Flutter y Signals se ha contrastado con el código fuente de Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0, y son detalles internos de esas versiones. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar con las variantes y el ejercicio final.

Un consejo: **antes de leer cada apartado, intenta decir tú lo que ocurre** en ese paso. Lo que no sepas explicar es lo que debes repasar en la unidad indicada.

## 1. Crear el controlador y su señal

Hay dos caminos, y los dos terminan en el mismo constructor. Este es un fragmento de [daisy_theme_controller.dart](../../../lib/themes/application/daisy_theme_controller.dart):

```dart
DaisyThemeController({
  DaisyThemeModel initialTheme = DaisyThemes.light,
}) : _palette = FlutterSignal<DaisyThemeModel>(initialTheme);
```

**Vista previa.** `_ThemePreviewState.initState` llama a `DaisyThemeController(initialTheme: DaisyThemes.cupcake)`. Esa llamada crea un controlador y, en su lista de inicialización, una `FlutterSignal` que guarda el modelo `cupcake` (unidades 14–15). La crea una sola vez, porque `initState` se ejecuta una vez por cada `State` (unidad 19).

**Servicio global.** Este es un fragmento de [daisy_theme_service.dart](../../../lib/themes/application/daisy_theme_service.dart):

```dart
static final DaisyThemeController _controller = DaisyThemeController();
```

Los campos `static` de Dart se inicializan la primera vez que se accede a ellos (unidad 17). En la aplicación de la unidad 25, ese primer acceso se produce al construir el `DaisyThemeScope` sin `controller`. En el [ejemplo actual](../../../example/lib/main.dart), `main` llama antes a `DaisyThemeService.initialize()`, por lo que el controlador ya existe, y además tiene una suscripción cuyo cuerpo todavía está por escribir. No interviene en el recorrido que sigue, pero también se ejecutará con cada cambio.

**Quién conserva el dato:** la señal `_palette`, que es privada. No hay otra copia. Ni el scope, ni el contexto, ni los widgets guardan el tema, sino que lo leen.

### Practica 1

Hay un `DaisyThemeModel` constante, `DaisyThemes.cupcake`, y una señal que lo contiene. ¿Cuántos modelos hay después de crear dos controladores con `initialTheme: DaisyThemes.cupcake`? ¿Y cuántas señales?

<details>
<summary>Ver respuesta</summary>

Un único modelo, y dos señales. Cada controlador crea su propia señal, pero las dos guardan una referencia al mismo objeto constante. Lo que se sustituye al cambiar de tema es qué referencia guarda cada señal; el modelo no se modifica (unidades 8 y 27). Por eso los dos controladores son independientes aunque empiecen con el mismo valor.

</details>

## 2. Obtener la vista pública: `_ThemeListenable`

Nadie fuera del controlador puede tocar `_palette`. Lo que se entrega es otra cosa. Fragmento del mismo archivo:

```dart
late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(_palette);

ValueListenable<DaisyThemeModel> get theme => _theme;
```

La primera vez que alguien lee `controller.theme`, `late final` crea un adaptador `_ThemeListenable` y lo guarda; las siguientes, devuelve ese mismo objeto. Es un objeto distinto de la señal, que solo guarda una referencia a ella y le reenvía cada operación:

```dart
DaisyThemeModel get value => _source.value;
void addListener(VoidCallback listener) => _source.addListener(listener);
void removeListener(VoidCallback listener) => _source.removeListener(listener);
```

Este último fragmento está resumido: en el archivo real, los dos métodos tienen cuerpo con llaves y `@override`, aunque el comportamiento es este. El tipo que se ve fuera es `ValueListenable`, que no tiene setter. Además, un cast a `ValueNotifier` falla, ya que el adaptador realmente no lo es (unidad 16).

### Practica 2

¿Por qué importa que `theme` devuelva siempre el mismo objeto? Piensa en lo que hará `InheritedNotifier` en el apartado 3 cuando reciba un widget nuevo.

<details>
<summary>Ver respuesta</summary>

`InheritedNotifier` compara el notifier anterior con el nuevo. Si `theme` devolviera un adaptador nuevo en cada lectura, serían objetos distintos en cada reconstrucción del scope: retiraría el listener, añadiría otro y lo trataría como un cambio de fuente, notificando a los dependientes sin que el tema hubiera cambiado. La unidad 30 rompe esto a propósito, y *Public theme views hide the mutable source behind an adapter* lo detecta con `identical`.

</details>

## 3. Montar el scope y empezar a escuchar

Fragmento de [daisy_theme_scope.dart](../../../lib/themes/application/daisy_theme_scope.dart):

```dart
DaisyThemeScope({
  super.key,
  required super.child,
  DaisyThemeController? controller,
}) : super(notifier: controller?.theme ?? DaisyThemeService.theme);
```

El constructor solo elige la fuente: el controlador recibido o, si es `null`, el servicio (unidad 23). **El constructor de un widget no escucha nada.** Un widget es solo una descripción.

La escucha empieza cuando Flutter crea el **elemento** para ese widget. Este fragmento es del SDK, de `widgets/inherited_notifier.dart`:

```dart
_InheritedNotifierElement(InheritedNotifier<T> widget) : super(widget) {
  widget.notifier?.addListener(_handleUpdate);
}
```

Sigue la llamada de principio a fin:

1. El elemento del scope entrega su método `_handleUpdate` a `addListener` del adaptador.
2. El adaptador lo reenvía a `_source.addListener`, es decir, a la señal.
3. La señal, mediante `ValueNotifierSignalMixin`, guarda ese listener en un mapa y crea una suscripción interna, que es un `effect` que lee su propio valor.
4. Como un `effect` se ejecuta una vez al crearse, esa suscripción se salta la primera ejecución con una variable `first`. Por eso registrar un listener no produce un aviso.

**Cadena de escucha ya preparada:** señal → adaptador → elemento del scope. Todavía ningún widget depende de nada.

### Practica 3

Si `MyApp.build` se ejecutara de nuevo y creara otro `DaisyThemeScope` con el mismo controlador, ¿se añadiría otro listener?

<details>
<summary>Ver respuesta</summary>

No. Flutter reutiliza el elemento, porque el tipo y la clave coinciden, y llama a su `update` con el widget nuevo. `update` compara los notifiers: al recibir el mismo adaptador, no retira ni añade nada (unidades 18 y 22). El listener está asociado al elemento, no al widget, por lo que su vida no depende de las reconstrucciones.

</details>

## 4. Leer el tema y registrar la dependencia

El consumidor de la vista previa está dentro de un `Builder`. Ejecuta `final theme = context.daisyTheme;`, y a partir de aquí hay tres llamadas encadenadas.

Fragmento de [build_context.dart](../../../lib/themes/core/extension/build_context.dart):

```dart
DaisyThemeModel get daisyTheme => DaisyThemeScope.of(this);
```

La extensión solo abrevia (unidad 24). Fragmento de [daisy_theme_scope.dart](../../../lib/themes/application/daisy_theme_scope.dart):

```dart
final scope = context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>();

if (scope == null) {
  throw FlutterError('Coloca DaisyThemeScope por encima de este widget.');
}

return scope.notifier!.value;
```

Aquí, con una sola línea, ocurren dos cosas distintas:

1. **Búsqueda.** Flutter busca el `DaisyThemeScope` más cercano por encima de este contexto. La vista previa encuentra el suyo, y no el global, porque es el más próximo (unidades 20 y 25).
2. **Registro.** El elemento del `Builder` queda apuntado en la lista de dependientes del elemento del scope (unidad 21). **Quien registra la dependencia es el consumidor, al hacer esta llamada.**

Después, `scope.notifier!.value` lee el valor actual: adaptador → señal → modelo `cupcake`. El `!` es seguro porque el constructor siempre entrega un notifier. Esta lectura se hace fuera de cualquier contexto reactivo de Signals, de modo que la señal no sabe nada de este `Builder`. Hay dos relaciones separadas: la **señal conoce al elemento del scope**, y el **elemento del scope conoce a sus dependientes**.

### Practica 4

La pantalla contiene `const _ThemePreview()` y un `Text` que muestra `Light`, leídos con `final theme = context.daisyTheme;` en `_ThemeExample.build`. ¿De qué scope depende `_ThemeExample`? ¿De cuál depende el `Builder` de la vista previa? ¿Depende `_ThemePreviewState` de alguno?

<details>
<summary>Ver respuesta</summary>

`_ThemeExample` depende del scope global, el único que tiene por encima. El `Builder` depende del scope de la vista previa. `_ThemePreviewState` no depende de ninguno: nunca llama a `context.daisyTheme`, sino que construye el scope y le entrega su controlador. Por eso no se reconstruye al cambiar el tema de la vista previa. Lo que se reconstruye es el `Builder`.

</details>

## 5. Pulsar el botón y decidir si hay cambio

El botón tiene este callback, creado cuando se construyó la vista previa. Es un fragmento de la aplicación de la unidad 25:

```dart
onPressed: () => _controller.setTheme(
  theme.id == DaisyThemes.dark.id ? DaisyThemes.cupcake : DaisyThemes.dark,
),
```

Es una closure que conserva dos cosas: `_controller`, a través de su `State`, y `theme`, que es la **lectura hecha en ese `build`** (unidad 2). Flutter la ejecuta al reconocer la pulsación. `theme` es `cupcake`, así que propone `dark`.

```dart
void setTheme(DaisyThemeModel theme) => _palette.value = theme;
```

Este fragmento es del controlador. El método no compara ni notifica: delega en el setter de la señal. La decisión se toma allí. Esto es un fragmento de `signals_core`, recortado:

```dart
if (force || !isInitialized || !equalityCheck.equals(val, internalValue)) {
  beforeUpdate(val);
  internalSetValue(val);
  return true;
}
return false;
```

1. Si la señal ya ha sido liberada, antes de esto lanza `SignalsWriteAfterDisposeError` (unidad 13).
2. `equalityCheck` es, por defecto, `==`, y `==` en `DaisyThemeModel` lo aporta Equatable, comparando `props` (unidades 8 y 27).
3. Si son iguales, no hace nada: ni guarda el objeto nuevo ni avisa.
4. Si son distintos, guarda el nuevo y continúa con el aviso.

Quien decide notificar no es el botón, ni el controlador, ni el scope. **Es la señal, al comparar.**

### Practica 5

El controlador contiene `DaisyThemes.dark` y se llama a `setTheme(DaisyThemes.dark.copyWith(border: DaisyThemes.dark.border))`. ¿Es otro objeto? ¿Qué objeto contiene la señal después? ¿Se avisa a alguien?

<details>
<summary>Ver respuesta</summary>

`copyWith` crea otro objeto, pero con los mismos datos, y `==` da verdadero. La señal conserva el objeto que ya tenía, y se descarta el nuevo; por tanto, nadie recibe un aviso. Comprobarás esto con `identical` en la variante 1.

</details>

## 6. Avisar: de la señal al elemento del scope

Con el valor ya guardado, la señal avisa a sus suscriptores. Uno de ellos es la suscripción del apartado 3, cuyo cuerpo, ya pasada la primera ejecución, llama al listener. Ese listener es `_handleUpdate`:

```dart
void _handleUpdate() {
  _dirty = true;
  markNeedsBuild();
}
```

Este fragmento es de Flutter. Fíjate en lo que **no** hace: no reconstruye el consumidor, ni busca widgets, ni lee el tema. Anota que hay un aviso pendiente y marca **su propio elemento** para reconstruirlo. `markNeedsBuild` lo añade a la lista de pendientes y pide a Flutter que programe un frame.

Y todo esto es **síncrono**: cuando `setTheme` devuelve el control, el listener ya se ejecutó, y el valor nuevo ya está en la señal, pero ningún `build` se ha ejecutado aún.

### Practica 6

Dentro de un `onPressed`, escribes `_controller.setTheme(DaisyThemes.dark); print(_controller.theme.value.id); print(theme.id);`. Si `theme` se leyó en el último `build` y contenía `cupcake`, ¿qué imprime cada línea?

<details>
<summary>Ver respuesta</summary>

Imprime `dark` y `cupcake`. La primera lee la señal, que ya cambió, porque la asignación es síncrona. La segunda usa la variable local de la closure, una lectura hecha antes del cambio. Esa variable no se actualiza: habría que esperar a otro `build`, que creará otra closure con otro `theme`.

</details>

## 7. Reconstruir: del scope a los dependientes

Llega el frame. Flutter reconstruye los elementos marcados, y entre ellos el del scope. Este fragmento también es de Flutter:

```dart
@override
Widget build() {
  if (_dirty) {
    notifyClients(widget as InheritedNotifier<T>);
  }
  return super.build();
}
```

1. Como `_dirty` es verdadero, llama a `notifyClients`, que recorre sus dependientes y llama a `didChangeDependencies` de cada uno. Eso los marca para reconstruirlos. **Aquí se solicita la reconstrucción de los consumidores**, y lo hace el elemento del scope.
2. `super.build()` devuelve el `child` del widget del scope. Es la misma instancia que antes, así que Flutter no reconstruye el subárbol por ese motivo (unidad 18). Solo se reconstruye quien está en la lista.
3. En ese mismo frame se reconstruye el `Builder`. Vuelve a ejecutar `context.daisyTheme`, ahora obtiene `dark`, y crea un `Container` y un `Text` nuevos con los tokens de ese tema.
4. Con esas descripciones actualizadas, Flutter actualiza lo que haga falta y hace el trazado y el pintado.

El widget `_ThemeExample` no se toca: depende de otro scope. `_ThemePreviewState.build` no se vuelve a ejecutar, pues no es dependiente, y el botón recibe la closure nueva porque está dentro del `Builder`.

### Practica 7

Antes de un frame se llama a `setTheme` tres veces, con tres temas distintos. ¿Cuántas veces se ejecuta `_handleUpdate`? ¿Y el `build` del consumidor? ¿Qué tema lee?

<details>
<summary>Ver respuesta</summary>

`_handleUpdate` se ejecuta tres veces, una por cada aviso, ya que las notificaciones son síncronas. El `build` del consumidor se ejecuta una sola vez en el frame siguiente, porque marcar algo ya marcado no añade trabajo (unidad 22). Lee el valor actual, es decir, el tercer tema. Las lecturas intermedias nunca llegan a la interfaz.

</details>

## 8. Desmontar y liberar

Al cerrarse la vista previa, Flutter recorre el subárbol y lo desmonta **desde las hojas hacia arriba**: en `_InactiveElements._unmount`, primero visita los hijos y después llama a `unmount` del elemento. Por eso el orden es:

1. El `Builder` deja de estar registrado como dependiente de su scope.
2. El elemento del scope se desmonta. Este fragmento es de Flutter:

   ```dart
   @override
   void unmount() {
     (widget as InheritedNotifier<T>).notifier?.removeListener(_handleUpdate);
     super.unmount();
   }
   ```

   Retira su listener, adaptador y señal mediante, y nada más. El controlador está **prestado**: el scope no lo libera (unidades 13 y 25).
3. Por último, el elemento de `_ThemePreview` se desmonta y Flutter llama a `_ThemePreviewState.dispose`. Como es el propietario, este llama a `_controller.dispose()`:

   ```dart
   void dispose() {
     _subscriptionCanceler?.call();
     _subscriptionCanceler = null;
     _palette.dispose();
   }
   ```

   Si no se llamó a `initialize`, `_subscriptionCanceler` es `null` y no pasa nada.

Con el servicio global este paso no existe. No hay ningún propietario que lo libere, y su controlador dura todo el programa. Desmontar un scope que lo usa solo retira esa escucha.

### Practica 8

¿Por qué es seguro que `_ThemePreviewState.dispose` libere el controlador si el scope aún lo estaba usando hace un instante? ¿Qué pasaría si el controlador lo creara un `State` situado **dentro** del subárbol del scope, y lo pasara a un scope exterior por algún otro medio?

<details>
<summary>Ver respuesta</summary>

Porque `_ThemePreviewState` está por encima de su scope, de modo que el scope ya se desmontó y retiró su listener cuando llega el `dispose` del propietario. Si el propietario estuviera debajo del scope, el orden se invertiría: liberaría el controlador con el scope aún escuchando. Es el caso de «liberar antes de tiempo» de la unidad 25, y por eso el propietario debe vivir más que quien lo usa.

</details>

## 9. Comprobar la traza

Ya has seguido el recorrido por escrito. Ahora, **escribe en un papel la lista que crees que producirá esta prueba** y compárala después. Hay dos consumidores: uno lee el tema y otro no.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final traza = <String>[];

class Propietario extends StatefulWidget {
  const Propietario({super.key});

  @override
  State<Propietario> createState() => _PropietarioState();
}

class _PropietarioState extends State<Propietario> {
  late final DaisyThemeController _controller;

  void _anotarAviso() => traza.add('aviso: ${_controller.theme.value.id}');

  @override
  void initState() {
    super.initState();
    _controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    _controller.theme.addListener(_anotarAviso);
    traza.add('propietario: controlador creado');
  }

  @override
  void dispose() {
    traza.add('propietario: dispose');
    _controller.theme.removeListener(_anotarAviso);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    traza.add('propietario: build');
    return DaisyThemeScope(
      controller: _controller,
      child: Column(
        children: [
          const Consumidor(),
          const NoLee(),
          ElevatedButton(
            onPressed: () {
              traza.add('pulsación: antes de setTheme');
              _controller.setTheme(DaisyThemes.dark);
              traza.add('pulsación: después de setTheme');
            },
            child: const Text('Cambiar'),
          ),
        ],
      ),
    );
  }
}

class Consumidor extends StatefulWidget {
  const Consumidor({super.key});

  @override
  State<Consumidor> createState() => _ConsumidorState();
}

class _ConsumidorState extends State<Consumidor> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    traza.add('consumidor: didChangeDependencies');
  }

  @override
  void dispose() {
    traza.add('consumidor: dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = context.daisyTheme;
    traza.add('consumidor: build con ${tema.id}');
    return Text(tema.name);
  }
}

class NoLee extends StatelessWidget {
  const NoLee({super.key});

  @override
  Widget build(BuildContext context) {
    traza.add('no lee: build');
    return const Text('Sin tema');
  }
}

void main() {
  testWidgets('la traza del cambio de tema', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Propietario()));
    expect(traza, [
      'propietario: controlador creado',
      'propietario: build',
      'consumidor: didChangeDependencies',
      'consumidor: build con cupcake',
      'no lee: build',
    ]);
    traza.clear();

    await tester.tap(find.text('Cambiar'));
    expect(traza, [
      'pulsación: antes de setTheme',
      'aviso: dark',
      'pulsación: después de setTheme',
    ]);
    traza.clear();

    await tester.pump();
    expect(traza, [
      'consumidor: didChangeDependencies',
      'consumidor: build con dark',
    ]);
    traza.clear();

    await tester.pumpWidget(const SizedBox.shrink());
    expect(traza, ['consumidor: dispose', 'propietario: dispose']);
  });
}
```

Pasa. Compara cada bloque con el apartado correspondiente:

- **Montaje.** El propietario crea el controlador y construye; `didChangeDependencies` se ejecuta antes del primer `build` (unidad 19).
- **Pulsación.** `aviso: dark` queda **entre** `antes` y `después`: es la notificación síncrona. No aparece ningún `build`.
- **Frame.** Solo `consumidor` se reconstruye. `propietario` y `no lee` no aparecen, y ese silencio es la mitad de la prueba.
- **Desmontaje.** Hijo antes que propietario.

Observa que esta traza no puede ver el `_handleUpdate` interno, y por eso `aviso` es de un listener nuestro, registrado en la misma señal. El paso del elemento del scope lo hemos seguido leyendo el código de Flutter, en los apartados 6 y 7, no observándolo aquí. Tampoco demuestra nada sobre colores ni píxeles (unidad 30).

### Practica 9

Añade `await tester.pump();` justo antes de `await tester.tap(...)`. ¿Cambia alguna línea de la traza? ¿Y si `NoLee` deja de ser `const`, tanto en su constructor como en su uso, pero `Propietario` no se reconstruye?

<details>
<summary>Ver respuesta</summary>

Con el `pump` no cambia nada: no hay trabajo pendiente, de modo que ese frame no ejecuta ningún `build`. Quitar `const` a `NoLee` tampoco cambia nada en esta traza: como `_PropietarioState.build` no se vuelve a ejecutar, la instancia hija es la misma. `const` solo protegería si el padre se reconstruyera (unidad 25).

</details>

## 10. Seis variantes

Resuelve cada una antes de abrir la solución. Para cada una, di hasta qué paso llega el recorrido, y qué pasos cambian. Son ejemplos independientes; cuando ejecutes uno, sustituye al anterior en `test/estudio_flujo_test.dart`.

### Variante 1: volver a asignar un tema equivalente

El controlador contiene `DaisyThemes.light` y recibe `DaisyThemes.light.copyWith()`. ¿Hasta qué paso llega? ¿Qué objeto contiene la señal? ¿Se programa un frame?

<details>
<summary>Ver solución</summary>

Llega hasta la comparación del apartado 5 y se detiene: `==` es verdadero. No se guarda el objeto nuevo, no hay aviso y no se programa ningún frame.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('un tema equivalente se detiene en la comparación', (
    tester,
  ) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var avisos = 0;
    var builds = 0;
    void escuchar() => avisos++;
    controller.theme.addListener(escuchar);

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

    final copia = DaisyThemes.light.copyWith();
    expect(identical(copia, DaisyThemes.light), isFalse);
    expect(copia, DaisyThemes.light);

    controller.setTheme(copia);

    expect(avisos, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(identical(controller.theme.value, DaisyThemes.light), isTrue);

    await tester.pump();
    expect(builds, 1);
    controller.theme.removeListener(escuchar);
  });
}
```

Se trata de un detalle útil: si dos modelos son iguales según `==` pero se diferencian en algo que no está en `props`, ese cambio se pierde sin ninguna señal de error. Es la razón por la que la unidad 29 insiste en mantener `props`.

</details>

### Variante 2: cambiar la vista previa manteniendo el tema global

La aplicación tiene un scope global y, dentro, uno de vista previa. Se cambia solo la vista previa. ¿Qué elementos reciben aviso? ¿Qué consumidores se reconstruyen? ¿Qué señales cambian?

<details>
<summary>Ver solución</summary>

Cambia una señal, la del controlador de la vista previa. Sus listeners son los de ese scope, de modo que el elemento del scope global no recibe ningún aviso, y sus dependientes no aparecen en la lista recorrida. La señal global no se ha tocado.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('la vista previa cambia sola', (tester) async {
    final preview = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(preview.dispose);
    final builds = <String, int>{'global': 0, 'preview': 0};

    Widget lector(String nombre) => Builder(
      builder: (context) {
        builds[nombre] = builds[nombre]! + 1;
        return Text('$nombre:${context.daisyTheme.id}');
      },
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          child: Column(
            children: [
              lector('global'),
              DaisyThemeScope(controller: preview, child: lector('preview')),
            ],
          ),
        ),
      ),
    );

    preview.setTheme(DaisyThemes.dark);
    await tester.pump();

    expect(find.text('global:light'), findsOneWidget);
    expect(find.text('preview:dark'), findsOneWidget);
    expect(builds, {'global': 1, 'preview': 2});
    expect(DaisyThemeService.theme.value, DaisyThemes.light);
  });
}
```

Si cambias el servicio global, ocurre lo simétrico: la vista previa no se entera, ni siquiera estando dentro del scope global, porque su consumidor depende del scope más cercano.

</details>

### Variante 3: pasar el mismo controlador a dos scopes

Dos scopes hermanos reciben el mismo controlador. Hay un solo `setTheme`. ¿Cuántas señales hay? ¿Cuántos listeners del tipo `_handleUpdate`? ¿Quién libera el controlador, y cuántas veces?

<details>
<summary>Ver solución</summary>

Hay una señal y un adaptador, pero dos elementos de scope, cada uno con su propio `_handleUpdate`. Aunque tengan el mismo nombre, son métodos de dos objetos distintos, así que la señal los guarda como dos listeners, y el mapa no los confunde. Por tanto, un `setTheme` avisa a los dos, y cada uno notifica a sus dependientes. Lo libera su único propietario, una sola vez; los dos scopes solo retiran su escucha.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('dos scopes con el mismo controlador', (tester) async {
    final compartido = DaisyThemeController();
    addTearDown(compartido.dispose);
    final builds = <String, int>{'a': 0, 'b': 0};

    Widget lector(String nombre) => Builder(
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
            DaisyThemeScope(controller: compartido, child: lector('a')),
            DaisyThemeScope(controller: compartido, child: lector('b')),
          ],
        ),
      ),
    );

    compartido.setTheme(DaisyThemes.dark);
    await tester.pump();

    expect(find.text('a:dark'), findsOneWidget);
    expect(find.text('b:dark'), findsOneWidget);
    expect(builds, {'a': 2, 'b': 2});
  });
}
```

</details>

### Variante 4: sustituir un controlador por otro

Un scope pasa de recibir `primero` a recibir `segundo`. Nadie llama a `setTheme`. ¿Se reconstruye el consumidor? ¿Por qué camino? Después, ¿qué ocurre si cambia `primero`?

<details>
<summary>Ver solución</summary>

Sí se reconstruye, aunque ninguna señal haya cambiado. El padre reconstruye el scope con otro `notifier`, y Flutter llama a `update` en el mismo elemento:

1. `update` compara y ve dos notifiers distintos: retira `_handleUpdate` del primero y lo añade al segundo.
2. `updateShouldNotify` es verdadero porque `oldWidget.notifier != notifier`, así que notifica a los dependientes.

Es el mismo final con otro origen: no pasa por `_dirty`. Después, un cambio en `primero` no llega a nadie: ya no se le escucha. Los dos controladores siguen vivos, y el propietario de cada uno debe liberarlos.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sustituir la fuente del scope', (tester) async {
    final primero = DaisyThemeController();
    final segundo = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(primero.dispose);
    addTearDown(segundo.dispose);
    var builds = 0;
    final hijo = Builder(
      builder: (context) {
        builds++;
        return Text(context.daisyTheme.name);
      },
    );

    Widget arbol(DaisyThemeController controller) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(controller: controller, child: hijo),
    );

    await tester.pumpWidget(arbol(primero));
    expect(find.text('Light'), findsOneWidget);

    await tester.pumpWidget(arbol(segundo));
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, 2);

    primero.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, 2);

    segundo.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(find.text('Cupcake'), findsOneWidget);
    expect(builds, 3);
  });
}
```

El `hijo` es la misma instancia en los dos árboles: su reconstrucción viene de la notificación, no de un widget nuevo.

</details>

### Variante 5: consultar el tema con un contexto sin scope ancestro

Hay dos casos: un árbol sin ningún scope, y un `build` que **crea** el scope y usa su propio `context` para leer. ¿En qué línea se separan del recorrido normal?

<details>
<summary>Ver solución</summary>

En la comprobación de `of`: `dependOnInheritedWidgetOfExactType` devuelve `null`, no se registra ninguna dependencia y se lanza `FlutterError`. En el segundo caso, el contexto de ese `build` pertenece al widget que crea el scope, por lo que el scope está **debajo** de él, no encima (unidad 20). Se corrige con un `Builder` o con un widget aparte, que aporte un contexto situado por debajo.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class CreaYLee extends StatelessWidget {
  const CreaYLee({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = context.daisyTheme;
    return DaisyThemeScope(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(tema.name),
      ),
    );
  }
}

void main() {
  testWidgets('sin ningún scope', (tester) async {
    await tester.pumpWidget(
      Builder(builder: (context) => Text(context.daisyTheme.name)),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(
      error.toString(),
      'Coloca DaisyThemeScope por encima de este widget.',
    );
  });

  testWidgets('el contexto que crea el scope está encima', (tester) async {
    await tester.pumpWidget(const CreaYLee());
    expect(tester.takeException(), isA<FlutterError>());
  });
}
```

</details>

### Variante 6: conservar una lectura antigua

Guardas `final antigua = controller.theme.value;`, cambias el tema y comparas. ¿Qué contiene `antigua`? Ahora, usa la closure del botón de la unidad 25: si el usuario lo pulsa **dos veces antes del siguiente frame**, ¿qué tema queda?

<details>
<summary>Ver solución</summary>

`antigua` sigue siendo `light`. Es una referencia obtenida en un momento concreto, y el modelo no se modifica, sino que se sustituye (unidades 1 y 8).

La segunda pregunta es más interesante. Las dos pulsaciones ejecutan la misma closure, con la misma variable `theme`, la lectura del último `build`, porque todavía no hay otra. Así que las dos proponen `dark`. La segunda es igual que el valor actual, y se detiene en la comparación. **El tema queda en `dark`, y no vuelve al inicial.** Si la closure leyera `controller.theme.value`, vería el valor actual, y alternaría correctamente.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('una lectura guardada no cambia', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    final antigua = controller.theme.value;
    controller.setTheme(DaisyThemes.dark);

    expect(antigua, DaisyThemes.light);
    expect(controller.theme.value, DaisyThemes.dark);
    expect(identical(antigua, DaisyThemes.light), isTrue);
  });

  Widget botones(
    DaisyThemeController controller, {
    required bool leerAlPulsar,
  }) {
    return MaterialApp(
      home: DaisyThemeScope(
        controller: controller,
        child: Builder(
          builder: (context) {
            final leido = context.daisyTheme;
            return ElevatedButton(
              onPressed: () {
                final actual = leerAlPulsar ? controller.theme.value : leido;
                controller.setTheme(
                  actual.id == DaisyThemes.light.id
                      ? DaisyThemes.dark
                      : DaisyThemes.light,
                );
              },
              child: Text(leido.name),
            );
          },
        ),
      ),
    );
  }

  testWidgets('dos pulsaciones con la lectura del build', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(botones(controller, leerAlPulsar: false));

    await tester.tap(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(controller.theme.value, DaisyThemes.dark);
    expect(find.text('Dark'), findsOneWidget);
  });

  testWidgets('dos pulsaciones leyendo el valor actual', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(botones(controller, leerAlPulsar: true));

    await tester.tap(find.byType(ElevatedButton));
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(controller.theme.value, DaisyThemes.light);
    expect(find.text('Light'), findsOneWidget);
  });
}
```

Las dos versiones son correctas para lo que hacen, y entre frames casi nunca hay dos pulsaciones reales. Lo importante es saber cuál de las dos lecturas estás usando: la del `build` para **mostrar**, y la de `.value` para **decidir** en el momento.

</details>

## Ejercicio final: explica el recorrido sin mirar

Cierra esta guía y deja abiertos solo los [archivos de `lib/`](../../../lib/themes/application/) y la aplicación de la unidad 25. Sin mirar los apartados anteriores:

1. Escribe los diez pasos del cambio de `Switch preview theme`, de `Cupcake` a `Dark`, en orden. En cada paso, di **qué objeto actúa, qué llamada hace y en qué archivo está**.
2. Marca con una señal los pasos que ocurren **una sola vez, al preparar**, y con otra los que ocurren **en cada cambio**.
3. Indica en qué paso se responden las cuatro preguntas: quién conserva el dato, quién registra la dependencia, quién avisa y quién solicita reconstruir.
4. Busca en tu texto las palabras «automáticamente», «reacciona», «se actualiza solo» o «Flutter se encarga». Cada vez que aparezca una, sustitúyela por el objeto y la llamada que corresponda.

<details>
<summary>Ver solución</summary>

**Preparación, una sola vez:**

1. `_ThemePreviewState.initState` crea `DaisyThemeController(initialTheme: cupcake)`, y su lista de inicialización crea `FlutterSignal`. *Quién conserva el dato:* la señal `_palette`. `daisy_theme_controller.dart`.
2. La primera lectura de `_controller.theme`, en el constructor del scope, crea mediante `late final` el adaptador `_ThemeListenable`. `daisy_theme_controller.dart`.
3. Flutter crea el elemento del scope para ese widget. Su constructor llama a `adaptador.addListener(_handleUpdate)`, que lo reenvía a `señal.addListener`, y esta crea una suscripción interna. `inherited_notifier.dart`, `daisy_theme_controller.dart` y `value_notifier.dart` de `signals_flutter`.
4. El `build` del `Builder` lee `context.daisyTheme`, que llama a `DaisyThemeScope.of`, y `dependOnInheritedWidgetOfExactType` añade ese elemento a los dependientes del scope. *Quién registra la dependencia:* el consumidor, al hacer esa llamada. Después, `scope.notifier!.value` obtiene `cupcake`. `build_context.dart` y `daisy_theme_scope.dart`.

**En cada cambio:**

5. Flutter reconoce la pulsación y ejecuta la closure `onPressed`, que usa el `theme` leído en el último `build` y llama a `_controller.setTheme(DaisyThemes.dark)`.
6. `setTheme` asigna `_palette.value`. El setter de la señal compara con `==`, que es el de Equatable. Si son iguales, termina aquí. Si no, guarda `dark`. `signal.dart` de `signals_core`.
7. *Quién avisa:* la señal, que ejecuta su suscripción interna, y esta llama a `_handleUpdate`, de forma síncrona. `_handleUpdate` pone `_dirty = true` y llama a `markNeedsBuild`, lo que programa un frame. `setTheme` termina después de esto.
8. En el frame, el elemento del scope se reconstruye: como `_dirty` es verdadero, llama a `notifyClients`, que llama a `didChangeDependencies` en cada dependiente, y estos se marcan para reconstruirse. *Quién solicita reconstruir:* el elemento del scope. Devuelve el mismo `child`, y el resto del subárbol no se reconstruye por eso.
9. El `Builder` se reconstruye y vuelve a leer `context.daisyTheme`, obteniendo `dark`. Crea un `Container` y un `Text` con esos tokens, y una closure nueva. Flutter hace después el trazado y el pintado de lo que cambió.

**Al terminar, una sola vez:**

10. Al desmontar, el `Builder` deja de ser dependiente; el elemento del scope llama a `removeListener(_handleUpdate)`, reenviado a la señal; y `_ThemePreviewState.dispose`, como propietario y por encima del scope, llama a `_controller.dispose()`, que libera la señal. El scope no libera nada: está prestado.

Si tu explicación tiene estos objetos y llamadas, aunque con otras palabras, está bien. Si fallaste en un paso concreto, repasa: pasos 1–2 en las unidades 14–16; paso 3 en la 22; paso 4 en las 20, 21 y 23; pasos 5–6 en las 8, 9 y 27; pasos 7–9 en las 18 y 22; y paso 10 en las 13, 19 y 25.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Dónde vive el tema actual? ¿Cuántas copias hay de él? **Apartado 1.**
2. ¿Qué diferencia hay entre el objeto señal y el objeto adaptador? ¿Por qué `theme` devuelve siempre el mismo? **Apartado 2.**
3. ¿Qué objeto empieza a escuchar: el widget del scope o su elemento? ¿Cuándo? **Apartado 3.**
4. ¿Qué dos cosas hace `dependOnInheritedWidgetOfExactType`? ¿Sabe la señal qué widgets leen el tema? **Apartado 4.**
5. ¿Quién decide si un cambio merece un aviso, y usando qué comparación? **Apartado 5.**
6. Cuando `setTheme` devuelve el control, ¿qué ha pasado ya y qué no? **Apartados 6 y 7.**
7. ¿Qué hace `_handleUpdate`? ¿Reconstruye el consumidor? ¿Quién llama a `didChangeDependencies`? **Apartados 6 y 7.**
8. ¿Por qué no se reconstruye el subárbol completo del scope? **Apartado 7.**
9. ¿Qué retira el scope al desmontarse y qué libera el propietario? ¿En qué orden? **Apartado 8.**
10. ¿Puedes resolver las seis variantes indicando en qué paso se separan del recorrido normal? **Apartado 10.**

Puedes dar la unidad por comprendida cuando expliques cada objeto, valor, relación y llamada sin decir «ocurre automáticamente». Con esto termina el recorrido principal del plan. La [unidad 32](32-imports-exports-y-limites-del-paquete.md) es un complemento: cómo otra aplicación consume todo esto.

## Para consultar si necesitas reforzar

- [Unidad 22](22-inherited-notifier-unir-avisos-y-dependencias.md): del aviso a la dependencia, con más detalle.
- [Unidad 25](25-scopes-anidados-e-independencia.md): la aplicación completa y los escenarios de varios scopes.
- [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html): referencia oficial.
- [Documentación de Signals](https://dartsignals.dev/): contrasta lo que leas con la versión instalada.
- [Pruebas de scopes](../../../test/themes/daisy_theme_scope_test.dart): muchas de estas variantes, comprobadas en el propio proyecto.

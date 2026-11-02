# 13. Propiedad de los recursos y `dispose`

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 12](12-efectos-y-suscripciones.md) · **Estado:** pendiente

## Qué vas a aprender

Imagina una vista previa que utiliza un controlador de tema. La vista desaparece de la pantalla, pero otra parte de la aplicación todavía quiere utilizar ese mismo controlador. Si la vista lo libera simplemente porque lo estaba usando, la otra parte se queda con un recurso terminado. En cambio, si la vista deja registrado un listener que ya no necesita, ese listener seguirá recibiendo avisos.

Al terminar podrás identificar quién crea o recibe un recurso, quién decide el final de su vida y quién debe retirar una escucha concreta. Practicarás cómo desmontar un consumidor, reutilizar un controlador y liberarlo cuando su propietario termine. También distinguirás la parada de un efecto de la liberación de una señal y verás qué cambia `autoDispose`.

Los ejemplos completos son pruebas Flutter independientes. Copia **una cada vez** a `test/estudio_propiedad_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_propiedad_test.dart
```

Necesitas las dependencias ya resueltas. Antes de mirar cada `expect`, intenta predecir el resultado; después lee la explicación paso a paso. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar después con DaisyUI y el ejercicio final.

Usaremos `test` para comprobar objetos y callbacks, y `testWidgets` para montar un árbol controlado. Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Los detalles sobre registros y liberación se refieren a esas versiones.

## 1. Una referencia no decide quién es propietario

Un **recurso** es un objeto cuya vida o relaciones requieren gestión: por ejemplo, un controlador que conserva una señal o una suscripción que mantiene un callback registrado. Una **referencia** permite acceder al objeto, pero tenerla no indica quién debe liberarlo: dos variables pueden apuntar al mismo controlador.

Llamaremos **propietario** a la parte que, según el diseño acordado, es responsable de terminar la vida útil del recurso. Normalmente es quien lo crea para su propio uso, aunque esa responsabilidad también puede transferirse mediante un contrato claro. Un **consumidor** puede recibir el recurso prestado para leerlo o escucharlo sin asumir su liberación.

Una analogía: una biblioteca presta un libro a dos lectores. Que uno termine de leerlo no le autoriza a destruir el libro que el otro todavía utiliza. La analogía termina ahí: en memoria, varias partes comparten referencias a la vez y cada tipo tiene su propia API y sus condiciones para terminar su vida.

Con el controlador de DaisyUI se ven cuatro acciones distintas. Este es un **fragmento** con las cuatro llamadas:

```dart
final controller = DaisyThemeController(); // Crear
controller.theme.addListener(escuchar); // Escuchar
controller.theme.removeListener(escuchar); // Dejar de escuchar
controller.dispose(); // Liberar
```

1. `DaisyThemeController()` construye el controlador y su señal privada, `_palette`.
2. `controller.theme` es una vista de lectura que reenvía `addListener` a esa señal; así queda registrado el callback.
3. `removeListener` retira ese registro. El controlador sigue vivo y puede seguir cambiando.
4. `dispose` termina la vida de la señal. Lo llama el propietario cuando el controlador ya no se necesita.

Por eso un mismo consumidor puede ser dueño de **su suscripción** y usar prestado el controlador. Si hay varios consumidores, cada uno retira su propio registro; el propietario coordina el final del controlador con todos ellos.

### Practica 1

Una vista recibe un controlador creado por otra parte y registra un listener. ¿De qué es responsable al terminar?

<details>
<summary>Ver respuesta</summary>

De retirar la escucha que registró. El controlador es prestado: su propietario decide cuándo liberarlo, teniendo en cuenta a los demás consumidores.

</details>

## 2. Dos consumidores de una misma fuente

Vamos a comprobar esa separación con dos listeners sobre un solo controlador. Registramos ambos, cambiamos el tema a `dark`, retiramos el primero y cambiamos a `cupcake`.

**Antes de mirar los `expect`**, predice qué nombres guarda cada lista y cuál es el valor actual al terminar.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dos consumidores y una fuente compartida', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    final primero = <String>[];
    final segundo = <String>[];
    void escucharPrimero() => primero.add(controller.theme.value.name);
    void escucharSegundo() => segundo.add(controller.theme.value.name);

    controller.theme.addListener(escucharPrimero);
    controller.theme.addListener(escucharSegundo);
    addTearDown(() => controller.theme.removeListener(escucharSegundo));

    controller.setTheme(DaisyThemes.dark);
    controller.theme.removeListener(escucharPrimero);
    controller.setTheme(DaisyThemes.cupcake);

    expect(primero, ['Dark']);
    expect(segundo, ['Dark', 'Cupcake']);
    expect(controller.theme.value.name, 'Cupcake');
  });
}
```

El recorrido es:

1. Se crea el controlador y se registran los dos callbacks en la señal, a través de `controller.theme`.
2. El cambio a `dark` llama a ambos. Cada uno lee `controller.theme.value` y guarda `Dark`: el listener no recibe el valor como argumento.
3. Retirar `escucharPrimero` no retira `escucharSegundo` ni termina la vida del controlador.
4. El cambio a `cupcake` añade `Cupcake` solo a la segunda lista. El valor actual sigue disponible.
5. Al terminar la prueba, se retira el segundo listener y después se libera el controlador.

`addTearDown` registra una limpieza que se ejecuta aunque falle un `expect`, y las limpiezas corren en orden **inverso** al de registro. Registrar `controller.dispose` justo después de crear el controlador hace que sea lo último en ejecutarse: primero terminan los consumidores y después el propietario libera la fuente. Es el mismo orden que queremos en una aplicación.

### Practica 2

¿Qué pasa con el segundo listener cuando se retira el primero? Y si `addTearDown(controller.dispose)` se registrara después del `addTearDown` que retira `escucharSegundo`, ¿qué limpieza se ejecutaría primero?

<details>
<summary>Ver respuesta</summary>

El segundo sigue registrado y recibe `Cupcake`: retirar una escucha no elimina las demás. Si se invierte el orden de registro, `dispose` se ejecutaría primero y el consumidor se retiraría de una fuente ya terminada. Por eso conviene registrar la limpieza del propietario justo al crear el recurso.

</details>

## 3. Registrar dos veces: cada implementación tiene su política

`removeListener` necesita la misma función que se entregó a `addListener`. ¿Qué ocurre si registramos **dos veces** la misma función? En la unidad 5 vimos que `ChangeNotifier` cuenta cada registro, y en la unidad 9 que una señal no crea dos entradas. Ahora lo comparamos con el mismo código.

**Antes de mirar los `expect`**, predice cuántos avisos habrá en cada prueba después del primer cambio y después de retirar una vez. En la tercera prueba, ¿retira algo la función anónima nueva?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ValueNotifier: cada alta cuenta', () {
    final fuente = ValueNotifier<int>(0);
    addTearDown(fuente.dispose);
    var avisos = 0;
    void escuchar() => avisos++;

    fuente.addListener(escuchar);
    fuente.addListener(escuchar);
    fuente.value = 1;
    expect(avisos, 2);

    fuente.removeListener(escuchar);
    fuente.value = 2;
    expect(avisos, 3);

    fuente.removeListener(escuchar);
    fuente.value = 3;
    expect(avisos, 3);
  });

  test('controlador: la misma función deja un registro', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var avisos = 0;
    void escuchar() => avisos++;

    controller.theme.addListener(escuchar);
    controller.theme.addListener(escuchar);
    controller.setTheme(DaisyThemes.dark);
    expect(avisos, 1);

    controller.theme.removeListener(escuchar);
    controller.setTheme(DaisyThemes.light);
    expect(avisos, 1);
  });

  test('una función anónima nueva no retira la registrada', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    var avisos = 0;

    controller.theme.addListener(() => avisos++);
    controller.theme.removeListener(() => avisos++);
    controller.setTheme(DaisyThemes.dark);
    expect(avisos, 1);
  });
}
```

Las dos primeras pruebas registran dos veces y retiran una, pero terminan de forma distinta:

1. `ValueNotifier` conserva los dos registros. Un cambio produce dos llamadas; tras una retirada queda un registro, que añade el tercer aviso; hace falta otra retirada para dejar de recibirlos.
2. La señal del controlador guarda sus listeners en un mapa cuya clave es la función. El segundo `addListener` encuentra la entrada existente y no añade otra. Un cambio produce un aviso y una sola retirada la quita.
3. En la tercera prueba, las dos expresiones `() => avisos++` crean funciones distintas aunque su texto coincida. Retirar la segunda no encuentra nada y la primera sigue registrada. Como no conservamos ninguna referencia a ella, ya no podemos retirarla; solo termina cuando se libera la señal.

La identidad de la función importa en ambas implementaciones. La política de duplicados, en cambio, pertenece a cada una, y por eso conviene no depender de ella: guarda la función en una variable o declárala con nombre, y empareja cada alta con su retirada.

### Practica 3

Un consumidor registra `escuchar` dos veces por error, en una fuente cuyo tipo declarado es `ValueListenable`, y lo retira una vez. ¿Puedes saber con ese tipo si seguirá recibiendo avisos?

<details>
<summary>Ver respuesta</summary>

No: el contrato `ValueListenable` no fija la política de duplicados. Con un `ValueNotifier` quedaría un registro; con la señal del controlador, ninguno. La solución no es averiguar la implementación ni liberar la fuente, sino emparejar cada alta con su retirada, sin registrar dos veces.

</details>

## 4. Qué significa `dispose`

`dispose` es una operación definida por cada tipo para terminar su uso y liberar o desconectar lo que administra. No es una instrucción general de Dart y no borra el objeto de la memoria: mientras queden referencias sigue siendo alcanzable. La recogida de memoria y la limpieza explícita son asuntos distintos. Por eso hay que consultar el contrato de cada tipo.

`DaisyThemeController.dispose()` delega en el `dispose()` de su `FlutterSignal`. Veamos qué ocurre.

**Antes de mirar los `expect`**, predice si el listener recibe un último aviso al liberar y qué ocurre si se intenta cambiar el tema después.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('un controlador liberado no admite cambios', () {
    final controller = DaisyThemeController();
    var avisos = 0;
    void escuchar() => avisos++;
    controller.theme.addListener(escuchar);

    controller.dispose();
    expect(avisos, 0);
    expect(
      () => controller.setTheme(DaisyThemes.dark),
      throwsA(isA<SignalsWriteAfterDisposeError>()),
    );
    expect(avisos, 0);

    controller.theme.removeListener(escuchar);
    controller.dispose();
  });
}
```

1. Liberar no avisa: el tema no ha cambiado y `avisos` sigue en 0. La señal también vacía su registro de listeners.
2. `setTheme` intenta escribir en la señal liberada y esta lanza `SignalsWriteAfterDisposeError`. `throwsA` comprueba que la función lanza un error de ese tipo. La escritura no llega a producir ningún aviso.
3. Retirar el listener después no lanza; simplemente no encuentra el registro.
4. Un segundo `dispose()` tampoco lanza: la señal comprueba si ya estaba liberada y retorna.

Hay una operación que parece seguir funcionando: leer `controller.theme.value` devuelve el último valor e imprime una advertencia en modo depuración. No lo conviertas en una regla: un controlador liberado ya no es una fuente activa.

Compáralo con el [`ChangeNotifier`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html) de la unidad 5. Los dos coinciden en lo importante: solo debe llamarlo el propietario, no emiten un último aviso y dejan de ser utilizables. Pero los detalles difieren: `ChangeNotifier` usa comprobaciones de depuración, de modo que un segundo `dispose()` se detecta como error en ese modo. Cada tipo fija sus condiciones; que una llamada no lance no la convierte en un buen diseño.

El orden correcto también se mantiene cuando hay widgets: primero se desmonta el consumidor y después se libera la fuente. Liberarla antes no lanzó en las secuencias que probamos, pero dejaría un scope montado sobre una fuente terminada, sin que nadie pueda cambiar el tema que muestra.

### Practica 4

¿Es lo mismo retirar tu listener que liberar el controlador? ¿Llamar a `controller.dispose()` borra el objeto de la memoria o envía un último aviso?

<details>
<summary>Ver respuesta</summary>

No es lo mismo: retirar tu listener conserva la fuente y las demás escuchas; liberar termina la fuente para todos. Y no hace ninguna de las dos cosas: no hay aviso final y la memoria la gestiona otro mecanismo, cuando el objeto deja de ser alcanzable.

</details>

## 5. Detener un efecto no libera su señal

En la unidad 12, `effect` devolvía una función para detener **esa observación**. La señal que el efecto lee puede compartirse con otros consumidores y vivir más tiempo; su propietario decide cuándo llamar a `dispose`. Del mismo modo, la función que devuelve `subscribe` cancela esa suscripción y nada más.

**Antes de mirar los `expect`**, predice qué contiene el registro y cuánto valen `tema.disposed` y `tema.value` antes de liberar la señal. `disposed` es un getter de Signals que indica si la señal ya se liberó.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('detener un efecto no libera su señal', () {
    final tema = signal('claro');
    final registro = <String>[];
    final detener = effect(() {
      registro.add(tema.value);
    });

    tema.value = 'oscuro';
    detener();
    tema.value = 'bosque';

    expect(registro, ['claro', 'oscuro']);
    expect(tema.disposed, isFalse);
    expect(tema.value, 'bosque');

    tema.dispose();
    expect(tema.disposed, isTrue);
  });
}
```

1. Al crearse, el efecto se ejecuta y registra `claro`; el cambio a `oscuro` lo ejecuta otra vez.
2. `detener()` termina la observación. El cambio a `bosque` ya no añade ninguna entrada.
3. La señal sigue activa: `disposed` es `false` y `.value` devuelve `bosque`.
4. Solo cuando el test, que creó la señal, llama a `tema.dispose()`, `disposed` pasa a `true`.

### Practica 5

Dos efectos observan la misma señal y uno de ellos ya no es necesario. ¿Qué llamada corresponde a ese consumidor? ¿Por qué no debería llamar a `tema.dispose()`?

<details>
<summary>Ver respuesta</summary>

Debe llamar a su función de parada, que termina solo su observación. `tema.dispose()` terminaría la fuente también para el otro efecto y para cualquier código que quiera escribir en ella. Esa decisión corresponde al propietario de la señal.

</details>

## 6. `autoDispose`: una regla diferente y explícita

Signals permite configurar una señal con `SignalOptions(autoDispose: true)`. Con esta opción, la señal se libera cuando se retira su **última** suscripción activa. Es otra forma de acordar su vida útil: no significa que todos los recursos se liberen solos ni que una señal sin observadores se libere al crearla.

**Antes de mirar los `expect`**, parte de una señal con `autoDispose: true` y dos suscripciones. ¿Cuándo pasa `disposed` a `true`?

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('autoDispose y último observador', () {
    final tema = signal(
      'claro',
      options: const SignalOptions(autoDispose: true),
    );
    final uno = tema.subscribe((_) {});
    final dos = tema.subscribe((_) {});
    expect(tema.disposed, isFalse);

    uno();
    expect(tema.disposed, isFalse);

    dos();
    expect(tema.disposed, isTrue);
  });
}
```

`options: const SignalOptions(...)` crea un objeto de opciones y se lo entrega a `signal`. `subscribe` devuelve una función de cancelación, como practicamos en la unidad 12. Al cancelar `uno` queda otro observador y la señal sigue viva. Al cancelar `dos` se retira el último y la señal se libera; por eso el test no llama a `dispose` ni la reutiliza después.

La comparación con el apartado 5 muestra el cambio: con las opciones predeterminadas, retirar observadores no libera la señal. Con `autoDispose`, retirar el último transfiere esa decisión a la propia señal, y quien quiera seguir usando la fuente debe saberlo. DaisyUI no usa esta opción: su controlador se crea con las opciones predeterminadas y puede quedarse sin observadores y volver a utilizarse, como veremos a continuación.

### Practica 6

En la prueba cancelamos una de dos suscripciones de una señal con `autoDispose: true`. ¿Se libera ya? ¿Qué ocurriría con esa misma secuencia si la señal usara las opciones predeterminadas?

<details>
<summary>Ver respuesta</summary>

No se libera todavía, porque sigue existiendo otra suscripción; se libera al cancelar la última. Con las opciones predeterminadas, cancelar las dos no la libera: `disposed` seguiría en `false` hasta que su propietario llamara a `dispose`.

</details>

## 7. El controlador real de DaisyUI

En [daisy_theme_controller.dart](../../../lib/themes/application/daisy_theme_controller.dart) encontramos este **fragmento**:

```dart
DaisyThemeController({
  DaisyThemeModel initialTheme = DaisyThemes.light,
}) : _palette = FlutterSignal<DaisyThemeModel>(initialTheme);

final FlutterSignal<DaisyThemeModel> _palette;

late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(
  _palette,
);

ValueListenable<DaisyThemeModel> get theme => _theme;

void dispose() => _palette.dispose();
```

Veamos qué objeto cumple cada papel. La sintaxis del constructor y de `late final` se estudia en las unidades 15 y 16.

1. **El controlador** crea y conserva la señal `_palette`, y administra su vida: su `dispose` delega en el de la señal.
2. **La vista `theme`** es un `_ThemeListenable`, un adaptador que lee la señal y le reenvía `addListener` y `removeListener`. No guarda listeners ni otros recursos propios, así que no se libera por separado y no tiene `dispose`.
3. **El [scope](../../../lib/themes/application/daisy_theme_scope.dart)** recibe un controlador opcional y pasa `controller?.theme ?? DaisyThemeService.theme` a `InheritedNotifier`. Usa esa vista **prestada**: ni crea el controlador ni llama a su `dispose`. Flutter registra la escucha del `InheritedNotifier` mientras el scope está montado y la retira al sustituir su fuente o al desmontarlo.
4. **El [servicio](../../../lib/themes/application/daisy_theme_service.dart)** conserva su propio controlador estático, que usa el scope cuando no recibe otro. No debes liberarlo desde un consumidor, y el servicio tampoco expone un método público para hacerlo. Lo estudiaremos en la unidad 17.
5. **`_ThemePreviewState`**, de la versión del ejemplo anterior al commit `41fe41f` (puedes consultarla con `git show 41fe41f~1:example/lib/main.dart`, y está reproducida en el [apartado 8 de la unidad 25](25-scopes-anidados-e-independencia.md#8-el-ejemplo-anterior-completo)), crea su controlador en `initState`, se lo entrega al scope y llama a `_controller.dispose()` en su propio `dispose`. Es propietario del controlador que creó. El ciclo de vida de `State` se estudia en las unidades 18 y 19.

Escuchar no transfiere la propiedad. Comprobémoslo desmontando un scope y reutilizando su controlador.

**Antes de mirar los `expect`**, predice qué nombre se muestra al volver a montar y quién libera el controlador.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('desmontar, reutilizar y volver a montar', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    Widget pantalla() => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        controller: controller,
        child: Builder(builder: (context) => Text(context.daisyTheme.name)),
      ),
    );

    await tester.pumpWidget(pantalla());
    expect(find.text('Light'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    controller.setTheme(DaisyThemes.dark);

    await tester.pumpWidget(pantalla());
    expect(find.text('Dark'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

1. `pumpWidget` monta el primer árbol y se muestra `Light`.
2. Sustituirlo por `SizedBox.shrink()` desmonta el scope y su consumidor. Termina la escucha del scope, no el controlador.
3. El test conserva el controlador y cambia su tema a `dark`. No hay ningún scope escuchando, pero la señal sigue viva.
4. Un nuevo árbol lee el valor actual y muestra `Dark`.
5. Desmontamos el segundo árbol al final del cuerpo de la prueba y, después, `addTearDown` libera el controlador.

La prueba muestra que el recorrido permite reutilizar el controlador. No demuestra cada llamada interna de Flutter ni un repintado en un dispositivo; para entender quién gestiona la escucha hay que leer el código y el contrato de `InheritedNotifier`, que estudiaremos en la unidad 22.

### Practica 7

En la prueba, ¿quién creó el controlador? ¿Qué relación termina al desmontar el scope? ¿Quién lo libera y cuándo?

<details>
<summary>Ver respuesta</summary>

Lo creó el test, que además es su propietario. Al desmontar termina la escucha del scope, gestionada por Flutter, pero no la vida del controlador; por eso se puede volver a montar con él. El test lo libera al final, después de desmontar el último scope.

</details>

## 8. Sustituir una fuente prestada

Un consumidor puede pasar de observar una fuente a observar otra. La regla es retirar su relación con la anterior y establecerla con la nueva, sin liberar ninguna si son prestadas. Un widget que registre listeners a mano debe contemplar esa sustitución; Flutter documenta `initState`, `didUpdateWidget` y `dispose` como los lugares habituales para hacerlo, y los estudiaremos en la unidad 19. Aquí usaremos el scope real, que ya gestiona su propia escucha.

Montamos el scope con `primero` (`Light`) y lo actualizamos con `segundo` (`Dark`). Después cambiamos `primero` a `Cupcake` y `segundo` a `Light`, procesando un frame tras cada cambio.

**Antes de mirar los `expect`**, predice qué cambios reconstruyen el consumidor en este árbol aislado y quién libera los controladores.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('sustituir un controlador prestado', (tester) async {
    final primero = DaisyThemeController();
    final segundo = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(primero.dispose);
    addTearDown(segundo.dispose);
    var builds = 0;
    final consumidor = Builder(
      builder: (context) {
        builds++;
        return Text(context.daisyTheme.name);
      },
    );

    Widget pantalla(DaisyThemeController controller) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(controller: controller, child: consumidor),
    );

    await tester.pumpWidget(pantalla(primero));
    await tester.pumpWidget(pantalla(segundo));
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, 2);

    primero.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(builds, 2);

    segundo.setTheme(DaisyThemes.light);
    await tester.pump();
    expect(find.text('Light'), findsOneWidget);
    expect(builds, 3);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

1. El primer montaje y la sustitución producen dos construcciones y se muestra `Dark`. El mismo objeto `consumidor` se reutiliza entre los dos árboles; lo que cambia es el scope que tiene encima.
2. Cambiar `primero` no incrementa el contador: sigue vivo, pero ya no es la fuente de este scope.
3. Cambiar `segundo` sí: tras `pump` aparece `Light`, con tres construcciones.
4. El test desmonta el árbol y después `addTearDown` libera los dos controladores. El scope no liberó ninguno al sustituirlo, porque ninguno era suyo.

La cifra de construcciones describe este árbol controlado; en otro árbol, un widget puede reconstruirse por otras causas.

### Practica 8

¿Por qué cambiar `primero` deja de reconstruir ese consumidor tras la sustitución? ¿Sería correcto que el scope liberara `primero` en ese momento?

<details>
<summary>Ver respuesta</summary>

El scope retiró su escucha de `primero` y pasó a escuchar la vista de `segundo`; `primero` sigue vivo, pero ya nadie de este árbol lo observa. No sería correcto liberarlo: es prestado, y su propietario, el test, podría volver a usarlo.

</details>

## Ejercicio final: un controlador que sobrevive a una vista

Escribe una prueba de widgets que:

1. Cree un controlador, cuyo tema inicial es `Light`, y registre su liberación.
2. Registre un callback manual que guarde los nombres recibidos en una lista, y monte un scope con el mismo controlador que muestre el nombre del tema.
3. Cambie el tema a `Dark` y procese un frame. Predice la lista y el texto visible.
4. Retire el callback manual y desmonte el scope. Cambie el tema a `Cupcake`: ¿puede seguir usándose el controlador? ¿Qué contiene ahora la lista?
5. Monte de nuevo un scope con el mismo controlador y compruebe el texto actual.
6. Desmonte el árbol y deje que el controlador se libere una sola vez.

Después explica quién poseía el controlador, quién poseía el registro manual y quién gestionaba la escucha del scope. Como variación, imagina un segundo consumidor manual que no se retira: ¿recibiría el cambio a `Cupcake`? ¿Qué habría que coordinar antes de liberar el controlador?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el controlador sobrevive a un consumidor', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    final avisos = <String>[];
    void escuchar() => avisos.add(controller.theme.value.name);

    Widget pantalla() => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        controller: controller,
        child: Builder(builder: (context) => Text(context.daisyTheme.name)),
      ),
    );

    controller.theme.addListener(escuchar);
    await tester.pumpWidget(pantalla());

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(avisos, ['Dark']);
    expect(find.text('Dark'), findsOneWidget);

    controller.theme.removeListener(escuchar);
    await tester.pumpWidget(const SizedBox.shrink());
    controller.setTheme(DaisyThemes.cupcake);
    expect(avisos, ['Dark']);

    await tester.pumpWidget(pantalla());
    expect(find.text('Cupcake'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El test crea el controlador y es responsable de liberarlo; `addTearDown` lo hace una sola vez, después de desmontar. También registra y retira su callback manual, porque esa suscripción es suya. El scope recibe el controlador prestado y Flutter gestiona su escucha mientras está montado. Tras retirar el callback y desmontar, el controlador sigue admitiendo cambios: la lista conserva `['Dark']` y el nuevo scope lee `Cupcake`.

En la variación, el segundo consumidor sí recibiría `Cupcake`. Antes de liberar el controlador tendría que retirar su registro y dejar de necesitar la fuente; el propietario libera cuando ningún consumidor la usa.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué diferencia existe entre tener una referencia y ser propietario del recurso? **Apartado 1.**
2. ¿Puede un consumidor poseer su suscripción y usar prestada la fuente? Pon un ejemplo. **Apartado 1.**
3. ¿Por qué el segundo listener sigue recibiendo avisos tras retirar el primero? **Apartado 2.**
4. ¿En qué orden se ejecutan las limpiezas de `addTearDown` y por qué registramos pronto `controller.dispose`? **Apartado 2.**
5. ¿Qué ocurre al registrar dos veces la misma función en un `ValueNotifier` y en el controlador? ¿Y al retirar una función anónima nueva? **Apartado 3.**
6. ¿Qué hace y qué no hace `DaisyThemeController.dispose()` respecto a los listeners, las escrituras y la memoria? **Apartado 4.**
7. ¿Qué detiene `detener()` y cuándo se libera la señal de ese ejemplo? **Apartado 5.**
8. ¿Qué cambia `autoDispose` y qué ocurre al retirar el último observador? **Apartado 6.**
9. ¿Por qué `controller.theme` no se libera por separado? **Apartado 7.**
10. ¿Quién posee el controlador de `_ThemePreviewState` y qué papel desempeña `DaisyThemeScope`? **Apartado 7.**
11. ¿Qué demuestra volver a montar el scope y qué no demuestra? **Apartado 7.**
12. ¿Por qué cambiar la primera fuente deja de reconstruir el consumidor tras sustituirla? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques, para cada objeto, quién lo crea, quién lo usa prestado, quién retira cada escucha y quién lo libera. Con esta unidad termina el Bloque 3. El Bloque 4 empieza en la [unidad 14](14-el-concepto-de-controller.md), que estudia qué responsabilidades tiene un controlador.

## Para consultar si necesitas reforzar

- [`FlutterSignal`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html) y [`SignalOptions`](https://pub.dev/documentation/signals_core/latest/signals_core/SignalOptions-class.html): la señal que usa el controlador y la opción `autoDispose`. Compara `latest` con las versiones resueltas del proyecto.
- [`ChangeNotifier.dispose`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html) y [`removeListener`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/removeListener.html): el contrato con el que comparamos, incluidos los registros repetidos.
- [`State.dispose`](https://api.flutter.dev/flutter/widgets/State/dispose.html): limpieza de los recursos de un estado y sustitución de suscripciones; se estudia con detalle en la unidad 19.
- [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html): relación entre notifier, dependientes y cambios de fuente.
- [Controlador](../../../lib/themes/application/daisy_theme_controller.dart), [scope](../../../lib/themes/application/daisy_theme_scope.dart), [servicio](../../../lib/themes/application/daisy_theme_service.dart) y [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento actual del proyecto.

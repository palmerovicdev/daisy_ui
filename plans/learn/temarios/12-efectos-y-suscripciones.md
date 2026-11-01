# 12. Efectos y suscripciones

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 11](11-computed-estado-derivado.md) · **Estado:** pendiente

## Qué vas a aprender

Imagina que queremos guardar un registro cada vez que cambia el tema seleccionado. La unidad 11 calculaba un texto para
mostrarlo; ahora queremos **hacer una acción**: añadir una entrada a una lista. Esa acción tiene que ocurrir cuando
cambie el tema y también tiene que poder terminar.

Al terminar podrás crear un `effect`, predecir cuándo se ejecuta, limpiar lo que inicia cada ejecución y detenerlo.
Sabrás distinguir esa parada de la liberación de la señal, comparar `effect`, `subscribe` y `addListener`, y explicar
por separado un cálculo, un efecto y una reconstrucción de Flutter. Por último lo aplicaremos al controlador de DaisyUI.

Los ejemplos completos son pruebas Flutter independientes. Copia **una cada vez** a `test/estudio_efectos_test.dart` y
ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_efectos_test.dart
```

Necesitas las dependencias ya resueltas. Antes de mirar cada `expect`, intenta predecir el resultado; después lee la
explicación paso a paso. Los fragmentos identificados como tales no son archivos completos. La lista `registro`
sustituye a una acción externa para que podamos comprobar su orden. Puedes estudiar los apartados 1–3 en una sesión, 4–6
en otra y terminar después con los apartados 7–9 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0;
consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. El controlador actual de DaisyUI guarda el
tema en una señal, un `FlutterSignal`; aun así, su flujo de temas no necesita un `effect` propio. Veremos por qué en el
apartado 9.

## 1. Almacenar, calcular, actuar y mostrar

Supongamos que el tema actual es `claro`. Alrededor de ese dato pueden ocurrir cuatro trabajos diferentes:

1. **Almacenar:** una señal conserva el texto `claro` y permite cambiarlo.
2. **Calcular:** `computed(() => 'Tema: ${tema.value}')` describe cómo obtener `Tema: claro` a partir de la fuente.
3. **Actuar:** algo añade `claro` a un registro externo. Esa modificación es un **efecto secundario**: una acción
   observable fuera del cálculo de un valor.
4. **Mostrar:** un consumidor de Flutter observa el dato y participa en una reconstrucción de la interfaz.

`effect` se ocupa del tercer trabajo. Un cálculo responde a «¿qué valor sale de estos datos?»; un efecto responde a
«¿qué hay que hacer cuando estos datos cambian?». Un efecto real podría enviar datos a otro sistema o iniciar una
operación, pero esas acciones tienen sus propios problemas de errores, cancelación y orden. Añadir a una lista nos
permite estudiar la observación sin esconderlos.

Una analogía: un termómetro indica la temperatura y una fórmula la convierte a otra escala, pero apuntar cada cambio en
una libreta es un encargo aparte. La analogía no explica cómo se descubren las dependencias ni cuándo termina el
encargo; eso es lo que estudiaremos a continuación.

Si solo necesitas un dato derivado, es preferible un `computed` o una expresión a mantener otra señal sincronizada con
un efecto: así no hay dos datos que puedan contradecirse.

### Practica 1

Si solo quieres mostrar una etiqueta obtenida del tema, ¿qué piezas necesitas? ¿Hace falta una acción externa?

<details>
<summary>Ver respuesta</summary>

Necesitas obtener el texto y conectarlo con un consumidor de la interfaz. Una acción externa solo hace falta si además
quieres hacer algo como registrar o guardar el cambio. Calcular no ejecuta ese registro y registrar no dibuja el texto.

</details>

## 2. Crear, ejecutar y detener un `effect`

`effect` recibe una función sin argumentos: **el trabajo** que debe realizar. Devuelve otra función, también sin
argumentos, que termina la observación. Este fragmento muestra las dos; no es un programa completo:

```dart
final detener = effect(() {
  registro.add(tema.value);
});

// Más tarde:
detener();
```

Al crear el efecto, la versión instalada ejecuta el trabajo de inmediato. Durante esa ejecución, cada señal que se lee
queda registrada como dependencia, igual que vimos con `SignalBuilder` y `computed`. Si una dependencia cambia, el
trabajo se ejecuta otra vez. `detener` conserva la función de parada; `detener()` la ejecuta.

**Antes de mirar los `expect`**, predice qué contiene el registro en cada paso: el tema empieza en `claro`, creamos el
efecto, asignamos `oscuro` dos veces, lo detenemos y asignamos `bosque`. ¿Se puede seguir leyendo la señal?

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('ejecución inicial, cambios y parada', () {
    final tema = signal('claro');
    addTearDown(tema.dispose);
    final registro = <String>[];

    final detener = effect(() {
      registro.add(tema.value);
    });
    expect(registro, ['claro']);

    tema.value = 'oscuro';
    tema.value = 'oscuro';
    expect(registro, ['claro', 'oscuro']);

    detener();
    tema.value = 'bosque';
    expect(registro, ['claro', 'oscuro']);
    expect(tema.value, 'bosque');
  });
}
```

Paso a paso:

1. Al crear el efecto, el callback lee `claro` y lo añade. No espera al primer cambio.
2. La primera asignación de `oscuro` cambia el valor y el efecto se ejecuta de nuevo, antes de pasar a la línea
   siguiente.
3. La segunda asignación propone un valor igual. La señal lo descarta, como vimos en la unidad 9, y no hay otra
   ejecución.
4. `detener()` retira la observación de este efecto. Después, `bosque` no añade ninguna entrada.
5. La señal sigue viva y devuelve `bosque`. Detener no borra el registro ni libera la señal: al terminar, el test
   ejecuta `tema.dispose` porque fue quien la creó.

### Practica 2

En la prueba detenemos el efecto antes de escribir `bosque`. ¿Cuál es el valor actual de la señal? ¿Qué se añade al
registro? ¿Qué diferencia hay entre `detener()` y `tema.dispose()`?

<details>
<summary>Ver respuesta</summary>

La señal contiene `bosque` y el registro no recibe ninguna entrada. `detener()` termina la observación de este efecto;
`tema.dispose()` termina la vida de la señal. Otros consumidores podrían seguir usando la señal después de detener el
efecto, así que son decisiones distintas.

</details>

## 3. La limpieza de cada ejecución

A veces cada ejecución inicia algo que debe terminar antes de iniciar lo siguiente: por ejemplo, una escucha asociada al
tema actual. Para eso, el callback puede **devolver una función de limpieza**. La versión instalada la llama antes de
volver a ejecutar el callback y también cuando se detiene el efecto.

Hay por tanto dos funciones que no debemos confundir: la que devuelve el **callback** limpia una ejecución y la que
devuelve **`effect`** detiene el efecto completo.

**Antes de mirar el `expect`**, predice el orden de las entradas. Cada ejecución registra `abrir` con el tema actual y
devuelve una función que registra `cerrar` con ese mismo tema. Después cambiamos de `claro` a `oscuro` y detenemos.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('limpieza por ejecución y limpieza final', () {
    final tema = signal('claro');
    addTearDown(tema.dispose);
    final registro = <String>[];

    final detener = effect(() {
      final actual = tema.value;
      registro.add('abrir $actual');
      return () => registro.add('cerrar $actual');
    });
    tema.value = 'oscuro';
    detener();

    expect(registro, [
      'abrir claro',
      'cerrar claro',
      'abrir oscuro',
      'cerrar oscuro',
    ]);
  });
}
```

El recorrido es:

1. La primera ejecución guarda `claro` en `actual`, registra `abrir claro` y devuelve su limpieza.
2. Al cambiar el tema, primero se llama a esa limpieza: `cerrar claro`. Usa el `actual` que capturó su closure, aunque
   la señal ya contenga `oscuro`.
3. Se ejecuta otra vez el callback: `abrir oscuro`, con otra variable `actual` y otra limpieza.
4. `detener()` llama a la limpieza pendiente, `cerrar oscuro`, y termina la observación.

La lista solo simula abrir y cerrar; un recurso real necesita una API de cancelación apropiada. Si el trabajo iniciado
es asíncrono, detener el efecto no cancela por sí mismo un `Future` ni deshace una petición ya enviada: hay que diseñar
su cancelación o ignorar los resultados obsoletos. Ni la limpieza ni `detener` equivalen a `tema.dispose()`.

### Practica 3

Si el efecto se detiene sin haber cambiado el tema, ¿qué entrada añade la limpieza pendiente? ¿Por qué capturamos
`actual` en vez de leer `tema.value` al cerrar?

<details>
<summary>Ver respuesta</summary>

Añade `cerrar claro`, que corresponde a lo que abrió la primera ejecución. Capturamos `actual` porque la limpieza debe
cerrar lo que abrió **su** ejecución: cuando cambia el tema, una lectura en ese momento ya devolvería el valor nuevo y
registraría `cerrar oscuro` antes de haberlo abierto.

</details>

## 4. Qué lecturas se convierten en dependencias

El efecto no observa todas las señales que aparecen escritas en su código, sino las que **lee durante cada ejecución**.
Si una condición cambia de rama, la siguiente ejecución puede utilizar otras señales y el seguimiento se ajusta a ellas.

**Antes de mirar el `expect`**, predice qué valores guarda el efecto. `usarLocal` es verdadero, `local` vale `claro` y
`global` vale `oscuro`. Cambiaremos `global` a `bosque`, `local` a `nieve`, la condición a falso, `local` a `noche` y
`global` a `sol`.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('las dependencias cambian con la rama', () {
    final usarLocal = signal(true);
    final local = signal('claro');
    final global = signal('oscuro');
    addTearDown(usarLocal.dispose);
    addTearDown(local.dispose);
    addTearDown(global.dispose);
    final registro = <String>[];

    final detener = effect(() {
      registro.add(usarLocal.value ? local.value : global.value);
    });
    global.value = 'bosque';
    local.value = 'nieve';
    usarLocal.value = false;
    local.value = 'noche';
    global.value = 'sol';
    detener();

    expect(registro, ['claro', 'nieve', 'bosque', 'sol']);
  });
}
```

Paso a paso:

1. La primera ejecución lee `usarLocal` y `local`, y registra `claro`. Cambiar `global` a `bosque` no la repite.
2. Cambiar `local` a `nieve` sí provoca otra ejecución, que registra `nieve`.
3. Cambiar la condición provoca otra. Ahora se lee la rama global y se registra su valor actual, `bosque`.
4. Desde esa ejecución se siguen `usarLocal` y `global`: `noche` no provoca nada y `sol` se registra.

Igual que en las unidades 10 y 11, importa **cuándo** se lee. Este fragmento recibe un valor ya capturado y no registra
`local` como dependencia:

```dart
final nombre = local.value;
final detener = effect(() {
  registro.add(nombre);
});
```

Asimismo, una lectura posterior a un `await` no forma parte de la ejecución síncrona que estamos observando. Para
trabajo asíncrono, lee los datos necesarios antes del primer `await` y gestiona por separado errores, cancelación y
resultados tardíos.

### Practica 4

Después de pasar a la rama global, ¿qué sucede si cambiamos solo `local`? ¿Y si volvemos a poner `usarLocal` en
verdadero sin haber detenido el efecto?

<details>
<summary>Ver respuesta</summary>

Cambiar `local` no ejecuta el efecto: la última ejecución leyó `usarLocal` y `global`. Al poner `usarLocal` en
verdadero, se ejecuta porque esa condición sí se leyó; la nueva ejecución lee la rama local, registra su valor actual,
`noche`, y vuelve a seguir `local`.

</details>

## 5. `subscribe` y `addListener`

Una **suscripción** es la relación que mantiene activa una observación. Ya conocemos tres formas de crearla, y cada una
tiene su propia manera de terminar:

- `effect` rastrea las señales leídas durante su callback y devuelve la función que lo detiene.
- `senal.subscribe(callback)` observa esa señal concreta, entrega el valor como argumento, llama al callback una primera
  vez con el valor actual y devuelve una función para cancelar.
- `senal.addListener(listener)` es el contrato `ValueListenable` que implementa `FlutterSignal`. Registra una función
  sin argumentos, que lee `.value` si necesita el dato, y se retira con `removeListener`. Con las opciones
  predeterminadas, registrarla no la ejecuta.

**Antes de mirar los `expect`**, predice qué lista contiene `claro` antes de cambiar la señal. Después cambiamos a
`oscuro`, cancelamos las dos observaciones y cambiamos a `bosque`. ¿Qué listas quedan?

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('subscribe y addListener', () {
    final tema = signal('claro');
    addTearDown(tema.dispose);
    final suscripcion = <String>[];
    final avisos = <String>[];
    void escuchar() => avisos.add(tema.value);

    final cancelar = tema.subscribe(suscripcion.add);
    tema.addListener(escuchar);
    expect(suscripcion, ['claro']);
    expect(avisos, isEmpty);

    tema.value = 'oscuro';
    cancelar();
    tema.removeListener(escuchar);
    tema.value = 'bosque';

    expect(suscripcion, ['claro', 'oscuro']);
    expect(avisos, ['oscuro']);
  });
}
```

Paso a paso:

1. `subscribe` llama de inmediato a `suscripcion.add` con `claro`. `addListener` no llama a `escuchar`.
2. Al cambiar a `oscuro`, `subscribe` entrega el valor nuevo y `escuchar` lo lee por su cuenta.
3. `cancelar()` y `removeListener(escuchar)` terminan dos relaciones independientes. Por eso `bosque` no llega a ninguna
   lista, aunque la señal sí cambia.

Hay que retirar la misma función que se registró: escribir otra función anónima no retira la anterior. La llamada
inicial omitida por `addListener` depende de `runCallbackOnListen`, que es falso por defecto; no la traslades sin
comprobarla a otras implementaciones de `ValueListenable`.

### Practica 5

¿Cuál de los dos callbacks recibe el valor como argumento? ¿Cuál se ejecuta durante el registro? ¿Qué llamada termina
cada relación?

<details>
<summary>Ver respuesta</summary>

`subscribe` entrega el valor como argumento y se ejecuta durante el registro con `claro`; termina con la función
`cancelar` que devolvió. El listener no recibe argumentos ni se ejecuta al registrarlo en esta configuración; termina
con `removeListener(escuchar)`.

</details>

## 6. Un efecto puede observar un derivado

Un `computed` también se puede leer dentro de un efecto. Entonces el efecto depende del **resultado derivado**: si
cambia una fuente pero el resultado sigue siendo igual, la acción no se repite. Es la misma distinción de la unidad 11
entre revisar un cálculo y notificar un cambio de resultado.

**Antes de mirar los `expect`**, predice cuántas entradas añade el efecto con un borde que pasa de 1 a 2, a 3 y a 1, si
el derivado indica si el borde es grueso, es decir, si vale 2 o más.

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('el efecto sigue el resultado del derivado', () {
    final borde = signal(1);
    final grueso = computed(() => borde.value >= 2);
    addTearDown(borde.dispose);
    addTearDown(grueso.dispose);
    final registro = <bool>[];

    final detener = effect(() {
      registro.add(grueso.value);
    });
    expect(registro, [false]);

    borde.value = 2;
    expect(registro, [false, true]);
    borde.value = 3;
    expect(registro, [false, true]);
    borde.value = 1;
    expect(registro, [false, true, false]);

    detener();
  });
}
```

Al crear el efecto se calcula `false` y se añade. Con borde 2 el resultado cambia a `true` y el efecto se ejecuta. Con
borde 3 se revisa el cálculo, pero `3 >= 2` sigue siendo `true`, así que no se añade nada. Con borde 1 el resultado
vuelve a cambiar. Hubo tres escrituras y dos ejecuciones nuevas del efecto.

### Practica 6

Si el efecto leyera `borde.value >= 2` directamente, sin el `computed`, ¿qué contendría el registro tras la misma
secuencia? ¿Por qué?

<details>
<summary>Ver respuesta</summary>

`[false, true, true, false]`. El efecto dependería del número, que cambia en las tres escrituras, y se ejecutaría cada
vez. Con el `computed`, la dependencia es el resultado booleano, que no cambia al pasar de 2 a 3.

</details>

## 7. Un efecto no es una reconstrucción

Que un efecto se haya ejecutado no dice nada sobre la pantalla. Para mostrar datos hace falta un consumidor de Flutter
como `SignalBuilder`, que ya estudiamos, y un frame que procese la construcción.

**Antes de mirar los `expect`**, predice qué ha cambiado justo después de asignar `oscuro`, antes de `pump`, y qué
cambia después. El árbol tiene un `Builder` normal y un `SignalBuilder` que leen la misma señal que el efecto.

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('el efecto y la interfaz son relaciones distintas', (
    tester,
  ) async {
    final tema = signal('claro');
    addTearDown(tema.dispose);
    final registro = <String>[];

    final detener = effect(() {
      registro.add(tema.value);
    });
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            Builder(builder: (_) => Text('Puntual: ${tema.value}')),
            SignalBuilder(builder: (_) => Text('Observado: ${tema.value}')),
          ],
        ),
      ),
    );

    tema.value = 'oscuro';
    expect(registro, ['claro', 'oscuro']);
    expect(find.text('Observado: claro'), findsOneWidget);

    await tester.pump();
    expect(find.text('Observado: oscuro'), findsOneWidget);
    expect(find.text('Puntual: claro'), findsOneWidget);

    detener();
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Paso a paso:

1. Al asignar `oscuro`, el efecto se ejecuta en ese momento y el registro ya contiene el valor nuevo.
2. El árbol todavía muestra `Observado: claro`. El elemento del `SignalBuilder` solo quedó marcado para reconstruirse.
3. `pump` procesa el frame y el `SignalBuilder` vuelve a leer la señal. El `Builder` normal no tenía ninguna observación
   y en este árbol nada más lo reconstruye, así que sigue mostrando la lectura anterior.

El efecto no ha intervenido en ninguna de esas construcciones. Si lo quitamos, el texto se actualiza igual. Por la misma
razón, no crees un efecto dentro de `build` sin decidir quién conserva y detiene cada instancia: `build` puede repetirse
y cada ejecución añadiría otra observación.

### Practica 7

Un efecto añade una entrada a una lista. ¿Demuestra eso que Flutter ha reconstruido un widget? ¿Qué comprobarías para
saberlo?

<details>
<summary>Ver respuesta</summary>

No. La acción y el build son eventos distintos, como muestra el registro actualizado antes de `pump`. Para comprobarlo
necesitas una prueba de widget que procese el frame y compruebe el texto, o un contador dentro del callback del
consumidor.

</details>

## 8. Escribir desde un efecto: ciclos, `peek` y `untracked`

Un efecto puede escribir en una señal, pero si lee y escribe **la misma** se vuelve a provocar a sí mismo. Este
fragmento tiene ese problema:

```dart
effect(() {
  contador.value = contador.value + 1;
});
```

La lectura registra `contador` como dependencia y la escritura lo cambia, así que el efecto debe ejecutarse otra vez, y
otra. En la versión instalada, Signals detecta el ciclo tras unas cien iteraciones y la creación del efecto lanza una
`SignalEffectException`. Si lo que buscas es un dato derivado, la solución no es corregir el bucle, sino usar
`computed`.

A veces el callback necesita un dato sin que ese dato deba provocar otra ejecución. `peek()`, que vimos en la unidad 10,
lee el valor sin registrar la dependencia.

**Antes de mirar el `expect`**, predice qué entradas se añaden si cambiamos primero `prefijo` y después `tema`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('una lectura no rastreada no provoca otra ejecución', () {
    final tema = signal('claro');
    final prefijo = signal('Tema');
    addTearDown(tema.dispose);
    addTearDown(prefijo.dispose);
    final registro = <String>[];

    final detener = effect(() {
      registro.add('${prefijo.peek()}: ${tema.value}');
    });
    prefijo.value = 'Elegido';
    expect(registro, ['Tema: claro']);

    tema.value = 'oscuro';
    expect(registro, ['Tema: claro', 'Elegido: oscuro']);

    detener();
  });
}
```

Cambiar `prefijo` no ejecuta el efecto, porque su lectura no se registró. Cambiar `tema` sí, y en esa ejecución `peek()`
obtiene el valor actual, `Elegido`. `untracked(() => prefijo.value)` consigue lo mismo para todas las lecturas que haga
la función que recibe. Ninguna de las dos es un remedio general: si las usas para esconder un ciclo, sigues manteniendo
dos datos sincronizados a mano.

### Practica 8

Si en la prueba quitamos `peek()` y escribimos `${prefijo.value}`, ¿qué contendrá el registro después de las dos
asignaciones?

<details>
<summary>Ver respuesta</summary>

`['Tema: claro', 'Elegido: claro', 'Elegido: oscuro']`. `prefijo` pasa a ser una dependencia, así que su cambio provoca
una ejecución más, que combina el prefijo nuevo con el tema que todavía es `claro`.

</details>

## 9. El controlador de DaisyUI

El [controlador actual](../../../lib/themes/application/daisy_theme_controller.dart) guarda el tema en un
`FlutterSignal` privado y lo expone mediante una vista de lectura. Este es un **fragmento** del archivo real:

```dart
void setTheme(DaisyThemeModel theme) => _palette.value = theme;
```

```dart
final class _ThemeListenable implements ValueListenable<DaisyThemeModel> {
  // ...
  @override
  DaisyThemeModel get value => _source.value;
}
```

`controller.theme` devuelve esa vista, un `_ThemeListenable`, cuyo getter `value` lee la señal `_palette`. Eso importa
porque el rastreo depende de lo que **se ejecuta**, no del tipo que aparece en el código: si `controller.theme.value` se
evalúa durante un efecto, el getter lee la señal en ese contexto y queda registrada la dependencia. La vista también
ofrece `addListener` y `removeListener`, que delegan en los de la señal. La unidad 16 estudia esta clase con detalle.

**Antes de mirar los `expect`**, predice qué guarda cada lista: creamos un efecto y un listener sobre el mismo
controlador, cambiamos a `dark`, proponemos una copia igual de `dark`, cancelamos ambas observaciones y cambiamos a
`cupcake`.

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('efecto y listener sobre el controlador', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    final delEfecto = <String>[];
    final delListener = <String>[];
    void escuchar() => delListener.add(controller.theme.value.name);

    final detener = effect(() {
      delEfecto.add(controller.theme.value.name);
    });
    controller.theme.addListener(escuchar);
    expect(delEfecto, ['Light']);
    expect(delListener, isEmpty);

    controller.setTheme(DaisyThemes.dark);
    controller.setTheme(DaisyThemes.dark.copyWith());
    expect(delEfecto, ['Light', 'Dark']);
    expect(delListener, ['Dark']);

    detener();
    controller.theme.removeListener(escuchar);
    controller.setTheme(DaisyThemes.cupcake);
    expect(delEfecto, ['Light', 'Dark']);
    expect(delListener, ['Dark']);
    expect(controller.theme.value.name, 'Cupcake');
  });
}
```

Paso a paso:

1. El efecto se ejecuta al crearlo y guarda `Light`. Al leer `controller.theme.value` queda registrada la señal
   `_palette`. El listener no se ejecuta al registrarlo.
2. `setTheme(dark)` asigna a `_palette.value`. La señal compara con `==`, acepta el cambio y ambas observaciones
   reaccionan.
3. La copia de `dark` es otro objeto, pero `==` la considera igual. La señal la descarta y ninguna lista crece.
4. Después de `detener()` y `removeListener`, `cupcake` no se añade a ninguna lista. El controlador sigue vivo y
   devuelve `Cupcake`.
5. El test creó el controlador y lo libera al terminar. Detener un efecto o retirar un listener no lo libera.

Las dos formas son válidas para que una pieza externa reaccione al tema. El listener es el contrato de Flutter que
promete el tipo público `ValueListenable`, sin mencionar Signals. El efecto aprovecha que hoy la vista lee una señal por
dentro; es más cómodo si combina varias señales, pero depende de ese detalle de implementación.

¿Por qué el flujo de temas no usa ningún `effect`? Porque ya tiene quien escuche: el
[scope](../../../lib/themes/application/daisy_theme_scope.dart) extiende `InheritedNotifier` y recibe `controller.theme`
como `notifier`. Flutter llama a `addListener` sobre esa vista y actualiza a los dependientes del scope. Un efecto
añadiría otra observación que no participa en esa reconstrucción. La conexión completa se estudia en las unidades 20–23.

### Practica 9

`controller.theme` tiene el tipo `ValueListenable`, que no pertenece a Signals. ¿Por qué el efecto de la prueba se
vuelve a ejecutar al llamar a `setTheme`? ¿Por qué, aun así, el scope no necesita un efecto?

<details>
<summary>Ver respuesta</summary>

Porque durante la ejecución del efecto el getter `value` de la vista lee `_palette.value`, y esa lectura de la señal es
la que queda registrada; el tipo declarado no interviene. El scope no lo necesita porque `InheritedNotifier` usa el
contrato `addListener` de la vista para recibir los avisos y actualizar a sus dependientes.

</details>

## Ejercicio final: registrar una etiqueta derivada

Escribe una prueba que:

1. Cree dos señales, `tema = 'claro'` y `borde = 1`, y derive con `computed` una etiqueta como `claro: fino`. El borde
   es `grueso` si vale al menos 2 y `fino` en caso contrario.
2. Cree un efecto que añada la etiqueta a una lista. Predice la entrada inicial.
3. Cambie el borde a 2 y después a 3. ¿Se añade algo en ambos pasos? Razona con el valor de la etiqueta.
4. Dentro de `batch`, cambie el tema a `oscuro` y el borde a 1. `batch`, que usamos en la unidad 11, agrupa las dos
   escrituras antes de procesar el efecto. ¿Qué etiqueta recibe al terminar el lote?
5. Detenga el efecto, cambie el tema a `bosque` y lea el derivado. ¿Qué devuelve la lectura? ¿Cambia el registro?
6. Libere el derivado y las fuentes. Explica por qué el test es responsable de hacerlo.

Como variación, repite las dos escrituras del paso 4 sin `batch`: ¿qué entrada adicional aparece? Después imagina que el
efecto lee `etiqueta.peek()` en lugar de `etiqueta.value`: ¿cuántas entradas quedarían?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('un efecto registra una etiqueta derivada', () {
    final tema = signal('claro');
    final borde = signal(1);
    final etiqueta = computed(() {
      final tipo = borde.value >= 2 ? 'grueso' : 'fino';
      return '${tema.value}: $tipo';
    });
    addTearDown(tema.dispose);
    addTearDown(borde.dispose);
    addTearDown(etiqueta.dispose);
    final registro = <String>[];

    final detener = effect(() {
      registro.add(etiqueta.value);
    });
    expect(registro, ['claro: fino']);

    borde.value = 2;
    borde.value = 3;
    expect(registro, ['claro: fino', 'claro: grueso']);

    batch(() {
      tema.value = 'oscuro';
      borde.value = 1;
    });
    expect(registro, ['claro: fino', 'claro: grueso', 'oscuro: fino']);

    detener();
    tema.value = 'bosque';
    expect(etiqueta.value, 'bosque: fino');
    expect(registro, ['claro: fino', 'claro: grueso', 'oscuro: fino']);
  });
}
```

Al crear el efecto se registra `claro: fino`. Borde 2 cambia la etiqueta a `claro: grueso`; borde 3 deja el resultado
igual y no añade nada. El lote procesa el efecto una vez, con los dos valores finales: `oscuro: fino`. Tras detener,
cambiar el tema ya no añade entradas, pero el derivado sigue disponible y devuelve `bosque: fino`. El test creó las
señales y el derivado, así que los libera: `addTearDown` ejecuta las limpiezas en orden inverso, primero el derivado y
después sus fuentes. En esta prueba no hay ninguna reconstrucción de Flutter.

Sin `batch`, la primera escritura produce además `oscuro: grueso`, el estado intermedio. Con `etiqueta.peek()` el efecto
no tendría ninguna dependencia: solo quedaría la entrada inicial, `claro: fino`.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué diferencia hay entre almacenar un tema, calcular una etiqueta y registrar una acción? **Apartado 1.**
2. ¿Cuándo se ejecuta por primera vez un efecto y qué establece sus dependencias? **Apartado 2.**
3. ¿Qué hace `detener()` y qué puede seguir haciendo el propietario de la señal? **Apartado 2.**
4. ¿Qué diferencia hay entre la función que devuelve el callback y la que devuelve `effect`? **Apartado 3.**
5. ¿Por qué `cerrar claro` ocurre antes de `abrir oscuro`? ¿Qué se cierra al detener? **Apartado 3.**
6. ¿Por qué un cambio de `global` no provoca nada al principio y sí tras cambiar de rama? **Apartado 4.**
7. ¿Qué recibe el callback de `subscribe` y cuándo se llama por primera vez? ¿Y un listener de `addListener`?
   **Apartado 5.**
8. ¿Por qué un efecto que lee un `computed` puede ejecutarse menos veces que las escrituras de su fuente? **Apartado
   6.**
9. ¿Quién conecta un dato observable con la interfaz? ¿Por qué una acción no demuestra una reconstrucción? **Apartado
   7.**
10. ¿Qué ocurre si un efecto lee y escribe la misma señal? ¿Para qué sirven `peek()` y `untracked`? **Apartado 8.**
11. ¿Por qué un efecto que lee `controller.theme.value` sí registra una dependencia? **Apartado 9.**
12. ¿Por qué el flujo de temas de DaisyUI no necesita un efecto propio? **Apartado 9.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques qué lectura crea cada dependencia,
qué provoca cada ejecución y quién detiene la observación sin confundirla con liberar la fuente. La unidad 13 estudia la
propiedad de los recursos y `dispose`.

## Para consultar si necesitas reforzar

- [`effect`](https://pub.dev/documentation/signals_core/latest/signals_core/effect.html): firma, ejecución y función de
  parada. Compara `latest` con las versiones resueltas del proyecto.
- [Documentación de Signals](https://dartsignals.dev/): contexto general de señales, efectos y dependencias.
- [`ValueListenable`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html): el contrato de lectura y
  escucha que usa la vista del controlador.
- [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html): cómo se conecta un
  `Listenable` con sus dependientes; se estudia en la unidad 22.
- [Controlador](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart) y
  [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento actual de DaisyUI.
- [Dependencias declaradas](../../../pubspec.yaml) y [versiones resueltas](../../../pubspec.lock): comprueba qué
  implementación estás estudiando antes de trasladar sus detalles a otro proyecto.

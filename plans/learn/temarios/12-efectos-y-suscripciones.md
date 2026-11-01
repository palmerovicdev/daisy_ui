# 12. Efectos y suscripciones

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 11](11-computed-estado-derivado.md)

- **Bloque:** Signals: almacenar y relacionar estado.
- **Estado de estudio:** pendiente.
- **Fuentes contrastadas:** 1 de noviembre de 2026.

## Qué vas a conseguir

Imagina que queremos guardar un registro cada vez que cambia el tema seleccionado. La unidad anterior calculaba un
texto para mostrarlo; ahora queremos **hacer una acción**: añadir una entrada a un registro. Aprenderás a observar las
señales que usa esa acción, a saber cuándo se ejecuta y a detener la observación. También distinguirás esa parada de
la limpieza de recursos creados en cada ejecución y de la liberación de la señal.

Al terminar podrás explicar por separado un cálculo, un efecto y una reconstrucción de Flutter. Los ejemplos de Signals
son una profundización: el controlador actual de DaisyUI usa `ValueNotifier` y su flujo de temas no necesita un
`effect` propio. Preparar esta guía no marca la unidad como dominada.

## Cómo practicar

Las prácticas se contrastaron con `signals_flutter` **7.1.0**, `signals_core` **7.0.0** y `preact_signals` **7.0.0**
resueltos en [pubspec.lock](../../../pubspec.lock). Los detalles de ejecución descritos corresponden a estas versiones,
los valores predeterminados y las secuencias mostradas. Cada bloque A–E y la solución del proyecto es una prueba Flutter
completa e independiente. Antes de abrirlo, escribe tu predicción. Copia un bloque cada vez a un archivo nuevo como
`test/estudio_efectos_test.dart` y ejecuta, con las dependencias ya resueltas:

```shell
flutter test --no-pub test/estudio_efectos_test.dart
```

`test` define una prueba, `expect(actual, esperado)` comprueba el resultado y la lista `registro` sustituye a una
acción externa para que podamos ver su orden. No son programas independientes para DartPad. Al terminar puedes borrar
tu archivo de práctica. En todos los ejemplos el test crea y libera sus recursos; la unidad 13 profundiza en la
propiedad y los ciclos de vida.

## 12.1. Tres trabajos diferentes

Supongamos que el tema actual es `claro`:

1. **Almacenar:** una señal conserva el texto `claro` y permite cambiarlo.
2. **Calcular:** `computed(() => 'Tema: ${tema.value}')` describe cómo obtener `Tema: claro` a partir de la fuente.
   Su propósito es ofrecer un valor derivado; no necesitas guardar otro texto modificable por separado.
3. **Actuar:** un efecto puede añadir `claro` a un registro externo cuando se ejecuta. Esa modificación del registro es
   un **efecto secundario**: una acción observable fuera del cálculo de un valor.
4. **Mostrar:** un consumidor de Flutter observa el dato y participa en una reconstrucción de interfaz. Ni `computed`
   ni añadir una línea al registro dibujan por sí solos un widget.

Un efecto puede enviar datos a otro sistema o iniciar una operación, pero esas acciones reales tienen sus propios
problemas de errores, cancelación y orden; añadir a una lista nos permite estudiar la observación sin ocultarlos.
Es preferible derivar una etiqueta con `computed` o una expresión que mantener otra señal sincronizada con un efecto.

**Piensa:** si cambia el tema y solo quieres mostrar su nombre, ¿qué pieza calcula el texto? ¿Necesitas también una
acción externa? Responde antes de abrir la práctica siguiente.

### Practica 1

Si solo quieres mostrar una etiqueta obtenida del tema, ¿qué pieza necesitas: un cálculo, una acción externa o ambas?

<details>
<summary>Ver respuesta</summary>

Necesitas obtener el texto y conectarlo a un consumidor de interfaz. Una acción externa solo es necesaria si además quieres hacer algo como registrar o guardar el cambio; calcular no ejecuta ese registro por sí solo.

</details>

## 12.2. Crear, ejecutar y detener un `effect`

`effect` recibe una función sin argumentos. Al crearlo, la implementación instalada ejecuta esa función de inmediato.
Durante esa ejecución, las lecturas de señales dentro del contexto del efecto registran las dependencias. Un cambio
pertinente puede provocar otra ejecución. La llamada a `effect` devuelve una función sin argumentos que detiene la
observación; conservarla permite que el responsable decida cuándo terminar.

```dart
final detener = effect(() {
  registro.add(tema.value);
});
// Más tarde:
detener();
```

La primera función es **el trabajo** del efecto. `detener` es otra función, devuelta por `effect`: escribir su nombre
la conserva; `detener()` la ejecuta. Detener no borra el historial ni elimina la señal compartida. Una lectura de
`tema.value` fuera del callback es puntual y no añade esa fuente a las dependencias del efecto.

### Ejemplo A: registrar y detener

**Predice:** el tema empieza en `claro`. Creamos el efecto, asignamos `oscuro` dos veces, lo detenemos y asignamos
`bosque`. ¿Qué contiene el registro en cada paso? ¿Se puede seguir leyendo la señal?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('A: efecto inicial, cambios y parada', () {
    final tema = signal('claro');
    final registro = <String>[];
    final detener = effect(() { registro.add(tema.value); });
    expect(registro, ['claro']);
    tema.value = 'oscuro';
    tema.value = 'oscuro';
    expect(registro, ['claro', 'oscuro']);
    detener();
    tema.value = 'bosque';
    expect(registro, ['claro', 'oscuro']);
    expect(tema.value, 'bosque');
    tema.dispose();
  });

}
```

Al crear el efecto, el callback lee `claro` y lo añade: no espera al primer cambio. La primera asignación a `oscuro`
provoca una nueva ejecución; la segunda asigna un valor igual y en este caso no provoca otra. Al llamar a `detener()`,
se retiran las relaciones de observación del efecto. La señal sigue viva y su valor pasa a `bosque`, aunque el registro
ya no crezca. Por último el test, que creó la señal, llama a `tema.dispose()`.

La ejecución inmediata del ejemplo no implica que toda combinación de lotes y callbacks reentrantes tenga el mismo
orden. La igualdad de la fuente y el hecho de que una observación esté activa también importan.

**Comprueba:** ¿quién lee el valor, quién modifica la lista y qué llamada termina la observación? ¿Qué diferencia hay
entre detener el efecto y liberar la señal?

### Practica 2

En A detenemos el efecto antes de escribir `bosque`. ¿Cuál es el valor actual de la señal y qué se añade al registro?

<details>
<summary>Ver respuesta</summary>

La señal conserva `bosque`, pero el efecto detenido no añade una nueva entrada. La función de parada cancela esa observación; no libera ni borra automáticamente la señal.

</details>

## 12.3. Limpieza de cada ejecución

A veces cada ejecución inicia algo que debe terminar antes de iniciar lo siguiente: por ejemplo, una escucha asociada
al tema actual. El callback del efecto puede **devolver una función de limpieza**. En la implementación instalada se
llama a esa limpieza antes de volver a ejecutar el callback y también cuando se detiene el efecto. Esta función no es
la misma que `effect(...)` entrega para detener la observación completa.

### Ejemplo B: abrir y cerrar

**Predice:** cada ejecución registra `abrir` con el tema actual y devuelve una función que registra `cerrar` con ese
mismo tema. Después cambiamos de `claro` a `oscuro` y detenemos. ¿En qué orden aparecen las cuatro entradas?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('B: limpieza por ejecución y limpieza final', () {
    final tema = signal('claro');
    final registro = <String>[];
    final detener = effect(() {
      final actual = tema.value;
      registro.add('abrir $actual');
      return () => registro.add('cerrar $actual');
    });
    tema.value = 'oscuro';
    detener();
    expect(registro, ['abrir claro', 'cerrar claro', 'abrir oscuro', 'cerrar oscuro']);
    tema.dispose();
  });

}
```

`actual` captura el valor de **esa ejecución**. Primero se abre `claro`. Antes de volver a ejecutar el efecto se llama a
la limpieza anterior, que cierra `claro`; entonces se abre `oscuro`. Al detener, se llama a la limpieza pendiente y se
cierra `oscuro`. La limpieza devuelta desde el callback es útil para liberar aquello que esa ejecución creó; la función
`detener` termina el efecto completo. Ninguna de las dos llamadas equivale a `tema.dispose()`.

La lista solo simula abrir y cerrar; un recurso real debe tener una API de cancelación apropiada. Si el trabajo ya
iniciado es asíncrono, detener el efecto no cancela por sí mismo un `Future` ni deshace una petición ya enviada. Hay que
diseñar explícitamente su cancelación o ignorar resultados obsoletos cuando corresponda.

**Comprueba:** si el efecto se detiene sin cambiar el tema, ¿qué limpieza se ejecuta? ¿Por qué capturamos `actual` en
vez de leer otra vez `tema.value` al cerrar?

### Practica 3

En B el efecto se detiene sin cambiar el tema. ¿Qué entrada añade la limpieza pendiente?

<details>
<summary>Ver respuesta</summary>

Añade `cerrar claro`: corresponde al recurso simulado que abrió la primera ejecución. La función que devuelve el callback limpia esa ejecución; la que devuelve `effect` detiene el efecto completo.

</details>

## 12.4. Qué lecturas se convierten en dependencias

Al ejecutarse, el efecto registra las señales leídas en su contexto. Si una condición cambia la rama, la siguiente
ejecución puede utilizar otras señales; el seguimiento se ajusta a las lecturas de esa ejecución. El efecto no observa
todas las variables que aparecen escritas en su código, solo las lecturas rastreadas que se realizan.

### Ejemplo C: elegir una fuente

**Predice:** `usarLocal` es verdadero, `local` vale `claro` y `global` vale `oscuro`. Cambiaremos global a `bosque`,
local a `nieve`, la condición a falso, local a `noche` y global a `sol`. ¿Qué cuatro valores guarda el efecto?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('C: dependencias cambian con la rama', () {
    final usarLocal = signal(true);
    final local = signal('claro');
    final global = signal('oscuro');
    final registro = <String>[];
    final detener = effect(() {
      registro.add(usarLocal.value ? local.value : global.value);
    });
    global.value = 'bosque';
    local.value = 'nieve';
    usarLocal.value = false;
    local.value = 'noche';
    global.value = 'sol';
    expect(registro, ['claro', 'nieve', 'bosque', 'sol']);
    detener();
    usarLocal.dispose(); local.dispose(); global.dispose();
  });

}
```

Al comienzo se leen `usarLocal` y `local`, por lo que cambiar solo `global` no ejecuta el efecto. Cambiar `local`
registra `nieve`. Al cambiar la condición, se lee la rama global y se registra el valor actual `bosque`. Ahora `local`
no interviene; el cambio posterior de `global` registra `sol`. Al detener se deja de observar; luego el test libera
las tres fuentes.

Si hubieras escrito `final nombre = local.value` **antes** del callback y después usaras `nombre` dentro, el efecto
recibiría ese valor capturado, no una lectura rastreada de `local`. Asimismo, una lectura posterior a un `await` no
forma parte de la ejecución síncrona de seguimiento que estamos usando aquí. Para trabajo asíncrono, captura los datos
necesarios de forma síncrona y gestiona por separado errores, cancelación y resultados tardíos.

**Comprueba:** ¿qué fuentes se siguen antes y después de cambiar la condición? ¿Qué diferencia hay entre leer la
señal dentro del callback y usar una copia obtenida antes?

### Practica 4

En C, después de cambiar a la rama global, ¿qué sucede si cambiamos solo `local`?

<details>
<summary>Ver respuesta</summary>

En esa secuencia no se ejecuta el efecto por ese cambio: la última ejecución leyó la condición y `global`, no `local`. Al cambiar la condición o la señal observada puede volver a ejecutarse.

</details>

## 12.5. `subscribe` y `addListener`

Una **suscripción** es la relación que mantiene una observación activa. Hay varias interfaces para crearla:

- `effect` rastrea las señales leídas durante su callback y devuelve la función que lo detiene.
- En estas versiones, `senal.subscribe(callback)` observa esa señal, entrega el valor al callback, lo llama inicialmente
  con el valor actual y devuelve una función para cancelar.
- `FlutterSignal` también implementa `ValueListenable`: `addListener` registra una función sin argumentos y
  `removeListener` la retira. Con la configuración predeterminada del ejemplo, registrar el listener no llama al
  callback externo inicialmente. Para conocer el valor, el listener lee `.value`.

### Ejemplo D: observar la misma señal de dos maneras

**Predice:** registramos primero `subscribe` y después `addListener`. Sin cambiar aún la señal, ¿qué lista contiene
`claro`? Luego cambiamos a `oscuro`, cancelamos ambas observaciones y cambiamos a `bosque`. ¿Qué listas quedan?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('D: subscribe y addListener', () {
    final tema = signal('claro');
    final suscripcion = <String>[];
    final avisos = <String>[];
    final cancelar = tema.subscribe(suscripcion.add);
    void escuchar() => avisos.add(tema.value);
    tema.addListener(escuchar);
    expect(suscripcion, ['claro']);
    expect(avisos, isEmpty);
    tema.value = 'oscuro';
    cancelar(); tema.removeListener(escuchar);
    tema.value = 'bosque';
    expect(suscripcion, ['claro', 'oscuro']);
    expect(avisos, ['oscuro']);
    tema.dispose();
  });

}
```

`subscribe` entrega `claro` durante el registro y después `oscuro`. El listener Flutter solo añade `oscuro`, al recibir
el aviso y leer la señal. Después de `cancelar()` y `removeListener(escuchar)`, ninguna de las dos listas incorpora
`bosque`. Debe retirarse la misma función registrada; escribir otra función anónima no garantiza retirar la anterior.
El comportamiento inicial de `addListener` indicado aquí usa el valor predeterminado `runCallbackOnListen`; no lo
traslades sin comprobarlo a otras configuraciones u otras implementaciones de `ValueListenable`.

**Comprueba:** ¿cuál de los callbacks recibe directamente el valor? ¿Qué función cancela cada relación? ¿Cuál ejecuta
un callback externo inicialmente en esta práctica?

### Practica 5

En D, ¿qué lista recibe `claro` durante el registro y cómo se cancela cada escucha?

<details>
<summary>Ver respuesta</summary>

`subscribe` entrega inicialmente `claro` y devuelve `cancelar`; el listener Flutter del ejemplo no se llama inicialmente y se retira con `removeListener(escuchar)`. Son dos relaciones independientes.

</details>

## 12.6. Efecto, cálculo y reconstrucción no son lo mismo

Un efecto puede leer un `computed`: entonces observa el resultado derivado y ejecuta una acción cuando ese resultado
cambia en la secuencia del proyecto final. Si cambia una fuente pero el resultado sigue siendo igual, no hay que
suponer una acción por cada escritura. En la unidad 11 vimos además que cálculo, cambio del resultado y aviso son
pasos diferentes.

Para mostrar datos, un `SignalBuilder` o un `ValueListenableBuilder` puede conectar la observación con Flutter. En un
test de widgets, cambiar la señal y procesar un frame con `pump` son pasos distintos. Una reconstrucción puede tener
otras causas; no afirmes que un efecto reconstruye la interfaz solo porque haya ejecutado una acción. Tampoco crees un
efecto repetidamente en `build` sin definir quién conserva y detiene cada instancia: las reconstrucciones pueden crear
múltiples observaciones.

Evita escribir desde un efecto en una señal que ese mismo efecto lee sin comprender la dependencia: puedes producir un
ciclo. Si solo buscas un dato derivado, usa una derivación. `peek()` y `untracked` sirven para lecturas deliberadamente
no rastreadas, pero no son un remedio universal para sincronizar estado o resolver el ciclo de vida.

### Practica 6

¿Demuestra un efecto que añade una entrada a una lista que Flutter ha reconstruido un widget?

<details>
<summary>Ver respuesta</summary>

No. La acción y el build son eventos distintos. Un consumidor como `ValueListenableBuilder` conecta el dato a Flutter; se necesita una prueba de widget o una observación apropiada para comprobar esa reconstrucción.

</details>

## 12.7. Conexión con DaisyUI

El [controlador actual](../../../lib/themes/application/daisy_theme_controller.dart) crea un
`ValueNotifier<DaisyThemeModel>` privado llamado `_palette`. Su getter `theme` lo expone como
`ValueListenable<DaisyThemeModel>`, `setTheme` asigna `_palette.value` y `dispose` libera el notificador. El
[scope](../../../lib/themes/application/daisy_theme_scope.dart) extiende `InheritedNotifier` y recibe esa vista como
`notifier`. Así Flutter puede escuchar la fuente y actualizar dependientes; no hace falta crear un efecto de Signals
para ello. La conexión completa se estudiará en las unidades 20–23.

Una lectura de `controller.theme.value` dentro de `effect` no convierte ese `ValueNotifier` en una señal de Signals:
ambos ofrecen lectura, pero no comparten automáticamente el mecanismo de rastreo. Si una pieza externa necesita
escucharlo, puede usar su contrato `ValueListenable`, como en esta prueba.

### Ejemplo E: escuchar y dejar de escuchar el controlador

**Predice:** empezamos con el tema predeterminado, registramos un listener, cambiamos a `dark`, lo retiramos y volvemos a
`light`. ¿Qué nombre guarda la lista? ¿Quién libera el controlador?

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('E: fuente de DaisyUI y listener', () {
    final controller = DaisyThemeController();
    final registro = <String>[];
    void escuchar() => registro.add(controller.theme.value.name);
    controller.theme.addListener(escuchar);
    controller.setTheme(DaisyThemes.dark);
    controller.theme.removeListener(escuchar);
    controller.setTheme(DaisyThemes.light);
    expect(registro, ['Dark']);
    controller.dispose();
  });

}
```

El listener lee `Dark` al recibir el aviso. Tras retirarlo, volver a `Light` no añade otra entrada. El test creó el
controlador y lo libera; retirar el listener y liberar el controlador son operaciones distintas. La igualdad del
modelo también participa en la decisión del notificador de avisar, como se estudió en las unidades 7 y 8.

### Practica 7

En E, ¿por qué cambiar a `light` después de retirar el listener no añade otro nombre?

<details>
<summary>Ver respuesta</summary>

El controlador sigue vivo y cambia su notificador, pero el callback ya no está registrado. El test, que creó el controlador, lo libera al terminar.

</details>

## Proyecto de la unidad: registrar una etiqueta derivada

Usa dos señales, `tema = 'claro'` y `borde = 1`, y deriva una etiqueta con `computed`: el borde es `grueso` si es al
menos 2 y `fino` en caso contrario. Crea un efecto que añada esa etiqueta a una lista.

1. Predice la entrada inicial.
2. Cambia el borde a 2 y después a 3. ¿Se añade algo en ambos pasos? Razona con el valor de la etiqueta.
3. Dentro de `batch`, cambia el tema a `oscuro` y el borde a 1. ¿Qué etiqueta recibe el efecto al terminar el lote?
4. Detén el efecto, cambia el tema a `bosque` y lee el derivado. ¿Qué muestra la lectura? ¿Cambia el registro?
5. Libera el derivado y las fuentes cuando ya no se usan. Explica por qué el test es responsable de hacerlo.

`batch` agrupa las dos escrituras de la práctica antes de procesar el efecto, que observa el resultado final. Esta
secuencia no demuestra el comportamiento de todos los usos posibles de lotes. Intenta resolverla antes de consultar la
solución.

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('proyecto: efecto sobre derivado y batch', () {
    final tema = signal('claro');
    final borde = signal(1);
    final etiqueta = computed(() => '${tema.value}: ${borde.value >= 2 ? 'grueso' : 'fino'}');
    final registro = <String>[];
    final detener = effect(() { registro.add(etiqueta.value); });
    borde.value = 2;
    borde.value = 3;
    batch(() { tema.value = 'oscuro'; borde.value = 1; });
    expect(registro, ['claro: fino', 'claro: grueso', 'oscuro: fino']);
    detener();
    tema.value = 'bosque';
    expect(etiqueta.value, 'bosque: fino');
    expect(registro, ['claro: fino', 'claro: grueso', 'oscuro: fino']);
    etiqueta.dispose(); borde.dispose(); tema.dispose();
  });
}
```

Al crear el efecto se registra `claro: fino`. Borde 2 cambia la etiqueta a `claro: grueso`; borde 3 deja el resultado
igual y en esta secuencia no añade otra entrada. El lote produce `oscuro: fino` después de sus dos asignaciones. Al
parar, cambiar el tema ya no añade entradas; el derivado sigue disponible y al leerlo devuelve `bosque: fino`. El test
libera primero el derivado y después las fuentes. No hay ninguna reconstrucción de Flutter en esta prueba.

</details>

## Comprueba si puedes avanzar

1. ¿Cuál es la diferencia entre almacenar un tema, calcular una etiqueta y registrar una acción?
2. ¿Cuándo se ejecuta por primera vez el efecto de A y qué lectura establece su dependencia?
3. ¿Qué hace `detener()` y qué puede seguir haciendo el propietario de la señal?
4. En B, ¿qué diferencia hay entre la función devuelta por el callback y la devuelta por `effect`?
5. ¿Por qué `cerrar claro` ocurre antes de `abrir oscuro`? ¿Qué se cierra al detener?
6. En C, ¿por qué un cambio de `global` no provoca nada al principio y sí tras cambiar de rama?
7. ¿Qué recibe `subscribe` y cuándo se invoca inicialmente en D? ¿Y `addListener`?
8. ¿Por qué leer `controller.theme.value` en un efecto no suscribe automáticamente el `ValueNotifier`?
9. ¿Quién conecta un dato observable con la interfaz? ¿Por qué una acción no demuestra una reconstrucción?
10. ¿Qué problema puede aparecer si un efecto lee y escribe la misma señal? ¿Quién debe detener las observaciones?

<details>
<summary>Consultar claves de los ejemplos y la comprobación final</summary>


### Preguntas breves

- Una etiqueta se calcula a partir del tema; si solo quieres mostrarla no necesitas registrar una acción externa. El
  consumidor de Flutter se ocupa de la conexión con la interfaz.
- **A:** el registro pasa de `['claro']` a `['claro', 'oscuro']` y permanece así. Tras detener, la señal sigue
  leyendo `bosque`; el test la libera después.
- **B:** `abrir claro`, `cerrar claro`, `abrir oscuro`, `cerrar oscuro`. Si no hubiera cambio, detener cerraría
  `claro`. Capturar `actual` permite cerrar lo que se abrió en esa ejecución, aunque el valor actual ya sea otro.
- **C:** `['claro', 'nieve', 'bosque', 'sol']`. Primero se siguen condición y local; tras cambiar de rama, condición y
  global. Cambiar una señal fuera de la rama activa no ejecuta el efecto.
- **D:** `subscribe` guarda `['claro', 'oscuro']`; el listener guarda `['oscuro']`. El primero recibe el valor y
  devuelve una función de cancelación; el segundo lee `.value` y se retira con la misma referencia de callback.
- **E:** se guarda `['Dark']`. El test retira su listener y, como propietario, libera el controlador.

### Claves de la comprobación final

1. La señal conserva el estado; el cálculo produce un valor; el efecto realiza una acción externa al cálculo.
2. Inmediatamente al crearlo; lee `tema.value` dentro del callback.
3. Retira la observación y ejecuta la limpieza pendiente del efecto. La señal no se libera por ello y puede seguir
   leyéndose y cambiándose mientras esté viva.
4. La limpieza interna corresponde al trabajo de una ejecución; la función exterior detiene el efecto completo.
5. Se limpia la ejecución anterior antes de iniciar la siguiente; al detener se limpia la última.
6. Solo se sigue la rama leída; al cambiar la condición se actualizan las dependencias utilizadas.
7. `subscribe` recibe un valor y entrega el inicial; el listener no recibe argumentos ni se llama inicialmente con la
   configuración de D.
8. `ValueNotifier` usa otro mecanismo de escucha; una lectura no registra una dependencia de Signals.
9. Un consumidor como `SignalBuilder` o `ValueListenableBuilder` conecta observación e interfaz. Una acción en una
   lista no prueba que Flutter haya reconstruido un widget.
10. Puede provocar ejecuciones encadenadas o un ciclo. Quien crea o asume la responsabilidad de la observación debe
    disponer de su parada; la propiedad de recursos se profundiza en la unidad 13.

</details>

## Para consultar si necesitas reforzar

- [API de `effect` de Signals](https://pub.dev/documentation/signals_core/latest/signals_core/effect.html): firma,
  creación y función de parada. La página `latest` puede cambiar respecto a la versión instalada.
- [Documentación de Signals](https://dartsignals.dev/): contexto general de señales, efectos y dependencias.
- [Contrato `ValueListenable` de Flutter](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) y
  [ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html): lectura,
  escucha y conexión con widgets.
- Implementación local de `signals_core` 7.0.0, `src/core/effect.dart`, y de `preact_signals` 7.0.0,
  `src/effect.dart`: ejecución inicial, limpieza por ejecución y cancelación. Contrástala con las versiones del lock.
- [Controlador de DaisyUI](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart) y
  [pruebas del controlador](../../../test/themes/daisy_theme_controller_test.dart): relación con el proyecto actual.

## Qué se ha comprobado

Se contrastaron las fuentes instaladas y los archivos actuales del controlador y el scope. Las seis prácticas se
ejecutaron como pruebas Flutter con las versiones indicadas: comprobaron listas, valores y orden en esas secuencias.
Esto no demuestra comportamiento de red, cancelación de operaciones asíncronas, reconstrucciones adicionales ni
repintados en un dispositivo. El servidor del grafo rechazó indexar esta carpeta por su configuración de acceso; los
archivos pertinentes se revisaron directamente. La unidad sigue pendiente hasta que puedas resolver y explicar las
prácticas.

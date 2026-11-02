# 04. `Listenable`: recibir avisos

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 3](03-objetos-referencias-tipos-y-contratos.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 2 registramos funciones en una lista para poder llamarlas más tarde. Flutter tiene un contrato para expresar esa capacidad: `Listenable`.

Al terminar podrás registrar y retirar listeners, seguir quién recibe cada aviso y distinguir lo que promete el contrato de las decisiones de una implementación. También veremos cómo se escuchan los cambios de tema en DaisyUI.

Los programas completos de esta guía usan Flutter. Puedes copiarlos en [DartPad](https://dartpad.dev/), elegir **Flutter** y pulsar **Run**; su salida aparece en la consola. Cada programa es independiente. Si necesitas descansar, puedes hacer una pausa después del apartado 3 y continuar otro día.

## 1. ¿Para qué sirve escuchar?

Imagina una aplicación en la que el tema puede cambiar. Un panel quiere mostrar un mensaje cuando eso ocurra y un registro de diagnóstico también quiere enterarse.

Leer el tema una vez les da el dato de ese momento. Para recibir avisos posteriores necesitan registrar una función que alguien pueda llamar cuando corresponda. Esa función es el **listener** que estudiamos en la unidad 2.

En este recorrido hay tres papeles:

1. Una **fuente** permite registrar funciones interesadas en recibir avisos.
2. Cada **consumidor** entrega un listener: por ejemplo, el panel o el diagnóstico.
3. La implementación decide cuándo **notificar**, es decir, cuándo llamar a los listeners que correspondan.

Estos papeles no tienen por qué ser objetos separados. Una misma clase puede guardar un dato, aceptar listeners y emitir avisos. Por ahora queremos saber quién registra una función, quién la llama y qué hace su cuerpo.

### Practica 1

El panel registra una función que imprime `Panel avisado`. El diagnóstico registra otra. Si la fuente llama solo a la función del panel, ¿qué hace el diagnóstico?

<details>
<summary>Ver respuesta</summary>

Su función no se ejecuta en ese aviso. Registrar dos listeners no significa que una llamada a uno ejecute por sí sola el otro: la implementación debe llamar a cada función que quiera avisar.

</details>

## 2. ¿Qué promete `Listenable`?

`Listenable` es un contrato de Flutter para registrar y retirar listeners. Estas son sus dos operaciones principales; es un fragmento para leer, no un programa completo:

```dart
void addListener(VoidCallback listener);
void removeListener(VoidCallback listener);
```

- `addListener` recibe una función para registrarla.
- `removeListener` recibe una función para retirar su registro.
- `VoidCallback` es otro nombre para `void Function()`: una función sin argumentos cuyo resultado no se utiliza.

Por ejemplo, en `fuente.addListener(avisar)` se llama **ahora** a `addListener` y se le entrega la función `avisar`. Escribimos `avisar` sin paréntesis porque queremos entregar la función; `avisar()` intentaría ejecutarla en ese momento. La implementación de la fuente es la que determina cuándo llamar al listener registrado.

Si solo sabemos que una variable tiene tipo `Listenable`, podemos registrar y retirar funciones con esos métodos. Ese contrato no ofrece una propiedad `.value`, ni un método `emitir`, `notifyListeners` o `dispose`. Una implementación concreta puede tener operaciones adicionales, pero necesitamos conocer su tipo para utilizarlas.

Tampoco podemos deducir solamente de `Listenable` qué cambio provoca un aviso, cómo se tratan los registros repetidos o cuándo se llama a los listeners. Para eso hay que conocer la implementación.

### Practica 2

Una función recibe `Listenable fuente` y una función `avisar` sin argumentos. ¿Cuáles de estas operaciones permite el contrato?

```dart
fuente.addListener(avisar);
fuente.removeListener(avisar);
fuente.value;
fuente.notifyListeners();
```

<details>
<summary>Ver respuesta</summary>

Las dos primeras: el contrato permite registrar y retirar un listener. `value` y `notifyListeners()` no forman parte de `Listenable`. Una fuente concreta podría ofrecerlos mediante otro tipo, pero no podemos asumirlo a partir de este.

</details>

## 3. Seguir dos listeners paso a paso

Vamos a construir un avisador pequeño para ver lo que sucede por dentro. Es un ejemplo didáctico: no pretende sustituir las implementaciones de Flutter ni resolver todas sus situaciones de uso.

```dart
import 'package:flutter/foundation.dart';

class AvisadorManual implements Listenable {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void emitir() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

void main() {
  final avisador = AvisadorManual();
  final Listenable fuente = avisador;

  void panel() => print('Panel avisado');
  void diagnostico() => print('Diagnóstico avisado');

  fuente.addListener(panel);
  fuente.addListener(diagnostico);
  print('Registrados');

  avisador.emitir();

  fuente.removeListener(panel);
  print('Panel retirado');
  avisador.emitir();

  fuente.removeListener(diagnostico);
  avisador.emitir();
  print('Fin');
}
```

La salida es:

```text
Registrados
Panel avisado
Diagnóstico avisado
Panel retirado
Diagnóstico avisado
Fin
```

Primero, las piezas del avisador:

- `implements Listenable` indica que la clase cumple el contrato y aporta el código de sus dos métodos.
- `<VoidCallback>[]` crea una lista vacía de funciones sin argumentos.
- `addListener` añade la función a la lista; `removeListener` retira una entrada que coincide con ella.
- `emitir()` es un método propio de este ejemplo. Recorre la lista y `listener()` ejecuta cada función encontrada.

Ahora sigue los avisos:

1. Registramos `panel` y `diagnostico`. En esta implementación, registrar solo añade funciones a la lista; todavía no ejecuta sus cuerpos.
2. El primer `emitir()` llama a las dos funciones, en el orden en que están en la lista.
3. Retiramos `panel`. El segundo `emitir()` solo encuentra a `diagnostico`.
4. Retiramos `diagnostico`. El tercer `emitir()` encuentra la lista vacía, así que no imprime ningún aviso.

`avisador` y `fuente` acceden al mismo objeto. `fuente` tiene tipo `Listenable`, así que permite registrar y retirar; `avisador` tiene tipo `AvisadorManual`, que además permite llamar a `emitir()`. El método `emitir` no es parte del contrato `Listenable`.

Este ejemplo llama a los listeners durante el recorrido y en el orden de su lista. No podemos atribuir esas decisiones a todas las implementaciones de `Listenable`. Aquí registramos y retiramos fuera del recorrido; la clase tampoco maneja cambios de la lista durante un aviso ni errores de los listeners.

### Practica 3

En el programa anterior, retira `panel` **antes** de la primera llamada a `emitir()`. ¿Cuántas veces se imprime cada aviso? ¿La función `panel` deja de existir?

<details>
<summary>Ver respuesta</summary>

`Panel avisado` no aparece. `Diagnóstico avisado` aparece dos veces: el diagnóstico sigue registrado durante las dos primeras emisiones. Retirar `panel` de la lista no destruye la función; todavía podrías llamarla directamente con `panel()` dentro de `main`.

</details>

## 4. El aviso y el dato son pasos distintos

El listener de `Listenable` no recibe el tema como argumento. Si necesita consultarlo, su cuerpo debe tener alguna forma de acceder al dato. En este ejemplo usamos una variable capturada, como en la unidad 2:

```dart
import 'package:flutter/foundation.dart';

class AvisadorManual implements Listenable {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void emitir() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

void main() {
  final avisador = AvisadorManual();
  var tema = 'claro';
  final lecturaInicial = tema;

  void mostrar() => print('Actual: $tema; inicial: $lecturaInicial');
  avisador.addListener(mostrar);

  tema = 'oscuro';
  print('Dato cambiado: $tema');
  avisador.emitir();
  avisador.emitir();

  avisador.removeListener(mostrar);
  tema = 'cupcake';
  avisador.emitir();
  print('Final: $tema');
}
```

La salida es:

```text
Dato cambiado: oscuro
Actual: oscuro; inicial: claro
Actual: oscuro; inicial: claro
Final: cupcake
```

La asignación `tema = 'oscuro'` cambia el dato, pero en este programa no llama al avisador. Después, cada llamada a `emitir()` ejecuta `mostrar`: por eso aparecen dos avisos aunque no cambiemos el tema entre ellos. La función consulta `tema` al ejecutarse; `lecturaInicial` conserva el texto que se guardó antes.

Tras retirar el listener, el tema cambia a `'cupcake'`, pero la siguiente emisión no llama a `mostrar`. Otra implementación podría unir cambio y aviso o comparar valores antes de notificar. Esas decisiones no están determinadas por el contrato `Listenable`.

`ValueListenable<T>`, que estudiaremos en la unidad 6, añade al contrato una lectura `.value`; el listener sigue siendo una función sin argumentos.

### Practica 4

¿Qué pasaría si quitamos las dos primeras llamadas a `emitir()`? ¿Se imprimirá algún aviso de `mostrar`? ¿Cuál será el valor final del tema?

<details>
<summary>Ver respuesta</summary>

No se imprimirá ningún aviso de `mostrar`: cuando llega la última emisión, ya retiramos el listener. Sí se imprimen `Dato cambiado: oscuro` y `Final: cupcake`, porque son llamadas a `print` independientes. El tema final es `'cupcake'`.

</details>

## 5. Retirar el listener de la fuente correcta

Para dejar de escuchar necesitas identificar **qué función registraste y en qué fuente**. Imagina dos avisadores independientes, uno para la aplicación y otro para una vista previa. Este es un fragmento que utiliza la clase `AvisadorManual` del apartado 3:

```dart
final app = AvisadorManual();
final vistaPrevia = AvisadorManual();
final listener = () => print('Aviso');

app.addListener(listener);
vistaPrevia.removeListener(listener);
app.emitir();

app.removeListener(listener);
app.emitir();
```

El primer `removeListener` busca el registro en `vistaPrevia`; no modifica la lista de `app`. Por eso, la primera emisión de `app` imprime `Aviso`. La segunda ya no lo imprime porque retiramos el listener de la fuente donde se había registrado.

Guardar la función en `listener` nos permite entregar la misma al registrar y al retirar. Escribir otra función anónima con el mismo cuerpo en `removeListener` no garantiza que coincida con la registrada.

Retirar un listener tampoco equivale a liberar la fuente: `removeListener` trata el registro; `dispose`, cuando una clase lo ofrece, pertenece al ciclo de vida del recurso. La propiedad y la limpieza se estudian en la unidad 13.

### Practica 5

Una pantalla cambia de escuchar la fuente A a escuchar la fuente B. ¿Qué dos operaciones debe hacer para dejar de recibir avisos de A y empezar a recibir los de B?

<details>
<summary>Ver respuesta</summary>

Debe retirar de A el listener que registró allí y registrarlo en B. Necesita conservar acceso tanto al callback como a la fuente anterior para retirar esa relación correctamente.

</details>

## 6. Cada implementación decide cómo avisar

En nuestro `AvisadorManual`, `addListener` añade una entrada a una lista y `removeListener` elimina una entrada que coincide. Por tanto, si registramos dos veces el mismo callback, tendremos dos entradas. Una retirada elimina una; queda otra que recibirá el siguiente aviso.

Esa conclusión se obtiene **leyendo el código del ejemplo**. No se puede aplicar sin más a todas las fuentes `Listenable`: hay que consultar la implementación concreta. Lo mismo ocurre con la política de cambios que producen avisos y con el tratamiento de errores o modificaciones durante una notificación.

### Practica 6

En el avisador del apartado 3, registramos dos veces `panel`, llamamos a `emitir()`, retiramos `panel` una vez y volvemos a emitir. ¿Cuántas veces se ejecuta `panel` en cada emisión?

<details>
<summary>Ver respuesta</summary>

En la primera, dos veces: hay dos entradas en la lista. La retirada elimina una entrada, así que en la segunda se llama una vez. Esta respuesta corresponde a nuestro avisador de ejemplo, no a una regla general de `Listenable`.

</details>

## 7. Recibir un aviso no es lo mismo que reconstruir una pantalla

Un listener puede hacer muchas cosas: imprimir un mensaje, consultar un dato o pedir una actualización de la interfaz. Si su cuerpo solo imprime, lo que hemos demostrado es que esa función se ejecutó.

Para que un widget muestre información nueva, hace falta una conexión que lleve el aviso hasta un mecanismo de actualización de Flutter. Después, durante una reconstrucción, el código puede volver a leer los datos. Notificar, reconstruir y pintar son pasos distintos; estudiaremos esa conexión con más detalle en las unidades sobre widgets y scopes.

### Practica 7

Un test registra `() => print('Aviso')` y comprueba que se imprimió el mensaje. ¿Qué demuestra? ¿Demuestra que un widget se reconstruyó?

<details>
<summary>Ver respuesta</summary>

Demuestra que se ejecutó ese listener y produjo la impresión. Por sí solo no demuestra ninguna reconstrucción: para comprobarla hay que observar o probar también el widget que recibe la actualización.

</details>

## 8. Escuchar el tema en DaisyUI

En el [controlador](../../../lib/themes/application/daisy_theme_controller.dart), `theme` devuelve un objeto `_ThemeListenable` mediante el tipo público `ValueListenable<DaisyThemeModel>`. Ese objeto no conserva su propia lista de listeners: cuando registras `controller.theme.addListener(avisar)`, entrega la función a `_palette`, la señal que guarda el tema. Para retirar esa misma función usa `removeListener`.

`setTheme` asigna el modelo a `_palette.value`. La señal compara los valores y, si acepta el cambio, avisa a sus listeners. Las unidades 7 y 9 estudian esa comparación; aquí interesa distinguir registrar, recibir y retirar. La [prueba del controlador](../../../test/themes/daisy_theme_controller_test.dart) comprueba avisos y retirada; eso no demuestra por sí solo una reconstrucción de interfaz.

### Practica 8

Si registras `avisar` mediante `controller.theme`, ¿en qué objeto se registra? ¿Cómo dejas de escuchar?

<details>
<summary>Ver respuesta</summary>

Se registra en la señal `_palette`: el objeto devuelto por `theme` le reenvía la función. Para dejar de escuchar, llama a `controller.theme.removeListener(avisar)` con la misma función.

</details>

## Ejercicio final: dos consumidores y dos avisos

Escribe un programa Flutter de consola utilizando `AvisadorManual` del apartado 3:

1. Crea un avisador y guarda un tema inicial `'claro'`.
2. Declara dos listeners: uno imprime el tema actual y el otro cuenta e imprime cuántos avisos ha recibido.
3. Registra los dos listeners. Cambia el tema a `'oscuro'` y emite un aviso.
4. Retira el listener que muestra el tema. Cambia el tema a `'cupcake'` y emite otro aviso.
5. Retira el contador, emite una vez más e imprime el tema final y el número de avisos contados.

Antes de ejecutar, predice toda la salida. Señala quién cambia el tema, quién ejecuta cada listener y qué queda en la lista antes de cada emisión. Como variación, registra un listener en una segunda fuente y comprueba que retirarlo de la primera no lo retira de la segunda.

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/foundation.dart';

class AvisadorManual implements Listenable {
  final _listeners = <VoidCallback>[];

  @override
  void addListener(VoidCallback listener) => _listeners.add(listener);

  @override
  void removeListener(VoidCallback listener) => _listeners.remove(listener);

  void emitir() {
    for (final listener in _listeners) {
      listener();
    }
  }
}

void main() {
  final avisador = AvisadorManual();
  var tema = 'claro';
  var avisos = 0;

  void mostrarTema() => print('Tema: $tema');
  void contarAviso() {
    avisos = avisos + 1;
    print('Avisos: $avisos');
  }

  avisador.addListener(mostrarTema);
  avisador.addListener(contarAviso);

  tema = 'oscuro';
  avisador.emitir();

  avisador.removeListener(mostrarTema);
  tema = 'cupcake';
  avisador.emitir();

  avisador.removeListener(contarAviso);
  avisador.emitir();
  print('Final: $tema; avisos: $avisos');
}
```

```text
Tema: oscuro
Avisos: 1
Avisos: 2
Final: cupcake; avisos: 2
```

`main` cambia el tema. `emitir` recorre la lista y llama a los listeners: en la primera emisión están los dos; en la segunda solo queda `contarAviso`; en la tercera la lista está vacía. El último `print` es independiente de los avisos.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Para qué se registra un listener y quién decide llamarlo? **Apartado 1.**
2. ¿Qué operaciones ofrece `Listenable` y cuáles no puedes deducir de ese tipo? **Apartado 2.**
3. En `AvisadorManual`, ¿qué sucede al registrar, emitir y retirar? **Apartado 3.**
4. ¿Puede cambiar el dato sin avisar? ¿Puede nuestro avisador emitir dos veces sin otro cambio? **Apartado 4.**
5. ¿Por qué necesitas conservar la fuente y el callback usados para registrar? **Apartado 5.**
6. ¿Por qué el resultado de registrar dos veces depende de la implementación? **Apartado 6.**
7. ¿Qué demuestra un listener que imprime un mensaje? ¿Qué hace falta comprobar para hablar de una reconstrucción? **Apartado 7.**
8. En DaisyUI, ¿qué objeto recibe el registro y la retirada? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques las respuestas con tus palabras. La siguiente unidad estudia `ChangeNotifier`, una implementación de Flutter que permite producir avisos.

## Para consultar si necesitas reforzar

- [`Listenable` en Flutter](https://api.flutter.dev/flutter/foundation/Listenable-class.html): el contrato de escucha.
- [`addListener`](https://api.flutter.dev/flutter/foundation/Listenable/addListener.html) y [`removeListener`](https://api.flutter.dev/flutter/foundation/Listenable/removeListener.html): registro y retirada.
- [`VoidCallback`](https://api.flutter.dev/flutter/dart-ui/VoidCallback.html): el tipo de las funciones que se registran.
- [`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html): lectura de un valor además de escucha; lo estudiaremos en la unidad 6.

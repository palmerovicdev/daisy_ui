# 05. `ChangeNotifier`: producir avisos

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 4](04-listenable-recibir-avisos.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 4 construimos un avisador para entender cómo registrar, llamar y retirar listeners. Ahora usaremos
`ChangeNotifier`, una clase de Flutter que ya proporciona un mecanismo de notificación.

Al terminar podrás construir un contador que avisa a sus consumidores y explicar qué ocurre si cambia sin avisar o
si avisa sin cambiar. También distinguirás quién decide notificar, quién escucha y quién conecta un aviso con una
pantalla.

Los programas completos usan Flutter. Puedes copiarlos en [DartPad](https://dartpad.dev/), elegir **Flutter** y pulsar
**Run**; observa la consola. Cada programa es independiente. Puedes hacer una pausa después del apartado 3 y continuar
el resto en otra sesión.

## 1. De escuchar a producir un aviso

En la unidad anterior, `Listenable` nos permitió expresar que una fuente acepta listeners. Ese contrato indica cómo
registrar y retirar funciones, pero no nos dice qué operación del objeto debe producir un aviso.

`ChangeNotifier` implementa `Listenable` y aporta las operaciones para administrar listeners y notificarlos. Podemos
crear una clase que lo extienda y añadirle el dato y las acciones que necesitemos:

```dart
class Contador extends ChangeNotifier {
  // Aquí añadiremos el dato y las operaciones del contador.
}
```

Este fragmento no es un programa completo. Por usar `extends ChangeNotifier`, nuestro contador heredará
`addListener`, `removeListener` y el mecanismo de `notifyListeners()`.

La decisión de **cuándo** llamar a `notifyListeners()` sigue siendo nuestra. `ChangeNotifier` no sabe por sí solo qué
significa incrementar un contador, ni vigila automáticamente todos los campos de la subclase.

Piensa en una lista de personas a quienes se puede llamar: el mecanismo permite mantener la lista y hacer las llamadas.
La clase que administra el dato decide en qué momento iniciar un aviso. La analogía sirve para separar esas
responsabilidades; no describe llamadas telefónicas ni tiempos de espera.

### Practica 1

Queremos un contador que avise cuando aumente. ¿Quién aporta el mecanismo para llamar a los listeners y quién decide
que debe usarse después del incremento?

<details>
<summary>Ver respuesta</summary>

`ChangeNotifier` aporta el mecanismo de notificación. Nuestro método `incrementar` decide usarlo llamando a
`notifyListeners()` después de cambiar la cantidad.

</details>

## 2. Un contador que avisa

Construyamos un contador con dos consumidores. Antes de ejecutarlo, intenta predecir qué número verá cada uno:

```dart
import 'package:flutter/foundation.dart';

class Contador extends ChangeNotifier {
  int _cantidad = 0;

  int get cantidad => _cantidad;

  void incrementar() {
    _cantidad = _cantidad + 1;
    notifyListeners();
  }
}

void main() {
  final contador = Contador();

  void panel() => print('Panel: ${contador.cantidad}');
  void registro() => print('Registro: ${contador.cantidad}');

  contador.addListener(panel);
  contador.addListener(registro);

  print('Antes: ${contador.cantidad}');
  contador.incrementar();
  print('Después: ${contador.cantidad}');

  contador.removeListener(panel);
  contador.incrementar();

  contador.removeListener(registro);
  contador.dispose();
}
```

La salida es:

```text
Antes: 0
Panel: 1
Registro: 1
Después: 1
Registro: 2
```

Sigue la primera llamada a `incrementar()`:

1. El campo `_cantidad` pasa de `0` a `1`.
2. `notifyListeners()` inicia el aviso a los listeners registrados.
3. Se ejecutan `panel` y `registro`. Cada función consulta `contador.cantidad` en ese momento y lee `1`.
4. Al terminar los callbacks, la ejecución vuelve a `incrementar()` y luego a `main`, que imprime `Después: 1`.

En este ejemplo, `ChangeNotifier` llama a los listeners durante `notifyListeners()`, antes de que esa llamada retorne.
Después retiramos `panel`: el segundo incremento cambia el dato a `2`, pero solo `registro` sigue escuchando. Al final,
`main`, que creó el contador, retira el listener restante y libera el contador con `dispose()`.

El listener no recibe la cantidad como argumento: `VoidCallback` es una función sin argumentos. Cada consumidor del
ejemplo la consulta mediante el getter `cantidad` cuando se ejecuta. El getter lo escribimos en `Contador`;
`ChangeNotifier` no proporciona por sí mismo un campo `cantidad` ni un getter `value`.

`notifyListeners()` es una operación protegida para la implementación. En el código de aplicación, la subclase decide
cuándo llamarla dentro de sus métodos; el consumidor usa una operación como `incrementar()`. La anotación ayuda al
analizador a detectar usos desde fuera, pero no es una barrera de privacidad en tiempo de ejecución.

### Practica 2

En `incrementar`, intercambia el orden de las dos instrucciones: primero notifica y después suma uno. ¿Qué mostrarán
`panel` y `registro` en el primer aviso? ¿Qué cantidad quedará al terminar el método?

<details>
<summary>Ver respuesta</summary>

Ambos mostrarán `0`, porque los callbacks se ejecutan antes de que la instrucción de suma cambie el campo. Al terminar
el método, la cantidad será `1`. El orden dentro de `incrementar` determina qué dato leen durante el aviso.

</details>

## 3. Cambiar y notificar son operaciones distintas

¿Cambiar el contador obliga a que alguien reciba un aviso? ¿Un aviso demuestra que hubo un cambio? Probemos tres
operaciones distintas:

```dart
import 'package:flutter/foundation.dart';

class Contador extends ChangeNotifier {
  int _cantidad = 0;

  int get cantidad => _cantidad;

  void incrementarSinAvisar() {
    _cantidad = _cantidad + 1;
  }

  void avisarSinCambiar() {
    notifyListeners();
  }

  void incrementar() {
    _cantidad = _cantidad + 1;
    notifyListeners();
  }
}

void main() {
  final contador = Contador();
  var avisos = 0;

  void observar() {
    avisos = avisos + 1;
    print('Aviso $avisos: ${contador.cantidad}');
  }

  contador.addListener(observar);
  contador.incrementarSinAvisar();
  print('Después del cambio: ${contador.cantidad}');

  contador.avisarSinCambiar();
  contador.avisarSinCambiar();
  contador.incrementar();

  contador.removeListener(observar);
  contador.incrementar();
  print('Final: ${contador.cantidad}; avisos: $avisos');
  contador.dispose();
}
```

La salida es:

```text
Después del cambio: 1
Aviso 1: 1
Aviso 2: 1
Aviso 3: 2
Final: 3; avisos: 3
```

La primera operación cambia el campo a `1` y no llama a `notifyListeners()`: el listener no se ejecuta entonces.
Las dos llamadas a `avisarSinCambiar()` sí lo ejecutan, aunque el campo siga valiendo `1`. Después,
`incrementar()` suma uno y avisa. La última llamada a `incrementar()` vuelve a cambiar el dato, pero el listener ya
está retirado y no recibe ese aviso.

En total hay **tres cambios del dato**, **cuatro llamadas a `notifyListeners()`** y **tres ejecuciones del listener**.
La última notificación no encuentra registrado a `observar`. Contar estas cosas por separado nos ayuda a entender
qué ha pasado.

En una aplicación, omitir un aviso que necesita un consumidor puede dejarlo mostrando un dato anterior hasta que vuelva
a leerlo por otra causa. Avisar sin necesidad también puede provocar trabajo adicional. La política adecuada depende
de lo que signifique cada operación.

### Practica 3

Elimina las dos llamadas a `avisarSinCambiar()`. ¿Qué cantidad queda al final y cuántos avisos recibe `observar`?

<details>
<summary>Ver respuesta</summary>

La cantidad final sigue siendo `3`: esas dos llamadas no modificaban el dato. `observar` recibe un solo aviso, el del
primer `incrementar()`. El último incremento ocurre después de retirarlo.

</details>

## 4. Una política: cuándo merece la pena avisar

Supongamos que nuestro contador solo admite cantidades de `0` a `2`. Queremos avisar cuando el número cambie, pero no
cuando alguien intente incrementarlo estando ya en `2`:

```dart
import 'package:flutter/foundation.dart';

class ContadorLimitado extends ChangeNotifier {
  int _cantidad = 0;

  int get cantidad => _cantidad;

  void incrementar() {
    if (_cantidad == 2) {
      return;
    }
    _cantidad = _cantidad + 1;
    notifyListeners();
  }
}

void main() {
  final contador = ContadorLimitado();
  void observar() => print('Cantidad: ${contador.cantidad}');

  contador.addListener(observar);
  contador.incrementar();
  contador.incrementar();
  contador.incrementar();
  print('Final: ${contador.cantidad}');

  contador.removeListener(observar);
  contador.dispose();
}
```

La salida es:

```text
Cantidad: 1
Cantidad: 2
Final: 2
```

Las dos primeras llamadas cambian la cantidad y notifican. En la tercera, la condición `_cantidad == 2` es verdadera:
`return` termina el método antes de la suma y antes de `notifyListeners()`.

Esta comparación es **la política de nuestra clase**. No es una comparación automática que `ChangeNotifier` aplique
a todos sus campos. Otras fuentes pueden tener otras reglas; por ejemplo, estudiaremos la política de `ValueNotifier`
en la unidad 7.

### Practica 4

Si quitamos `return` y dejamos el resto igual, ¿qué ocurre en la tercera llamada? ¿Mantendría el contador el límite?

<details>
<summary>Ver respuesta</summary>

La tercera llamada sumaría uno y avisaría con `Cantidad: 3`. El contador ya no respetaría el límite de `2`: en este
código, la condición y el `return` son los que impiden llegar a la suma.

</details>

## 5. ¿Qué pasa con los registros repetidos?

`ChangeNotifier` permite registrar el mismo callback más de una vez. Si se registra dos veces y luego se retira una
vez **fuera de una notificación**, queda un registro activo:

```dart
import 'package:flutter/foundation.dart';

class Campana extends ChangeNotifier {
  void sonar() => notifyListeners();
}

void main() {
  final campana = Campana();
  var llamadas = 0;
  void escuchar() {
    llamadas = llamadas + 1;
    print('Llamada $llamadas');
  }

  campana.addListener(escuchar);
  campana.addListener(escuchar);
  campana.sonar();

  campana.removeListener(escuchar);
  campana.sonar();

  campana.removeListener(escuchar);
  campana.sonar();
  campana.dispose();
}
```

La salida es `Llamada 1`, `Llamada 2` y `Llamada 3`, cada una en su línea. La primera emisión encuentra dos registros;
la segunda, uno; la tercera, ninguno. Para compensar dos registros iguales hacen falta dos retiradas.

Esto describe `ChangeNotifier`, no una regla para todas las implementaciones de `Listenable`. Si se retira un callback
duplicado **durante** una notificación, Flutter documenta que puede volver a llamarlo en ese mismo recorrido aunque
se haya retirado una vez. Consulta [removeListener](https://api.flutter.dev/flutter/foundation/ChangeNotifier/removeListener.html)
si necesitas manejar ese caso. Aquí hacemos las retiradas entre emisiones.

Un listener añadido durante una notificación no participa en ese recorrido; puede participar en el siguiente. Si un
listener lanza una excepción, `ChangeNotifier` la captura y la reporta mediante Flutter. La documentación de
[notifyListeners](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html) explica estos casos.

### Practica 5

En el programa de la campana, ¿qué ocurriría en la segunda llamada a `sonar()` si quitamos la primera retirada?

<details>
<summary>Ver respuesta</summary>

Los dos registros seguirían presentes, así que el listener se ejecutaría dos veces más e imprimiría `Llamada 3` y
`Llamada 4`. Habría que retirar ambos registros para que dejara de escuchar.

</details>

## 6. Dejar de escuchar y liberar el objeto

`removeListener` retira un registro de escucha. No destruye el contador ni retira los listeners de otros consumidores.
Por ejemplo, el panel puede dejar de escuchar mientras el registro de diagnóstico sigue recibiendo avisos.

`dispose()` termina la vida útil del `ChangeNotifier` y limpia sus listeners; **no envía un último aviso**. Debe
llamarlo quien sea responsable de ese objeto cuando ya nadie vaya a usarlo. Un consumidor que recibe un contador
prestado normalmente retira su listener, pero no decide por su cuenta liberar el objeto compartido.

Después de `dispose`, el notificador ya no debe usarse para registrar listeners ni para notificar. Flutter permite
llamar a `removeListener` después de la liberación para facilitar la limpieza, pero eso no reactiva el objeto. Tampoco
se debe llamar a `dispose` durante una notificación en curso. La propiedad y el ciclo de vida se estudian con más
detalle en la unidad 13.

Si una subclase necesita sobrescribir `dispose` para liberar recursos adicionales que posee, debe llamar también a
`super.dispose()`. Este fragmento iría dentro de la subclase:

```dart
@override
void dispose() {
  // Liberar aquí los recursos adicionales que posee la subclase.
  super.dispose();
}
```

### Practica 6

Dos pantallas comparten un contador que pertenece a otro objeto. Una de ellas deja de necesitarlo. ¿Debe retirar su
listener o liberar el contador completo? ¿Recibirá un aviso de despedida al ejecutar `dispose()`?

<details>
<summary>Ver respuesta</summary>

La pantalla debe retirar su propio listener. El propietario decide cuándo liberar el contador compartido, una vez que
ya no se necesite. `dispose()` no envía un aviso de despedida.

</details>

## 7. Del aviso a la pantalla

Los programas anteriores funcionan sin una interfaz. Para que una pantalla muestre el nuevo contador necesitamos un
widget que escuche la fuente y conecte el aviso con la construcción de la interfaz.

Por ejemplo, [`ListenableBuilder`](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html) escucha un
`Listenable`. Este fragmento presupone un `contador` que ya existe y sigue vivo:

```dart
ListenableBuilder(
  listenable: contador,
  builder: (context, child) {
    return Text('Cantidad: ${contador.cantidad}');
  },
)
```

El recorrido es:

1. El contador guarda la cantidad y `incrementar()` la modifica.
2. El método llama a `notifyListeners()`.
3. `ListenableBuilder` escucha el aviso y lo conecta con una actualización de su parte de la interfaz.
4. Cuando Flutter ejecuta el `builder`, este vuelve a leer `contador.cantidad` y construye el texto.

La primera construcción también lee el contador inicial, sin necesitar un aviso previo. Una impresión en consola
prueba que se ejecutó ese listener; por sí sola no prueba que se haya reconstruido o repintado un widget. Flutter
puede reconstruir por otros motivos y agrupar trabajo entre frames: no deduzcas una cantidad fija de reconstrucciones
o repintados contando llamadas a `notifyListeners()`.

### Practica 7

Si `incrementar()` cambia la cantidad pero no llama a `notifyListeners()`, ¿qué dato obtendrías al consultar el contador?
¿Tiene garantizado el texto actualizarse en ese momento?

<details>
<summary>Ver respuesta</summary>

Una lectura del contador obtiene la cantidad nueva. El texto no tiene garantizada una actualización en ese momento:
sin el aviso, `ListenableBuilder` no recibe esa señal para actualizarse. Otra causa podría provocar una reconstrucción
más tarde y entonces leer el dato nuevo.

</details>

## 8. Comparación con DaisyUI

Usamos `ChangeNotifier` para estudiar un mecanismo de Flutter. El [controlador real de DaisyUI](../../../lib/themes/application/daisy_theme_controller.dart)
**no extiende `ChangeNotifier`**. Este fragmento pertenece a su clase:

```dart
final FlutterSignal<DaisyThemeModel> _palette;

void setTheme(DaisyThemeModel theme) {
  _palette.value = theme;
}
```

El controlador conserva una señal en `_palette` y cambia su valor mediante `setTheme`. Además, su getter `theme`
ofrece una vista `ValueListenable<DaisyThemeModel>`; el adaptador `_ThemeListenable` reenvía los registros y retiradas
de listeners a la fuente.

La pregunta sigue siendo útil: ¿quién guarda el dato, quién inicia el cambio y quién escucha? En nuestro contador,
`incrementar()` asigna el número y llama explícitamente a `notifyListeners()`. En DaisyUI, `setTheme` asigna el tema
a una señal. Las reglas concretas de esa señal se estudian en la unidad 9; no debemos asumir que sean las mismas de
`ChangeNotifier`.

El [scope de temas](../../../lib/themes/application/daisy_theme_scope.dart) utiliza la vista del controlador con
`InheritedNotifier` para conectar los avisos con sus dependientes. Estudiaremos ese recorrido y el ciclo de vida del
controlador más adelante.

### Practica 8

Si buscas `notifyListeners()` dentro de `DaisyThemeController.setTheme`, ¿lo encontrarás? ¿Qué línea cambia el tema?

<details>
<summary>Ver respuesta</summary>

No hay una llamada a `notifyListeners()` en ese método. El tema se asigna mediante `_palette.value = theme`; `_palette`
es una señal, cuya implementación de avisos estudiaremos más adelante.

</details>

## Ejercicio final: un contador con límite y reinicio

Escribe un programa Flutter de consola que:

1. Declare `ContadorLimitado extends ChangeNotifier`, con cantidad inicial `0`, getter `cantidad` y máximo `2`.
2. En `incrementar()`, sume uno y avise si la cantidad es menor que `2`. Si ya es `2`, no cambie ni avise.
3. En `reiniciar()`, ponga la cantidad en `0` y avise solo si antes no era `0`.
4. Registre dos listeners: `panel` y `registro`, que impriman la cantidad actual con sus nombres.
5. Llame tres veces a `incrementar()`, retire `panel` y llame dos veces a `reiniciar()`.
6. Retire `registro` y libere el contador. Antes de ejecutar, predice toda la salida y explica qué operaciones no
   producen aviso.

Como variación, imagina que `reiniciar()` avisa siempre: ¿cuál sería la línea adicional de salida?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/foundation.dart';

class ContadorLimitado extends ChangeNotifier {
  int _cantidad = 0;

  int get cantidad => _cantidad;

  void incrementar() {
    if (_cantidad == 2) return;
    _cantidad = _cantidad + 1;
    notifyListeners();
  }

  void reiniciar() {
    if (_cantidad == 0) return;
    _cantidad = 0;
    notifyListeners();
  }
}

void main() {
  final contador = ContadorLimitado();
  void panel() => print('Panel: ${contador.cantidad}');
  void registro() => print('Registro: ${contador.cantidad}');

  contador.addListener(panel);
  contador.addListener(registro);
  contador.incrementar();
  contador.incrementar();
  contador.incrementar();

  contador.removeListener(panel);
  contador.reiniciar();
  contador.reiniciar();

  contador.removeListener(registro);
  contador.dispose();
}
```

```text
Panel: 1
Registro: 1
Panel: 2
Registro: 2
Registro: 0
```

El tercer intento de incremento termina sin cambiar ni avisar porque la cantidad ya es `2`. El primer reinicio cambia
a `0` y avisa solo a `registro`, porque `panel` fue retirado. El segundo reinicio no avisa: el dato ya es `0`. Si
`reiniciar()` notificara siempre, aparecería una línea adicional `Registro: 0`.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué aporta `ChangeNotifier` y quién decide llamar a `notifyListeners()`? **Apartado 1.**
2. ¿Qué dato leen los listeners durante `incrementar()` y por qué importa el orden de las instrucciones? **Apartado 2.**
3. ¿Puede cambiar un dato sin avisar? ¿Puede haber un aviso sin cambio? **Apartado 3.**
4. ¿Dónde está escrita la regla que evita avisar al alcanzar el límite? **Apartado 4.**
5. ¿Qué pasa con dos registros iguales y una retirada entre emisiones? **Apartado 5.**
6. ¿Qué diferencia hay entre retirar un listener y liberar el notificador? **Apartado 6.**
7. ¿Qué pieza conecta el aviso con la construcción del texto? ¿Prueba un aviso que hubo repintado? **Apartado 7.**
8. ¿Cómo cambia el tema el controlador de DaisyUI y por qué no debemos atribuirle `ChangeNotifier`? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques las respuestas con tus palabras.
La siguiente unidad estudia `ValueListenable<T>`, un contrato que combina escucha con lectura de un valor actual.

## Para consultar si necesitas reforzar

- [`ChangeNotifier`](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html): la clase que administra
  listeners y permite notificarlos.
- [`notifyListeners`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/notifyListeners.html): cuándo llamar a
  los listeners y qué ocurre durante una notificación.
- [`addListener`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/addListener.html) y
  [`removeListener`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/removeListener.html): registros y retiradas.
- [`dispose`](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html): fin de la vida del notificador.
- [`ListenableBuilder`](https://api.flutter.dev/flutter/widgets/ListenableBuilder-class.html): conectar una fuente con
  una parte de la interfaz.

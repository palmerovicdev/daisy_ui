# 09. Señales: `signal<T>` y `FlutterSignal<T>`

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 8](08-identidad-igualdad-e-inmutabilidad.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 7 vimos un `ValueNotifier`: guarda un valor, permite sustituirlo y avisa a sus listeners. Ahora
aprenderemos otra forma de guardar estado observable: una **señal** del paquete Signals.

Al terminar podrás crear una señal, leer y cambiar su valor, registrar y retirar un listener y seguir el orden de los
avisos. También sabrás reconocer el objeto señal, el valor que contiene y una lectura hecha en un momento anterior.
Después compararemos estos ejemplos con el controlador de temas que usa DaisyUI.

Los programas de consola completos son independientes. Para ejecutarlos en este proyecto, copia **uno cada vez** a
`test/estudio_senal_test.dart`, añade `import 'package:flutter_test/flutter_test.dart';` junto a sus imports y cambia el
nombre de su `void main()` a `void ejemplo()`. Deja las clases, si las hay, fuera de esa función y añade al final:

```dart
void main() {
  test('práctica de señales', ejemplo);
}
```

Después ejecuta `flutter test --no-pub test/estudio_senal_test.dart` desde la raíz. El test llama a `ejemplo` y
muestra sus `print` en la consola; `--no-pub` requiere las dependencias ya resueltas. La prueba guiada de widgets y la
del controlador ya tienen su propio `main` de test: cópialas sin envolverlas de nuevo. DartPad no incluye
necesariamente `signals_flutter`, por lo que no asumimos que pueda ejecutar estos ejemplos. Predice la salida antes
de mirarla. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar después con Flutter, DaisyUI y el
ejercicio final. Borra tu archivo de práctica cuando termines si no necesitas conservarlo.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals`
7.0.0. Puedes consultar las versiones resueltas en [pubspec.lock](../../../pubspec.lock). Los detalles de las
notificaciones se refieren a las opciones predeterminadas y las secuencias que se muestran. El controlador actual de
DaisyUI guarda su tema en una señal como estas; lo veremos en el apartado 9.

## 1. Una caja que conserva un valor

Imagina que necesitamos guardar el nombre del tema seleccionado. Podemos leerlo cuando lo necesitemos y cambiarlo
cuando el usuario elija otro. Una señal es un objeto que conserva un valor actual y que también permite observar sus
cambios; empezaremos por crearla y leerla.

```dart
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  final FlutterSignal<String> tema = signal<String>('claro');

  print('Inicial: ${tema.value}');
  tema.value = 'oscuro';
  print('Actual: ${tema.value}');

  tema.dispose();
}
```

La salida es:

```text
Inicial: claro
Actual: oscuro
```

Lee la primera línea de `main` por partes:

1. `signal<String>('claro')` llama a una función que crea una señal con el texto inicial `'claro'`.
2. `FlutterSignal<String>` es el tipo del objeto señal que devuelve esa función. `String` indica el tipo del dato que
   contiene; no significa que `tema` sea un texto.
3. `tema` guarda una referencia al objeto señal. `tema.value` consulta el texto actual que esa señal conserva.
4. `tema.value = 'oscuro'` propone un nuevo texto a la **misma señal**. La siguiente lectura devuelve `'oscuro'`.
5. Al terminar, `tema.dispose()` libera la señal que creó este programa. En la unidad 13 estudiaremos en detalle quién
   es responsable de la limpieza.

Puedes imaginar la señal como una caja con una etiqueta para consultar o cambiar lo que contiene. La caja no es el
texto. La analogía no explica cómo funcionan los avisos: los veremos en el apartado 3.

### Practica 1

Si cambiamos la creación a `signal<int>(3)`, ¿qué tipo de valor guarda la señal? ¿Qué devuelve `tema.value` inicialmente
si la variable se declara con el tipo adecuado?

<details>
<summary>Ver respuesta</summary>

Guarda un `int` y la primera lectura devuelve `3`. El objeto sigue siendo una señal: su tipo sería
`FlutterSignal<int>`. Si conservásemos el tipo `FlutterSignal<String>`, el programa no compilaría porque los tipos de
los valores no coinciden.

</details>

## 2. `final`, lectura anterior y valor actual

`final` impide reasignar la variable `tema` para que apunte a otra señal. No impide que la señal admita un nuevo
valor. Además, guardar una lectura no crea una suscripción ni hace que la variable resultante cambie después.

```dart
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  final tema = signal<String>('claro');
  final lecturaAnterior = tema.value;

  tema.value = 'oscuro';

  print('Lectura anterior: $lecturaAnterior');
  print('Lectura actual: ${tema.value}');

  tema.dispose();
}
```

La salida es:

```text
Lectura anterior: claro
Lectura actual: oscuro
```

`final tema = ...` deja que Dart infiera `FlutterSignal<String>` a partir de la expresión de la derecha. La lectura
`tema.value` devuelve el texto que existe en ese momento; `lecturaAnterior` conserva ese texto. Después, la escritura
cambia el valor de la señal, no el texto ya obtenido. Los `String` de este ejemplo son inmutables; con un objeto
mutable compartido habría que distinguir la referencia de su contenido, como vimos en la unidad 8.

### Practica 2

¿Qué mostraría `lecturaAnterior` si añadimos `tema.value = 'bosque';` antes de los dos `print`? ¿Y qué mostraría
la lectura actual?

<details>
<summary>Ver respuesta</summary>

La lectura anterior seguiría siendo `claro`: se guardó antes de ambas escrituras. La lectura actual mostraría
`bosque`, el último valor guardado por la señal. Ninguna escritura ha reasignado la variable `tema`.

</details>

## 3. Escuchar cambios y dejar de escuchar

Leer `.value` una vez responde «¿qué valor hay ahora?». Para enterarnos de cambios futuros necesitamos una observación.
`FlutterSignal` puede utilizarse como `ValueListenable`: permite registrar un listener sin argumentos y retirarlo
usando la misma función. El listener puede leer `.value` cuando recibe el aviso.

```dart
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  final tema = signal<String>('claro');

  void escuchar() {
    print('Aviso: ${tema.value}');
  }

  tema.addListener(escuchar);
  print('Antes de cambiar');
  tema.value = 'oscuro';
  print('Después de cambiar');
  tema.removeListener(escuchar);
  tema.value = 'bosque';
  print('Final: ${tema.value}');

  tema.dispose();
}
```

La salida es:

```text
Antes de cambiar
Aviso: oscuro
Después de cambiar
Final: bosque
```

1. La declaración de `escuchar` crea una función; aún no la ejecuta.
2. `addListener(escuchar)` registra esa función. Con la configuración predeterminada de esta señal, registrarla no
   imprime el valor inicial.
3. Se imprime `Antes de cambiar`. Al proponer `oscuro`, la señal acepta y guarda ese valor; el listener lo lee cuando
   recibe el aviso.
4. En esta secuencia concreta, sin `batch` externo ni escrituras reentrantes, el callback termina antes de que el
   programa imprima `Después de cambiar`.
5. `removeListener(escuchar)` retira el registro. La señal sigue activa y acepta `bosque`, pero esa función ya no se
   ejecuta. Una lectura posterior sí obtiene `bosque`.
6. El programa, que creó la señal, la libera al final.

El aviso no lleva el texto como argumento: `escuchar` consulta el valor ya guardado. La señal no conserva la lista de
valores anteriores; si necesitas un historial, algún objeto debe guardarlo. El orden mostrado es el de este ejemplo:
no lo extrapoles sin comprobar a lotes explícitos o a callbacks que escriben otra vez en una señal.

### Practica 3

Si movemos `tema.removeListener(escuchar)` después de `tema.value = 'bosque'`, ¿qué línea adicional aparecerá y dónde?

<details>
<summary>Ver respuesta</summary>

Aparecerá `Aviso: bosque` después de `Después de cambiar` y antes de `Final: bosque`. El callback sigue registrado
cuando se acepta el segundo cambio y consulta el valor recién guardado. Después se retira con la misma referencia.

</details>

## 4. Una asignación igual no siempre produce un aviso

En la configuración predeterminada de las versiones de esta guía, la señal compara la propuesta con el valor actual
mediante `==`. Si son iguales, conserva el valor que ya tenía y no propaga esa propuesta. Si son distintos, guarda el
nuevo valor y propaga el cambio. Esta es una política de la implementación y configuración estudiadas, no una regla
de todos los tipos que implementan `ValueListenable`.

```dart
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  final tema = signal<String>('claro');
  var avisos = 0;

  void escuchar() {
    avisos++;
    print('Aviso $avisos: ${tema.value}');
  }

  tema.addListener(escuchar);
  tema.value = 'claro';
  tema.value = 'oscuro';
  tema.value = 'oscuro';
  tema.value = 'bosque';

  print('Valor final: ${tema.value}; avisos: $avisos');
  tema.removeListener(escuchar);
  tema.dispose();
}
```

La salida es:

```text
Aviso 1: oscuro
Aviso 2: bosque
Valor final: bosque; avisos: 2
```

La primera propuesta, `claro`, coincide con el valor inicial y se descarta. La segunda cambia el valor a `oscuro` y
produce un aviso. Repetir `oscuro` se descarta; `bosque` sí cambia el valor y produce el segundo aviso. Hubo cuatro
asignaciones al setter y dos ejecuciones del listener.

La comparación de la señal instalada aplica la igualdad de la propuesta frente al valor actual. El `ValueNotifier` de
Flutter compara el actual frente a la propuesta. Una igualdad bien definida es simétrica, así que esa diferencia de
orden no debería cambiar el resultado. La señal también admite opciones de comparación y operaciones avanzadas como
`set(..., force: true)`; no las estamos usando aquí ni las usa el controlador de DaisyUI.

### Practica 4

Partiendo de `claro`, ¿cuántos avisos habría si las propuestas fueran `oscuro`, `claro` y `claro`?

<details>
<summary>Ver respuesta</summary>

Dos. `claro → oscuro` y `oscuro → claro` son cambios. La última propuesta coincide con el valor actual `claro` y se
descarta. La comparación se hace con el valor **vigente en cada paso**, no siempre con el inicial.

</details>

## 5. Objetos distintos que se consideran iguales

En la unidad 8 vimos que identidad e igualdad responden preguntas distintas. Si una señal recibe un objeto diferente
pero `==` lo considera igual al actual, la configuración predeterminada puede conservar el objeto anterior. Vamos a
comprobarlo con el mismo modelo pequeño de nombre y borde:

```dart
import 'package:signals_flutter/signals_flutter.dart';

class TemaSimple {
  const TemaSimple(this.nombre, this.borde);

  final String nombre;
  final int borde;

  @override
  bool operator ==(Object other) =>
      other is TemaSimple && nombre == other.nombre && borde == other.borde;

  @override
  int get hashCode => Object.hash(nombre, borde);
}

void main() {
  final original = TemaSimple('claro', 1);
  final equivalente = TemaSimple('claro', 1);
  final distinto = TemaSimple('claro', 2);
  final tema = signal<TemaSimple>(original);
  var avisos = 0;

  void escuchar() => avisos++;
  tema.addListener(escuchar);

  tema.value = equivalente;
  print('Conserva original: ${identical(tema.value, original)}');
  print('Avisos tras equivalente: $avisos');

  tema.value = distinto;
  print('Guarda distinto: ${identical(tema.value, distinto)}');
  print('Avisos finales: $avisos');

  tema.removeListener(escuchar);
  tema.dispose();
}
```

La salida es:

```text
Conserva original: true
Avisos tras equivalente: 0
Guarda distinto: true
Avisos finales: 1
```

Las tres llamadas al constructor de `main` crean objetos distintos: no se usa `const` al invocarlas. La regla de
`TemaSimple` compara `nombre` y `borde`, por lo que `equivalente == original` da `true`. La señal descarta esa
propuesta y sigue conservando exactamente `original`. `distinto` tiene otro borde; se guarda y provoca un aviso.
`hashCode` usa los mismos datos para mantener el contrato explicado en la unidad 8; no es la comparación que ejecuta
el setter en esta práctica.

### Practica 5

Si `TemaSimple` no definiera `==` y usara la igualdad por identidad de `Object`, ¿qué pasaría al asignar
`equivalente`, creado por separado?

<details>
<summary>Ver respuesta</summary>

Sería distinto de `original` según esa regla de identidad. En esta configuración la señal guardaría `equivalente` y
avisaría una vez, aunque los campos tuvieran los mismos datos. El resultado depende de la igualdad que use el tipo y
de las opciones de la señal.

</details>

## 6. Cambiar una lista por dentro o sustituirla

Una señal que contiene una lista guarda una referencia a ella. Llamar a `add` modifica esa lista; no equivale a
asignar otro valor al setter de la señal. Observemos también qué ve una referencia obtenida antes del cambio:

```dart
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  final temas = signal<List<String>>(<String>['claro']);
  final anterior = temas.value;
  var avisos = 0;

  void escuchar() => avisos++;
  temas.addListener(escuchar);

  temas.value.add('oscuro');
  print('Anterior tras add: $anterior; avisos: $avisos');
  temas.value = temas.value;
  print('Tras reasignar la misma lista: $avisos');
  temas.value = <String>[...temas.value];
  print('Tras asignar una copia: $avisos');
  print('Misma lista: ${identical(anterior, temas.value)}');

  temas.removeListener(escuchar);
  temas.dispose();
}
```

La salida es:

```text
Anterior tras add: [claro, oscuro]; avisos: 0
Tras reasignar la misma lista: 0
Tras asignar una copia: 1
Misma lista: false
```

`anterior` y el valor inicial apuntan a la misma lista; por eso `anterior` ve el `add`. Esa llamada no ejecuta el
setter ni provoca el aviso del ejemplo. Reasignar la misma lista sí pasa por el setter, pero la lista es igual a sí
misma y la propuesta se descarta. La expansión `[...]` crea otra lista exterior; las listas ordinarias del ejemplo
usan igualdad por identidad, así que la nueva lista se acepta aunque tenga los mismos elementos.

La copia exterior no copia necesariamente los objetos que contiene. Para evitar mutaciones accidentales se puede
construir una colección no modificable y decidir explícitamente cómo comparar su contenido, como practicamos en las
unidades 7 y 8. Las APIs especializadas de colecciones de Signals pueden tener otras políticas: aquí usamos una señal
ordinaria que contiene una lista.

### Practica 6

Después de crear la copia, ¿qué pasaría con `anterior` si hacemos `temas.value.add('nieve')`? ¿Se ejecutaría el
listener por esa llamada a `add`?

<details>
<summary>Ver respuesta</summary>

`anterior` seguiría viendo `[claro, oscuro]`: apunta a la lista anterior, no a la copia exterior actual. La copia sí
contendría `nieve`, pero `add` no llama al setter, de modo que en este ejemplo no se añade otro aviso. Si los elementos
fueran objetos mutables compartidos, modificar uno de ellos podría observarse desde ambas listas.

</details>

## 7. Una señal y una vista de lectura

Un consumidor puede necesitar leer el tema y escuchar sin recibir la operación de escritura en su tipo declarado.
`ValueListenable<String>` expresa ese contrato. Podemos referirnos a la misma señal con ese tipo:

```dart
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  final FlutterSignal<String> tema = signal<String>('claro');
  final ValueListenable<String> lectura = tema;

  void escuchar() => print('Vista: ${lectura.value}');
  lectura.addListener(escuchar);
  tema.value = 'oscuro';
  print('Mismo objeto: ${identical(tema, lectura)}');

  lectura.removeListener(escuchar);
  tema.dispose();
}
```

La salida es:

```text
Vista: oscuro
Mismo objeto: true
```

`tema` y `lectura` son dos referencias al mismo objeto. Mediante `lectura`, el tipo `ValueListenable` permite consultar
`value` y registrar o retirar listeners, pero no declara un setter ni `dispose`. Cambiar el tipo de la referencia no
cambia la clase real de la señal ni crea un adaptador. Si alguien recupera el tipo concreto mediante un cast, podría
acceder a otras operaciones; esto no es una barrera absoluta de encapsulación.

En `signals_flutter` 7.1.0, `FlutterSignal` extiende la señal del núcleo e implementa la interfaz de
`ValueNotifier` mediante un mixin; no hereda la implementación de `ChangeNotifier`. El mixin conecta `addListener` con
una suscripción de Signals. Con las opciones predeterminadas omite la llamada inicial al listener externo. En esta
implementación registrar dos veces el mismo callback no crea dos entradas; otras implementaciones, como el
`ChangeNotifier` de la unidad 5, pueden comportarse de manera diferente.

### Practica 7

Si una función recibe solo `ValueListenable<String> lectura`, ¿puede leer el valor? ¿Puede escribir
`lectura.value = 'oscuro'` sin cambiar el tipo declarado?

<details>
<summary>Ver respuesta</summary>

Puede leer `.value` y registrar o retirar un listener. No puede asignar usando solo ese tipo, porque el contrato no
declara el setter. Esto no demuestra que el objeto concreto sea inmutable: en el ejemplo es la misma señal mutable.

</details>

## 8. ¿Cómo llega un cambio a un widget?

Un listener que imprime un valor demuestra que se recibió un aviso. Para mostrar el cambio en pantalla, Flutter
necesita un consumidor conectado a la fuente. `ValueListenableBuilder` es uno de esos consumidores: recibe un
`ValueListenable`, registra su escucha y construye widgets con el valor que recibe en su `builder`.

Este **fragmento** muestra la conexión; necesita estar dentro de un árbol de widgets y que alguien conserve y libere
la señal:

```dart
ValueListenableBuilder<String>(
  valueListenable: tema,
  builder: (context, valor, child) => Text('Tema: $valor'),
)
```

El builder recibe el valor actual en `valor`; `Text` describe el texto que se quiere mostrar. Cuando el consumidor
recibe un aviso, Flutter puede programar una reconstrucción. La asignación y el procesamiento del siguiente frame son
pasos distintos. Una reconstrucción tampoco demuestra por sí sola qué píxeles se repintaron.

### Prueba guiada

Esta prueba completa monta un árbol pequeño, cambia la señal y procesa el siguiente frame con `pump`. Cópiala en
`test/estudio_senal_widget_test.dart` dentro del proyecto y ejecuta
`flutter test --no-pub test/estudio_senal_widget_test.dart` con las dependencias resueltas:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  testWidgets('el builder muestra el valor actual', (tester) async {
    final tema = signal<String>('claro');
    addTearDown(tema.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder<String>(
          valueListenable: tema,
          builder: (context, valor, child) => Text('Tema: $valor'),
        ),
      ),
    );
    expect(find.text('Tema: claro'), findsOneWidget);

    tema.value = 'oscuro';
    await tester.pump();
    expect(find.text('Tema: oscuro'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

`pumpWidget` monta el árbol; `Directionality` aporta la dirección de texto necesaria para este ejemplo. `expect`
comprueba que exista el texto indicado. Después de cambiar la señal, `pump` procesa un frame y la segunda comprobación
encuentra el nuevo texto. Al final desmontamos el árbol antes de que `addTearDown` libere la señal creada por la prueba.
Esta prueba comprueba ese árbol y esa secuencia, no una pantalla física ni todos los posibles repintados.

Una lectura ordinaria de `.value` no registra por sí sola una dependencia de reconstrucción. Signals también ofrece
contextos que rastrean lecturas y `SignalBuilder`; los estudiaremos en la unidad 10, sin confundirlos con este
`ValueListenableBuilder`.

### Practica 8

Si solo creamos la señal, leemos una vez `tema.value` y construimos un `Text` con ese texto, ¿queda registrado un
listener por el mero hecho de haber leído `.value`?

<details>
<summary>Ver respuesta</summary>

No. Esa lectura ordinaria obtiene un valor puntual; no crea por sí sola una suscripción para reconstruir el widget.
En la prueba guiada, `ValueListenableBuilder` establece la escucha y Flutter procesa la actualización. La unidad 10
explicará los contextos de lectura rastreada de Signals.

</details>

## 9. ¿Dónde aparece esto en DaisyUI?

El [controlador actual](../../../lib/themes/application/daisy_theme_controller.dart) guarda el tema en una señal:

```dart
DaisyThemeController({
  DaisyThemeModel initialTheme = DaisyThemes.light,
}) : _palette = FlutterSignal<DaisyThemeModel>(initialTheme);

final FlutterSignal<DaisyThemeModel> _palette;

late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(
  _palette,
);

ValueListenable<DaisyThemeModel> get theme => _theme;

void setTheme(DaisyThemeModel theme) => _palette.value = theme;

void dispose() => _palette.dispose();
```

Es un fragmento de la clase real, no un programa completo. Cada controlador crea su propia señal privada `_palette`
llamando directamente al constructor `FlutterSignal`; la función `signal` del apartado 1 hace esa misma llamada.
`setTheme` asigna a la señal, así que se aplica la comparación del apartado 4, y `dispose` delega su limpieza.

A diferencia de la vista de lectura del apartado 7, `theme` no devuelve la misma señal con otro tipo. Devuelve otro
objeto, que cumple el contrato `ValueListenable` y reenvía cada operación a la señal:

```dart
final class _ThemeListenable implements ValueListenable<DaisyThemeModel> {
  _ThemeListenable(this._source);

  final FlutterSignal<DaisyThemeModel> _source;

  @override
  DaisyThemeModel get value => _source.value;

  @override
  void addListener(VoidCallback listener) {
    _source.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _source.removeListener(listener);
  }
}
```

Este objeto no guarda otro tema: sigue habiendo una sola fuente. Pero como su clase real no es una señal, un cast a
`FlutterSignal` falla, cosa que no ocurría en el apartado 7. La unidad 16 estudia esta decisión con detalle.

El [scope](../../../lib/themes/application/daisy_theme_scope.dart) recibe esa vista y usa `InheritedNotifier` para
conectar sus avisos con consumidores que registran una dependencia heredada. Esa conexión se estudiará más adelante. La
señal guarda el tema y avisa; no se le puede atribuir por sí sola la reconstrucción de los widgets.

### Prueba guiada

Puedes ejecutar esta prueba dentro del proyecto para observar el controlador real:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('la vista escucha la señal del controlador', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    final lectura = controller.theme;
    final avisos = <String>[];
    void escuchar() => avisos.add(lectura.value.name);

    expect(lectura, isNot(isA<FlutterSignal<DaisyThemeModel>>()));

    lectura.addListener(escuchar);
    controller.setTheme(DaisyThemes.dark);
    lectura.removeListener(escuchar);
    controller.setTheme(DaisyThemes.cupcake);

    expect(avisos, ['Dark']);
    expect(lectura.value, DaisyThemes.cupcake);
  });
}
```

La primera comprobación muestra que la vista no es una señal. La lista conserva `Dark` porque el listener estaba
registrado durante ese cambio. Después de retirarlo, el controlador sigue cambiando y la lectura actual obtiene
`cupcake`, sin añadir otro aviso. La prueba muestra lectura y escucha; no demuestra una reconstrucción de widgets.

### Practica 9

Si dos controladores se crean por separado y cambiamos el tema de uno, ¿se modifica por ello la señal del otro?
¿Qué pieza del constructor permite razonarlo?

<details>
<summary>Ver respuesta</summary>

No por ese cambio: cada constructor ejecuta `FlutterSignal<DaisyThemeModel>(initialTheme)` y guarda su propia señal en
`_palette`. Los valores iniciales pueden coincidir, pero los controladores creados por separado administran fuentes
distintas.

</details>

## Ejercicio final: un selector de tema

Escribe un programa Flutter de consola que:

1. Declare una clase `SelectorTema` con una señal privada de `String`, inicializada en `'claro'`.
2. Exponga esa señal mediante un getter de tipo `ValueListenable<String>`, un método `seleccionar` y un método
   `dispose` que libere la señal.
3. Cree un selector, conserve la lectura inicial y registre un listener que imprima cada valor recibido y cuente avisos.
4. Seleccione `'oscuro'`, otra vez `'oscuro'` y después `'bosque'`; retire el listener y seleccione `'claro'`.
5. Imprima la lectura inicial, el valor actual y el número de avisos; libere el selector.

Predice la salida antes de mirar la solución. Como variaciones, mueve la retirada después de la última selección y
explica qué cambia; después crea dos selectores y comprueba que cambiar uno no modifica el otro.

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/foundation.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SelectorTema {
  final FlutterSignal<String> _tema = signal<String>('claro');

  ValueListenable<String> get tema => _tema;

  void seleccionar(String nuevo) => _tema.value = nuevo;

  void dispose() => _tema.dispose();
}

void main() {
  final selector = SelectorTema();
  final lectura = selector.tema;
  final inicial = lectura.value;
  var avisos = 0;

  void escuchar() {
    avisos++;
    print('Aviso $avisos: ${lectura.value}');
  }

  lectura.addListener(escuchar);
  selector.seleccionar('oscuro');
  selector.seleccionar('oscuro');
  selector.seleccionar('bosque');
  lectura.removeListener(escuchar);
  selector.seleccionar('claro');

  print('Inicial: $inicial');
  print('Actual: ${lectura.value}; avisos: $avisos');
  selector.dispose();
}
```

```text
Aviso 1: oscuro
Aviso 2: bosque
Inicial: claro
Actual: claro; avisos: 2
```

La primera selección de `oscuro` y la de `bosque` cambian el valor; repetir `oscuro` se descarta. La última selección
se acepta, pero el listener ya no está registrado. La lectura inicial conserva el texto anterior y la lectura actual
obtiene `claro`. El selector posee la señal; el programa retira el listener que registró y al final libera el selector.

Si retiramos el listener después de la última selección, aparece `Aviso 3: claro`. Dos selectores construidos por
separado crean señales distintas, por lo que cambiar uno no modifica el valor almacenado por el otro. La vista
`ValueListenable` limita las operaciones disponibles por ese tipo; para ocultar la fuente mutable frente a un cast se
necesita un objeto de lectura separado, que es lo que hace `_ThemeListenable` en DaisyUI.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué devuelve `signal<String>('claro')` y qué devuelve su `.value`? **Apartado 1.**
2. ¿Qué impide `final` y por qué una lectura anterior no cambia al escribir en la señal? **Apartado 2.**
3. ¿Quién llama al listener, cómo obtiene el valor actual y cómo deja de recibir avisos? **Apartado 3.**
4. ¿Por qué cuatro asignaciones pueden producir solo dos avisos? **Apartado 4.**
5. ¿Por qué se conserva `original` cuando se propone un objeto distinto pero igual? **Apartado 5.**
6. ¿Por qué `value.add(...)` no avisa y asignar una lista exterior nueva sí puede avisar? **Apartado 6.**
7. ¿Qué permite `ValueListenable` y por qué no vuelve inmutable el objeto real? **Apartado 7.**
8. ¿Qué conecta la señal con el widget de la prueba y para qué sirve `pump`? **Apartado 8.**
9. ¿Qué objeto guarda el tema en el controlador actual y qué devuelve su getter `theme`? **Apartado 9.**
10. ¿Quién retira una escucha y quién libera la señal creada en las prácticas? **Apartados 3 y 9.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques con tus palabras qué se crea, qué
se guarda, quién escucha y cuándo se avisa. La siguiente unidad profundiza en dependencias reactivas y
`SignalBuilder`.

## Para consultar si necesitas reforzar

- [`signal<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/signal.html) y
  [`FlutterSignal<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html):
  creación de la señal y contratos que implementa.
- [`SignalOptions`](https://pub.dev/documentation/signals_core/latest/signals_core/SignalOptions-class.html): opciones
  de Signals; compara la documentación `latest` con la versión resuelta en el proyecto.
- [`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) y
  [`ValueListenableBuilder<T>`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html): lectura,
  escucha y conexión con widgets.
- [Controlador de temas](../../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../../lib/themes/application/daisy_theme_scope.dart) y
  [pruebas del controlador](../../../test/themes/daisy_theme_controller_test.dart): uso real en DaisyUI.

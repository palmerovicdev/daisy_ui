# 16. Vistas de lectura, getters y delegación

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 15](15-construccion-del-controlador-y-sintaxis-de-dart.md) · **Estado:** pendiente

## Qué vas a aprender

Imagina que un selector guarda el tema en una señal privada. Cualquier parte de la aplicación debe poder leer el tema y enterarse de sus cambios, pero solo el selector debería decidir cómo se cambia. ¿Basta con devolver la señal con otro tipo declarado, o hace falta entregar un objeto diferente?

Al terminar podrás leer el getter `theme` de `DaisyThemeController` y explicar qué objeto devuelve. Distinguirás dos estrategias: **limitar el tipo** de una referencia al mismo objeto y **crear un adaptador** que reenvía las operaciones. También sabrás para qué sirve el `late final` del controlador y por qué el adaptador conserva el rastreo de Signals.

Los ejemplos completos son pruebas independientes. Copia **una cada vez** a `test/estudio_vistas_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_vistas_test.dart
```

Necesitas las dependencias ya resueltas. Antes de mirar cada `expect` o la salida, intenta predecir el resultado. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar después con DaisyUI y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Cada prueba cabe en un solo archivo, así que su `main` pertenece a la misma biblioteca que las clases y **podría** acceder a sus miembros privados, como vimos en la unidad 15. En el proyecto real, una prueba o una aplicación están en otra biblioteca y no pueden hacerlo.

## 1. Un getter parece un campo, pero ejecuta código

Empecemos por la sintaxis. Un **getter** es un método que se declara con `get` y se llama sin paréntesis. Quien lo usa escribe lo mismo que para leer un campo, pero cada acceso ejecuta su cuerpo:

```dart
import 'package:flutter_test/flutter_test.dart';

class Tema {
  Tema(this.nombre) : etiquetaGuardada = 'Tema: $nombre';

  String nombre;
  final String etiquetaGuardada;

  String get etiqueta {
    print('Calculo la etiqueta de $nombre');
    return 'Tema: $nombre';
  }
}

void main() {
  test('un getter se ejecuta en cada acceso', () {
    final tema = Tema('claro');
    print('Objeto creado');

    expect(tema.etiqueta, 'Tema: claro');
    expect(tema.etiqueta, 'Tema: claro');

    tema.nombre = 'oscuro';
    expect(tema.etiqueta, 'Tema: oscuro');
    expect(tema.etiquetaGuardada, 'Tema: claro');
  });
}
```

Entre los mensajes de la prueba verás esta salida:

```text
Objeto creado
Calculo la etiqueta de claro
Calculo la etiqueta de claro
Calculo la etiqueta de oscuro
```

Paso a paso:

1. El constructor guarda `claro` en `nombre` y `Tema: claro` en `etiquetaGuardada`. No ejecuta el getter: por eso `Objeto creado` aparece primero.
2. Cada `tema.etiqueta` ejecuta el cuerpo y construye el texto en ese momento. Dos accesos son dos ejecuciones.
3. Después de cambiar `nombre`, el getter usa el valor actual, mientras que `etiquetaGuardada` conserva el texto calculado al crear el objeto.

Si el cuerpo es una sola expresión se puede usar `=>`, como en `String get etiqueta => 'Tema: $nombre';`. Este getter no tiene un setter asociado, así que `tema.etiqueta = 'otra'` no compila. Algo parecido ocurre con un campo `final`: Dart genera solo su getter. Por eso un contrato que declara un getter, como `value` en `ValueListenable`, puede cumplirse tanto con un getter como con un campo `final`. Lo aprovecharemos en el apartado 6.

### Practica 1

Si añadimos una tercera lectura de `tema.etiqueta` al final de la prueba, ¿aparece otra línea en la salida? ¿Y si leemos `tema.etiquetaGuardada` diez veces?

<details>
<summary>Ver respuesta</summary>

La tercera lectura añade otra línea `Calculo la etiqueta de oscuro`: un getter ejecuta su cuerpo en cada acceso. Leer el campo `etiquetaGuardada` no imprime nada porque devuelve un texto que ya está guardado y su lectura no ejecuta ese cuerpo.

</details>

## 2. Primera estrategia: limitar el tipo

En las unidades 7 y 9 vimos una forma sencilla de ofrecer una vista de lectura: guardar una referencia a la señal con un tipo que no declara el setter. Veamos qué protege exactamente y qué no.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class SelectorTema {
  SelectorTema() : _tema = signal<String>('claro');

  final FlutterSignal<String> _tema;

  ValueListenable<String> get tema => _tema;

  void seleccionar(String nuevoTema) => _tema.value = nuevoTema;

  void dispose() => _tema.dispose();
}

void main() {
  test('el getter devuelve la propia señal', () {
    final selector = SelectorTema();
    addTearDown(selector.dispose);

    expect(selector.tema.value, 'claro');
    expect(identical(selector.tema, selector._tema), isTrue);
    expect(selector.tema is FlutterSignal<String>, isTrue);

    final recuperada = selector.tema as FlutterSignal<String>;
    recuperada.value = 'oscuro';
    expect(selector.tema.value, 'oscuro');
  });
}
```

El recorrido es:

1. `selector.tema` ejecuta el getter, que devuelve la referencia guardada en `_tema`. No crea ningún objeto.
2. `identical` lo confirma: solo hay una señal. La prueba puede leer `_tema` porque está en el mismo archivo.
3. `is` pregunta por el **objeto real**, no por el tipo declarado, y responde que sí es un `FlutterSignal<String>`.
4. `as` convierte la referencia a ese tipo. El tipo declarado volvió a incluir el setter y `recuperada.value = 'oscuro'` cambia el tema sin pasar por `seleccionar`.

Este fragmento, en cambio, no compila, porque `ValueListenable` no declara un setter `value`:

```dart
selector.tema.value = 'oscuro';
```

Limitar el tipo protege frente a errores involuntarios: el editor no ofrece esa operación y el código normal no puede llamarla. Sirve también para comunicar la intención de la API. Pero no separa nada en tiempo de ejecución. Quien conozca el tipo real puede recuperarlo con un cast y el selector deja de ser el único camino para cambiar el tema.

### Practica 2

Si añadimos un cast a `ValueNotifier<String>` en lugar de `FlutterSignal<String>`, ¿funcionará? Razónalo con lo que vimos en la unidad 9 sobre los contratos que cumple `FlutterSignal`.

<details>
<summary>Ver respuesta</summary>

Sí. `FlutterSignal<T>` implementa `ValueNotifier<T>`, así que el objeto real también cumple ese tipo. El cast no cambia el objeto: solo cambia qué operaciones permite la referencia. Mediante `ValueNotifier<String>` también existe un setter `value`, de modo que se podría cambiar el tema.

</details>

## 3. Segunda estrategia: un adaptador que delega

Podemos entregar **otro objeto**, que cumpla `ValueListenable<String>` y que por dentro conserve una referencia a la señal. Cada operación del contrato se reenvía a la señal. Ese objeto se llama **adaptador**: presenta una fuente a través de la interfaz que necesita quien la consume. Reenviar una operación a otro objeto se llama **delegar**.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class LecturaTema implements ValueListenable<String> {
  LecturaTema(this._fuente);

  final FlutterSignal<String> _fuente;

  @override
  String get value => _fuente.value;

  @override
  void addListener(VoidCallback listener) {
    _fuente.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _fuente.removeListener(listener);
  }
}

void main() {
  test('el adaptador es otro objeto', () {
    final fuente = signal<String>('claro');
    addTearDown(fuente.dispose);
    final ValueListenable<String> lectura = LecturaTema(fuente);

    expect(identical(lectura, fuente), isFalse);
    expect(lectura is FlutterSignal<String>, isFalse);
    expect(lectura is ValueNotifier<String>, isFalse);
    expect(() => lectura as FlutterSignal<String>, throwsA(isA<TypeError>()));

    final avisos = <String>[];
    void escuchar() => avisos.add(lectura.value);

    lectura.addListener(escuchar);
    fuente.value = 'oscuro';
    lectura.removeListener(escuchar);
    fuente.value = 'bosque';

    expect(avisos, ['oscuro']);
    expect(lectura.value, 'bosque');
  });
}
```

Paso a paso:

1. `LecturaTema(fuente)` crea un objeto nuevo con un único campo: una referencia a la señal. No copia el texto; solo hay una señal y un dato.
2. `is` responde `false` para `FlutterSignal` y `ValueNotifier`: la clase real es `LecturaTema`. Por eso el cast lanza un `TypeError`. No hay ningún tipo al que convertir la referencia para obtener un setter, porque este objeto no lo tiene.
3. `lectura.addListener(escuchar)` llama al método del adaptador, y este reenvía la misma función a la señal. El listener queda registrado en la señal; el adaptador no conserva una lista propia.
4. `fuente.value = 'oscuro'` hace que la señal avise. `escuchar` lee `lectura.value`, que a su vez lee `_fuente.value`.
5. Retirar el listener mediante el adaptador lo retira de la señal, y `bosque` ya no añade ningún aviso.

Aquí aparecen dos formas de relacionar clases. **Heredar** o implementar expresa «es un»: `LecturaTema` **es un** `ValueListenable<String>`, porque cumple ese contrato. **Composición** expresa «tiene un»: `LecturaTema` **tiene una** señal en un campo y la usa para hacer su trabajo, sin exponer el resto de sus operaciones.

Una analogía: una ventanilla de información atiende consultas y avisos consultando a la oficina interna, pero desde el mostrador no se puede modificar el archivo. La analogía termina ahí: el adaptador no filtra ni interpreta nada, solo reenvía las llamadas.

### Lo que un adaptador tampoco impide

El adaptador esconde la **señal**, no todo lo que pase por ella. Si el valor es un objeto mutable, `value` entrega una referencia a ese mismo objeto. En este **fragmento**, `lectura` sería un adaptador como el anterior, pero sobre una señal de tipo `List<String>`:

```dart
lectura.value.add('oscuro');
```

Quien solo tiene la vista ha modificado la lista que guarda la señal, y nadie recibe un aviso: es el problema de la unidad 7 con otro envoltorio. En DaisyUI esto no ocurre porque `DaisyThemeModel` es inmutable (unidad 8): para otro tema hace falta crear otro modelo y entregarlo al controlador. Un adaptador y un valor inmutable se complementan.

### Practica 3

Con solo una referencia `ValueListenable<String> lectura` que apunta a un `LecturaTema`, ¿qué operaciones puede hacer el consumidor? ¿Por qué el cast a `FlutterSignal<String>` del apartado 2 funcionaba y este falla?

<details>
<summary>Ver respuesta</summary>

Puede leer `value` y registrar o retirar listeners. El cast comprueba el objeto real: en el apartado 2 era una señal, así que la comprobación se cumplía; aquí es un `LecturaTema`, que no es una señal aunque guarde una dentro. Por eso lanza un `TypeError`.

</details>

## 4. `late final`: crear el adaptador una sola vez

Ahora queremos que `SelectorTema` cree su adaptador y siempre entregue el mismo. Lo natural sería escribir esto, pero este **fragmento** no compila:

```dart
final ValueListenable<String> _vista = LecturaTema(_tema);
```

El inicializador de un campo normal se ejecuta antes de que el objeto esté disponible, como vimos con la lista de inicialización en la unidad 15. En ese momento no se puede leer otro campo de la instancia como `_tema`. La palabra `late` cambia cuándo se ejecuta el inicializador: se **retrasa hasta la primera lectura**, cuando el objeto ya está construido y `_tema` ya tiene su valor. `final` sigue indicando que el campo no se reasigna. Esta espera se llama **inicialización diferida**.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

var adaptadoresCreados = 0;

final class _LecturaTema implements ValueListenable<String> {
  _LecturaTema(this._fuente) {
    adaptadoresCreados++;
    print('Se crea el adaptador');
  }

  final FlutterSignal<String> _fuente;

  @override
  String get value => _fuente.value;

  @override
  void addListener(VoidCallback listener) => _fuente.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _fuente.removeListener(listener);
}

final class SelectorTema {
  SelectorTema() : _tema = signal<String>('claro');

  final FlutterSignal<String> _tema;

  late final ValueListenable<String> _vista = _LecturaTema(_tema);

  ValueListenable<String> get tema => _vista;

  void seleccionar(String nuevoTema) => _tema.value = nuevoTema;

  void dispose() => _tema.dispose();
}

void main() {
  test('late final crea el adaptador en el primer acceso', () {
    final selector = SelectorTema();
    addTearDown(selector.dispose);
    print('Selector creado');
    expect(adaptadoresCreados, 0);

    final primera = selector.tema;
    print('Primer acceso hecho');
    expect(adaptadoresCreados, 1);

    final segunda = selector.tema;
    print('Segundo acceso hecho');
    expect(adaptadoresCreados, 1);
    expect(identical(primera, segunda), isTrue);
  });
}
```

Entre los mensajes de la prueba verás:

```text
Selector creado
Se crea el adaptador
Primer acceso hecho
Segundo acceso hecho
```

Paso a paso:

1. El constructor ejecuta su lista de inicialización y crea la señal. `_vista` todavía no tiene valor, y el contador sigue en 0.
2. `selector.tema` ejecuta el getter, que lee `_vista`. Como es la primera lectura, se ejecuta el inicializador: se crea el adaptador y se guarda.
3. El segundo acceso ejecuta otra vez el getter, pero `_vista` ya tiene valor y no se vuelve a inicializar. Las dos variables referencian el mismo adaptador.

Compara los dos momentos. `_tema` se inicializa en la lista del constructor, porque la señal es imprescindible desde el principio y se calcula con datos que ya están disponibles. `_vista` depende de `_tema`, así que usa `late` para poder leerlo. La razón principal de `late` aquí es poder usar el campo; no crear el adaptador si nadie lo pide es una consecuencia menor, porque se trata de un objeto muy pequeño.

### Practica 4

Si creamos un selector, llamamos a `seleccionar('oscuro')` y no leemos nunca `selector.tema`, ¿cuántos adaptadores se crean? ¿Se pierde el cambio de tema?

<details>
<summary>Ver respuesta</summary>

No se crea ninguno: `seleccionar` usa `_tema` directamente y nadie lee `_vista`. El cambio no se pierde porque se guarda en la señal. Si más tarde se lee `selector.tema`, el adaptador se crea en ese momento y su `value` devuelve `oscuro`, porque lee la fuente en lugar de guardar una copia.

</details>

## 5. ¿Una instancia o muchas?

¿Hace falta realmente guardar el adaptador? Podríamos crearlo en el propio getter y evitar el campo. Esta variante funciona para leer y escuchar, pero cambia la identidad. La siguiente prueba ofrece los dos getters en el mismo selector e incluye un consumidor sencillo que recuerda qué fuente tenía y cuenta cuántas veces cree que se la han cambiado:

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class LecturaTema implements ValueListenable<String> {
  LecturaTema(this._fuente);

  final FlutterSignal<String> _fuente;

  @override
  String get value => _fuente.value;

  @override
  void addListener(VoidCallback listener) => _fuente.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _fuente.removeListener(listener);
}

final class SelectorTema {
  SelectorTema() : _tema = signal<String>('claro');

  final FlutterSignal<String> _tema;

  late final ValueListenable<String> _vista = LecturaTema(_tema);

  ValueListenable<String> get estable => _vista;

  ValueListenable<String> get nuevaCadaVez => LecturaTema(_tema);

  void seleccionar(String nuevoTema) => _tema.value = nuevoTema;

  void dispose() => _tema.dispose();
}

final class Consumidor {
  ValueListenable<String>? _anterior;
  var cambiosDeFuente = 0;

  void recibir(ValueListenable<String> fuente) {
    if (fuente != _anterior) {
      cambiosDeFuente++;
      _anterior = fuente;
    }
  }
}

void main() {
  test('la identidad del adaptador', () {
    final selector = SelectorTema();
    addTearDown(selector.dispose);

    expect(identical(selector.estable, selector.estable), isTrue);
    expect(identical(selector.nuevaCadaVez, selector.nuevaCadaVez), isFalse);

    final avisos = <String>[];
    void escuchar() => avisos.add(selector.nuevaCadaVez.value);
    selector.nuevaCadaVez.addListener(escuchar);
    selector.seleccionar('oscuro');
    selector.nuevaCadaVez.removeListener(escuchar);
    selector.seleccionar('bosque');
    expect(avisos, ['oscuro']);

    final primero = Consumidor();
    final segundo = Consumidor();
    for (var i = 0; i < 3; i++) {
      primero.recibir(selector.estable);
      segundo.recibir(selector.nuevaCadaVez);
    }
    expect(primero.cambiosDeFuente, 1);
    expect(segundo.cambiosDeFuente, 3);
  });
}
```

El recorrido es:

1. `estable` entrega siempre el mismo adaptador. `nuevaCadaVez` ejecuta `LecturaTema(_tema)` en cada acceso y entrega uno distinto.
2. La retirada del listener funciona aunque se registró con un adaptador y se retiró con otro. Ambos reenvían a la misma señal. En `signals_flutter` 7.1.0, la señal conserva los listeners en un mapa cuya clave es la función recibida; lo que importa es la identidad de `escuchar`, no la del adaptador que la entregó.
3. `Consumidor` compara con `!=`. `LecturaTema` no redefine `==`, así que se aplica la regla por defecto de la unidad 8: dos objetos son iguales solo si son el mismo. El primero ve una fuente y mantiene el contador en 1 en las tres entregas. El segundo cuenta 3 aunque en realidad todos sus adaptadores lean la misma señal.

Ese consumidor se ha inventado para el ejemplo, pero la comparación es real. Más adelante veremos que el scope de DaisyUI recibe la vista cada vez que se reconstruye y Flutter compara la referencia con la anterior para saber si cambió la fuente. Con un adaptador nuevo en cada acceso, cada reconstrucción parecería un cambio de fuente. La unidad 22 estudia ese mecanismo; por ahora basta con esta regla: **si otro código puede comparar la referencia, debe mantenerse estable**.

### Practica 5

Imagina que `LecturaTema` redefine `==` y `hashCode` para que dos adaptadores de la misma fuente sean iguales. ¿Qué valor tendría `segundo.cambiosDeFuente`? ¿Qué seguiría respondiendo `identical`?

<details>
<summary>Ver respuesta</summary>

Valdría 1, porque `!=` dejaría de ver una fuente distinta. `identical` seguiría respondiendo `false`: siguen siendo objetos diferentes, y la regla de `==` no cambia eso (unidad 8). Funcionaría, pero añade una regla de igualdad y sigue creando un objeto en cada acceso. Guardar una sola instancia con `late final` es más sencillo.

</details>

## 6. La delegación conserva el rastreo

¿Se pierde la reactividad de Signals al poner un objeto por medio? Recuerda la unidad 10: lo que registra la dependencia es que `_fuente.value` se **ejecute** durante un callback observado. Quien llama importa poco; importa qué lectura ocurre y cuándo. Un adaptador que delega ejecuta esa lectura en cada acceso. Otro que copia el valor al crearse, no.

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class LecturaTema implements ValueListenable<String> {
  LecturaTema(this._fuente);

  final FlutterSignal<String> _fuente;

  @override
  String get value => _fuente.value;

  @override
  void addListener(VoidCallback listener) => _fuente.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _fuente.removeListener(listener);
}

final class CopiaTema implements ValueListenable<String> {
  CopiaTema(this._fuente) : value = _fuente.value;

  final FlutterSignal<String> _fuente;

  @override
  final String value;

  @override
  void addListener(VoidCallback listener) => _fuente.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _fuente.removeListener(listener);
}

void main() {
  testWidgets('delegar frente a copiar', (tester) async {
    final fuente = signal<String>('claro');
    addTearDown(fuente.dispose);
    final ValueListenable<String> delegada = LecturaTema(fuente);
    final ValueListenable<String> copia = CopiaTema(fuente);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            SignalBuilder(builder: (_) => Text('Delega: ${delegada.value}')),
            SignalBuilder(builder: (_) => Text('Copia: ${copia.value}')),
          ],
        ),
      ),
    );

    fuente.value = 'oscuro';
    await tester.pump();

    expect(find.text('Delega: oscuro'), findsOneWidget);
    expect(find.text('Copia: claro'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Después del cambio y de `pump`, el resultado esperado es:

```text
Delega: oscuro
Copia: claro
```

1. El primer `SignalBuilder` ejecuta `delegada.value` durante su callback. El getter ejecuta `_fuente.value` en ese mismo momento, de modo que la lectura de la señal queda rastreada aunque el callback no mencione la señal.
2. El segundo ejecuta `copia.value`, un campo `final` que ya tiene su texto: nunca llega a leer la señal durante el callback. Esa lectura ocurrió antes, en la lista de inicialización del constructor, fuera de cualquier observación.
3. Al cambiar la fuente, solo el primero pide otra construcción. El segundo sigue mostrando `claro`.

`CopiaTema` tiene además un fallo más sutil: sus listeners sí reciben avisos, pero al leer `value` obtienen el texto antiguo. El contrato de `ValueListenable` promete que `value` devuelve el valor **actual**. Copiar rompe esa promesa.

### El rastreo con el controlador real

`_ThemeListenable` delega como `LecturaTema`, así que `computed` y `effect` también registran la señal privada del controlador. Esta prueba usa los objetos reales del proyecto:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('computed y effect a través de la vista real', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    final etiqueta = computed(() => 'Tema: ${controller.theme.value.name}');
    addTearDown(etiqueta.dispose);
    expect(etiqueta.value, 'Tema: Light');

    final rastreadas = <String>[];
    final sinRastrear = <String>[];
    final detenerRastreado = effect(() {
      rastreadas.add(controller.theme.value.name);
    });
    final detenerSinRastrear = effect(() {
      sinRastrear.add(untracked(() => controller.theme.value.name));
    });

    controller.setTheme(DaisyThemes.dark);

    expect(etiqueta.value, 'Tema: Dark');
    expect(rastreadas, ['Light', 'Dark']);
    expect(sinRastrear, ['Light']);

    detenerRastreado();
    detenerSinRastrear();
  });
}
```

El `computed` y el primer `effect` leen `controller.theme.value`, que lee la señal privada dentro de su contexto. Por eso el cambio a `dark` actualiza la etiqueta y añade `Dark` al registro. El segundo efecto hace la misma lectura dentro de `untracked`, que ejecuta su función sin registrar lo que lee, así que no se vuelve a ejecutar.

¿Por qué `untracked` y no `peek()`, que vimos en la unidad 10? `controller.theme` tiene tipo `ValueListenable`, y ese contrato no declara `peek`: `controller.theme.peek()` no compila. Es otra consecuencia de la frontera: la vista solo ofrece lo que promete `ValueListenable`, aunque por dentro haya una señal.

### Practica 6

En `CopiaTema`, ¿qué texto leería un listener registrado cuando la fuente pasa a `oscuro`? ¿Qué hay que cambiar para que deje de quedarse antiguo y se rastree dentro de un `SignalBuilder`?

<details>
<summary>Ver respuesta</summary>

El listener recibiría el aviso, porque se registró en la señal, pero leería `claro`, el texto copiado. Hay que sustituir el campo por el getter `String get value => _fuente.value;` y quitar la inicialización `value = _fuente.value`. Entonces cada acceso lee la fuente: obtiene el valor actual y, durante un callback observado, registra la dependencia.

</details>

## 7. Otras opciones: `readonly()` y `computed`

Signals ya tiene algo llamado `readonly()`. ¿Por qué no usarlo? Veamos qué objeto devuelve y comparémoslo con un `computed`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('readonly y computed no son lo mismo', () {
    final fuente = signal<String>('claro');
    addTearDown(fuente.dispose);

    final soloLectura = fuente.readonly();
    expect(identical(soloLectura, fuente), isTrue);
    expect(soloLectura is FlutterSignal<String>, isTrue);

    final derivado = computed(() => fuente.value);
    addTearDown(derivado.dispose);
    expect(identical(derivado, fuente), isFalse);
    expect(derivado is FlutterSignal<String>, isFalse);

    fuente.value = 'oscuro';
    expect(soloLectura.value, 'oscuro');
    expect(derivado.value, 'oscuro');
  });
}
```

`readonly()` está definido en `signals_core` 7.0.0 como `ReadonlySignal<T> readonly() => this;` y `FlutterSignal` no lo redefine. Por tanto, devuelve **el mismo objeto** con otro tipo declarado: es la estrategia del apartado 2, no un adaptador. Un cast recupera el setter.

`computed(() => fuente.value)` sí crea otro objeto que no es una señal escribible. Pero, como vimos en la unidad 11, es un cálculo con su propia caché, sus propias dependencias y su propia vida útil: alguien debe liberarlo.

| Estrategia                          | ¿Otro objeto? | ¿Un cast recupera el setter? | ¿Hay que liberarlo aparte? |
|-------------------------------------|---------------|------------------------------|----------------------------|
| Limitar el tipo (`ValueListenable`) | No            | Sí                           | No                         |
| `fuente.readonly()`                 | No            | Sí                           | No                         |
| `computed(() => fuente.value)`      | Sí            | No                           | Sí                         |
| Adaptador que delega                | Sí            | No                           | No                         |

Ninguna opción es universalmente mejor. Limitar el tipo es lo más simple y suele bastar dentro de un mismo equipo o módulo. Un `computed` tiene sentido cuando el valor se transforma o se necesitan sus operaciones de señal. El adaptador cuesta unas pocas líneas más y compensa cuando el tipo público debe esconder de verdad la fuente mutable.

### Practica 7

Alguien propone escribir `ReadonlySignal<String> get tema => _tema.readonly();` en el selector, porque «así el tema queda de solo lectura». ¿Es cierto? ¿Qué comprobación usarías para responder?

<details>
<summary>Ver respuesta</summary>

Solo en parte. El tipo declarado no ofrece un setter, de modo que el código normal no puede escribir. Pero `identical(selector.tema, selector._tema)` respondería `true`: sigue siendo la misma señal, y un cast a `FlutterSignal<String>` recuperaría el setter. Ofrece la protección del apartado 2, no la del adaptador. Lo que dice «de solo lectura» es el tipo declarado, no el objeto.

</details>

## 8. El controlador real de DaisyUI

Ya tenemos todas las piezas para leer el [controlador de temas](../../../lib/themes/application/daisy_theme_controller.dart) completo. Es un **fragmento** porque omite los `import`:

```dart
final class DaisyThemeController {
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
}

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

Hay tres objetos. El controlador guarda dos referencias y el adaptador, una:

```text
DaisyThemeController
  ├─ _palette ───────────────► FlutterSignal<DaisyThemeModel>
  └─ _theme ──► _ThemeListenable       ▲    (guarda el tema y los listeners)
                  └─ _source ──────────┘
```

Sigamos `controller.theme.addListener(escuchar)`:

1. `controller.theme` ejecuta el getter, que lee `_theme`. La primera vez, `late final` crea el `_ThemeListenable` con la misma señal de `_palette`.
2. `addListener(escuchar)` se ejecuta en el adaptador, que llama a `_source.addListener(escuchar)`. El registro queda en la señal.
3. `controller.setTheme(DaisyThemes.dark)` escribe en `_palette.value`. La señal compara con `==`, como en las unidades 8 y 9, y al aceptar el valor llama a `escuchar`.
4. `escuchar` lee `controller.theme.value`. El adaptador lee `_source.value` y devuelve el modelo actual.

El consumidor solo ve `value`, `addListener` y `removeListener`. Para cambiar el tema debe usar `setTheme`, y el propietario es quien llama a `dispose`. Como `_ThemeListenable` empieza por `_`, su nombre tampoco existe fuera de esta biblioteca: otro archivo ni siquiera puede escribirlo como tipo. Esta prueba se ejecuta como código externo:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

void main() {
  test('theme es un adaptador estable', () {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    final vista = controller.theme;

    expect(identical(vista, controller.theme), isTrue);
    expect(vista is ValueNotifier<DaisyThemeModel>, isFalse);
    expect(vista is FlutterSignal<DaisyThemeModel>, isFalse);
    expect(
      () => vista as FlutterSignal<DaisyThemeModel>,
      throwsA(isA<TypeError>()),
    );

    final avisos = <String>[];
    void escuchar() => avisos.add(vista.value.name);

    vista.addListener(escuchar);
    controller.setTheme(DaisyThemes.dark);
    vista.removeListener(escuchar);
    controller.setTheme(DaisyThemes.cupcake);

    expect(avisos, ['Dark']);
    expect(vista.value, DaisyThemes.cupcake);
  });
}
```

La prueba comprueba la frontera que ofrece el tipo real: no es una señal ni un `ValueNotifier`, y el cast falla. Los avisos siguen llegando. No comprueba ninguna reconstrucción de widgets. En [test/themes/daisy_theme_scope_test.dart](../../../test/themes/daisy_theme_scope_test.dart), la prueba `A SignalBuilder can observe a theme controller directly` confirma el rastreo del apartado 6 con un `SignalBuilder`.

El [servicio de temas](../../../lib/themes/application/daisy_theme_service.dart) conserva un controlador propio, y su `theme` devuelve la vista de ese controlador. Por tanto, `DaisyThemeService.theme` también es un adaptador estable. La unidad 17 explica cómo se conserva ese controlador.

### Practica 8

Dibuja en un papel controlador, señal y adaptador después de crear **dos** controladores y leer `theme` en ambos. ¿Cuántos objetos hay de cada clase? Si cambias el tema del primero, ¿qué lee la vista del segundo? Después indica cuál de estas operaciones compila desde otra biblioteca: `controller.theme.value`, `controller._palette`, `controller.theme.value = DaisyThemes.dark`.

<details>
<summary>Ver respuesta</summary>

Hay dos `DaisyThemeController`, dos señales y dos `_ThemeListenable`. Cada adaptador apunta a la señal de su propio controlador, así que la vista del segundo sigue leyendo su tema. Solo compila `controller.theme.value`: `_palette` es privado de su biblioteca y `ValueListenable` no declara un setter `value`.

</details>

## Ejercicio final: una vista del borde

Escribe una prueba de widgets con una clase `SelectorBorde` que:

1. Guarde un `int` en una señal privada, con valor inicial `1`, y ofrezca `cambiar(int nuevoBorde)` y `dispose()`.
2. Exponga `ValueListenable<int> get borde`, implementado con un adaptador privado que delegue en la señal y se guarde en un campo `late final`.

La prueba debe comprobar que:

1. Dos lecturas de `selector.borde` devuelven el mismo objeto, que no es un `FlutterSignal<int>` y que el cast lanza un `TypeError`.
2. Un listener registrado mediante la vista recibe el cambio a `2` y deja de recibir avisos tras retirarlo.
3. Un `computed` que devuelve `'grueso'` si el borde es 2 o más y `'fino'` en otro caso sigue a la vista.
4. Un `SignalBuilder` que muestra `Borde: <valor>` usando la vista se actualiza después de `cambiar(3)` y `pump`.

Predice el resultado antes de abrir la solución. Como variaciones, cambia el getter por `=> _borde`: ¿qué comprobaciones fallan? Cambia luego el campo por `get borde => _Lectura(_borde)`: ¿cuál falla ahora?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final class _Lectura implements ValueListenable<int> {
  _Lectura(this._fuente);

  final FlutterSignal<int> _fuente;

  @override
  int get value => _fuente.value;

  @override
  void addListener(VoidCallback listener) => _fuente.addListener(listener);

  @override
  void removeListener(VoidCallback listener) =>
      _fuente.removeListener(listener);
}

final class SelectorBorde {
  SelectorBorde() : _borde = signal<int>(1);

  final FlutterSignal<int> _borde;

  late final ValueListenable<int> _vista = _Lectura(_borde);

  ValueListenable<int> get borde => _vista;

  void cambiar(int nuevoBorde) => _borde.value = nuevoBorde;

  void dispose() => _borde.dispose();
}

void main() {
  testWidgets('una vista que delega en la señal', (tester) async {
    final selector = SelectorBorde();
    addTearDown(selector.dispose);
    final vista = selector.borde;

    expect(identical(vista, selector.borde), isTrue);
    expect(vista is FlutterSignal<int>, isFalse);
    expect(() => vista as FlutterSignal<int>, throwsA(isA<TypeError>()));

    final avisos = <int>[];
    void escuchar() => avisos.add(vista.value);
    vista.addListener(escuchar);

    final tipo = computed(() => vista.value >= 2 ? 'grueso' : 'fino');
    addTearDown(tipo.dispose);
    expect(tipo.value, 'fino');

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: SignalBuilder(builder: (_) => Text('Borde: ${vista.value}')),
      ),
    );
    expect(find.text('Borde: 1'), findsOneWidget);

    selector.cambiar(2);
    expect(avisos, [2]);
    expect(tipo.value, 'grueso');
    vista.removeListener(escuchar);

    selector.cambiar(3);
    await tester.pump();
    expect(avisos, [2]);
    expect(find.text('Borde: 3'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

La identidad se mantiene porque `late final` guarda un único adaptador, y el cast falla porque su clase no es una señal. El listener se registra a través de la vista, pero queda en la señal; recibe `2` y, tras retirarlo, el cambio a `3` ya no se añade. El `computed` y el `SignalBuilder` leen `vista.value`, cuyo getter lee `_fuente.value` durante su contexto, así que ambos registran la dependencia. `tipo` no necesita listeners: al leerlo después del cambio detecta que su fuente cambió, como en la unidad 11. La prueba desmonta el árbol y después libera el derivado y el selector.

Con `=> _borde` dejan de cumplirse `vista is FlutterSignal<int>` (ahora es `true`) y la expectativa de que el cast lance un error. Todo lo demás sigue funcionando: la diferencia no está en los avisos, sino en lo que el consumidor puede recuperar. Con `get borde => _Lectura(_borde)` falla solo la primera comprobación de identidad, porque cada acceso crea otro objeto; la prueba usa `vista` a partir de ahí y los avisos se comportan igual.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué diferencia hay entre leer un campo guardado y un getter calculado? **Apartado 1.**
2. Si el getter devuelve la señal con tipo `ValueListenable`, ¿cuántos objetos hay y qué permite un cast? **Apartado 2.**
3. ¿Qué es un adaptador y qué significa que delega? **Apartado 3.**
4. ¿Qué diferencia hay entre «es un» y «tiene un» en `LecturaTema`? **Apartado 3.**
5. ¿Qué puede seguir ocurriendo con un valor mutable aunque uses un adaptador? **Apartado 3.**
6. ¿Por qué `_vista` necesita `late` y cuándo se ejecuta su inicializador? **Apartado 4.**
7. ¿Qué cambia si el getter crea un adaptador en cada acceso? ¿Por qué sigue funcionando retirar el listener? **Apartado 5.**
8. ¿Por qué `controller.theme.value` registra una dependencia en un `SignalBuilder` y una copia guardada no? **Apartado 6.**
9. ¿Por qué `peek()` no está disponible en `controller.theme` y qué alternativa tienes? **Apartado 6.**
10. ¿Qué devuelve `fuente.readonly()` y en qué se diferencia de un adaptador y de un `computed`? **Apartado 7.**
11. Dibuja controlador, señal y adaptador. ¿Dónde queda registrado un listener? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y distingas una interfaz de lectura de un objeto que realmente oculta la fuente mutable, indicando qué comprobación te lo demuestra. La unidad 17 estudia los miembros `static` y cómo `DaisyThemeService` conserva un controlador compartido.

## Para consultar si necesitas reforzar

- [Getters y setters](https://dart.dev/language/methods#getters-and-setters): declaración y uso.
- [Variables `late`](https://dart.dev/language/variables#late-variables): inicialización diferida.
- [Interfaces implícitas](https://dart.dev/language/classes#implicit-interfaces): qué exige `implements`.
- [Operadores `is` y `as`](https://dart.dev/language/operators#type-test-operators): comprobación y conversión de tipos.
- [`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html): el contrato que cumple el adaptador.
- [`ReadonlySignal`](https://pub.dev/documentation/signals_core/latest/signals_core/ReadonlySignal-class.html) y [`FlutterSignal<T>`](https://pub.dev/documentation/signals_flutter/latest/signals_flutter/FlutterSignal-class.html): tipos de Signals. Compara `latest` con las versiones resueltas del proyecto.
- [Controlador](../../../lib/themes/application/daisy_theme_controller.dart), [servicio](../../../lib/themes/application/daisy_theme_service.dart) y [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): uso real en DaisyUI.

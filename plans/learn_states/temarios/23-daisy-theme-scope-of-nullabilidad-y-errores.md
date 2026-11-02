# 23. `DaisyThemeScope.of`, nullabilidad y errores

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 22](22-inherited-notifier-unir-avisos-y-dependencias.md) · **Estado:** pendiente

## Qué vas a aprender

Ya conoces el mecanismo: el scope escucha, el consumidor registra una dependencia y Flutter reconstruye. Queda leer con calma las pocas líneas donde ocurre todo eso, porque tienen símbolos que hemos ido aplazando:

```dart
DaisyThemeScope({
  super.key,
  required super.child,
  DaisyThemeController? controller,
}) : super(notifier: controller?.theme ?? DaisyThemeService.theme);

static DaisyThemeModel of(BuildContext context) {
  final scope = context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>();

  if (scope == null) {
    throw FlutterError('Coloca DaisyThemeScope por encima de este widget.');
  }

  return scope.notifier!.value;
}
```

Al terminar podrás explicar cada `?`, `?.`, `??` y `!` de estas líneas y decir qué ocurriría sin ellos. Podrás ejecutar mentalmente una consulta con scope, otra sin scope y otra con scopes anidados, y justificar el `!` del notifier a partir del constructor. También sabrás desde qué métodos del ciclo de vida se puede llamar a `of`, y por qué.

Los programas sin dependencias de los apartados 2, 3, 4 y 6 se pueden ejecutar en [DartPad](https://dartpad.dev/) en modo **Dart**. Las pruebas son archivos completos: copia **una cada vez** a `test/estudio_of_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_of_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–4 en una sesión, 5–6 en otra y terminar con 7–8 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas.

## 1. El patrón `of(context)`

Muchas clases de Flutter ofrecen un método estático con la misma forma: `Theme.of(context)`, `Navigator.of(context)` o `MediaQuery.of(context)`. DaisyUI lo imita. Es una convención, no una característica del lenguaje: `of` es un nombre como cualquier otro.

¿Por qué se escribe así? Queremos obtener datos del scope, pero **aún no tenemos el scope**: eso es precisamente lo que buscamos. Por eso el método es estático: se llama con el nombre de la clase y no necesita una instancia (unidad 17). Y recibe un contexto porque la búsqueda necesita un punto de partida (unidad 20).

El método oculta tres decisiones que no queremos repetir en cada consumidor:

1. **Cómo buscar**, registrando la dependencia.
2. **Qué hacer si no hay nada**: lanzar un error con un mensaje útil.
3. **Qué devolver**: el tema, no el scope. El consumidor no necesita saber que hay un `notifier`.

Compara lo que escribiría cada consumidor con el método y sin él. Este es un **fragmento**:

```dart
// Con el método:
final tema = DaisyThemeScope.of(context);

// Sin el método, en cada lugar:
final scope = context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>();
if (scope == null) {
  throw FlutterError('Coloca DaisyThemeScope por encima de este widget.');
}
final tema = scope.notifier!.value;
```

Muchas clases añaden también `maybeOf`, que devuelve `null` en lugar de lanzar un error. `DaisyThemeScope` no lo tiene. Lo escribirás en el ejercicio final.

### Practica 1

¿Se podría escribir `of` como un método de instancia, es decir, `scope.of(context)`? ¿Qué problema tendrías para llamarlo?

<details>
<summary>Ver respuesta</summary>

Se podría declarar, pero para llamarlo necesitarías ya una referencia a un `DaisyThemeScope`, que es lo que intentas conseguir. El método estático rompe ese círculo: el punto de partida es el contexto del consumidor, y el resultado es lo que se encontró al subir.

</details>

## 2. `null` y los tipos con `?`

Antes de seguir, necesitamos un concepto de Dart. `null` significa **ausencia de valor**. En Dart, una variable de tipo `String` nunca puede contener `null`; para permitirlo hay que escribir `String?`. Este sistema se llama *null safety*: la ausencia queda escrita en el tipo, de modo que el compilador la tiene en cuenta.

```dart
class Controlador {
  Controlador(this.tema);

  final String tema;
}

String describir(Controlador? controlador) {
  if (controlador == null) {
    return 'sin controlador';
  }
  return controlador.tema;
}

void main() {
  print(describir(Controlador('cupcake')));
  print(describir(null));
}
```

La salida es:

```text
cupcake
sin controlador
```

Las líneas importantes:

- `Controlador? controlador` admite un `Controlador` o `null`.
- Dentro del `if`, el programa retorna si es `null`. Después de esa comprobación, Dart sabe que `controlador` no es `null` y permite escribir `controlador.tema`. Esto se llama **promoción de tipos**. También ocurre al asignar un valor no nulo a una variable local.

Sin la comprobación, el analizador rechaza el programa. Este **fragmento** no compila:

```dart
String describir(Controlador? controlador) => controlador.tema;
// The property 'tema' can't be unconditionally accessed because the receiver can be 'null'.
```

Es la misma idea de la unidad 3: el tipo declarado limita lo que se puede hacer con una variable, aunque el objeto real tenga más capacidades. `Controlador?` no promete tener un `tema`.

Los parámetros nombrados tienen una regla relacionada, que es la que usa el constructor del scope:

```dart
class Scope {
  Scope({required this.hijo, this.controlador});

  final String hijo;
  final String? controlador;
}

void main() {
  final sinControlador = Scope(hijo: 'texto');
  final conControlador = Scope(hijo: 'texto', controlador: 'preview');

  print(sinControlador.controlador);
  print(conControlador.controlador);
}
```

La salida es:

```text
null
preview
```

Un parámetro nombrado es opcional salvo que lleve `required`. Si no se entrega, recibe su valor predeterminado (unidad 15), que es `null` cuando no se indica otro. Por eso un parámetro opcional sin predeterminado **debe** admitir `null`:

```dart
// Fragmento que no compila:
Mala({String nombre});
// The parameter 'nombre' can't have a value of 'null' because of its type,
// but the implicit default value is 'null'.
```

En `DaisyThemeScope`, `DaisyThemeController? controller` no lleva `required`. Es opcional y su ausencia significa «usa el servicio».

### Practica 2

¿Compilan estas líneas? (a) `String a = null;` (b) `String? b = null;` (c) `String? c = 'hola'; print(c.length);` (d) `String? d = leer(); if (d != null) print(d.length);`

<details>
<summary>Ver respuesta</summary>

(a) No: `String` no admite `null`. (b) Sí. (c) Sí, aunque pueda sorprender: Dart ve que acabamos de asignar un valor no nulo y promociona la variable. (d) Sí: dentro del `if`, `d` está promocionada. En (c) y (d), la promoción depende de lo que Dart puede demostrar sobre esa variable local.

</details>

## 3. `?.` y `??`: seguir o elegir otra cosa

Comprobar `null` con un `if` es correcto, pero largo. Dart tiene dos operadores para los casos más habituales:

- `a?.b` significa: si `a` es `null`, el resultado es `null`; si no, el resultado es `a.b`.
- `a ?? b` significa: si `a` no es `null`, el resultado es `a`; si lo es, se evalúa `b`.

**Antes de mirar la salida**, predice qué se imprime y fíjate en cuándo aparece el mensaje del servicio:

```dart
class Controlador {
  Controlador(this.tema);

  final String tema;
}

String consultarServicio() {
  print('Se consulta el servicio');
  return 'light';
}

String? temaDe(Controlador? controlador) => controlador?.tema;

String elegir(Controlador? controlador) {
  return controlador?.tema ?? consultarServicio();
}

void main() {
  print(temaDe(Controlador('cupcake')));
  print(temaDe(null));
  print(elegir(Controlador('cupcake')));
  print(elegir(null));
}
```

La salida es:

```text
cupcake
null
cupcake
Se consulta el servicio
light
```

Paso a paso:

1. `temaDe` devuelve `String?`. Con un controlador da su tema; con `null`, da `null`, sin intentar acceder a nada.
2. `elegir(Controlador('cupcake'))`: `?.` da `'cupcake'`, que no es `null`, así que `??` termina. **`consultarServicio` no se llama**: el lado derecho de `??` solo se evalúa si hace falta.
3. `elegir(null)`: `?.` da `null`, de modo que `??` evalúa el lado derecho, y ahí aparece el mensaje.

El tipo también cambia. `controlador?.tema` es `String?`, y `controlador?.tema ?? consultarServicio()` es `String`, porque por cualquiera de los dos caminos llega un texto. `??` es la forma de pasar de «puede faltar» a «seguro que hay un valor».

### Practica 3

`final x = a?.b ?? c;`. Rellena la tabla. `a` puede ser `null`, y `b` y `c` no lo son:

| `a`          | Valor de `a?.b` | ¿Se evalúa `c`? | Valor de `x` |
|--------------|-----------------|-----------------|--------------|
| `null`       | ?               | ?               | ?            |
| Un objeto    | ?               | ?               | ?            |

<details>
<summary>Ver respuesta</summary>

Si `a` es `null`: `a?.b` es `null`, se evalúa `c`, y `x` es `c`. Si `a` es un objeto: `a?.b` es `a.b`, no se evalúa `c`, y `x` es `a.b`.

</details>

## 4. El constructor del scope

Ya podemos leer su expresión más densa:

```dart
// Fragmento de daisy_theme_scope.dart.
DaisyThemeScope({
  super.key,
  required super.child,
  DaisyThemeController? controller,
}) : super(notifier: controller?.theme ?? DaisyThemeService.theme);
```

Las dos ramas son las de la tabla anterior:

| Se llama con              | `controller?.theme` | ¿Se evalúa el servicio? | Valor de `notifier`     |
|---------------------------|---------------------|-------------------------|-------------------------|
| `controller: preview`     | `preview.theme`     | No                      | `preview.theme`         |
| Sin `controller`          | `null`              | Sí                      | `DaisyThemeService.theme` |

**Antes de mirar los `expect`**, predice a qué vista apunta `notifier` en cada scope:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('las dos ramas del constructor', () {
    final preview = DaisyThemeController();
    addTearDown(preview.dispose);

    final conController = DaisyThemeScope(
      controller: preview,
      child: const SizedBox.shrink(),
    );
    final sinController = DaisyThemeScope(child: const SizedBox.shrink());

    expect(identical(conController.notifier, preview.theme), isTrue);
    expect(
      identical(sinController.notifier, DaisyThemeService.theme),
      isTrue,
    );
  });
}
```

Del constructor se deducen tres consecuencias que no están a la vista.

**`controller` no se guarda.** No lleva `this.` ni hay un campo con ese nombre. Es un parámetro normal, que solo existe mientras se ejecuta el constructor. El scope conserva únicamente `notifier`, la vista de lectura. Por eso, un consumidor que encuentra el scope no puede obtener el controlador ni cambiar el tema a través de él. Este **fragmento** no compila:

```dart
scope.controller;
// The getter 'controller' isn't defined for the type 'DaisyThemeScope'.
```

**El constructor no es `const`.** Ejecuta un getter y un operador, algo que no se puede resolver al compilar. Por eso, en el [ejemplo](../../../example/lib/main.dart), `const` aparece dentro y no fuera:

```dart
// Fragmento de example/lib/main.dart.
return DaisyThemeScope(
  child: const MaterialApp(
    // ...
```

Escribir `const DaisyThemeScope(...)` provoca `The constructor being called isn't a const constructor.`

**Con controlador, el servicio ni se toca.** Como `??` no evalúa su lado derecho, y la unidad 17 estableció que un campo estático se inicializa en su primer acceso, un programa donde todos los scopes reciben un controlador nunca crea el controlador del servicio. Compruébalo en esta réplica, sin dependencias:

```dart
class Controlador {
  Controlador(this.nombre) {
    print('Se crea $nombre');
  }

  final String nombre;
}

abstract final class Servicio {
  static final _controlador = Controlador('global');

  static String get nombre => _controlador.nombre;
}

class Scope {
  Scope({Controlador? controlador})
    : fuente = controlador?.nombre ?? Servicio.nombre;

  final String fuente;
}

void main() {
  print('Empieza main');
  final local = Scope(controlador: Controlador('local'));
  print(local.fuente);
  final global = Scope();
  print(global.fuente);
}
```

La salida es:

```text
Empieza main
Se crea local
local
Se crea global
global
```

`Se crea global` aparece solo con el segundo scope, que es el primero que evalúa el lado derecho de `??`.

### Practica 4

Si el constructor fuera `: super(notifier: DaisyThemeService.theme ?? controller?.theme)`, ¿qué problema habría? ¿Qué diría el analizador?

<details>
<summary>Ver respuesta</summary>

`DaisyThemeService.theme` nunca es `null`, de modo que el lado derecho no se evaluaría nunca: el scope ignoraría el controlador que recibe, y todas las vistas previas mostrarían el tema global. El analizador avisa de que el lado izquierdo no puede ser `null`, y por eso `??` no tiene efecto. El orden de la expresión es la regla «si hay controlador, úsalo; si no, el servicio».

</details>

## 5. Las tres ramas de `of`

Vamos con el método. **Antes de mirar los `expect`**, ejecuta mentalmente la consulta de cada `Lector`:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Lector extends StatelessWidget {
  const Lector({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(DaisyThemeScope.of(context).name);
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('con un scope', (tester) async {
    final controller = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      pantalla(DaisyThemeScope(controller: controller, child: const Lector())),
    );
    expect(find.text('Dark'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sin scope', (tester) async {
    await tester.pumpWidget(pantalla(const Lector()));

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('Coloca DaisyThemeScope'));
    expect(find.byType(ErrorWidget), findsOneWidget);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('con scopes anidados', (tester) async {
    final exterior = DaisyThemeController(initialTheme: DaisyThemes.dark);
    final interior = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(exterior.dispose);
    addTearDown(interior.dispose);

    await tester.pumpWidget(
      pantalla(
        DaisyThemeScope(
          controller: exterior,
          child: DaisyThemeScope(controller: interior, child: const Lector()),
        ),
      ),
    );
    expect(find.text('Cupcake'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

**Con un scope**, línea a línea:

1. `context.dependOnInheritedWidgetOfExactType<DaisyThemeScope>()` encuentra el elemento del scope y registra la dependencia (unidad 21). Devuelve el widget actual. El tipo de la variable `scope` es `DaisyThemeScope?`.
2. `if (scope == null)` es falso. Después de esta línea, `scope` está promocionada a `DaisyThemeScope`.
3. `scope.notifier!.value` lee `notifier`, afirma que no es `null` y consulta `value` en el adaptador, que lee la señal. Devuelve el tema.

**Sin scope:**

1. La búsqueda devuelve `null`. No registra ninguna dependencia, porque no hay con quién.
2. El `if` es verdadero. `throw` detiene el método y lanza un `FlutterError`.
3. Nadie lo captura en `of` ni en `build`. Lo captura **Flutter**, en el código que ejecuta `build`, y lo notifica.
4. En lugar del subárbol que no se pudo describir, Flutter coloca un `ErrorWidget`. Es lo que ves como pantalla roja en modo de depuración, y gris en una versión de producción. Por eso `find.byType(Text)` no encuentra nada.

**Con scopes anidados:** las dos primeras líneas funcionan igual. Hay dos ancestros del tipo buscado, y el mapa de la unidad 21 asocia ese tipo con el más cercano: `interior`. El consumidor se registra solo en él, de modo que cambiar `exterior` no le afecta. La unidad 25 lo estudia con detalle.

`FlutterError` es una clase de Flutter para **errores de programación**: indican un fallo que hay que corregir en el código, no una situación esperable que el programa deba manejar. No está pensado para capturarlo con `try`. El mensaje debe decir cómo corregirlo. Compara «Coloca DaisyThemeScope por encima de este widget» con lo que veremos en el siguiente apartado.

### Practica 5

Un consumidor lanza este error, aunque hay un `DaisyThemeScope` en el mismo archivo. Di tres causas posibles, según lo estudiado en la unidad 20.

<details>
<summary>Ver respuesta</summary>

Primera: la lectura usa el contexto del widget que **crea** el scope, que está por encima (unidad 20, apartado 4). Segunda: el consumidor está en otra rama, como un hermano del scope, o en una ruta nueva abierta con `Navigator` (apartado 7). Tercera: un callback como `(_) => context.daisyTheme` usa el contexto exterior (apartado 6). En todos los casos, la pregunta es la misma: ¿el scope está entre los ancestros de este contexto?

</details>

## 6. `!`: una afirmación que puede fallar

`!` convierte `T?` en `T`. **No comprueba nada para ti**: si el valor es `null`, lanza un error en ese momento. Es tu forma de decirle al compilador: «yo sé algo que tú no puedes demostrar».

```dart
int duplicar(int? numero) => numero! * 2;

void main() {
  print(duplicar(4));
  try {
    print(duplicar(null));
  } on TypeError catch (error) {
    print('Error: $error');
  }
}
```

La salida es:

```text
8
Error: Null check operator used on a null value
```

`try` ejecuta un bloque, y `on TypeError catch` captura ese tipo de error, para poder mostrarlo aquí sin detener el programa. El mensaje es correcto, pero no dice qué falta ni cómo arreglarlo.

### ¿Por qué `scope` no necesita `!` y `notifier` sí?

Las dos variables pueden ser `null` según su tipo. Pero la promoción de tipos del apartado 2 solo funciona cuando Dart puede **demostrar** que el valor no cambia entre la comprobación y el uso:

- `scope` es una variable local: nadie más puede modificarla. Tras el `if`, queda promocionada.
- `notifier` es un campo público de otra clase. Este **fragmento** no compila, aunque acabamos de comprobarlo:

```dart
if (scope.notifier == null) return;
print(scope.notifier.value);
// The property 'value' can't be unconditionally accessed because the receiver can be 'null'.
```

Dart no promociona campos públicos, porque un getter de una subclase podría devolver algo distinto en cada lectura.

¿Y por qué es nullable? Porque `InheritedNotifier<T>` declara `final T? notifier;`. Esa clase de Flutter admite un scope sin fuente, para los casos en los que aún no hay nada que escuchar. El tipo de un campo heredado no cambia: en `DaisyThemeScope`, sigue siendo `ValueListenable<DaisyThemeModel>?`.

### La justificación del `!`

`!` es aceptable cuando puedes razonar por qué nunca falla. En este caso:

1. El único constructor de `DaisyThemeScope` entrega `controller?.theme ?? DaisyThemeService.theme`.
2. Por el apartado 3, el tipo de esa expresión es `ValueListenable<DaisyThemeModel>`, sin `?`: el lado derecho nunca es `null`.
3. `notifier` es `final`: no se puede cambiar después.

Por lo tanto, **ningún `DaisyThemeScope` puede tener `notifier` nulo**. Lo sabemos nosotros por el constructor; el compilador no lo deduce, porque solo ve el tipo heredado. Si mañana alguien añadiera un constructor que permitiera `null`, el `!` dejaría de estar justificado. Compruébalo con un scope propio que sí lo permite:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class ScopeDebil extends InheritedNotifier<ValueNotifier<int>> {
  const ScopeDebil({super.key, super.notifier, required super.child});

  static int of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ScopeDebil>();
    if (scope == null) {
      throw FlutterError('Coloca ScopeDebil por encima de este widget.');
    }
    return scope.notifier!.value;
  }
}

class Lector extends StatelessWidget {
  const Lector({super.key});

  @override
  Widget build(BuildContext context) => Text('${ScopeDebil.of(context)}');
}

void main() {
  testWidgets('un notifier nulo rompe el !', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: ScopeDebil(child: Lector()),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<TypeError>());
    expect(error, isNot(isA<FlutterError>()));
    expect(error.toString(), contains('Null check operator'));
  });
}
```

Aquí el scope **existe**, pero sin fuente. El `if` no lo detecta y el `!` falla con el mensaje genérico. Esto muestra por qué `of` trata cada caso de un modo diferente: «no hay scope» es un error del usuario de la biblioteca y merece un mensaje claro; «no hay notifier» es imposible en `DaisyThemeScope`, y por eso basta con el `!`.

### Practica 6

Reescribe la última línea de `of` sin `!`, con una variable local y un `if`. ¿Qué ganarías y qué perderías? ¿Qué harías si `DaisyThemeScope` permitiera un `notifier` nulo?

<details>
<summary>Ver respuesta</summary>

```dart
// Fragmento.
final notifier = scope.notifier;
if (notifier == null) {
  throw FlutterError('El scope no tiene tema.');
}
return notifier.value;
```

La variable local se puede promocionar. Se gana un mensaje mejor, en un caso que hoy no puede ocurrir, y se pierde brevedad, con una rama que nunca se ejecuta ni se prueba. Si el scope sí permitiera `null`, el `if` sería necesario: `!` solo se justifica cuando el caso nulo es imposible.

</details>

## 7. Búsqueda por tipo exacto

`dependOnInheritedWidgetOfExactType<T>` usa el tipo como clave del mapa. El nombre lo dice: **exacto**. **Antes de mirar los `expect`**, predice qué encuentra el lector en cada árbol:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class OtroDato extends InheritedWidget {
  const OtroDato({super.key, required super.child});

  @override
  bool updateShouldNotify(OtroDato oldWidget) => false;
}

class ScopeHijo extends DaisyThemeScope {
  ScopeHijo({super.key, required super.child, super.controller});
}

class Lector extends StatelessWidget {
  const Lector({super.key});

  @override
  Widget build(BuildContext context) => Text(context.daisyTheme.name);
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('otro tipo intermedio no estorba', (tester) async {
    await tester.pumpWidget(
      pantalla(
        DaisyThemeScope(child: const OtroDato(child: Lector())),
      ),
    );
    expect(find.text('Light'), findsOneWidget);
  });

  testWidgets('una subclase no se encuentra', (tester) async {
    await tester.pumpWidget(pantalla(ScopeHijo(child: const Lector())));
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('la subclase no oculta al scope de arriba', (tester) async {
    final interior = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(interior.dispose);

    await tester.pumpWidget(
      pantalla(
        DaisyThemeScope(
          child: ScopeHijo(controller: interior, child: const Lector()),
        ),
      ),
    );
    expect(find.text('Light'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Las reglas son directas:

1. **Otro tipo intermedio no interrumpe la búsqueda.** Cada tipo tiene su entrada en el mapa. `OtroDato` no compite con el scope.
2. **El tipo debe coincidir exactamente.** `ScopeHijo` es un `DaisyThemeScope` para el sistema de tipos, pero su entrada en el mapa es `ScopeHijo`. Por eso la búsqueda no lo ve.
3. **Es un error silencioso.** En la tercera prueba, el lector recibe el tema del servicio y no el de `interior`, sin ningún aviso.

`DaisyThemeScope` no es `final`, a diferencia del controlador, así que se puede extender, pero **su `of` no encontraría esa subclase**. En la práctica, no conviene crear subclases de un `InheritedWidget` con `of`.

### Practica 7

Se añade un `MediaQuery` entre el scope y el lector. ¿Cambia el resultado de `context.daisyTheme`? ¿Y si se añade otro `DaisyThemeScope` en esa posición?

<details>
<summary>Ver respuesta</summary>

Con `MediaQuery` no cambia: es otro tipo y tiene otra entrada en el mapa. Con otro `DaisyThemeScope`, sí: pasa a ser el más cercano de ese tipo exacto, y el lector leerá su tema.

</details>

## 8. Desde dónde se puede llamar a `of`

Como `of` registra una dependencia, importa **cuándo** se llama. La unidad 19 ya mostró el fallo en `initState`. Estos son el resto de los casos. **Antes de mirar los `expect`**, predice qué ocurre en `dispose` y qué efecto tiene leer dentro de un callback:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class LectorAlLiberar extends StatefulWidget {
  const LectorAlLiberar({super.key});

  @override
  State<LectorAlLiberar> createState() => _LectorAlLiberarState();
}

class _LectorAlLiberarState extends State<LectorAlLiberar> {
  @override
  Widget build(BuildContext context) => const SizedBox.shrink();

  @override
  void dispose() {
    DaisyThemeScope.of(context);
    super.dispose();
  }
}

var builds = 0;
String? leido;

class LectorAlPulsar extends StatelessWidget {
  const LectorAlPulsar({super.key});

  @override
  Widget build(BuildContext context) {
    builds++;
    return GestureDetector(
      onTap: () => leido = DaisyThemeScope.of(context).name,
      child: const Text('Leer'),
    );
  }
}

void main() {
  testWidgets('dispose ya no puede buscar', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(child: const LectorAlLiberar()),
      ),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isA<FlutterError>());
  });

  testWidgets('leer en un callback también registra', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: const LectorAlPulsar(),
        ),
      ),
    );
    expect(builds, 1);

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(builds, 1);

    await tester.tap(find.text('Leer'));
    await tester.pump();
    expect(leido, 'Dark');
    expect(builds, 1);

    controller.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(builds, 2);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

1. **En `dispose`**, el contexto ya se ha retirado: buscar lanza un `FlutterError`, igual que con el contexto guardado de la unidad 20. Si necesitas el tema al terminar, debes guardarlo antes. Por ejemplo, en `didChangeDependencies`.
2. **En un callback**, la lectura funciona y da el valor actual. Pero fíjate en lo que ocurre después: el primer `setTheme` no provoca un `build`, y el segundo sí. **La pulsación ha registrado una dependencia**, que antes no existía y que dura hasta el desmontaje (unidad 21). No es un error, pero el widget se reconstruirá sin necesidad.

Si solo quieres leer una vez, por ejemplo en un callback, puedes usar la operación que no registra nada. Con `DaisyThemeScope` puedes hacerlo así, y esta es una consulta correcta sin ningún efecto secundario:

```dart
// Fragmento.
final scope = context.getInheritedWidgetOfExactType<DaisyThemeScope>();
final nombre = scope?.notifier?.value.name;
```

El resumen del plan queda así:

| Dónde                                   | ¿Se puede? | Efecto                                                     |
|-----------------------------------------|------------|------------------------------------------------------------|
| `build` (también de `Builder`)          | Sí         | Valor actual y dependencia. Es el caso normal              |
| `didChangeDependencies`                 | Sí         | Se repite cuando cambia el tema. Para derivar datos        |
| `didUpdateWidget`                       | Sí         | Valor actual. Se aplica lo mismo que en `build`            |
| `initState`                             | No         | Error: `initState` no se repetiría (unidad 19)             |
| Constructor del widget                  | No         | Aún no existe el contexto                                  |
| `dispose`                               | No         | Error: el contexto ya se retiró                            |
| Callback de un evento                   | Sí, sin más | Valor actual. Registra una dependencia que quizá sobra     |
| Tras un `await`                         | Con cuidado | Comprueba antes `mounted`                                  |

### Practica 8

Un botón en `build` hace `final tema = context.daisyTheme;` y en `onPressed` usa `tema.id`. Otro botón lee `context.daisyTheme.id` directamente en `onPressed`. Si el tema cambia entre la construcción y la pulsación, ¿qué lee cada uno? ¿Hay un problema con el primero?

<details>
<summary>Ver respuesta</summary>

El primero lee el `tema` capturado en la última construcción (una closure, unidad 2). Pero esa misma lectura registró una dependencia, de modo que si el tema cambia, se reconstruye y el callback se crea de nuevo con el valor actual. El problema solo aparece entre el cambio y el siguiente frame, algo imperceptible en la práctica. El segundo siempre lee el valor actual, a cambio de registrar la dependencia al pulsar. Es la forma que tenía el ejemplo con `theme.id` en `onPressed`: la primera opción, y es correcta.

</details>

## Ejercicio final: `temaOpcional`

`DaisyThemeScope` no ofrece `maybeOf`. Escribe tú esa función, sin modificar el paquete, y una prueba que la use.

1. Escribe `DaisyThemeModel? temaOpcional(BuildContext context)`, de una sola expresión, sin `if` ni `!`. Debe registrar una dependencia si hay scope, y devolver `null` si no lo hay.
2. Escribe un widget `Etiqueta` que muestre el nombre del tema, o `Sin tema` si no hay ninguno, sin usar `if`.
3. Comprueba cuatro escenarios: sin scope, con un scope, con scopes anidados, y al cambiar el tema del scope encontrado.
4. Comprueba que no queda ninguna excepción pendiente.

Predice los textos antes de abrir la solución. Como variaciones: explica por qué necesitas **dos** `?.` en la función. ¿Qué ocurriría si cambiaras el segundo por `!`? ¿Y si usaras `DaisyThemeScope.of` en lugar de la consulta?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

DaisyThemeModel? temaOpcional(BuildContext context) {
  return context
      .dependOnInheritedWidgetOfExactType<DaisyThemeScope>()
      ?.notifier
      ?.value;
}

class Etiqueta extends StatelessWidget {
  const Etiqueta({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(temaOpcional(context)?.name ?? 'Sin tema');
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('temaOpcional en cuatro escenarios', (tester) async {
    final exterior = DaisyThemeController();
    final interior = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(exterior.dispose);
    addTearDown(interior.dispose);

    await tester.pumpWidget(pantalla(const Etiqueta()));
    expect(find.text('Sin tema'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(
      pantalla(DaisyThemeScope(controller: exterior, child: const Etiqueta())),
    );
    expect(find.text('Light'), findsOneWidget);

    await tester.pumpWidget(
      pantalla(
        DaisyThemeScope(
          controller: exterior,
          child: DaisyThemeScope(
            controller: interior,
            child: const Etiqueta(),
          ),
        ),
      ),
    );
    expect(find.text('Cupcake'), findsOneWidget);

    interior.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

La función devuelve `DaisyThemeModel?`, porque una consulta sin scope no tiene tema. `Etiqueta` añade otro `?.` para leer `name`, y `??` da el texto alternativo: la expresión completa es un `String`, sin casos pendientes.

Los dos `?.` protegen de dos ausencias distintas. El primero, de que la búsqueda no encuentre nada. El segundo, de que el scope encontrado no tenga notifier: según el tipo `T?`, es posible. Con `!` en el segundo la función también sería correcta, y por el motivo del apartado 6, porque `DaisyThemeScope` siempre lo tiene. Si usaras `DaisyThemeScope.of`, el caso sin scope lanzaría un error, y `temaOpcional` dejaría de ser opcional.

Esta función registra la dependencia igual que `of`, y por eso el texto cambia a `Dark`: toda la diferencia está en el tratamiento de la ausencia.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Por qué `of` es estático y qué tres decisiones oculta? **Apartado 1.**
2. ¿Qué diferencia hay entre `String` y `String?`? ¿Qué es la promoción de tipos? **Apartado 2.**
3. ¿Por qué un parámetro nombrado opcional sin predeterminado debe admitir `null`? **Apartado 2.**
4. ¿Qué devuelven `a?.b` y `a ?? b`, y cuándo no se evalúa el lado derecho? **Apartado 3.**
5. ¿Qué ramas tiene el constructor del scope? ¿Se guarda `controller`? ¿Por qué no es `const`? **Apartado 4.**
6. Ejecuta mentalmente `of` con scope, sin scope y con scopes anidados. ¿Qué es `ErrorWidget`? **Apartado 5.**
7. ¿Qué hace `!`, y por qué `scope` no lo necesita y `notifier` sí? **Apartado 6.**
8. Justifica el `!` de `of` a partir del constructor actual. **Apartado 6.**
9. ¿Qué significa «tipo exacto»? ¿Qué le ocurre a una subclase? **Apartado 7.**
10. ¿Desde qué métodos se puede llamar a `of`, y qué efecto tiene hacerlo en un callback? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques cada rama del flujo, y por qué registrar dependencias se hace desde lugares adecuados del ciclo de vida. La unidad 24 estudia `context.daisyTheme`, la forma abreviada de este método.

## Para consultar si necesitas reforzar

- [Null safety en Dart](https://dart.dev/null-safety/understanding-null-safety): la guía oficial, con la promoción de tipos y la razón por la que no se promocionan los campos.
- [Operadores de Dart](https://dart.dev/language/operators): `?.`, `??` y `!`.
- [Manejo de errores en Flutter](https://docs.flutter.dev/testing/errors): `FlutterError`, `ErrorWidget` y cómo se notifican.
- [`InheritedWidget`](https://api.flutter.dev/flutter/widgets/InheritedWidget-class.html): la convención de `of` y `maybeOf`.
- [Scope](../../../lib/themes/application/daisy_theme_scope.dart) y [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento actual de DaisyUI.

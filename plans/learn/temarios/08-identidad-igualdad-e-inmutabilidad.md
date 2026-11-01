# 08. Identidad, igualdad e inmutabilidad

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 7](07-value-notifier-un-valor-mutable-que-notifica.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 7 vimos que `ValueNotifier` compara el valor que guarda con el valor propuesto. Si `==` dice que son
iguales, conserva el anterior y no avisa. Para entender esa decisión necesitamos separar tres preguntas:

- **Identidad:** ¿estamos hablando del mismo objeto?
- **Igualdad:** ¿la regla de `==` considera equivalentes esos valores?
- **Inmutabilidad:** ¿pueden cambiar los datos del objeto después de crearlo?

Aprenderás a responderlas con listas y objetos pequeños, y después las aplicaremos a los temas reales de DaisyUI.
También verás para qué sirve `hashCode` cuando guardamos objetos en un `Set`.

Los programas completos son independientes. Para los que no importan Flutter puedes usar [DartPad](https://dartpad.dev/)
en modo **Dart**; para los que importan `package:flutter/foundation.dart`, elige **Flutter**. Predice la salida antes
de ejecutar. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar después con DaisyUI y el ejercicio.

## 1. Identidad: ¿es el mismo objeto?

Imagina dos nombres que permiten acceder a una misma lista de temas. Si añadimos un tema usando uno de ellos, ¿qué se
ve al consultar el otro?

```dart
void main() {
  final primera = <String>['claro'];
  final compartida = primera;
  final copia = <String>[...primera];

  compartida.add('oscuro');

  print('Primera y compartida: ${identical(primera, compartida)}');
  print('Primera y copia: ${identical(primera, copia)}');
  print('Primera: $primera');
  print('Copia: $copia');
}
```

La salida es:

```text
Primera y compartida: true
Primera y copia: false
Primera: [claro, oscuro]
Copia: [claro]
```

`identical(a, b)` pregunta si las dos referencias corresponden al **mismo objeto**. No pregunta si sus contenidos se
parecen.

1. `primera` permite acceder a una lista que contiene `'claro'`.
2. `compartida = primera` guarda una referencia a esa **misma lista**; no crea otra.
3. `<String>[...primera]` crea otra lista exterior con los elementos que tenía `primera` en ese momento.
4. `compartida.add('oscuro')` modifica la primera lista. Como `primera` también apunta a ella, ve el cambio. `copia`
   apunta a otra lista y sigue teniendo solo `'claro'`.

La expansión `...` copia los elementos a la nueva lista exterior; si esos elementos fueran objetos mutables, las dos
listas podrían seguir compartiéndolos. Volveremos a ese caso en el apartado 6.

### Practica 1

Si cambiamos `final copia = <String>[...primera];` por `final copia = primera;`, ¿qué muestran `identical(primera, copia)`
y `copia` después de `compartida.add('oscuro')`?

<details>
<summary>Ver respuesta</summary>

`identical(primera, copia)` devuelve `true` y `copia` muestra `[claro, oscuro]`. Las tres variables permiten acceder a
la misma lista; no se ha creado una segunda lista.

</details>

## 2. Igualdad: ¿la regla los considera equivalentes?

Dos objetos pueden ser distintos y representar los mismos datos. `==` aplica la **regla de igualdad del tipo**. Esa
regla no siempre es la misma que la identidad.

Vamos a crear un modelo pequeño. Para este ejemplo, dos temas serán iguales si coinciden su nombre y su borde:

```dart
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

  print('Mismo objeto: ${identical(original, equivalente)}');
  print('Iguales: ${original == equivalente}');
  print('Borde distinto: ${original == distinto}');
}
```

La salida es:

```text
Mismo objeto: false
Iguales: true
Borde distinto: false
```

Las llamadas al constructor de `main` crean tres objetos. Aunque el constructor admite `const`, aquí lo llamamos sin
`const`; estudiaremos las construcciones constantes en el apartado 5.

El método `operator ==` define la regla de este tipo: primero comprueba que `other` sea un `TemaSimple` y después
compara `nombre` y `borde`. `original` y `equivalente` son objetos diferentes, pero sus dos datos coinciden, por eso la
regla los considera iguales. `distinto` tiene otro borde y no cumple esa regla.

La clase también define `hashCode` usando los mismos datos. Lo necesitamos para que los objetos se comporten de forma
coherente en colecciones como `Set`; lo explicaremos en el apartado 4. No hace falta memorizar ahora la sintaxis de
`@override` y `operator`: céntrate en **qué campos compara la regla**.

Una regla de igualdad debe comportarse de forma coherente: por ejemplo, un objeto debe ser igual a sí mismo y, si
`a == b`, también debe cumplirse `b == a`. Más adelante puedes consultar sus demás condiciones en las referencias.

### Practica 2

Supón que cambiamos la regla para comparar solamente `nombre`. ¿Cómo resultarían `original == distinto`? ¿Qué problema
podría haber si el borde importa para mostrar la interfaz?

<details>
<summary>Ver respuesta</summary>

Resultaría `true`: ambos se llaman `'claro'` y la nueva regla ignoraría el borde. Si el borde importa, estaríamos
tratando como equivalentes dos configuraciones que la interfaz necesita distinguir. Si cambiamos la igualdad, también
debemos ajustar `hashCode` para que use una regla coherente.

</details>

## 3. Dos listas con los mismos elementos

Las listas ordinarias creadas por separado en este ejemplo usan igualdad por identidad: tener los mismos elementos no
hace que `==` devuelva `true`. En Flutter podemos comparar sus elementos con `listEquals`:

```dart
import 'package:flutter/foundation.dart';

void main() {
  final primera = <int>[1, 2];
  final segunda = <int>[1, 2];
  final invertida = <int>[2, 1];

  print('Mismo objeto: ${identical(primera, segunda)}');
  print('Iguales con ==: ${primera == segunda}');
  print('Mismos elementos: ${listEquals(primera, segunda)}');
  print('Mismo orden: ${listEquals(primera, invertida)}');
}
```

La salida es:

```text
Mismo objeto: false
Iguales con ==: false
Mismos elementos: true
Mismo orden: false
```

`listEquals` compara la longitud y los elementos **en orden**, usando `==` para cada elemento. Por eso `[1, 2]` y
`[2, 1]` no coinciden con esa función.

No es una comparación profunda general de listas anidadas. Si los elementos son a su vez listas ordinarias,
`listEquals` compara esas listas interiores usando su propio `==`; no recorre automáticamente todos sus niveles.
Tampoco cambia la regla del setter de `ValueNotifier`: ese setter usa `==`, no `listEquals`.

### Practica 3

En el ejemplo anterior, ¿qué ocurriría si ejecutamos `final tercera = primera;` y comparamos
`identical(primera, tercera)` y `primera == tercera`?

<details>
<summary>Ver respuesta</summary>

Ambas expresiones darían `true`: las dos variables apuntarían a la misma lista. Eso es diferente de `segunda`, que se
creó por separado aunque contenga los mismos números.

</details>

## 4. `hashCode`: ayudar a encontrar valores en un conjunto

Un `Set` evita guardar dos elementos que considera iguales. Para buscar y organizar sus elementos, los conjuntos
basados en hash utilizan `hashCode` junto con `==`.

La regla que necesitamos recordar es:

> Si `a == b`, entonces `a.hashCode == b.hashCode` debe ser verdadero.

La inversa no está garantizada: dos objetos distintos y no iguales pueden tener el mismo hash. `hashCode` no es un
identificador único ni debemos depender de que sea el mismo número entre ejecuciones.

Veamos el contrato en acción con una versión completa de nuestro tema:

```dart
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
  final primero = TemaSimple('claro', 1);
  final equivalente = TemaSimple('claro', 1);
  final distinto = TemaSimple('claro', 2);
  final temas = <TemaSimple>{primero, equivalente, distinto};

  print('Son iguales: ${primero == equivalente}');
  print('Mismo hash: ${primero.hashCode == equivalente.hashCode}');
  print('Cantidad en el conjunto: ${temas.length}');
  print('Encuentra equivalente: ${temas.contains(equivalente)}');
}
```

La salida es:

```text
Son iguales: true
Mismo hash: true
Cantidad en el conjunto: 2
Encuentra equivalente: true
```

`primero` y `equivalente` cumplen la regla de igualdad y aportan los mismos campos a `Object.hash`; el segundo no añade
un elemento distinto al conjunto. `distinto` tiene otro borde y no es igual, así que el conjunto conserva dos temas.

Si definimos `==` por datos, debemos definir un `hashCode` coherente con esa igualdad. También debemos evitar cambiar
los campos que intervienen en ambos mientras un objeto está guardado como elemento de un conjunto basado en hash o
como clave de un mapa: de lo contrario, podría dejar de encontrarse correctamente.

### Practica 4

Si dos objetos tienen el mismo `hashCode`, ¿podemos afirmar que son iguales? Si `primero == equivalente` es `true`,
¿qué debe cumplirse con sus hashes?

<details>
<summary>Ver respuesta</summary>

Un mismo hash no demuestra igualdad: puede haber colisiones. En cambio, como `primero` y `equivalente` son iguales,
sus hashes deben ser iguales para respetar el contrato.

</details>

## 5. `final`, `const` y objetos que cambian

Es fácil confundir una variable que no podemos reasignar con un objeto que no podemos modificar. Mira este programa:

```dart
void main() {
  final lista = <int>[1];
  lista.add(2);

  const fija = <int>[1];
  const otra = <int>[1];
  var elegida = fija;
  elegida = <int>[3];

  print('Lista final: $lista');
  print('Constantes idénticas: ${identical(fija, otra)}');
  print('Fija: $fija');
  print('Elegida: $elegida');
}
```

La salida es:

```text
Lista final: [1, 2]
Constantes idénticas: true
Fija: [1]
Elegida: [3]
```

- `final lista` impide asignar otra referencia a esa variable. La lista a la que apunta es mutable, por eso `add(2)`
  funciona. Escribir `lista = <int>[]` no compilaría.
- `const fija` crea una lista constante. Esa lista no permite añadir ni cambiar elementos; intentar `fija.add(2)`
  produciría `UnsupportedError`.
- Las dos listas constantes equivalentes del ejemplo comparten una instancia canónica; por eso `identical(fija, otra)`
  devuelve `true`. No extrapoles eso a todas las listas u objetos creados en ejecución.
- `elegida` es una variable reasignable. Al hacer `elegida = <int>[3]`, pasa a apuntar a otra lista; la lista
  constante `fija` no cambia.

Un constructor declarado `const` permite crear valores constantes, pero también puede llamarse sin `const`. Las
llamadas no constantes a `TemaSimple` del apartado 2 producen objetos distintos aunque sus datos sean iguales.

### Practica 5

Si `final nombres = <String>['Ana'];`, ¿qué ocurre con `nombres.add('Luis')` y qué ocurre con
`nombres = <String>[]`?

<details>
<summary>Ver respuesta</summary>

`add` modifica la lista mutable y funciona. La asignación no compila porque intenta reasignar la variable `final`.
La restricción está en la referencia de la variable, no en el contenido de esa lista.

</details>

## 6. Copia exterior y vista no modificable

Una lista que no permite modificar su exterior no garantiza que todos sus elementos sean inmutables. Además, una
**copia** y una **vista** pueden reaccionar de forma diferente cuando cambia la lista original:

```dart
import 'dart:collection';

void main() {
  final fuente = <List<int>>[<int>[1]];
  final copia = List<List<int>>.unmodifiable(fuente);
  final vista = UnmodifiableListView<List<int>>(fuente);

  fuente.add(<int>[2]);
  fuente[0].add(9);

  print('Fuente: $fuente');
  print('Copia: $copia');
  print('Vista: $vista');
}
```

La salida es:

```text
Fuente: [[1, 9], [2]]
Copia: [[1, 9]]
Vista: [[1, 9], [2]]
```

Sigamos los cambios:

1. `List.unmodifiable(fuente)` crea otra lista **exterior**, que inicialmente contiene una referencia a la lista `[1]`.
2. `UnmodifiableListView(fuente)` crea una vista respaldada por `fuente`; no copia sus elementos a otra lista exterior.
3. Al añadir `[2]` a `fuente`, la copia exterior sigue teniendo un elemento; la vista refleja que la fuente ahora tiene
   dos.
4. Al añadir `9` a `fuente[0]`, tanto la copia como la vista ven `[1, 9]`: comparten la misma lista interior mutable.

No podemos añadir o sustituir elementos exteriores usando `copia` ni `vista`. Pero eso no hace inmutable la lista
interior. Para conservar un historial independiente hay que usar elementos inmutables o copiar y proteger los niveles
que puedan cambiar.

### Practica 6

Si después hacemos `fuente.add(<int>[3]);`, ¿cuántos elementos exteriores tendrán `copia` y `vista`? ¿Por qué?

<details>
<summary>Ver respuesta</summary>

`copia` seguirá teniendo uno: su lista exterior se creó antes de los dos `add`. `vista` mostrará tres porque está
respaldada por `fuente`, que ahora contiene tres elementos exteriores.

</details>

## 7. Por qué esto importa para `ValueNotifier`

En la unidad 7 vimos que el setter compara el valor anterior con el propuesto usando `==`. Si son iguales, retorna sin
reemplazarlo ni avisar; si son distintos, guarda el nuevo valor y notifica.

Este ejemplo usa el mismo tipo `TemaSimple` del apartado 2, pero incluye el programa completo para poder ejecutarlo por
separado:

```dart
import 'package:flutter/foundation.dart';

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
  final fuente = ValueNotifier<TemaSimple>(original);
  var avisos = 0;

  void observar() {
    avisos = avisos + 1;
    print('Aviso $avisos: borde ${fuente.value.borde}');
  }

  fuente.addListener(observar);
  fuente.value = equivalente;
  print('Conserva original: ${identical(fuente.value, original)}');
  fuente.value = distinto;
  print('Borde final: ${fuente.value.borde}');
  fuente.removeListener(observar);
  fuente.dispose();
}
```

La salida es:

```text
Conserva original: true
Aviso 1: borde 2
Borde final: 2
```

`equivalente` es otro objeto, pero su nombre y borde son iguales a los de `original`. El setter retorna antes de
guardarlo: la fuente conserva `original` y no avisa. `distinto` tiene borde `2`, así que la regla lo considera
diferente: el setter lo guarda y el listener lee el nuevo borde.

La elección de campos para `==` afecta a esta decisión. Si la igualdad ignorara un dato que el consumidor necesita,
el notificador podría descartar un objeto nuevo con ese dato cambiado. Por eso identidad, igualdad y diseño del estado
van juntas, aunque respondan a preguntas diferentes.

### Practica 7

Si quitamos `fuente.value = distinto;`, ¿cuántos avisos se imprimen y qué borde conserva la fuente?

<details>
<summary>Ver respuesta</summary>

No se imprime ningún aviso y el borde sigue siendo `1`. La propuesta `equivalente` compara igual y se descarta; sin la
segunda asignación no hay ningún valor distinto que guardar.

</details>

## 8. Identidad e igualdad en DaisyUI

El [modelo de tema](../../../lib/themes/domain/theme.dart), `DaisyThemeModel`, se declara con
`@Freezed(equal: false, toStringOverride: true)`. Con `equal: false`, Freezed no genera la igualdad: se define con
Equatable, donde `props` enumera los campos `id`, `name`, `description`, `colors`, `radius`, `size` y `border`, y cada
campo aporta su propia regla de igualdad. `copyWith` permite crear un modelo con cambios sin modificar el original.
Estudiaremos Freezed con más detalle en la unidad 27.

El [controlador](../../../lib/themes/application/daisy_theme_controller.dart) guarda el tema en una señal,
`FlutterSignal<DaisyThemeModel>`, que estudiaremos en la próxima unidad. Esa señal aplica la misma regla que el
`ValueNotifier` del apartado 7, así que la igualdad del modelo participa en la decisión de conservar el valor anterior
o aceptar y notificar el nuevo.

### Prueba guiada

Esta prueba es un archivo completo de **prueba de Flutter**, no un programa para DartPad. Puedes guardarla temporalmente
como `test/themes/estudio_unidad_08_test.dart` y ejecutar desde la raíz:

```sh
flutter test --no-pub test/themes/estudio_unidad_08_test.dart
```

Antes de ejecutarla, predice qué ocurre con la copia equivalente y con la copia que tiene otro borde:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Identidad, igualdad y cambios de tema', () {
    final original = DaisyThemes.light;
    final equivalente = original.copyWith();
    final modificado = original.copyWith(border: 2.0);
    final controller = DaisyThemeController(initialTheme: original);
    addTearDown(controller.dispose);
    var avisos = 0;
    void escuchar() => avisos = avisos + 1;
    controller.theme.addListener(escuchar);

    expect(identical(original, equivalente), isFalse);
    expect(original == equivalente, isTrue);
    expect(original.hashCode, equivalente.hashCode);
    expect(original == modificado, isFalse);
    expect(original.border, 1.0);
    expect(modificado.border, 2.0);

    controller.setTheme(equivalente);
    expect(identical(controller.theme.value, original), isTrue);
    expect(avisos, 0);
    controller.setTheme(modificado);
    expect(controller.theme.value, modificado);
    expect(avisos, 1);
    controller.theme.removeListener(escuchar);
  });
}
```

En esta prueba, `equivalente` es otra instancia que compara igual: el controlador conserva `original` y no avisa. La
copia con borde `2` compara distinta; el controlador la acepta y se registra un aviso. El original conserva su borde
`1`. La prueba comprueba estas instancias y notificaciones; no comprueba una reconstrucción de widget ni un repintado.

### Practica 8

Si `controller.theme.value` sigue siendo idéntico a `original` después de proponer `equivalente`, ¿por qué no basta con
decir que «se guardó la copia sin avisar»?

<details>
<summary>Ver respuesta</summary>

Porque el setter de la señal retorna antes de guardar una propuesta igual, como el de `ValueNotifier`. La prueba
comprueba que la fuente sigue conservando el objeto `original`; la copia no se guardó y tampoco produjo un aviso.

</details>

## Ejercicio final: una configuración de tema

Escribe un programa Dart completo que:

1. Declare `Configuracion` con `nombre` y `borde` como campos `final`.
2. Defina `==` y `hashCode` usando ambos campos. Añada `conBorde(int nuevoBorde)`, que devuelva una configuración nueva
   con el mismo nombre y el borde indicado.
3. Cree `inicial` con `'claro'` y borde `1`, `equivalente` con los mismos datos y `cambio` con `inicial.conBorde(2)`.
4. Imprima si `inicial` y `equivalente` son idénticos y si son iguales; compare también `inicial` con `cambio`.
5. Guarde los tres en un `Set`, imprima su tamaño y compruebe que el borde de `inicial` sigue siendo `1`.

Predice la salida antes de ejecutar. Después explica por qué el conjunto conserva ese número de elementos. Como
variación, imagina que la igualdad y el hash solo consideran el nombre: ¿cuántos elementos quedarían?

<details>
<summary>Ver una posible solución</summary>

```dart
class Configuracion {
  const Configuracion(this.nombre, this.borde);

  final String nombre;
  final int borde;

  Configuracion conBorde(int nuevoBorde) => Configuracion(nombre, nuevoBorde);

  @override
  bool operator ==(Object other) =>
      other is Configuracion && nombre == other.nombre && borde == other.borde;

  @override
  int get hashCode => Object.hash(nombre, borde);
}

void main() {
  final inicial = Configuracion('claro', 1);
  final equivalente = Configuracion('claro', 1);
  final cambio = inicial.conBorde(2);
  final conjunto = <Configuracion>{inicial, equivalente, cambio};

  print('Idénticos: ${identical(inicial, equivalente)}');
  print('Iguales: ${inicial == equivalente}');
  print('Cambio igual: ${inicial == cambio}');
  print('Elementos: ${conjunto.length}');
  print('Borde original: ${inicial.borde}');
}
```

```text
Idénticos: false
Iguales: true
Cambio igual: false
Elementos: 2
Borde original: 1
```

`inicial` y `equivalente` son objetos distintos pero iguales, por lo que el conjunto conserva un solo elemento para
ese valor. `cambio` tiene otro borde y no compara igual, así que aporta el segundo. `conBorde` crea otra configuración
y no modifica `inicial`.

Si igualdad y hash solo consideraran el nombre, los tres resultarían iguales y el conjunto tendría un elemento. Eso
podría ser una mala regla si queremos distinguir configuraciones por su borde.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué pregunta responde `identical` y cómo pueden dos variables acceder al mismo objeto? **Apartado 1.**
2. ¿Pueden dos objetos distintos ser iguales con `==`? ¿Quién define esa regla? **Apartado 2.**
3. ¿En qué se diferencian `==` y `listEquals` para las listas del ejemplo? **Apartado 3.**
4. Si dos objetos son iguales, ¿qué debe cumplirse sobre sus hashes? ¿Vale la regla inversa? **Apartado 4.**
5. ¿Qué impide `final` y qué diferencia hay con una lista `const`? **Apartado 5.**
6. ¿Qué cambia entre una copia exterior no modificable y una vista respaldada por una fuente? **Apartado 6.**
7. ¿Por qué `ValueNotifier` puede conservar el objeto anterior al recibir otro distinto? **Apartado 7.**
8. En DaisyUI, ¿qué muestra la prueba de `copyWith` y qué no demuestra? **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques las respuestas con tus palabras.
La siguiente unidad estudia las señales de Signals, el mecanismo observable que usa el controlador actual para guardar
sus temas.

## Para consultar si necesitas reforzar

- [`identical`](https://api.dart.dev/dart-core/identical.html) y [`Object.==`](https://api.dart.dev/dart-core/Object/operator_equals.html):
  identidad y regla de igualdad.
- [`Object.hashCode`](https://api.dart.dev/dart-core/Object/hashCode.html) y
  [Effective Dart: igualdad](https://dart.dev/effective-dart/design#equality): el contrato entre igualdad y hash.
- [Variables en Dart](https://dart.dev/language/variables): `final` y `const`.
- [`List.unmodifiable`](https://api.dart.dev/dart-core/List/List.unmodifiable.html) y
  [`UnmodifiableListView`](https://api.dart.dev/dart-collection/UnmodifiableListView-class.html): copia exterior y vista.
- [`listEquals`](https://api.flutter.dev/flutter/foundation/listEquals.html) y
  [`ValueNotifier.value`](https://api.flutter.dev/flutter/foundation/ValueNotifier/value.html): comparación de listas y
  decisión del setter.

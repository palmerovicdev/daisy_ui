# 08. Identidad, igualdad e inmutabilidad

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 7](07-value-notifier-un-valor-mutable-que-notifica.md)

- **Bloque:** el sistema de notificaciones de Flutter.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 31 de octubre de 2026.

## Qué vas a conseguir

Podrás responder tres preguntas distintas sobre dos valores: ¿son el mismo objeto?, ¿la igualdad de su tipo los
considera equivalentes? y ¿pueden cambiar sus datos? Veremos cómo esas preguntas afectan a las referencias compartidas,
los conjuntos y la decisión de notificar de `ValueNotifier`.

Después lo aplicaremos al modelo real de DaisyUI, a una copia con `copyWith` y al controlador de temas. Freezed y
Signals tienen unidades propias más adelante: aquí examinaremos solo lo necesario para comprobar ejemplos concretos.
La elaboración de esta guía no significa que hayas completado el estudio.

## Ruta y progreso

Repasa de la unidad 3 qué es una referencia y de la unidad 7 las dos ramas del setter de `ValueNotifier`. Los ejemplos
A–D y la solución del proyecto son **programas completos e independientes** para [DartPad](https://dartpad.dev/) en
modo Dart; copia uno cada vez. El ejemplo E es una prueba para ejecutar en este repositorio con Flutter. Los demás
bloques son fragmentos para leer, no programas completos.

- [ ] [8.1. Identidad y referencias compartidas](#81-identidad-y-referencias-compartidas).
- [ ] [8.2. Igualdad: una regla del tipo](#82-igualdad-una-regla-del-tipo).
- [ ] [8.3. Listas y comparación de contenido](#83-listas-y-comparación-de-contenido).
- [ ] [8.4. El contrato de `hashCode`](#84-el-contrato-de-hashcode).
- [ ] [8.5. `final`, `const` y cambios internos](#85-final-const-y-cambios-internos).
- [ ] [8.6. Inmutabilidad, copias y vistas](#86-inmutabilidad-copias-y-vistas).
- [ ] [8.7. Igualdad y notificaciones](#87-igualdad-y-notificaciones).
- [ ] [8.8. Los temas reales de DaisyUI](#88-los-temas-reales-de-daisyui).
- [ ] [Resolver el proyecto](#proyecto-de-la-unidad-un-valor-de-configuración).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes repartirlo en tres sesiones: 8.1–8.3, 8.4–8.6, y 8.7–8.8 con el proyecto. Predice antes de ejecutar y
revisa las soluciones al final. Marca cada casilla cuando puedas explicar las variaciones sin copiarlas.

## 8.1. Identidad y referencias compartidas

### El problema

Dos personas pueden tener una llave para la misma caja o una llave para cada una de dos cajas con el mismo contenido.
Una etiqueta que apunta a la caja no es una copia de su contenido. La analogía ayuda a seguir referencias, pero las
variables de Dart no son llaves físicas: representan referencias a objetos.

[`identical(a, b)`](https://api.dart.dev/dart-core/identical.html) pregunta si ambas referencias corresponden al mismo
objeto. Que dos variables sean diferentes no demuestra que señalen objetos diferentes. Si son referencias al mismo
objeto mutable, un cambio por una referencia es visible al leer por la otra.

### Ejemplo A: una referencia compartida y otra lista

```dart
void main() {
  final primera = <String>['claro'];
  final alias = primera;
  final copia = <String>[...primera];

  print('primera y alias: ${identical(primera, alias)}');
  print('primera y copia: ${identical(primera, copia)}');
  alias.add('oscuro');
  print('primera: $primera');
  print('copia: $copia');
}
```

Dibuja las tres variables y las dos listas. `...primera` coloca las referencias de los elementos en una lista nueva;
no copia recursivamente los objetos que pudieran ser esos elementos. Aquí son cadenas inmutables. `final` evita
reasignar cada variable, no impide ejecutar `add` en una lista mutable.

### Comprobación

- ¿Cuál de las listas cambia al llamar a `alias.add`? ¿Por qué?
- ¿Qué ocurriría si `copia` se inicializara con `primera`, sin crear una lista?
- ¿Probar que dos objetos no son idénticos dice si sus contenidos son iguales?

**Puedes avanzar cuando:** dibujas las referencias sin confundir dos variables con dos objetos.

## 8.2. Igualdad: una regla del tipo

La identidad pregunta por el objeto; `a == b` pregunta por la igualdad que corresponda a `a`. La implementación
predeterminada de [`Object.==`](https://api.dart.dev/dart-core/Object/operator_equals.html) usa identidad, pero una
clase puede definir igualdad por datos. Con valores no nulos se utiliza el operador del lado izquierdo; `null` tiene
reglas propias. La clase debe respetar reflexividad, simetría, transitividad y consistencia mientras no cambien los
datos relevantes. Las reglas completas están en [Effective Dart](https://dart.dev/effective-dart/design#equality).

### Ejemplo B: objetos distintos con los mismos datos

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
  final alias = original;
  final equivalente = TemaSimple('claro', 1);
  final distinto = TemaSimple('claro', 2);

  print('alias idéntico: ${identical(original, alias)}');
  print('copia idéntica: ${identical(original, equivalente)}');
  print('copia igual: ${original == equivalente}');
  print('borde distinto: ${original == distinto}');
  print('hash igual: ${original.hashCode == equivalente.hashCode}');
}
```

Aunque el constructor admita `const`, las llamadas de este ejemplo no son constantes: cada invocación generativa no
constante crea una instancia nueva. El operador revisa tipo, nombre y borde. Dos objetos distintos pueden ser iguales
según esa regla. Añadimos `hashCode` para respetar el contrato que estudiaremos a continuación.

### Comprobación

- ¿Qué sucede con `original == equivalente` si se elimina el operador personalizado?
- ¿Qué afirmas exactamente al decir que dos temas son iguales en este ejemplo?
- Si solo compararas `nombre`, ¿qué sucedería con dos temas de distinto borde? ¿Conviene esa regla para tu uso?

**Puedes avanzar cuando:** explicas por separado `identical`, `==` y los campos elegidos para la regla.

## 8.3. Listas y comparación de contenido

Las listas ordinarias del ejemplo A heredan una igualdad que no compara sus elementos. Por eso, dos listas nuevas con
los mismos elementos no son iguales mediante `==`, aunque puedas comparar sus contenidos con otra operación. Esto no
impide que otro tipo defina una igualdad diferente.

En Flutter, [`listEquals`](https://api.flutter.dev/flutter/foundation/listEquals.html) compara longitud y elementos en
orden usando `==` para cada elemento. No garantiza comparación profunda de colecciones anidadas: si un elemento es otra
lista ordinaria, su propia igualdad sigue sin comparar su contenido. Para una necesidad de comparación profunda debe
elegirse una política apropiada, por ejemplo `DeepCollectionEquality` de `package:collection`.

Fragmento para leer en Flutter:

```dart

final a = <int>[1, 2];
final b = <int>[1, 2];
final anidadaA = <List<int>>[<int>[1]];
final anidadaB = <List<int>>[<int>[1]];
// identical(a, b): false; a == b: false; listEquals(a, b): true.
// listEquals(anidadaA, anidadaB): false por las listas interiores.
```

Cambiar el orden de `b` a `[2, 1]` hace que `listEquals(a, b)` sea `false`. Piensa si el orden representa una
diferencia de producto antes de adoptar esa comparación. `ValueNotifier` no llama por sí mismo a `listEquals`.

### Comprobación

- ¿Qué compara `listEquals` cuando sus elementos son objetos con `==` personalizado?
- ¿Por qué una comprobación superficial puede no servir para listas anidadas?
- ¿Cuál de las tres operaciones preguntaría si `a` y `b` son literalmente la misma lista?

## 8.4. El contrato de `hashCode`

Un `hashCode` es un entero usado, entre otras cosas, por los `Set` y `Map` basados en hash para organizar la búsqueda.
No es un identificador único ni sustituye a `==`. La regla esencial es **si `a == b`, sus hash deben ser iguales**.
La inversa no está garantizada: dos objetos diferentes y no iguales pueden compartir hash. No dependas de que el
número sea el mismo entre ejecuciones. Consulta [`Object.hashCode`](https://api.dart.dev/dart-core/Object/hashCode.html)
y [`HashSet`](https://api.dart.dev/dart-collection/HashSet-class.html).

El conjunto usa hash e igualdad para reconocer elementos equivalentes. Si defines `==` por datos y dejas un hash
incompatible, un conjunto o mapa puede no encontrar una clave equivalente. Si modificas un campo que afecta a igualdad
o hash mientras el objeto está dentro de la colección, la búsqueda y retirada pueden dejar de comportarse como esperas.
No es necesario adivinar un resultado concreto de un programa que viola ese contrato.

### Ejemplo C: un conjunto de valores

```dart
class Preferencia {
  const Preferencia(this.nombre, this.borde);

  final String nombre;
  final int borde;

  @override
  bool operator ==(Object other) =>
      other is Preferencia && nombre == other.nombre && borde == other.borde;

  @override
  int get hashCode => Object.hash(nombre, borde);
}

void main() {
  final primero = Preferencia('claro', 1);
  final equivalente = Preferencia('claro', 1);
  final distinto = Preferencia('claro', 2);
  final conjunto = <Preferencia>{primero, equivalente, distinto};
  print('objetos idénticos: ${identical(primero, equivalente)}');
  print('hashes iguales: ${primero.hashCode == equivalente.hashCode}');
  print('elementos: ${conjunto.length}');
  print('encuentra equivalente: ${conjunto.contains(equivalente)}');
}
```

Predice la salida. `Object.hash` combina los campos de este ejemplo: ambos objetos iguales le pasan los mismos valores.
Es una forma de construir el hash, no una prueba de que no existan colisiones.

### Comprobación

- Si dos hashes son iguales, ¿deben ser iguales los objetos?
- ¿Por qué el conjunto conserva dos elementos y no tres?
- ¿Por qué sería peligroso hacer mutable `borde` mientras una preferencia se usa como clave?

## 8.5. `final`, `const` y cambios internos

`final` permite inicializar una variable una sola vez. Una variable `final` puede referirse a un objeto creado en
ejecución y mutable. Un campo `final` también puede apuntar a una lista mutable: no se puede sustituir la referencia,
pero eso por sí solo no protege el contenido. Consulta [variables en Dart](https://dart.dev/language/variables).

`const` declara un valor constante de compilación; un constructor constante exige condiciones para producir un objeto
constante, y sus campos de instancia deben ser `final`. En un contexto constante, los valores anidados deben ser
constantes. Un constructor declarado `const` también puede invocarse sin `const` en tiempo de ejecución, como en B.
Dart puede compartir la instancia canónica de expresiones constantes equivalentes; no extrapoles el resultado de
`identical` de esas expresiones a todas las construcciones ordinarias.

### Ejemplo D: referencias y colecciones constantes

```dart
void main() {
  final lista = <int>[1];
  lista.add(2);
  const fija = <int>[1];
  const otra = <int>[1];
  var elegida = fija;
  elegida = <int>[3];
  print('final mutable: $lista');
  print('const compartida: ${identical(fija, otra)}');
  print('fija: $fija');
  print('elegida: $elegida');
}
```

No ejecutes `fija.add(2)` en este programa: la lista constante rechaza el cambio con `UnsupportedError`. La variable
`elegida` es reasignable aunque inicialmente apunte a un valor constante. En cambio `lista = <int>[]` no compila porque
`lista` es `final`. Son dos restricciones en lugares distintos: la variable y el objeto.

### Comprobación

- ¿Por qué `lista.add(2)` funciona, pero `lista = <int>[]` no compila?
- ¿Qué resultado tiene `identical(fija, otra)` y por qué es especial este caso constante?
- ¿Se vuelve mutable `fija` al reasignar `elegida`?

## 8.6. Inmutabilidad, copias y vistas

Un objeto inmutable mantiene su estado observable durante toda su vida. No basta con impedir que una referencia se
reasigne si ese objeto expone una lista mutable u otro objeto mutable. Para razonar sobre una estructura completa hay
que seguir también sus elementos y cualquier referencia compartida hacia ellos.

[`List.unmodifiable`](https://api.dart.dev/dart-core/List/List.unmodifiable.html) crea una lista exterior que no admite
cambiar longitud ni elementos y toma los elementos del iterable. No crea copias profundas de esos elementos. Una
[`UnmodifiableListView`](https://api.dart.dev/dart-collection/UnmodifiableListView-class.html), en cambio, es una vista
no modificable respaldada por la fuente: quien conserva la lista original puede modificarla y la vista reflejará el
cambio. Una lista copiada puede compartir objetos mutables con el original.

Fragmento para razonar:

```dart

final fuente = <List<int>>[<int>[1]];
final copia = List<List<int>>.unmodifiable(fuente);
fuente.add
(<int>[2]); // copia sigue teniendo una sola lista exterior.
fuente[0].
add
(
9
); // copia[0] también ve [1, 9]: elemento compartido.
// copia.add(<int>[3]);     // UnsupportedError: exterior no modificable.
```

Para un estado histórico fiable se necesita evitar cambios posteriores en todas las partes relevantes, sea usando
objetos inmutables y compartiéndolos, o copiando y protegiendo los niveles necesarios. Una copia superficial no es
incorrecta por definición: es suficiente cuando sus elementos compartidos son inmutables o la aplicación controla su
vida útil y mutación.

### Comprobación

- ¿Por qué `copia.length` es uno después del `add` a `fuente`?
- ¿Por qué el contenido de `copia[0]` cambia de todos modos?
- ¿Qué cambia si se usa una vista sobre `fuente` en lugar de una copia exterior?

## 8.7. Igualdad y notificaciones

En la unidad 7 vimos el [setter de
`ValueNotifier`](https://api.flutter.dev/flutter/foundation/ValueNotifier/value.html):
compara `valorAnterior == valorPropuesto`. Si son iguales retorna **antes de reemplazar el objeto** y sin notificar;
si son distintos almacena el propuesto y llama a `notifyListeners`. El contrato de `ValueListenable` no exige esa
política a todas sus implementaciones.

Si un objeto mutable ya almacenado cambia por dentro, nadie llamó al setter. Guardar una referencia al valor anterior
tampoco recupera su estado anterior, pues puede apuntar al mismo objeto modificado. Al diseñar valores inmutables, una
actualización puede crear otro objeto dejando el anterior intacto; la igualdad define qué cambios considera relevantes
el consumidor. Si la igualdad ignora una propiedad que sí importa a la interfaz, la política del setter puede descartar
la propuesta y conservar un valor obsoleto para ese consumidor.

**Ejercicio mental:** un `ValueNotifier<TemaSimple>` contiene `TemaSimple('claro', 1)` de B. Le asignas otro con los
mismos campos y después uno con borde 2. ¿Cuántos avisos recibe un listener que permaneció registrado? ¿Qué instancia
queda almacenada tras la primera asignación? Compara tu respuesta con las soluciones.

## 8.8. Los temas reales de DaisyUI

[`DaisyThemeModel`](../../../lib/themes/domain/theme.dart) declara `id`, `name`, `description`, `colors`, `radius`, `size`
y `border`; el archivo usa `@freezed`. En la salida generada actual
[`theme.freezed.dart`](../../../lib/themes/domain/generated/theme.freezed.dart), la igualdad comprueba identidad como
atajo y después tipo y esos campos mediante sus respectivas igualdades. El `hashCode` generado combina tipo y campos.
Esto no significa que cualquier objeto anidado tenga automáticamente igualdad profunda: cada campo aporta su propia
regla. Freezed genera `copyWith`; lo estudiaremos en detalle en la unidad 27.

[`DaisyThemes.light`](../../../lib/themes/domain/daisy_themes.dart) es un tema constante. `copyWith` permite proponer otro
modelo sin modificar el original. Compartir referencias a partes que no cambian no implica por sí solo una mutación ni
una copia profunda. El [`DaisyThemeController`](../../../lib/themes/application/daisy_theme_controller.dart) conserva una
señal interna, expone una vista de lectura y asigna mediante `setTheme`.

### Ejemplo E: prueba en el proyecto

Crea temporalmente `test/themes/estudio_unidad_08_test.dart` con este contenido y ejecuta
`flutter test --no-pub test/themes/estudio_unidad_08_test.dart`. La prueba usa las dependencias del proyecto; no se
puede copiar tal cual en DartPad sin incorporarlas.

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
    void escuchar() => avisos++;
    controller.theme.addListener(escuchar);

    expect(identical(original, equivalente), isFalse);
    expect(original == equivalente, isTrue);
    expect(original.hashCode, equivalente.hashCode);
    expect(original == modificado, isFalse);
    expect(original.border, 1.0);
    expect(modificado.border, 2.0);

    controller.setTheme(equivalente);
    expect(avisos, 0);
    controller.setTheme(modificado);
    expect(avisos, 1);
    expect(controller.theme.value, modificado);
    controller.theme.removeListener(escuchar);
  });
}
```

Predice cada `expect` antes de ejecutarla. La prueba observa estas instancias y operaciones concretas de la versión
instalada; no demuestra todas las reglas internas de Signals ni que un widget se haya reconstruido. La prueba existente
[del controlador](../../../test/themes/daisy_theme_controller_test.dart) también verifica que una copia equivalente de
`light` no avisa y que cambiar a `dark` sí avisa. No atribuyas sin verificar todas las ramas de `ValueNotifier` al
setter de la señal: ese será nuestro estudio de la unidad 9.

### Comprobación

- ¿Cómo sabes que cambiar `border` en la copia no cambió el original?
- ¿Qué compara el operador generado del tema y quién compara cada objeto anidado?
- ¿Qué permite afirmar exactamente la prueba sobre avisos? ¿Qué no comprueba?

## Materiales de estudio seleccionados

Todos son gratuitos; las referencias oficiales están en inglés y esta guía en español.

- **D1 · Dart:** [`identical`](https://api.dart.dev/dart-core/identical.html) y
  [variables, `final` y `const`](https://dart.dev/language/variables) — 8.1 y 8.5: referencias, identidad y constantes.
- **D2 · Dart:** [`Object.==`](https://api.dart.dev/dart-core/Object/operator_equals.html),
  [`Object.hashCode`](https://api.dart.dev/dart-core/Object/hashCode.html) y
  [Effective Dart: igualdad](https://dart.dev/effective-dart/design#equality) — 8.2 y 8.4: contrato y diseño.
- **D3 · Dart:** [`List.==`](https://api.dart.dev/dart-core/List/operator_equals.html),
  [`List.unmodifiable`](https://api.dart.dev/dart-core/List/List.unmodifiable.html) y
  [`UnmodifiableListView`](https://api.dart.dev/dart-collection/UnmodifiableListView-class.html) — 8.3 y 8.6.
- **F1 · Flutter:** [`listEquals`](https://api.flutter.dev/flutter/foundation/listEquals.html) y
  [setter de `ValueNotifier`](https://api.flutter.dev/flutter/foundation/ValueNotifier/value.html) — 8.3 y 8.7.
- **P1 · Freezed:** [documentación del paquete](https://pub.dev/packages/freezed) — 8.8; contrasta la documentación
  con el código generado por la versión resuelta en este proyecto.
- **P2 · Proyecto:** [modelo](../../../lib/themes/domain/theme.dart),
  [código generado](../../../lib/themes/domain/generated/theme.freezed.dart),
  [controlador](../../../lib/themes/application/daisy_theme_controller.dart) y
  [pruebas](../../../test/themes/daisy_theme_controller_test.dart).
- **P3 · Práctica:** [DartPad](https://dartpad.dev/) y su [documentación](https://dart.dev/tools/dartpad) para A–D y
  el proyecto de la unidad; Flutter local para E.

## Proyecto de la unidad: un valor de configuración

Diseña `Configuracion` con `nombre` y `borde` inmutables. Dos configuraciones son iguales si coinciden ambos campos.
Añade un método `conBorde` que devuelva otra configuración con el mismo nombre y el borde indicado. Usa `==` y
`hashCode` coherentes. No uses Freezed: implementa el ejercicio para entender qué contrato debe cumplir.

### Requisitos

1. Crea `inicial` con `claro` y borde 1, `equivalente` con los mismos datos y `cambio` mediante `conBorde(2)`.
2. Imprime si `inicial` y `equivalente` son idénticos y si son iguales; compara también `inicial` con `cambio`.
3. Inserta los tres en un `Set` y muestra su tamaño. Comprueba que el borde de `inicial` sigue siendo 1.
4. Predice todas las salidas antes de ejecutarlo. Explica qué ocurre con cada objeto y qué regla usa el conjunto.

### Variaciones

- Haz que igualdad y hash utilicen solo `nombre`: ¿cuántos elementos quedan en el conjunto? ¿Por qué podría ser una
  mala política si el borde se muestra en pantalla?
- ¿Por qué crear `conBorde(1)` puede producir un objeto distinto pero igual?
- ¿Qué peligro introduces si `borde` pasa a ser mutable después de guardar la instancia en un conjunto?
- ¿Por qué no tiene sentido exigir que los hashes de dos configuraciones distintas sean diferentes?

Una solución ejecutable aparece al final. Diseña primero la tuya; una implementación coherente puede seguir otras
formas equivalentes.

## Errores de comprensión que vamos a comprobar

- Identificar dos variables diferentes con dos objetos diferentes, o una referencia guardada con una copia profunda.
- Suponer que `==` significa siempre identidad o siempre igualdad profunda.
- Creer que `identical` con constantes demuestra que todas las construcciones equivalentes son idénticas.
- Pensar que dos objetos con el mismo hash son necesariamente iguales.
- Cambiar un campo que interviene en igualdad mientras el objeto está en una colección basada en hash.
- Pensar que `final` vuelve inmutable la lista a la que apunta o que `const` impide reasignar otra variable.
- Confundir una vista respaldada por una fuente con una copia exterior y con una copia profunda.
- Atribuir a cualquier `ValueListenable` la política del setter de `ValueNotifier`.
- Dar por demostrada una reconstrucción de widget por una prueba que solo cuenta avisos.

## Comprobación final

Responde sin consultar las soluciones y justifica cada respuesta:

1. ¿Qué pregunta responde `identical` y qué pregunta responde `==`?
2. ¿Cómo pueden dos referencias distintas observar una mutación de la misma lista?
3. ¿Por qué dos listas ordinarias del mismo contenido pueden no ser iguales con `==`?
4. ¿Qué comprueba `listEquals` y qué límite tiene con listas anidadas?
5. Indica el contrato entre `==` y `hashCode`. ¿Vale también a la inversa?
6. ¿Qué riesgos aparecen al cambiar la igualdad de un objeto dentro de un `Set`?
7. Distingue reasignar una variable `final`, modificar el objeto al que apunta y modificar una lista `const`.
8. ¿Por qué las dos expresiones constantes de D son idénticas? ¿Ocurre siempre con cualquier constructor?
9. ¿Qué protege una lista exterior no modificable? Compara copia exterior y vista.
10. ¿Por qué el setter de `ValueNotifier` puede conservar el objeto anterior cuando recibe uno diferente?
11. ¿Qué campos compara la igualdad generada del tema actual y cómo se comparan sus valores anidados?
12. En E, ¿qué sabemos sobre las copias, el original y el número de avisos? ¿Qué no prueba?

**Unidad dominada cuando:** puedes resolver el proyecto, justificar los ejemplos y separar identidad, igualdad e
inmutabilidad sin copiar las respuestas.

## Soluciones para contrastar después de practicar

### Ejemplo A

```text
primera y alias: true
primera y copia: false
primera: [claro, oscuro]
copia: [claro]
```

`primera` y `alias` apuntan a la misma lista. La expansión creó otra lista exterior, que no recibe el `add`.

### Ejemplo B

```text
alias idéntico: true
copia idéntica: false
copia igual: true
borde distinto: false
hash igual: true
```

Sin igualdad personalizada, las dos instancias generativas no constantes diferentes usan la igualdad por identidad de
`Object`. Si solo comparas el nombre, el par con distinto borde se consideraría igual; su `hashCode` también tendría que
basarse únicamente en los campos relevantes para esa regla.

### Ejemplo C

```text
objetos idénticos: false
hashes iguales: true
elementos: 2
encuentra equivalente: true
```

`primero` y `equivalente` son distintos pero iguales; el segundo no añade un elemento equivalente adicional. El borde
2 hace que el tercer valor no sea igual. El contrato no exige que su hash sea distinto.

### Ejemplo D

```text
final mutable: [1, 2]
const compartida: true
fija: [1]
elegida: [3]
```

Las listas constantes equivalentes del ejemplo se canonizan. El `add` actúa sobre una lista mutable; reasignar
`elegida` cambia esa variable y no modifica la lista constante.

### Fragmentos y ejercicio mental

En 8.3, `listEquals(a, b)` es `true`, pero la comparación de las listas anidadas es `false` por los elementos
interiores. En 8.6, `copia.length` es 1 y `copia[0]` es `[1, 9]`. Con una vista respaldada por `fuente`, el `add` a
la fuente se reflejaría también en la vista.

En 8.7 hay **un aviso**. La primera propuesta es igual y `ValueNotifier` conserva la instancia anterior; la segunda
difiere por el borde, se almacena y se notifica. Esto describe el setter de `ValueNotifier`, no todas las señales.

En E los `expect` pasan con los valores y dependencias del proyecto comprobados para esta guía. La copia equivalente
es distinta e igual; el nuevo borde es distinto y el original conserva 1. Se observa un aviso en las dos llamadas al
controlador. La prueba no mide reconstrucciones ni demuestra la política general del paquete Signals.

### Una solución del proyecto

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
  print('idénticos: ${identical(inicial, equivalente)}');
  print('iguales: ${inicial == equivalente}');
  print('cambio igual: ${inicial == cambio}');
  print('elementos: ${conjunto.length}');
  print('borde original: ${inicial.borde}');
}
```

```text
idénticos: false
iguales: true
cambio igual: false
elementos: 2
borde original: 1
```

Si igualdad y hash solo consideran el nombre, los tres valores resultan iguales y el conjunto tiene un elemento.
`conBorde(1)` crea otra instancia no constante con los mismos datos. Un borde mutable rompería la estabilidad
necesaria durante la pertenencia al conjunto. Hashes diferentes no están garantizados para valores desiguales.

### Claves de la comprobación final

1. Mismo objeto frente a regla de equivalencia del tipo.
2. Ambas apuntan a la misma lista; cambiarla por una se observa por la otra.
3. Su igualdad ordinaria no compara los elementos.
4. Elementos en orden mediante su `==`; no recorre profundamente listas anidadas por defecto.
5. Iguales implican igual hash; hash igual no implica objetos iguales.
6. La colección puede dejar de encontrar o retirar correctamente el objeto.
7. `final` impide reasignar; el objeto puede admitir cambios; la lista constante rechaza mutaciones.
8. Canonización de constantes equivalentes; una construcción generativa no constante crea otra instancia.
9. Protege longitud y elementos exteriores; la vista refleja cambios de la fuente, la copia exterior no, pero puede
   compartir elementos mutables.
10. Su comparación da `true` y retorna antes de guardar o notificar.
11. Compara tipo, `id`, `name`, `description`, `colors`, `radius`, `size` y `border`; cada valor anidado aporta su
    propia igualdad.
12. La copia equivalente es distinta e igual, el cambio conserva el original y en ese flujo se registra un aviso;
    no demuestra reconstrucción ni la política general de Signals.

## Qué se ha revisado y cómo se ha comprobado

- Se contrastaron las referencias enlazadas y los archivos actuales del modelo, su código generado, el controlador y
  sus pruebas. El proyecto resuelve Freezed 4.0.2 y `signals_flutter` 7.1.0; otras versiones pueden diferir.
- El servidor del grafo rechazó indexar esta raíz por su configuración de acceso; los archivos del proyecto citados se
  verificaron por lectura directa.
- Se ejecutaron localmente los ejemplos A–D y la solución del proyecto: sus salidas coincidieron con las soluciones.
  El analizador de Dart no encontró problemas en esos cinco programas. No se ejecutaron en DartPad.
- Pasaron la prueba temporal E y las tres pruebas existentes del controlador: **4 pruebas**. Después se retiró el
  archivo temporal. Estas pruebas no verifican la reconstrucción de widgets ni la apariencia de una pantalla.
- Se comprobaron los enlaces locales, el equilibrio de los bloques de código y `git diff --check`.

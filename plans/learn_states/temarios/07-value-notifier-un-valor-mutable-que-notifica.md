# 07. `ValueNotifier`: un valor mutable que notifica

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 6](06-value-listenable-avisos-y-valor-actual.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 6 usamos `ValueListenable<T>` para leer un valor y escuchar avisos. Ese contrato no incluye una operación para escribir el valor. Ahora estudiaremos `ValueNotifier<T>`, una implementación de Flutter que conserva un valor y permite asignarle otro.

Al terminar podrás predecir cuándo avisa al asignar un número o una lista, explicar por qué modificar una lista por dentro puede pasar desapercibido y reconocer qué parte de esa política se mantiene en el controlador actual de DaisyUI.

Los programas de consola completos usan Flutter. Puedes copiar cada uno en [DartPad](https://dartpad.dev/), elegir **Flutter** y pulsar **Run**; observa la consola. Predice la salida antes de ejecutar. Puedes hacer una pausa después del apartado 3 y continuar en otra sesión.

## 1. Del contrato a un valor que podemos cambiar

`ValueListenable<int>` permite consultar un entero y registrar listeners. `ValueNotifier<int>` cumple ese contrato y además permite asignar otro entero:

```dart
final contador = ValueNotifier<int>(0);
print(contador.value);
contador.value = 1;
```

Este es un fragmento, no un programa completo. La primera línea crea un notificador con valor inicial `0`; la segunda lo lee y la tercera propone el valor `1` mediante el **setter** `value`.

`ValueNotifier` extiende `ChangeNotifier`: hereda el mecanismo para registrar y retirar listeners, notificarlos y liberar el objeto. El propio setter decide cuándo utilizar ese mecanismo. Los listeners siguen siendo funciones sin argumentos; si quieren conocer el dato, pueden leer `.value` cuando los llamen.

### Practica 1

Si una función recibe un parámetro de tipo `ValueListenable<int>`, ¿puede leer `.value`? ¿Puede asignar otro valor mediante ese tipo?

<details>
<summary>Ver respuesta</summary>

Puede leerlo y registrar listeners. No puede asignar `fuente.value = ...` usando solo ese tipo: el contrato `ValueListenable` declara un getter, pero no un setter. El objeto concreto podría ofrecer un setter mediante otro tipo.

</details>

## 2. Qué hace el setter

Al escribir `contador.value = nuevoValor`, `ValueNotifier` compara el valor que ya conserva con el propuesto usando `==`. Su lógica es equivalente a este fragmento del SDK de Flutter:

```dart
set value(T newValue) {
  if (_value == newValue) {
    return;
  }
  _value = newValue;
  notifyListeners();
}
```

Léelo en orden:

1. Si el valor anterior es igual al propuesto según `==`, el setter termina con `return`.
2. Si no son iguales, guarda el valor propuesto.
3. Después llama a `notifyListeners()`, que ejecuta los listeners registrados.

Hay un detalle importante: si `==` dice que son iguales, el setter vuelve **antes de guardar** el nuevo valor. No solo se evita el aviso; se conserva el valor anterior. Veremos un caso donde dos objetos distintos se consideran iguales en el apartado 5.

Esta política pertenece a `ValueNotifier`, no a todos los `ValueListenable`. Tampoco significa que `ChangeNotifier` vigile automáticamente los campos de una clase, como vimos en la unidad 5.

### Practica 2

Un notificador contiene `2`. Le asignamos `2` y después `3`. ¿En qué asignación guarda un valor y avisa?

<details>
<summary>Ver respuesta</summary>

Al asignar `2`, la comparación da igual y el setter termina. Al asignar `3`, la comparación da distinto: guarda `3` y notifica a los listeners registrados.

</details>

## 3. Números: contar asignaciones y avisos

Vamos a seguir un ejemplo completo. Antes de ejecutarlo, predice las líneas que imprimirá el listener:

```dart
import 'package:flutter/foundation.dart';

void main() {
  final contador = ValueNotifier<int>(0);
  var avisos = 0;

  void observar() {
    avisos = avisos + 1;
    print('Aviso $avisos: ${contador.value}');
  }

  contador.addListener(observar);
  print('Inicial: ${contador.value}');
  contador.value = 1;
  contador.value = 1;
  contador.value = 2;
  contador.removeListener(observar);
  contador.value = 3;
  print('Final: ${contador.value}; avisos recibidos: $avisos');
  contador.dispose();
}
```

La salida es:

```text
Inicial: 0
Aviso 1: 1
Aviso 2: 2
Final: 3; avisos recibidos: 2
```

1. `0 == 1` es falso: se guarda `1` y se ejecuta `observar`.
2. `1 == 1` es verdadero: el setter termina sin guardar otro valor ni notificar.
3. `1 == 2` es falso: se guarda `2` y el listener recibe otro aviso.
4. Retiramos el listener. El cambio de `2` a `3` sí atraviesa la rama que guarda y notifica, pero `observar` ya no está registrado y no se ejecuta. La lectura final obtiene `3`.

Hay cuatro llamadas al setter, tres que guardan y notifican, y dos ejecuciones de ese listener. En este ejemplo, `main` crea el notificador, retira su listener y lo libera con `dispose()`.

### Practica 3

Si movemos `contador.removeListener(observar)` después de la asignación a `3`, ¿qué línea adicional aparece y cuántos avisos recibirá el listener?

<details>
<summary>Ver respuesta</summary>

Aparece `Aviso 3: 3` antes de la línea final. El listener recibe tres avisos porque sigue registrado durante los tres cambios a valores distintos.

</details>

## 4. Listas: cambiar su contenido o sustituirlas

Ahora guardaremos una lista de temas. Compara `temas.value.add(...)` con `temas.value = otraLista`:

```dart
import 'package:flutter/foundation.dart';

void main() {
  final temas = ValueNotifier<List<String>>(<String>['claro']);
  final listaGuardada = temas.value;
  var avisos = 0;

  void observar() {
    avisos = avisos + 1;
    print('Aviso $avisos: ${temas.value.join(', ')}');
  }

  temas.addListener(observar);
  temas.value.add('oscuro');
  print('Tras add: ${temas.value.join(', ')}');
  print('Lista guardada: ${listaGuardada.join(', ')}');

  temas.value = temas.value;
  print('Avisos tras reasignar: $avisos');

  temas.value = <String>[...temas.value, 'cupcake'];
  print('Final: ${temas.value.join(', ')}');
  temas.removeListener(observar);
  temas.dispose();
}
```

La salida es:

```text
Tras add: claro, oscuro
Lista guardada: claro, oscuro
Avisos tras reasignar: 0
Aviso 1: claro, oscuro, cupcake
Final: claro, oscuro, cupcake
```

`temas.value.add('oscuro')` primero lee la lista y después modifica esa lista con `add`. **No asigna** otra lista a `temas.value`, así que el setter no se ejecuta ni avisa por esa operación. Una lectura directa sí ve el contenido nuevo: la lista cambió. `listaGuardada` apunta a esa misma lista, no a una fotografía de su contenido anterior.

`temas.value = temas.value` sí llama al setter, pero le entrega la misma lista que ya conserva. La comparación da igual y no hay aviso. Esa reasignación no recupera el contenido anterior ni fuerza una notificación.

Por último, `<String>[...temas.value, 'cupcake']` crea una lista nueva con los elementos anteriores y uno más. En este ejemplo, las listas ordinarias usan igualdad por identidad: la nueva lista no es la anterior. El setter la guarda y notifica. El operador `...` copia las referencias de los elementos a la lista exterior nueva; no crea copias profundas de objetos mutables que pudieran estar dentro.

### Practica 4

Después de la última asignación, ¿`listaGuardada` apunta a la lista nueva? ¿Qué contenidos tiene?

<details>
<summary>Ver respuesta</summary>

No. Sigue apuntando a la lista anterior, que contiene `claro, oscuro`. La fuente ahora guarda otra lista que también contiene `cupcake`. Sustituir la lista del notificador no reasigna la variable `listaGuardada`.

</details>

## 5. ¿Mismo objeto o contenido igual?

Dos listas diferentes pueden contener los mismos elementos. Veamos qué compara el setter y qué nos dice `listEquals`:

```dart
import 'package:flutter/foundation.dart';

void main() {
  final primera = <int>[1, 2];
  final copia = <int>[1, 2];
  final numeros = ValueNotifier<List<int>>(primera);
  var avisos = 0;
  void observar() => avisos = avisos + 1;

  numeros.addListener(observar);
  print('Mismo objeto: ${identical(primera, copia)}');
  print('Iguales con ==: ${primera == copia}');
  print('Mismos elementos: ${listEquals(primera, copia)}');

  numeros.value = copia;
  print('Avisos tras copia: $avisos');
  numeros.value = copia;
  print('Avisos tras repetir: $avisos');

  numeros.removeListener(observar);
  numeros.dispose();
}
```

La salida es:

```text
Mismo objeto: false
Iguales con ==: false
Mismos elementos: true
Avisos tras copia: 1
Avisos tras repetir: 1
```

`identical` pregunta si son el mismo objeto. Las listas ordinarias recién creadas de este ejemplo se comparan por identidad con `==`, de modo que la copia es distinta para el setter aunque sus elementos coincidan. Al asignarla se guarda y se avisa; volver a asignar esa misma lista no produce otro aviso.

`listEquals` compara los elementos en orden usando el `==` de cada uno. Esa comparación la hacemos nosotros: el setter de `ValueNotifier` **no llama a `listEquals`**. Tampoco debemos asumir una comparación profunda general de listas anidadas. La unidad 8 profundizará en identidad, igualdad e inmutabilidad.

### Objetos diferentes que `==` considera iguales

También puede ocurrir lo contrario: dos objetos distintos pueden definir que son iguales. En ese caso, el setter conserva el objeto anterior. Este ejemplo define igualdad solo por código para mostrar qué implica esa decisión:

```dart
import 'package:flutter/foundation.dart';

class Etiqueta {
  Etiqueta(this.codigo, this.descripcion);

  final int codigo;
  final String descripcion;

  @override
  bool operator ==(Object other) => other is Etiqueta && codigo == other.codigo;

  @override
  int get hashCode => codigo.hashCode;
}

void main() {
  final original = Etiqueta(1, 'Original');
  final equivalente = Etiqueta(1, 'Nueva descripción');
  final fuente = ValueNotifier<Etiqueta>(original);
  var avisos = 0;
  void observar() => avisos = avisos + 1;

  fuente.addListener(observar);
  print('Mismo objeto: ${identical(original, equivalente)}');
  print('Iguales: ${original == equivalente}');
  fuente.value = equivalente;
  print('Descripción conservada: ${fuente.value.descripcion}');
  print('Conserva original: ${identical(fuente.value, original)}');
  print('Avisos: $avisos');

  fuente.removeListener(observar);
  fuente.dispose();
}
```

La salida es:

```text
Mismo objeto: false
Iguales: true
Descripción conservada: Original
Conserva original: true
Avisos: 0
```

El `==` de `Etiqueta` solo compara el código. Como ambos códigos son `1`, el setter retorna sin guardar `equivalente`. Por eso sigue la descripción `Original`. Si la descripción fuera relevante para quienes escuchan, esta regla de igualdad podría descartar una actualización que nos interesaba conservar. `hashCode` se declara de forma coherente con esa igualdad; sus reglas se estudian con detalle en la unidad 8.

### Practica 5

Si dos listas ordinarias diferentes tienen los mismos números, ¿`ValueNotifier` las trata como iguales por su contenido? ¿Y qué ocurre con `Etiqueta` si el código es igual aunque cambie la descripción?

<details>
<summary>Ver respuesta</summary>

En el ejemplo de listas, `==` considera distintas las dos listas, por lo que el setter guarda la nueva y avisa. En `Etiqueta`, el `==` definido por la clase considera iguales las dos instancias con el mismo código; el setter conserva la anterior y no avisa.

</details>

## 6. Elegir una política para listas

A veces queremos avisar solo cuando cambien los **elementos** de una lista, no cuando se cree otra lista con el mismo contenido. Podemos decidirlo antes de asignar al notificador. Este fragmento presupone una fuente de tipo `ValueNotifier<List<String>>` y la importación de `package:flutter/foundation.dart`:

```dart
void reemplazar(List<String> propuesta) {
  if (listEquals(fuente.value, propuesta)) return;
  fuente.value = List<String>.unmodifiable(propuesta);
}
```

Si las listas tienen los mismos textos en el mismo orden, `return` evita la asignación. Si son distintos, se crea una lista exterior no modificable y se asigna. Después, el setter de `ValueNotifier` sigue aplicando su propio `==`.

Esta es una política escrita por nosotros; `ValueNotifier` no compara automáticamente los elementos con `listEquals`. Una lista no modificable tampoco convierte en inmutables los objetos que pudiera contener, ni impide que alguien con acceso al notificador le asigne otro valor. En este ejemplo los elementos son `String`.

### Practica 6

La fuente contiene `['claro', 'oscuro']` y llamamos a `reemplazar` con otra lista que contiene esos mismos textos en el mismo orden. ¿Quién evita la asignación y por qué?

<details>
<summary>Ver respuesta</summary>

La condición de nuestra función la evita: `listEquals` devuelve `true` y `return` termina el método. El setter de `ValueNotifier` ni siquiera se llama en esa operación.

</details>

## 7. ¿Qué verá un widget?

En la unidad 6 vimos que `ValueListenableBuilder` escucha una fuente y construye un widget con su valor. Si mutamos una lista por dentro sin notificar, ¿puede la interfaz seguir mostrando una lectura anterior? Esta prueba permite observar un caso concreto.

La prueba es un archivo completo de **prueba de Flutter**, no un programa para DartPad. Puedes guardarla temporalmente como `test/value_notifier_practica_test.dart` y ejecutar desde la raíz:

```sh
flutter test --no-pub test/value_notifier_practica_test.dart
```

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Lista mutable y sustitución', (tester) async {
    final numeros = ValueNotifier<List<int>>(<int>[1]);
    var avisos = 0;
    void contarAviso() => avisos = avisos + 1;
    numeros.addListener(contarAviso);

    Widget pantalla() => Directionality(
      textDirection: TextDirection.ltr,
      child: ValueListenableBuilder<List<int>>(
        valueListenable: numeros,
        builder: (context, valor, child) => Text(valor.join(', ')),
      ),
    );

    await tester.pumpWidget(pantalla());
    expect(find.text('1'), findsOneWidget);

    numeros.value.add(2);
    expect(avisos, 0);
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    await tester.pumpWidget(pantalla());
    expect(find.text('1, 2'), findsOneWidget);
    expect(avisos, 0);

    numeros.value = <int>[...numeros.value, 3];
    expect(avisos, 1);
    await tester.pump();
    expect(find.text('1, 2, 3'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    numeros.removeListener(contarAviso);
    numeros.dispose();
  });
}
```

Después de `add`, la lista contiene `1, 2`, pero esa operación no notificó; en esta prueba, el primer `pump` sigue encontrando el texto anterior. Luego `pumpWidget(pantalla())` provoca una nueva construcción que vuelve a leer la lista y muestra `1, 2`, aunque el contador de avisos sigue en cero. Finalmente, sustituir la lista produce un aviso y el siguiente `pump` muestra `1, 2, 3`.

La prueba observa un árbol de widgets en ese escenario. No demuestra un repintado físico ni que cada aviso produzca una construcción independiente. Se desmonta el widget que escucha antes de liberar el notificador.

### Practica 7

¿Por qué aparece `1, 2` después de `pumpWidget` aunque no hubo aviso? ¿Qué operación de la prueba sí pasa por el setter?

<details>
<summary>Ver respuesta</summary>

La nueva construcción vuelve a leer la misma lista, cuyo contenido ya había cambiado con `add`. La asignación `numeros.value = <int>[...numeros.value, 3]` sí pasa por el setter y, en este caso, produce un aviso.

</details>

## 8. `ValueNotifier` y DaisyUI

El [controlador actual](../../../lib/themes/application/daisy_theme_controller.dart) no guarda el tema en un `ValueNotifier`, sino en una señal, `FlutterSignal`, que estudiaremos en la unidad 9. Este fragmento procede del archivo real:

```dart
final FlutterSignal<DaisyThemeModel> _palette;

late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(
  _palette,
);

ValueListenable<DaisyThemeModel> get theme => _theme;

void setTheme(DaisyThemeModel theme) => _palette.value = theme;
```

Lo aprendido en esta unidad sigue siendo útil: `FlutterSignal` cumple el contrato de `ValueNotifier` y, con sus opciones predeterminadas, compara mediante `==`. `setTheme` escribe en el setter de la señal, así que una propuesta igual se descarta sin avisar y una distinta sustituye el modelo y avisa. Lo que cambia es la implementación que hay debajo; no hereda el código de `ChangeNotifier`.

El getter público `theme` no devuelve la señal. Devuelve `_ThemeListenable`, un objeto de lectura separado que reenvía sus operaciones a `_palette`. En los ejemplos de esta unidad, limitar el tipo dejaba debajo el mismo notificador y un cast podía recuperar el setter. Aquí el objeto real no es un `ValueNotifier` y ese cast falla; la unidad 16 compara las dos estrategias. La clase permite al propietario liberar la señal mediante `controller.dispose()`. El [scope](../../../lib/themes/application/daisy_theme_scope.dart) utiliza la vista de lectura para conectar el tema con sus dependientes; estudiaremos ese recorrido más adelante.

La [prueba del controlador](../../../test/themes/daisy_theme_controller_test.dart) comprueba que una copia igual no avisa, que un tema distinto sí lo hace y que las retiradas funcionan.

### Practica 8

Si llamas a `controller.setTheme(nuevoTema)`, ¿qué setter se ejecuta? ¿`controller.theme` es otro objeto que almacena una copia del tema?

<details>
<summary>Ver respuesta</summary>

`setTheme` asigna a `_palette.value`, así que se ejecuta el setter de la señal, que aplica la comparación mediante `==`. `controller.theme` sí es otro objeto, un `_ThemeListenable`, pero no almacena una copia: su getter `value` lee `_palette` en cada consulta.

</details>

## Ejercicio final: favoritos observables

Escribe un programa Flutter de consola que:

1. Cree un `ValueNotifier<List<String>>` con una lista no modificable que contenga `'claro'`.
2. Declare `reemplazar(List<String> propuesta)`: si `listEquals` dice que el contenido es igual al actual, termina sin asignar; si es distinto, asigna una nueva `List<String>.unmodifiable(propuesta)`.
3. Registre un listener que imprima los favoritos actuales y cuente sus avisos.
4. Proponga `['claro']`, después `['claro', 'oscuro']` y finalmente otra lista con esos mismos dos textos.
5. Retire el listener, imprima la lista final y el número de avisos, y libere el notificador.

Predice la salida y explica qué comparación evita cada asignación. Como variación, cambia el orden de los dos textos en la última propuesta y comprueba si `listEquals` los considera iguales.

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/foundation.dart';

void main() {
  final favoritos = ValueNotifier<List<String>>(
    List<String>.unmodifiable(<String>['claro']),
  );
  var avisos = 0;

  void reemplazar(List<String> propuesta) {
    if (listEquals(favoritos.value, propuesta)) return;
    favoritos.value = List<String>.unmodifiable(propuesta);
  }

  void observar() {
    avisos = avisos + 1;
    print('Aviso $avisos: ${favoritos.value.join(', ')}');
  }

  favoritos.addListener(observar);
  reemplazar(<String>['claro']);
  reemplazar(<String>['claro', 'oscuro']);
  reemplazar(<String>['claro', 'oscuro']);
  favoritos.removeListener(observar);

  print('Final: ${favoritos.value.join(', ')}; avisos: $avisos');
  favoritos.dispose();
}
```

```text
Aviso 1: claro, oscuro
Final: claro, oscuro; avisos: 1
```

La primera y la tercera propuestas tienen los mismos elementos en el mismo orden que el valor vigente: nuestro `listEquals` evita esas asignaciones. La segunda es distinta, crea una lista nueva y la asigna; el setter la guarda y avisa. Si la última propuesta invierte el orden, `listEquals` la considera distinta y hay otro aviso.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué añade `ValueNotifier<T>` al contrato de lectura y escucha? **Apartado 1.**
2. ¿Qué ocurre en el setter cuando el valor anterior y el propuesto son iguales con `==`? **Apartado 2.**
3. ¿Por qué varias asignaciones pueden producir menos avisos recibidos? **Apartado 3.**
4. ¿Por qué `fuente.value.add(...)` modifica la lista sin notificar? ¿Qué ocurre al reasignar esa misma lista? **Apartado 4.**
5. ¿Por qué dos listas con los mismos elementos pueden producir un aviso al sustituir una por otra? **Apartado 5.**
6. ¿Puede descartarse un objeto distinto por resultar igual con `==`? ¿Qué objeto conserva el notificador? **Apartado 5.**
7. ¿Quién aplica la comparación por contenido con `listEquals` y cuáles son sus límites? **Apartado 6.**
8. ¿Qué demuestra la prueba de widget y qué ocurre en el controlador actual de DaisyUI? **Apartados 7 y 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques las respuestas con tus palabras. La siguiente unidad profundiza en identidad, igualdad e inmutabilidad.

## Para consultar si necesitas reforzar

- [`ValueNotifier<T>`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) y su [setter `value`](https://api.flutter.dev/flutter/foundation/ValueNotifier/value.html): comparación y notificación.
- [`listEquals`](https://api.flutter.dev/flutter/foundation/listEquals.html): comparación ordenada de elementos.
- [`List.unmodifiable`](https://api.dart.dev/dart-core/List/List.unmodifiable.html): lista exterior no modificable.
- [`ValueListenableBuilder<T>`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html): conexión de la fuente con un widget.
- [Igualdad de listas](https://api.dart.dev/dart-core/List/operator_equals.html) e [`identical`](https://api.dart.dev/dart-core/identical.html): igualdad e identidad de los objetos.

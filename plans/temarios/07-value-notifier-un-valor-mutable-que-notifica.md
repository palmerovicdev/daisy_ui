# 07. ValueNotifier: un valor mutable que notifica

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 6](06-value-listenable-avisos-y-valor-actual.md)

- **Bloque:** el sistema de notificaciones de Flutter.
- **Estado de estudio:** pendiente.
- **Investigación de fuentes:** 29 de octubre de 2026.

## Qué vas a conseguir

Podrás explicar qué guarda un `ValueNotifier<T>` y seguir su setter: compara el valor anterior y el propuesto mediante
`==`; si son iguales, retorna; si no lo son, guarda el nuevo valor y notifica. Sabrás predecir qué pasa al asignar un
número distinto, asignar el mismo número, modificar una lista por dentro y reemplazarla por otra.

También podrás distinguir la igualdad de la identidad lo suficiente para comprender esa decisión, incluyendo un caso
sutil: si dos objetos distintos resultan iguales, el setter **no reemplaza el objeto anterior**. La unidad 8
profundizará en identidad, igualdad, `hashCode` e inmutabilidad.

Esta unidad utiliza los contratos de la unidad 6, los avisos de las unidades 4 y 5 y las referencias de la unidad 3.
Nuestro controlador real de DaisyUI usa Signals, no `ValueNotifier`; lo compararemos sin asumir que sus políticas son
idénticas.

## Ruta y progreso

Antes de empezar, comprueba que puedes distinguir `ValueListenable<int>` como contrato de lectura y escucha de una
implementación concreta que permite escribir. Recuerda también que un listener no recibe el valor como argumento.

Los ejemplos **A–D** y la solución del proyecto son programas completos e independientes: abre
[DartPad](https://dartpad.dev/), selecciona un ejemplo de **Flutter**, copia un programa por vez y observa la consola.
El ejemplo **E** es una prueba de widgets para ejecutar en el repositorio. Los bloques restantes son fragmentos para
leer. DartPad admite `package:flutter` en modo Flutter, como explica su
[documentación](https://dart.dev/tools/dartpad); no necesita el paquete local `daisy_ui` para A–D.

- [ ] [7.1. Del contrato a una implementación mutable](#71-del-contrato-a-una-implementación-mutable).
- [ ] [7.2. Seguir la comparación del setter](#72-seguir-la-comparación-del-setter).
- [ ] [7.3. Contar asignaciones, cambios y avisos](#73-contar-asignaciones-cambios-y-avisos).
- [ ] [7.4. Modificar una lista por dentro](#74-modificar-una-lista-por-dentro).
- [ ] [7.5. Sustituir una lista por otra](#75-sustituir-una-lista-por-otra).
- [ ] [7.6. Comparar objetos iguales pero distintos](#76-comparar-objetos-iguales-pero-distintos).
- [ ] [7.7. Conectar los avisos con un widget](#77-conectar-los-avisos-con-un-widget).
- [ ] [7.8. Aplicar una política de contenido](#78-aplicar-una-política-de-contenido).
- [ ] [7.9. Comparar con DaisyUI y limpiar recursos](#79-comparar-con-daisyui-y-limpiar-recursos).
- [ ] [Completar el proyecto de la unidad](#proyecto-de-la-unidad-una-lista-de-favoritos-observable).
- [ ] [Superar la comprobación final](#comprobación-final).

Puedes dedicar una sesión a 7.1–7.3, otra a 7.4–7.6 y una tercera a 7.7–7.9 y el proyecto. Marca las casillas cuando
puedas explicar y resolver las variaciones sin copiar las respuestas.

## 7.1. Del contrato a una implementación mutable

### El problema

En la unidad 6 un consumidor recibió `ValueListenable<int>`: podía leer `.value` y escuchar, pero el tipo no ofrecía un
setter. ¿Qué clase de Flutter puede almacenar un valor y permitir que su propietario lo sustituya?

### La idea

[`ValueNotifier<T>`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) es un `ChangeNotifier` que
almacena un valor de tipo `T` e implementa `ValueListenable<T>`. Aporta:

1. Un valor inicial al construirlo: `ValueNotifier<int>(0)`.
2. Un getter para consultarlo: `notificador.value`.
3. Un setter para proponer un valor: `notificador.value = 1`.
4. El mecanismo heredado para registrar, retirar y notificar listeners, y para liberar el notificador.

El setter tiene una política concreta de comparación y notificación. No viene del contrato `ValueListenable` por sí
solo, ni significa que `ChangeNotifier` observe automáticamente todos los campos de cualquier subclase.

Imagina una caja con una etiqueta y un timbre. Puedes leer la etiqueta y proponer otra; el encargado compara ambas
con una regla concreta. Si la regla dice que son iguales, conserva la etiqueta anterior y no toca el timbre. Si no,
cambia la etiqueta y avisa. La analogía no significa que el encargado inspeccione el interior de cualquier objeto
al que la etiqueta haga referencia.

`ValueNotifier` suele funcionar bien con valores inmutables, como señala su documentación. Para objetos mutables que
se modifican por dentro, hay que diseñar la política de actualización y los límites de acceso.

### Comprobación

- ¿Qué agrega `ValueNotifier<int>` al contrato `ValueListenable<int>`?
- ¿Cuál es la diferencia entre `notificador.value` y `notificador.value = 1`?
- ¿Por qué no debes atribuir la política del setter a cualquier `ValueListenable`?

**Puedes avanzar cuando:** identificas objeto, valor almacenado, setter y oyentes como piezas diferentes.

## 7.2. Seguir la comparación del setter

### La implementación de Flutter

Este fragmento reproduce la lógica del setter de Flutter; `_value` es el campo interno y `newValue` el argumento de
la asignación. Consulta el [setter oficial](https://api.flutter.dev/flutter/foundation/ValueNotifier/value.html) y la
implementación local del SDK si quieres seguir el código completo:

```dart
set value(T newValue) {
  if (_value == newValue) {
    return;
  }
  _value = newValue;
  notifyListeners();
}
```

Lee las líneas en orden:

1. El setter compara **el valor almacenado** con el valor propuesto mediante `==`.
2. Si el resultado es `true`, `return` termina el setter. No llega a la asignación ni a `notifyListeners()`.
3. Si es `false`, `_value = newValue` sustituye lo almacenado.
4. A continuación, `notifyListeners()` ejecuta los listeners registrados según las reglas heredadas de
   `ChangeNotifier`. Cuando el callback consulta `.value`, encuentra el valor guardado en el paso anterior, salvo que
   otro código haya vuelto a cambiarlo durante una ejecución reentrante.

La comparación usa `==`, no una comparación profunda universal ni una búsqueda de cambios en todos los campos. En
Dart, para valores no nulos, el operador se resuelve sobre el operando izquierdo: aquí es el valor anterior. La
[referencia de operadores](https://dart.dev/language/operators#equality-and-relational-operators) explica los casos
con `null` y los operadores.

**Detalle importante:** si propones un objeto diferente cuya igualdad devuelve `true`, no solo falta el aviso: el
valor anterior permanece almacenado. Lo veremos con datos y referencias en 7.6.

### Comprobación

- ¿Qué líneas se ejecutan cuando `_value == newValue` es `true`? ¿Se reemplaza el objeto almacenado?
- Cuando la comparación da `false`, ¿qué sucede primero: guardar el valor o avisar?
- ¿El setter usa `identical` o `==` para decidir?

**Puedes avanzar cuando:** puedes narrar las dos ramas sin omitir el retorno temprano.

## 7.3. Contar asignaciones, cambios y avisos

### Ejemplo A: números iguales y distintos

Programa completo. Predice las seis líneas, las cuatro asignaciones y el número de avisos antes de ejecutarlo.

```dart
import 'package:flutter/foundation.dart';

void main() {
  final contador = ValueNotifier<int>(0);
  var avisos = 0;
  void observar() {
    avisos += 1;
    print('Aviso $avisos: ${contador.value}');
  }

  contador.addListener(observar);
  print('Inicial: ${contador.value}');
  contador.value = 1;
  contador.value = 1;
  print('Tras repetir: ${contador.value}');
  contador.value = 2;
  contador.removeListener(observar);
  contador.value = 3;
  print('Final: ${contador.value}');
  print('Avisos recibidos: $avisos');
  contador.dispose();
}
```

### Recorrido paso a paso

- La construcción almacena cero; registrar `observar` no lo ejecuta.
- `0 == 1` es `false`: se almacena uno y el callback lee uno durante el aviso.
- `1 == 1` es `true`: el setter retorna; no reemplaza ni avisa. La lectura sigue mostrando uno.
- `1 == 2` es `false`: se almacena dos y el listener recibe el segundo aviso.
- Se retira el listener. `2 == 3` es `false`, por lo que el setter almacena tres y llama al mecanismo de aviso;
  ese callback ya no está registrado y no se ejecuta.
- El propietario libera el notificador al terminar.

Hay cuatro llamadas al setter, tres asignaciones que pasan la comparación, tres llamadas a `notifyListeners` y dos
**ejecuciones de este listener**. En este ejemplo los callbacks se ejecutan durante el setter por el mecanismo de
`ChangeNotifier`; una reconstrucción de widgets es otra fase y requiere un consumidor.

### Comprobación

- Elimina `removeListener` hasta después de asignar tres. ¿Cuántos avisos recibe `observar`?
- Cambia la segunda asignación a `contador.value = 0`. ¿Qué valores lee el listener antes de la retirada?
- ¿Por qué no puedes contar avisos recibidos simplemente contando escrituras en el código?

**Puedes avanzar cuando:** puedes justificar cada rama de la comparación y contar emisiones y ejecuciones por separado.

## 7.4. Modificar una lista por dentro

### El problema

Un `ValueNotifier<List<String>>` contiene una lista. ¿Es lo mismo llamar a `notificador.value.add('oscuro')` que
asignar otra lista a `notificador.value`?

### Ejemplo B: una mutación que no pasa por el setter

Programa completo. Predice las seis líneas y dibuja las referencias a la lista antes y después de `add`.

```dart
import 'package:flutter/foundation.dart';

void main() {
  final temas = ValueNotifier<List<String>>(<String>['claro']);
  final guardada = temas.value;
  var avisos = 0;
  void observar() {
    avisos += 1;
    print('Aviso $avisos: ${temas.value.join(', ')}');
  }

  temas.addListener(observar);
  print('Inicial: ${temas.value.join(', ')}');
  temas.value.add('oscuro');
  print('Después de add: ${temas.value.join(', ')}');
  print('Referencia guardada: ${guardada.join(', ')}');
  temas.value = temas.value;
  print('Avisos tras reasignar: $avisos');
  temas.value = <String>[...temas.value, 'cupcake'];
  print('Final: ${temas.value.join(', ')}');
  temas.removeListener(observar);
  temas.dispose();
}
```

### Qué sucede

`temas.value.add('oscuro')` hace dos operaciones: el getter entrega la lista y `add` modifica **esa lista**. No hay
una asignación a `temas.value`, así que no se ejecuta el setter y no se emite aviso por esa operación. La lectura
posterior ve `oscuro` porque consulta la lista ya modificada. `guardada` referencia esa misma lista: tampoco es una
fotografía de sus contenidos anteriores.

`temas.value = temas.value` sí llama al setter, pero propone la misma lista que ya está almacenada. Para esta lista
ordinaria, `==` considera igual el objeto a sí mismo; el setter retorna. Esa reasignación no recupera el estado previo
ni fuerza un aviso por la mutación que ya ocurrió.

La última asignación crea una lista nueva con los elementos actuales y otro elemento. El operador `...` copia las
referencias a los elementos al construir la lista exterior; no hace una copia profunda. La lista nueva de este ejemplo
no es igual a la anterior con el `==` predeterminado de listas, por lo que se sustituye y avisa.

La documentación de [`ValueNotifier`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) menciona
expresamente esta limitación con listas mutables. Si guardas objetos mutables dentro de la lista nueva, esos elementos
pueden seguir compartidos: estudiaremos copias e inmutabilidad en la unidad 8.

### Comprobación

- ¿Qué método se ejecuta en `temas.value.add(...)` y cuál **no** se ejecuta?
- ¿Por qué una lectura directa puede ver `oscuro` aunque el listener no haya recibido aviso?
- ¿Qué ocurre si reasignas la misma lista después de mutarla?
- Después de la sustitución, ¿`guardada` pasa a ser la nueva lista? ¿Qué contiene la anterior?

**Puedes avanzar cuando:** distingues modificar el objeto devuelto de invocar el setter del notificador.

## 7.5. Sustituir una lista por otra

### Ejemplo C: identidad, contenido e igualdad de listas ordinarias

Programa completo. Cada literal de lista en este ejemplo es una lista no constante recién creada. Predice las siete
líneas y cuántas veces se ejecuta el callback.

```dart
import 'package:flutter/foundation.dart';

void main() {
  final primera = <int>[1, 2];
  final copia = <int>[1, 2];
  final numeros = ValueNotifier<List<int>>(primera);
  var avisos = 0;
  void observar() {
    avisos += 1;
    print('Aviso $avisos: ${numeros.value.join(', ')}');
  }

  numeros.addListener(observar);
  print('Mismo objeto: ${identical(primera, copia)}');
  print('Iguales con ==: ${primera == copia}');
  print('Elementos iguales: ${listEquals(primera, copia)}');
  numeros.value = copia;
  print('Guardó la copia: ${identical(numeros.value, copia)}');
  numeros.value = copia;
  numeros.value = <int>[1, 2, 3];
  print('Avisos totales: $avisos');
  numeros.removeListener(observar);
  numeros.dispose();
}
```

Las listas ordinarias de Dart comparan por identidad de forma predeterminada, no por sus elementos. Por eso
`primera == copia` es `false` aunque ambas contengan `1, 2`. El setter sustituye la primera por `copia` y notifica.
Volver a asignar `copia` propone la misma lista y no notifica. Asignar una lista nueva con tres elementos vuelve a
sustituir y notificar. La [API de igualdad de listas](https://api.dart.dev/dart-core/List/operator_equals.html)
describe esa regla predeterminada; clases de lista especializadas podrían definir otra igualdad.

[`identical`](https://api.dart.dev/dart-core/identical.html) pregunta si las referencias son al mismo objeto;
`listEquals` compara los elementos en orden usando su `==`. `listEquals` no hace una comparación profunda general de
colecciones anidadas. El setter de `ValueNotifier` **no llama a `listEquals`**: solo ejecuta el `==` de su valor
almacenado. La comparación por contenido del ejemplo es una consulta separada para estudiar la diferencia.

### Comprobación

- ¿Por qué crear una copia con los mismos elementos puede producir un aviso?
- ¿Qué ocurre si escribes `numeros.value = numeros.value` después de la primera sustitución?
- ¿Por qué `listEquals(primera, copia)` no cambia la política del setter?
- ¿Podemos deducir las reglas de igualdad de cualquier clase solo por la regla predeterminada de estas listas?

**Puedes avanzar cuando:** diferencias «misma referencia», «igualdad `==`» y «elementos iguales» en este ejemplo.

## 7.6. Comparar objetos iguales pero distintos

### El problema

Un modelo define igualdad por código. Si creamos otro modelo con el mismo código pero otra descripción, ¿qué queda
en el notificador después de asignarlo?

### Ejemplo D: el retorno conserva el objeto anterior

Programa completo. Es deliberadamente pequeño para aislar la igualdad: el campo `descripcion` no participa en `==`.
Predice las ocho líneas y señala en qué momento se sustituye el valor.

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
  final distinta = Etiqueta(2, 'Otra');
  final fuente = ValueNotifier<Etiqueta>(original);
  var avisos = 0;
  void observar() {
    avisos += 1;
    print('Aviso $avisos: ${fuente.value.descripcion}');
  }

  fuente.addListener(observar);
  print('Mismo objeto: ${identical(original, equivalente)}');
  print('Iguales: ${original == equivalente}');
  fuente.value = equivalente;
  print('Tras igual: ${fuente.value.descripcion}');
  print('Conserva original: ${identical(fuente.value, original)}');
  print('Avisos tras igual: $avisos');
  fuente.value = distinta;
  print('Tras distinto: ${fuente.value.descripcion}');
  print('Avisos finales: $avisos');
  fuente.removeListener(observar);
  fuente.dispose();
}
```

`original` y `equivalente` son objetos diferentes. Su `==` devuelve `true` porque ambos tienen código uno. El setter
retorna **antes** de guardar `equivalente`, así que `.value.descripcion` sigue siendo `Original`. No existe una
notificación para esa asignación. Con `distinta`, el código dos no es igual al uno: el setter guarda ese objeto y
notifica; el listener lee `Otra`.

La igualdad por código es una decisión de este ejemplo, no una recomendación universal: si `descripcion` es relevante
para los consumidores, ignorarla puede hacer que una actualización deseada sea descartada. La clase declara también
un `hashCode` coherente; Dart recomienda mantener esa coherencia al redefinir `==`. En la unidad 8 desarrollaremos
las reglas de igualdad, sus implicaciones y los modelos inmutables.

### Comprobación

- ¿Cuáles de `identical(original, equivalente)` y `original == equivalente` son `true`?
- Después de asignar `equivalente`, ¿qué descripción se lee y cuál es el objeto conservado?
- Si la igualdad también incluyera `descripcion`, ¿qué cambiaría en esa asignación?
- ¿Por qué no basta con preguntar si se llamó al setter para saber si se almacenó el argumento?

**Puedes avanzar cuando:** explicas por qué un valor distinto en identidad puede ser descartado por igualdad.

## 7.7. Conectar los avisos con un widget

### El problema

Si una lista cambia por dentro sin pasar por el setter, ¿qué ocurre con un texto construido antes? ¿Y puede volver a
mostrarse el dato modificado si el widget se reconstruye por otra causa?

### Ejemplo E: mutación silenciosa, reconstrucción y sustitución

Prueba completa. Copia el código a `test/value_notifier_practica_test.dart` y ejecuta desde la raíz:

```sh
flutter test --no-pub test/value_notifier_practica_test.dart
```

Predice qué texto encuentra cada expectativa y cuántos avisos llegan a `contarAviso`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Lista mutable y sustitución con ValueNotifier', (tester) async {
    final numeros = ValueNotifier<List<int>>(<int>[1]);
    var avisos = 0;
    void contarAviso() => avisos += 1;
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

Después de `add`, el `pump` por sí solo no tiene una actualización solicitada por esa mutación y el texto anterior
sigue en el árbol de esta prueba. `pumpWidget(pantalla())` vuelve a construir con una nueva configuración: el builder
consulta la misma lista mutable, ahora con dos elementos. Eso muestra que **la falta de aviso no congela el dato** y
que una reconstrucción causada por otra cosa puede revelar el cambio. Finalmente la sustitución con una lista nueva
produce un aviso; tras el siguiente frame se muestra el tercer elemento.

Esto es una prueba concreta de widgets y frames de prueba. No demuestra un repintado físico ni establece que todo
`pump` o toda reconstrucción se comporte igual en cualquier árbol. Para estudiar el widget, consulta
[`ValueListenableBuilder`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) y la
[introducción a pruebas de widgets](https://docs.flutter.dev/cookbook/testing/widget/introduction).

### Comprobación

- ¿Por qué el primer `pump` no muestra el elemento añadido en esta prueba?
- ¿Qué acción provoca que luego aparezca sin haber recibido un aviso?
- ¿Qué operación sí atraviesa el setter y por qué avisa en este caso?

**Puedes avanzar cuando:** separas cambio interno, aviso, construcción del árbol y pintura.

## 7.8. Aplicar una política de contenido

Si la intención es avisar solo cuando cambia el **contenido** de una lista de valores simples, una opción es comparar
antes de asignar y conservar listas no modificables. Este fragmento necesita un `ValueNotifier<List<String>> fuente`
ya creado; es un ejemplo de política, no un cambio al comportamiento interno de `ValueNotifier`:

```dart
void reemplazar(List<String> propuesta) {
  if (listEquals(fuente.value, propuesta)) return;
  fuente.value = List<String>.unmodifiable(propuesta);
}
```

`listEquals` compara longitud y elementos en orden usando el `==` de cada elemento. No compara profundamente por sí
mismo colecciones anidadas. Si el contenido es igual, el `return` evita crear y asignar otra lista; si es distinto,
creamos una lista exterior que no permite cambiar longitud ni elementos y la asignamos. La propia fuente sigue siendo
un `ValueNotifier`: su setter aplica después su `==` habitual.

[`List.unmodifiable`](https://api.dart.dev/dart-core/List/List.unmodifiable.html) no convierte en inmutables los
objetos que estén dentro; con `String` el contenido de este ejemplo es inmutable. Tampoco impide que alguien con
acceso al `ValueNotifier` escriba otro valor. Para proteger la API en producción, hay que controlar quién posee la
referencia mutable y qué objetos se entregan. El proyecto de esta unidad practica una política acotada.

### Comprobación

- Si la propuesta tiene los mismos textos en el mismo orden, ¿quién evita la asignación: `listEquals` o el setter?
- ¿Qué diferencia hay entre una lista exterior no modificable y una copia profunda de sus elementos?
- ¿Por qué no es correcto decir que `ValueNotifier` usa `listEquals` automáticamente?

**Puedes avanzar cuando:** sabes dónde está escrita la política adicional y cuáles son sus límites.

## 7.9. Comparar con DaisyUI y limpiar recursos

En [daisy_theme_controller.dart](../../lib/themes/application/daisy_theme_controller.dart),
`DaisyThemeController` crea `_palette` con `signal<DaisyThemeModel>(initialTheme)`. `setTheme` escribe
`_palette.value = theme`; `theme` expone un adaptador `ValueListenable<DaisyThemeModel>` cuyo getter y operaciones de
escucha se reenvían a la señal. **La señal no es el `ValueNotifier` del ejemplo**, y el controlador no hereda de
`ChangeNotifier`.

En [daisy_theme_controller_test.dart](../../test/themes/daisy_theme_controller_test.dart), la prueba
`Theme views notify on changes and support listener removal` comprueba que una copia equivalente de `light` no produce
un aviso y que el cambio a `dark` sí produce uno, para la vista global y un controlador local. Esa prueba demuestra
esos casos concretos; no demuestra por sí sola que Signals y `ValueNotifier` implementen el mismo setter o todos los
mismos casos límite. Las unidades 8 y 9 investigarán las reglas de igualdad del modelo y la señal.

El [scope](../../lib/themes/application/daisy_theme_scope.dart) entrega la vista a `InheritedNotifier`; el controlador
explícito es prestado por el scope y lo libera su propietario. En A–E y el proyecto, el código que crea cada
`ValueNotifier` es el propietario: retira sus listeners y llama a `dispose()` cuando termina. En E primero se desmonta
el
widget consumidor. El [`dispose` heredado](https://api.flutter.dev/flutter/foundation/ChangeNotifier/dispose.html)
no emite un último aviso y deja el objeto sin estado utilizable.

### Comprobación

- ¿Qué implementación escribe `setTheme` y qué tipo expone el getter `theme`?
- ¿Qué resultados concretos demuestra la prueba de DaisyUI y qué no demuestra sobre `ValueNotifier`?
- ¿Por qué un widget que recibe el notificador prestado no debería disponerlo por su cuenta?

**Puedes avanzar cuando:** puedes comparar los recorridos sin atribuir al proyecto una implementación que no usa.

## Materiales de estudio seleccionados

Todos los recursos se pueden consultar gratis. Las referencias oficiales están en inglés; los ejercicios y las
explicaciones de esta guía están en español.

- **F1 · Flutter: [ValueNotifier](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) y
  [setter `value`](https://api.flutter.dev/flutter/foundation/ValueNotifier/value.html)** — 7.1–7.4. Sigue la
  comparación, el retorno, la asignación y el aviso; lee la advertencia sobre valores mutables.
- **F2 · Flutter: [ValueListenable](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html) y
  [ChangeNotifier](https://api.flutter.dev/flutter/foundation/ChangeNotifier-class.html)** — 7.1 y 7.9. Distingue
  contrato, implementación y mecanismo heredado.
- **D1 · Dart: [operador `==` de List](https://api.dart.dev/dart-core/List/operator_equals.html),
  [identical](https://api.dart.dev/dart-core/identical.html) y
  [operadores de igualdad](https://dart.dev/language/operators#equality-and-relational-operators)** — 7.5–7.6.
  Contrasta la identidad de dos listas recién creadas con la igualdad definida por una clase.
- **F3 · Flutter: [listEquals](https://api.flutter.dev/flutter/foundation/listEquals.html)** — 7.5 y 7.8. Examina
  cómo compara elementos y cuál es el límite con colecciones anidadas.
- **D2 · Dart: [List.unmodifiable](https://api.dart.dev/dart-core/List/List.unmodifiable.html)** — 7.8 y proyecto.
  Distingue una lista no modificable de la inmutabilidad de sus elementos.
- **D3 · Dart: [igualdad y `hashCode`](https://dart.dev/effective-dart/design#equality)** — 7.6. Identifica por qué
  la clase del ejemplo declara ambos; la unidad 8 profundizará en sus reglas.
- **F4 · Flutter: [ValueListenableBuilder](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) e
  [introducción a pruebas de widgets](https://docs.flutter.dev/cookbook/testing/widget/introduction)** — 7.7. Localiza
  el listener del widget y distingue `pumpWidget` de `pump`.
- **P1 · [DartPad](https://dartpad.dev/) y su [documentación](https://dart.dev/tools/dartpad)** — A–D y proyecto en
  modo Flutter. El ejemplo E utiliza el repositorio local.
- **P2 · DaisyUI:** [controlador](../../lib/themes/application/daisy_theme_controller.dart),
  [scope](../../lib/themes/application/daisy_theme_scope.dart) y
  [pruebas del controlador](../../test/themes/daisy_theme_controller_test.dart) — 7.9.

## Proyecto de la unidad: una lista de favoritos observable

Construye una clase `Favoritos` que posea un `ValueNotifier<List<String>>`. Su valor inicial es una lista vacía no
modificable; los consumidores consultan y escuchan una referencia declarada como `ValueListenable<List<String>>`.
El propietario conserva la capacidad de reemplazar el valor mediante métodos de la clase.

### Requisitos

1. Implementa `agregar(nombre)` y `quitar(nombre)`. Trabaja con una lista nueva y usa `listEquals` para evitar asignar
   si el contenido propuesto es igual al actual.
2. Al aceptar un cambio, asigna una `List<String>.unmodifiable(...)`; las cadenas son inmutables. No modifiques la
   lista almacenada mediante `add` o `remove`.
3. Registra un listener que imprima los favoritos en cada aviso. Agrega `claro`, agrega `oscuro`, intenta agregar
   `claro` de nuevo, intenta quitar `forest` y quita `claro`.
4. Conserva una lectura inicial, imprime la lista inicial y la lista actual al terminar, retira el listener y libera
   el recurso desde su propietario.
5. Antes de ejecutar, anota la lista anterior, la propuesta, si se asigna y el número de avisos en cada operación.

La referencia `ValueListenable` de este proyecto restringe el tipo disponible, pero el objeto real sigue siendo el
`ValueNotifier` privado: no constituye una barrera completa frente a un cast. Una API de producción que necesite
ocultar la capacidad de escritura puede exponer un adaptador separado, como hace DaisyUI. La lista exterior no
modificable tampoco sería una copia profunda si contuviera objetos mutables.

### Variaciones

- Quita la comprobación `listEquals` de la función de reemplazo. Si se asigna una nueva lista con los mismos elementos,
  ¿qué comparación hace `ValueNotifier` y cuántos avisos extra produce el flujo? Ten en cuenta si `agregar` y `quitar`
  siguen creando siempre una propuesta.
- ¿Qué ocurre si el consumidor intenta `fuente.value.add('forest')` sobre la lista no modificable?
- ¿Qué pasaría si expones una lista mutable y alguien la modifica sin pasar por los métodos de `Favoritos`?
- ¿Qué cambiaría si el orden importara de otra manera para el producto? Identifica qué parte de la política habría
  que diseñar antes de decidir cuándo notificar.

Una solución completa aparece al final. Escribe primero tus predicciones y separa la comparación de contenido propia
que escribiste de la comparación `==` que efectúa el setter de Flutter.

## Errores de comprensión que vamos a comprobar

- Pensar que toda asignación a `.value` genera un aviso, incluso cuando `==` devuelve `true`.
- Pensar que un valor igual siempre se almacena aunque no haya aviso.
- Creer que `ValueNotifier` detecta la mutación interna de una lista sin ejecutar el setter.
- Confundir guardar una referencia a una lista con tomar una fotografía inmutable de sus elementos.
- Suponer que dos listas ordinarias se comparan por contenido mediante `==`.
- Suponer que `listEquals` se ejecuta dentro del setter de Flutter o que compara profundamente cualquier estructura.
- Creer que una lista exterior no modificable hace inmutables los objetos que contiene.
- Contar avisos, construcciones y repintados como si fueran el mismo evento.
- Atribuir la implementación de `ValueNotifier` a la señal de DaisyUI o liberar un recurso prestado.

## Comprobación final

Responde sin mirar las soluciones y justifica cada respuesta con la línea o fuente pertinente:

1. ¿Qué relación tienen `ValueNotifier<T>`, `ChangeNotifier` y `ValueListenable<T>`?
2. Describe las dos ramas del setter y explica qué ocurre antes de cada aviso.
3. En A, ¿cuántas llamadas al setter, avisos emitidos y ejecuciones del listener hay?
4. En B, ¿por qué `add` cambia el dato sin invocar el setter? ¿Qué pasa al reasignar la misma lista?
5. ¿Por qué `guardada` ve la mutación de B y qué conserva después de asignar otra lista?
6. En C, ¿por qué dos listas con los mismos elementos pueden provocar una sustitución y un aviso?
7. ¿Qué diferencia hay entre `identical`, `==` y `listEquals` en los ejemplos?
8. En D, ¿por qué se conserva `original` al asignar `equivalente`?
9. ¿Por qué en E puede aparecer el cambio silencioso tras otra reconstrucción?
10. ¿Qué protege `List.unmodifiable` y qué no garantiza acerca de elementos mutables?
11. ¿Qué prueba concreta de igualdad y avisos existe en DaisyUI y por qué no describe toda la política de Signals?
12. Explica el proyecto desde la propuesta de lista hasta la lectura del listener y la limpieza del propietario.

**Unidad dominada cuando:** resuelves los ejercicios, explicas el proyecto y predices las ramas del setter sin copiar
las soluciones. La elaboración de la guía no marca el estudio como completado.

## Soluciones para contrastar después de practicar

### Ejemplo A

```text
Inicial: 0
Aviso 1: 1
Tras repetir: 1
Aviso 2: 2
Final: 3
Avisos recibidos: 2
```

Hay cuatro llamadas al setter y tres llamadas a `notifyListeners`: para uno, dos y tres. El listener solo recibe las
dos primeras porque se retira antes de asignar tres. Si se retira después, recibe tres avisos.

### Ejemplo B

```text
Inicial: claro
Después de add: claro, oscuro
Referencia guardada: claro, oscuro
Avisos tras reasignar: 0
Aviso 1: claro, oscuro, cupcake
Final: claro, oscuro, cupcake
```

`guardada` sigue apuntando a la lista anterior, que contiene `claro, oscuro`; la última asignación almacena otra lista.
El aviso ocurre solo por la sustitución final, no por `add` ni por reasignar la misma lista.

### Ejemplo C

```text
Mismo objeto: false
Iguales con ==: false
Elementos iguales: true
Aviso 1: 1, 2
Guardó la copia: true
Aviso 2: 1, 2, 3
Avisos totales: 2
```

La primera lista nueva tiene los mismos elementos pero `==` devuelve `false` para esas listas ordinarias. Reasignar
`copia` propone la lista que ya estaba almacenada y no vuelve a avisar.

### Ejemplo D

```text
Mismo objeto: false
Iguales: true
Tras igual: Original
Conserva original: true
Avisos tras igual: 0
Aviso 1: Otra
Tras distinto: Otra
Avisos finales: 1
```

La igualdad por código hace que el setter retorne sin almacenar la nueva descripción. Si la igualdad también compara
la descripción, la propuesta dejaría de ser igual en este ejemplo y la sustitución produciría un aviso.

### Ejemplo E

Se observa `1` al inicio y después del primer `pump`; hay cero avisos. La siguiente llamada a `pumpWidget` muestra
`1, 2` sin aviso. Sustituir la lista produce un aviso y, tras `pump`, se encuentra `1, 2, 3`.

### Una solución del proyecto

```dart
import 'package:flutter/foundation.dart';

class Favoritos {
  final ValueNotifier<List<String>> _fuente =
      ValueNotifier<List<String>>(List<String>.unmodifiable(<String>[]));

  ValueListenable<List<String>> get fuente => _fuente;

  void _reemplazar(List<String> propuesta) {
    if (listEquals(_fuente.value, propuesta)) return;
    _fuente.value = List<String>.unmodifiable(propuesta);
  }

  void agregar(String nombre) {
    final propuesta = <String>[..._fuente.value];
    if (!propuesta.contains(nombre)) propuesta.add(nombre);
    _reemplazar(propuesta);
  }

  void quitar(String nombre) {
    final propuesta = <String>[..._fuente.value];
    propuesta.remove(nombre);
    _reemplazar(propuesta);
  }

  void dispose() => _fuente.dispose();
}

void main() {
  final favoritos = Favoritos();
  final fuente = favoritos.fuente;
  final inicial = fuente.value;
  void observar() => print('Aviso: ${fuente.value.join(', ')}');

  fuente.addListener(observar);
  favoritos.agregar('claro');
  favoritos.agregar('oscuro');
  favoritos.agregar('claro');
  favoritos.quitar('forest');
  favoritos.quitar('claro');
  print('Inicial: [${inicial.join(', ')}]');
  print('Actual: [${fuente.value.join(', ')}]');
  fuente.removeListener(observar);
  favoritos.dispose();
}
```

La salida es:

```text
Aviso: claro
Aviso: claro, oscuro
Aviso: oscuro
Inicial: []
Actual: [oscuro]
```

Las dos primeras operaciones y la última tienen propuestas distintas y generan tres avisos. La tercera y la cuarta
proponen el mismo contenido, por lo que `listEquals` evita la asignación. `inicial` sigue apuntando a la lista vacía
original, que no se modifica.

Si se elimina solo el `if (listEquals(...)) return`, ambos métodos siguen creando propuestas en todas las llamadas.
Las cinco propuestas se convierten en listas nuevas y ordinariamente distintas según `==`, de modo que habrá cinco
avisos: dos adicionales con el mismo contenido. Intentar añadir directamente a la lista no modificable lanza una
`UnsupportedError`.

### Claves de la comprobación final

1. `ValueNotifier` hereda de `ChangeNotifier` e implementa `ValueListenable<T>`; además ofrece un setter.
2. Si los valores son iguales retorna sin sustituir ni avisar; si no, guarda el nuevo y llama a `notifyListeners`.
3. Cuatro llamadas al setter, tres emisiones y dos ejecuciones del listener registrado.
4. `add` opera sobre la lista devuelta; reasignar esa misma lista llama al setter pero compara igual.
5. Es la misma lista mutable; después de sustituir, conserva la lista anterior y sus contenidos ya mutados.
6. El `==` predeterminado de esas listas no compara elementos y las dos instancias son distintas.
7. `identical` compara identidad; `==` aplica la igualdad del valor; `listEquals` compara elementos en orden por `==`.
8. Su igualdad por código devuelve `true` y el setter retorna antes de asignar.
9. Otra construcción puede consultar la lista compartida, aunque la mutación no haya emitido un aviso.
10. Impide cambiar la lista exterior; no hace inmutables ni copia profundamente sus elementos.
11. La prueba comprueba una copia equivalente de `light`, un cambio a `dark` y la retirada; no compara todos los
    detalles de implementación de Signals con los de `ValueNotifier`.
12. La clase crea la propuesta, compara contenido, asigna una lista no modificable si cambia y el setter notifica;
    el callback lee la fuente, se retira y el propietario libera el notificador.

## Qué se ha revisado y cómo se ha comprobado

- Se contrastaron el setter, la igualdad de listas y los demás materiales enlazados con las referencias oficiales.
  También se leyó el setter del SDK local y los archivos actuales del controlador, el scope y sus pruebas.
- El servidor del grafo rechazó indexar esta raíz durante las unidades anteriores por su configuración de acceso;
  las afirmaciones sobre los archivos citados de DaisyUI se contrastaron mediante lectura directa.
- Se extrajeron A–D y la solución del proyecto y se verificaron sus cinco salidas. También pasaron el ejemplo E,
  tres pruebas adicionales de igualdad y de las variaciones del proyecto, y las tres pruebas existentes del
  controlador: **12 pruebas en total**. El analizador no encontró errores en los ejemplos completos; informó de
  avisos de estilo por `print` en las prácticas de consola.
- Se comprobaron enlaces locales, anclas, bloques de código y espacios, además de `git diff --check`.
- La prueba de widgets verifica el árbol y los frames de prueba, no una pantalla física ni sus repintados. Los
  ejemplos no se ejecutaron en DartPad. El progreso se marca al resolver y explicar las prácticas.

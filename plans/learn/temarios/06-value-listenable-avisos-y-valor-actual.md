# 06. `ValueListenable`: avisos y valor actual

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 5](05-change-notifier-producir-avisos.md) · **Estado:** pendiente

## Qué vas a aprender

En la unidad 4 aprendimos a recibir avisos mediante `Listenable`. En la 5 creamos un contador que notificaba y cuyo
listener consultaba la cantidad. Ahora vamos a reunir esas dos necesidades en un contrato: **escuchar y poder leer un
valor actual**.

Al terminar podrás explicar qué ofrece `ValueListenable<T>`, qué lee un listener cuando recibe un aviso y por qué una
lectura guardada no se actualiza sola. También veremos un widget que escucha una fuente y la vista de tema de DaisyUI.

Los programas de consola completos usan Flutter. Puedes copiar cada uno en [DartPad](https://dartpad.dev/), elegir
**Flutter** y pulsar **Run**; observa la consola. Antes de ejecutar, intenta predecir la salida. Puedes hacer una pausa
después del apartado 3 y continuar en otra sesión.

## 1. Escuchar y consultar no son lo mismo

Imagina que un panel quiere saber cuál es el tema actual y enterarse cuando cambie. El contrato `Listenable` permite
registrar una función para recibir avisos, pero no ofrece una propiedad común para consultar el tema.

`ValueListenable<T>` amplía ese contrato con un getter llamado `value`. Así, una fuente de este tipo permite:

1. Leer el valor actual con `fuente.value`.
2. Registrar un listener con `fuente.addListener(observar)`.
3. Retirar ese listener con `fuente.removeListener(observar)`.

El listener sigue siendo una función **sin argumentos**. El aviso no le entrega el valor como parámetro. Si necesita el
dato, su cuerpo puede consultar `fuente.value` cuando se ejecuta.

Puedes imaginar una pantalla con un dato y una campanilla de aviso: puedes mirar la pantalla y también apuntarte para
escuchar la campanilla. El sonido no contiene el dato; necesitas mirar la pantalla. La analogía ayuda a separar aviso
y lectura, pero no determina cómo compara valores una implementación ni cuándo entrega los avisos.

### Practica 1

Si lees `fuente.value` una vez, ¿quedas registrado para recibir avisos futuros? Si ya estás registrado, ¿el listener
recibe automáticamente el valor como argumento?

<details>
<summary>Ver respuesta</summary>

No. Leer `.value` y registrar un listener son operaciones distintas. El listener no recibe argumentos; su cuerpo puede
leer `.value` cuando lo llamen.

</details>

## 2. Leer el tipo `ValueListenable<T>`

Estas son las operaciones relevantes del contrato, presentadas como fragmento para leer:

```dart
T get value;
void addListener(VoidCallback listener);
void removeListener(VoidCallback listener);
```

`T` representa el tipo del valor. Es la misma idea de genéricos que vimos en la unidad 3:

- En `ValueListenable<int>`, leer `.value` produce un entero.
- En `ValueListenable<String>`, produce un texto.
- En `ValueListenable<DaisyThemeModel>`, produce un modelo de tema.

El contrato permite leer y escuchar. No declara un setter para escribir `value`, ni ofrece por su tipo métodos
`dispose` o `notifyListeners`. Una implementación concreta puede tener otras operaciones, accesibles mediante una
referencia cuyo tipo las incluya.

Que esta interfaz no tenga setter tampoco significa que el valor sea inmutable o que nadie pueda cambiar la fuente.
Si el valor es, por ejemplo, una lista mutable, leerlo no crea por sí solo una copia independiente. Estudiaremos
referencias e inmutabilidad con más detalle en la unidad 8.

### Practica 2

Una función recibe `ValueListenable<String> fuente`. ¿Qué tipo devuelve `fuente.value`? ¿Puede esa función escribir
`fuente.value = 'oscuro'` usando solo ese tipo?

<details>
<summary>Ver respuesta</summary>

La lectura devuelve un `String`. La asignación no está disponible mediante `ValueListenable<String>`, porque ese
contrato declara el getter, pero no un setter para `value`.

</details>

## 3. Recibir un aviso y leer el valor

Vamos a utilizar `ValueNotifier<int>` como fuente concreta. Nos permite cambiar su valor y cumple el contrato
`ValueListenable<int>`. Para centrarnos en la lectura, en este ejemplo asignaremos números diferentes; las reglas de
igualdad de `ValueNotifier` se estudian en la unidad 7.

```dart
import 'package:flutter/foundation.dart';

void main() {
  final productor = ValueNotifier<int>(10);
  final ValueListenable<int> fuente = productor;
  final inicial = fuente.value;

  void observar() {
    print('Aviso: ${fuente.value}');
  }

  print('Inicial: $inicial');
  fuente.addListener(observar);
  productor.value = 20;
  print('Lectura guardada: $inicial');
  productor.value = 30;

  fuente.removeListener(observar);
  productor.value = 40;
  print('Actual: ${fuente.value}');
  productor.dispose();
}
```

La salida es:

```text
Inicial: 10
Aviso: 20
Lectura guardada: 10
Aviso: 30
Actual: 40
```

Sigue los pasos:

1. `productor` y `fuente` permiten acceder al **mismo objeto**. La segunda variable lo presenta mediante el tipo
   `ValueListenable<int>`; esa asignación no crea otro objeto ni un adaptador.
2. `inicial = fuente.value` guarda el entero leído en ese momento: `10`. No registra ningún listener.
3. `addListener(observar)` registra la función. Cuando el productor cambia a `20`, esta implementación notifica y
   llama a `observar`.
4. El callback consulta `fuente.value` al ejecutarse, por eso imprime `20`. La variable `inicial` sigue conservando
   `10`: no vuelve a realizar la lectura.
5. El cambio a `30` produce otro aviso. Tras retirar el listener, cambiar a `40` ya no ejecuta `observar`, pero una
   lectura posterior obtiene `40`.
6. `productor`, creado por `main`, se libera al final con `dispose()`.

El tipo de `fuente` permite leer y escuchar. `productor` tiene el tipo concreto `ValueNotifier<int>`, que además
permite escribir `.value` y liberarlo. El objeto real es el mismo; lo que cambia es qué operaciones expone cada tipo.

### Practica 3

En el programa anterior, retira `observar` justo después del cambio a `20`. ¿Qué avisos se imprimirán? ¿Qué mostrarán
al final `inicial` y `fuente.value`?

<details>
<summary>Ver respuesta</summary>

Solo se imprimirá `Aviso: 20`. `inicial` seguirá siendo `10` y la última lectura de `fuente.value` dará `40`.
Retirar el listener deja de avisar a esa función; no impide los cambios posteriores de la fuente.

</details>

## 4. ¿Quién guarda el historial?

Un aviso no contiene por sí solo el valor anterior ni crea un historial. Si queremos recordar lo que leímos en cada
aviso, nuestro código debe guardar esas lecturas:

```dart
import 'package:flutter/foundation.dart';

void main() {
  final productor = ValueNotifier<String>('claro');
  final ValueListenable<String> fuente = productor;
  final primeraLectura = fuente.value;
  final historial = <String>[];

  void guardarActual() {
    historial.add(fuente.value);
  }

  fuente.addListener(guardarActual);
  productor.value = 'oscuro';
  productor.value = 'cupcake';
  fuente.removeListener(guardarActual);
  productor.value = 'forest';

  print('Primera lectura: $primeraLectura');
  print('Actual: ${fuente.value}');
  print('Observados: ${historial.join(', ')}');
  productor.dispose();
}
```

La salida es:

```text
Primera lectura: claro
Actual: forest
Observados: oscuro, cupcake
```

Cada vez que se ejecuta `guardarActual`, el callback lee la fuente y añade el texto obtenido a la lista. `forest` no
aparece en el historial porque retiramos el listener antes de ese cambio. `primeraLectura` conserva el texto que se
obtuvo antes de los cambios.

En este ejemplo usamos cadenas y los cambios ocurren uno después de otro. Si el valor fuera un objeto mutable, guardar
su referencia no garantizaría una copia independiente de sus datos. Y si el valor volviera a cambiar antes de una
lectura, esa lectura obtendría el valor disponible en ese momento; el aviso no es una fotografía que contenga cada
transición.

### Practica 4

Añade `historial.add(fuente.value);` antes de `fuente.addListener(guardarActual)`. ¿Qué mostrará ahora la línea
`Observados`? ¿Esa lectura habrá registrado un listener?

<details>
<summary>Ver respuesta</summary>

Mostrará `Observados: claro, oscuro, cupcake`: añadimos explícitamente la lectura inicial a la lista. Esa lectura no
registra ningún listener; la suscripción ocurre en la llamada siguiente a `addListener`.

</details>

## 5. Un contrato puede tener distintas implementaciones

Una función que solo necesita leer un entero no tiene que conocer cómo se produce. Podemos entregarle tanto un
`ValueNotifier<int>` como una clase propia que cumpla `ValueListenable<int>`:

```dart
import 'package:flutter/foundation.dart';

class Puntuacion extends ChangeNotifier implements ValueListenable<int> {
  int _puntos = 0;

  @override
  int get value => _puntos;

  void sumar() {
    _puntos = _puntos + 1;
    notifyListeners();
  }
}

void mostrar(String nombre, ValueListenable<int> fuente) {
  print('$nombre: ${fuente.value}');
}

void main() {
  final numero = ValueNotifier<int>(10);
  final puntos = Puntuacion();

  void observarNumero() => mostrar('Número', numero);
  void observarPuntos() => mostrar('Puntos', puntos);

  mostrar('Número inicial', numero);
  mostrar('Puntos iniciales', puntos);
  numero.addListener(observarNumero);
  puntos.addListener(observarPuntos);

  numero.value = 11;
  puntos.sumar();

  numero.removeListener(observarNumero);
  puntos.removeListener(observarPuntos);
  numero.dispose();
  puntos.dispose();
}
```

La salida es:

```text
Número inicial: 10
Puntos iniciales: 0
Número: 11
Puntos: 1
```

`Puntuacion` hereda de `ChangeNotifier` el mecanismo de escucha e implementa el getter `value` que exige
`ValueListenable<int>`. Su método `sumar()` cambia el campo y llama a `notifyListeners()`, como hicimos en la unidad 5.

`mostrar` recibe el mismo tipo de contrato para ambos objetos y solo lee `fuente.value`. Para cambiar cada fuente,
`main` utiliza sus referencias concretas: el setter de `ValueNotifier` y el método `sumar()` de `Puntuacion`. Pasar una
fuente a `mostrar` no la convierte en otro objeto.

El contrato documenta que los listeners se llaman cuando cambia el valor. Una clase propia debe cumplir esa expectativa;
si `sumar()` cambiara el valor y omitiera el aviso, una lectura directa vería el dato nuevo, pero el listener no se
enteraría. El contrato no obliga a todas las implementaciones a usar `ChangeNotifier`, ni determina por sí solo todas
sus reglas de igualdad, almacenamiento o temporización.

### Practica 5

¿Puede `mostrar` llamar a `fuente.sumar()` o asignar `fuente.value = 5`? ¿Por qué `puntos.sumar()` sí es válido en
`main`?

<details>
<summary>Ver respuesta</summary>

Dentro de `mostrar`, el tipo de `fuente` es `ValueListenable<int>` y no ofrece `sumar` ni un setter `value`. En `main`,
`puntos` tiene el tipo concreto `Puntuacion`, que sí declara `sumar()`.

</details>

## 6. Mostrar el valor en un widget

Un [`ValueListenableBuilder<T>`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html) es un widget
que escucha una fuente `ValueListenable<T>` y entrega su valor a una función `builder` para construir parte de la
interfaz. Este fragmento presupone una fuente viva y un contexto de Flutter:

```dart
ValueListenableBuilder<int>(
  valueListenable: fuente,
  builder: (context, cantidad, child) {
    return Text('Cantidad: $cantidad');
  },
)
```

El widget obtiene el valor inicial para la primera construcción. Cuando recibe un aviso, vuelve a leer la fuente y
solicita una actualización; al construirse, el `builder` recibe el valor como `cantidad`.

No confundas las dos funciones: el **listener** de la fuente no recibe argumentos; el **builder** sí recibe
`context`, el valor y `child`. El widget administra su propia escucha y la retira al desmontarse o cambiar de fuente.
El propietario sigue siendo responsable de liberar la fuente cuando corresponda.

Una notificación, una reconstrucción y un repintado son pasos distintos. Flutter puede agrupar trabajo entre frames o
reconstruir por otros motivos; no deduzcas un número fijo de construcciones o repintados por contar avisos.

### Prueba guiada

Esta prueba es un archivo completo de **prueba de Flutter**, no un programa para DartPad. Puedes guardarla temporalmente
como `test/value_listenable_practica_test.dart` y ejecutar desde la raíz del proyecto:

```sh
flutter test --no-pub test/value_listenable_practica_test.dart
```

Antes de ejecutarla, predice qué texto aparece antes y después de `pump`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('El widget muestra el valor inicial y el actualizado', (tester) async {
    final productor = ValueNotifier<int>(1);
    var avisos = 0;
    void contarAviso() => avisos = avisos + 1;
    productor.addListener(contarAviso);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ValueListenableBuilder<int>(
          valueListenable: productor,
          builder: (context, cantidad, child) => Text('Cantidad: $cantidad'),
        ),
      ),
    );
    expect(find.text('Cantidad: 1'), findsOneWidget);
    expect(avisos, 0);

    productor.value = 2;
    productor.value = 3;
    expect(avisos, 2);
    expect(find.text('Cantidad: 1'), findsOneWidget);
    await tester.pump();
    expect(find.text('Cantidad: 3'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    productor.removeListener(contarAviso);
    productor.dispose();
  });
}
```

`pumpWidget` monta el widget y comprueba la lectura inicial: aparece `Cantidad: 1` sin avisos. Los cambios concretos a
`2` y `3` producen dos avisos antes de `pump`; hasta procesar el frame, la prueba todavía encuentra el texto anterior.
Después de `pump` encuentra `Cantidad: 3`. Al final desmonta el consumidor, retira el listener adicional y libera la
fuente.

Esta prueba observa el árbol de widgets y las notificaciones en ese escenario; no prueba un repintado físico de
pantalla ni establece que cada aviso produzca una construcción separada.

### Practica 6

En el fragmento del builder, ¿quién entrega `cantidad` a la función que construye el texto? ¿Ese parámetro se lo pasa
el `VoidCallback` del listener?

<details>
<summary>Ver respuesta</summary>

`ValueListenableBuilder` entrega el valor a su función `builder`. El listener registrado sobre la fuente no recibe ese
argumento: el widget lee el valor y después lo utiliza al llamar al builder.

</details>

## 7. La vista del tema en DaisyUI

Abre el [controlador de temas](../../../lib/themes/application/daisy_theme_controller.dart). Estos fragmentos pertenecen
al archivo real; no forman un programa independiente:

```dart
final FlutterSignal<DaisyThemeModel> _palette;

late final ValueListenable<DaisyThemeModel> _theme = _ThemeListenable(
  _palette,
);

ValueListenable<DaisyThemeModel> get theme => _theme;

void setTheme(DaisyThemeModel theme) {
  _palette.value = theme;
}
```

Sigue cada pieza:

1. El controlador crea y posee `_palette`, una señal que conserva el tema actual.
2. El getter `theme` ofrece una vista de tipo `ValueListenable<DaisyThemeModel>`: permite leer el tema y escuchar
   avisos.
3. Esa vista es `_ThemeListenable`, un **objeto adaptador distinto de la señal** que conserva una referencia a ella.
   Su getter `value` devuelve `_source.value` y sus métodos de escucha reenvían el listener a `_source`.
4. Para cambiar el tema, `setTheme` asigna el modelo a `_palette.value`. La señal es la fuente concreta que determina
   cómo se producen los avisos; estudiaremos su funcionamiento en la unidad 9.

La vista del controlador no almacena una copia separada del tema. Cada lectura consulta la fuente a través del
adaptador. Una variable que guarda el resultado de `controller.theme.value`, en cambio, conserva el modelo que obtuvo
en ese momento.

En el apartado 3, asignar un `ValueNotifier` a una variable `ValueListenable` conservaba una referencia al **mismo
objeto**. Aquí el controlador ofrece un adaptador separado: su clase no implementa setter para `value` ni `dispose`.
Esa diferencia no garantiza por sí sola que cualquier objeto devuelto por un getter sea inmutable.

La [prueba existente del controlador](../../../test/themes/daisy_theme_controller_test.dart) comprueba, entre otras
cosas, el registro y retirada de listeners y la lectura de un tema nuevo. En el
[scope de temas](../../../lib/themes/application/daisy_theme_scope.dart), la vista también se conecta a los dependientes
de Flutter; estudiaremos ese recorrido más adelante.

### Practica 7

¿Qué tipo tiene `controller.theme.value`? Si guardas ese resultado antes de llamar a `setTheme`, ¿la variable guardada
vuelve a consultar el controlador por sí sola?

<details>
<summary>Ver respuesta</summary>

Tiene tipo `DaisyThemeModel`. La variable conserva el modelo obtenido en esa lectura; para obtener el tema vigente hay
que volver a consultar `controller.theme.value`.

</details>

## Ejercicio final: un marcador observable

Escribe un programa Flutter de consola que:

1. Declare `Marcador extends ChangeNotifier implements ValueListenable<int>`, con `0` puntos iniciales y getter `value`.
2. Añada `sumar()`: aumenta un punto y después llama a `notifyListeners()`.
3. Declare `mostrar(String nombre, ValueListenable<int> fuente)`, que imprima el nombre y el valor actual.
4. Guarde una lectura inicial y registre dos listeners, `panel` y `registro`, que llamen a `mostrar`.
5. Sume dos veces, retire `panel`, sume una vez más y retire `registro`.
6. Imprima la lectura inicial y el valor actual. El propietario debe liberar el marcador.

Antes de ejecutar, predice la salida y explica dónde se guarda el dato, qué línea avisa y dónde se lee el valor. Como
variación, registra en una lista los valores observados por uno de los listeners.

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/foundation.dart';

class Marcador extends ChangeNotifier implements ValueListenable<int> {
  int _puntos = 0;

  @override
  int get value => _puntos;

  void sumar() {
    _puntos = _puntos + 1;
    notifyListeners();
  }
}

void mostrar(String nombre, ValueListenable<int> fuente) {
  print('$nombre: ${fuente.value}');
}

void main() {
  final marcador = Marcador();
  final ValueListenable<int> fuente = marcador;
  final inicial = fuente.value;
  void panel() => mostrar('Panel', fuente);
  void registro() => mostrar('Registro', fuente);

  fuente.addListener(panel);
  fuente.addListener(registro);
  marcador.sumar();
  marcador.sumar();
  fuente.removeListener(panel);
  marcador.sumar();
  fuente.removeListener(registro);

  print('Inicial: $inicial');
  print('Actual: ${fuente.value}');
  marcador.dispose();
}
```

```text
Panel: 1
Registro: 1
Panel: 2
Registro: 2
Registro: 3
Inicial: 0
Actual: 3
```

`_puntos` guarda el dato. `sumar()` lo cambia y llama a `notifyListeners()`; cada listener activo llama a `mostrar`, que
consulta `.value`. Después de retirar `panel`, solo `registro` recibe el tercer aviso. `inicial` conserva la lectura
anterior, mientras que la última consulta obtiene `3`.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué añade `ValueListenable<T>` a `Listenable`? ¿El listener recibe el valor como argumento? **Apartado 1.**
2. ¿Qué tipo tiene `.value` en `ValueListenable<String>` y qué operaciones ofrece ese contrato? **Apartado 2.**
3. ¿Por qué una lectura inicial puede ser distinta de una consulta posterior de la misma fuente? **Apartado 3.**
4. ¿Quién añade valores al historial y qué precaución existe si el valor es mutable? **Apartado 4.**
5. ¿Por qué `mostrar` puede aceptar dos implementaciones diferentes? **Apartado 5.**
6. ¿Quién conecta la fuente con el widget y qué demuestra la prueba de `pump`? **Apartado 6.**
7. En DaisyUI, ¿qué almacena el tema, qué ofrece el adaptador y dónde se cambia el valor? **Apartado 7.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques las respuestas con tus palabras.
La siguiente unidad estudia `ValueNotifier<T>` y su política al asignar valores.

## Para consultar si necesitas reforzar

- [`ValueListenable<T>`](https://api.flutter.dev/flutter/foundation/ValueListenable-class.html): escucha y getter
  `value`.
- [`Listenable`](https://api.flutter.dev/flutter/foundation/Listenable-class.html): registro y retirada de listeners.
- [`ValueNotifier<T>`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html): una implementación concreta
  que estudiaremos en la unidad 7.
- [`ValueListenableBuilder<T>`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html): conexión de
  una fuente con la construcción de un widget.
- [Genéricos en Dart](https://dart.dev/language/generics): cómo concretar `T` con un tipo como `int` o `String`.

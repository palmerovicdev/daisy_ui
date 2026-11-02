# 18. Widgets, elementos, estado y reconstrucción

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 17](17-instancias-static-y-servicio-global.md) · **Estado:** pendiente

## Qué vas a aprender

En el Bloque 4 dejamos el tema guardado en un controlador, con una señal que avisa cuando cambia. Falta el último tramo: ¿qué tiene que ocurrir para que un texto de la pantalla muestre el valor nuevo? En las pruebas anteriores usamos `pumpWidget`, `Builder` o `build` sin detenernos a explicar qué son. Ahora les toca a ellos.

Al terminar podrás explicar qué es un widget y por qué se vuelve a crear, qué conserva un `State` y qué papel tiene `build`. Distinguirás cambiar un dato de solicitar una reconstrucción, y reconstruir de volver a pintar. También podrás predecir cuántas veces se ejecuta un `build` y qué hay realmente dentro de `ValueListenableBuilder`.

Los ejemplos completos son pruebas de widgets independientes. Copia **una cada vez** a `test/estudio_widgets_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_widgets_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar con 7–9 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Las pruebas comprueban qué contiene el árbol y cuántas veces se ejecuta el código; no demuestran por sí solas cómo se ve una pantalla física.

## 1. Describir la interfaz en lugar de modificarla

Imagina que tienes un texto en pantalla que dice `claro` y quieres que diga `oscuro`. En muchos sistemas buscarías ese texto y le ordenarías cambiar, con algo parecido a `etiqueta.texto = 'oscuro'`. Flutter no funciona así: no modificas el texto existente, sino que **vuelves a describir cómo debe ser la interfaz** con los datos actuales. Esa forma de trabajar se llama **interfaz declarativa**.

La descripción es un **widget**: un objeto que indica qué mostrar y con qué configuración. `Text('claro')` no es un texto dibujado; es un objeto que describe un texto. Sus campos son `final`, de modo que no hay nada que cambiar en él.

**Antes de mirar los `expect`**, predice qué texto hay en el árbol después de cada paso:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('cambiar una variable no cambia la interfaz', (tester) async {
    var nombre = 'claro';

    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: Text(nombre)),
    );
    expect(find.text('claro'), findsOneWidget);

    nombre = 'oscuro';
    await tester.pump();
    expect(find.text('claro'), findsOneWidget);

    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: Text(nombre)),
    );
    expect(find.text('oscuro'), findsOneWidget);
  });
}
```

Paso a paso:

1. `Text(nombre)` lee la variable **una vez**, cuando se crea el widget, y conserva el texto `'claro'`. Es la lectura puntual de la unidad 1.
2. `nombre = 'oscuro'` cambia la variable. El widget ya creado no se entera, y `pump` procesa un frame sin que nadie haya pedido nada nuevo.
3. El segundo `pumpWidget` entrega una **descripción nueva**, creada con el valor actual. Flutter la compara con lo que había y actualiza lo necesario.

La idea central de toda esta unidad ya está aquí: para que cambie la interfaz, alguien debe volver a producir una descripción con los datos actuales. Lo que falta por ver es quién lo hace y cuándo.

### Practica 1

Si en el segundo `pumpWidget` escribiéramos `Text('claro')` en lugar de `Text(nombre)`, ¿qué texto mostraría el árbol? ¿Qué valor tendría `nombre`?

<details>
<summary>Ver respuesta</summary>

El árbol mostraría `claro` y `nombre` valdría `'oscuro'`. La interfaz muestra lo que dice la última descripción, no lo que contiene una variable. Dato e interfaz solo coinciden cuando se construye la descripción leyendo ese dato.

</details>

## 2. `StatelessWidget` y `build`

Escribir toda la descripción en un solo sitio no escala, así que podemos crear widgets propios. Un `StatelessWidget` es un widget que se describe a partir de otros en un método llamado `build`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var construcciones = 0;

class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) {
    construcciones++;
    return Directionality(textDirection: TextDirection.ltr, child: Text(texto));
  }
}

void main() {
  testWidgets('un StatelessWidget también se reconstruye', (tester) async {
    await tester.pumpWidget(const Etiqueta('claro'));
    expect(construcciones, 1);

    await tester.pumpWidget(const Etiqueta('oscuro'));
    expect(construcciones, 2);
    expect(find.text('oscuro'), findsOneWidget);

    await tester.pump();
    expect(construcciones, 2);

    const misma = Etiqueta('nieve');
    await tester.pumpWidget(misma);
    expect(construcciones, 3);
    await tester.pumpWidget(misma);
    expect(construcciones, 3);

    // ignore: prefer_const_constructors
    await tester.pumpWidget(Etiqueta('nieve'));
    expect(construcciones, 4);
  });
}
```

Las líneas nuevas:

- `extends StatelessWidget` obliga a escribir `build`, que recibe un `BuildContext` y devuelve un widget. El contexto se estudia en la unidad 20; por ahora no lo usamos.
- `construcciones` es una variable de nivel superior que usamos solo para contar llamadas.
- `{super.key}` reenvía un parámetro opcional al padre, como viste en la unidad 15. Volveremos a la `key` en el apartado 6.
- El comentario `ignore` solo le indica al analizador que omitimos `const` a propósito.

Paso a paso:

1. El primer `pumpWidget` necesita saber qué hay dentro de `Etiqueta`, así que Flutter ejecuta su `build`.
2. El segundo entrega otra `Etiqueta`, con otro texto: `build` se ejecuta de nuevo. **«Sin estado» no significa «no se reconstruye nunca»**, sino que el widget no conserva datos propios que cambien: todo lo que usa le llega de fuera.
3. `pump` procesa un frame, pero nadie ha pedido nada, y `build` no se ejecuta.
4. `misma` llega al árbol por primera vez: tercer `build`. Al entregar **el mismo objeto** otra vez, Flutter comprueba que la descripción no ha cambiado y no trabaja en ella.
5. La última línea crea un objeto nuevo. Flutter no compara los campos de los widgets para decidir: un objeto distinto basta para que `build` se ejecute, aunque el texto sea el mismo.

Aquí está la utilidad práctica de `const`. Un `const Hijo()` escrito dentro de un `build` es siempre el mismo objeto, de modo que reconstruir al padre no reconstruye a ese hijo. Lo aprovecharemos varias veces.

Hay un detalle que puede confundirte si experimentas. La unidad 8 explicó que dos constantes iguales son el mismo objeto. Pero `flutter test`, igual que el modo de depuración, compila con la opción `--track-widget-creation`, que añade a cada widget el lugar del código donde se creó. Por eso dos `const Etiqueta('nieve')` escritos en **líneas distintas** no son el mismo objeto en estas pruebas, y por eso el ejemplo guarda la constante en `misma`. Una misma línea de código sí produce siempre el mismo objeto, que es el caso habitual dentro de un `build`.

A esta ejecución de `build` para producir una descripción nueva se le llama **reconstruir**. Debe ser una operación que se pueda repetir sin consecuencias, porque Flutter decide cuándo y cuántas veces la ejecuta. Lo aprovecharemos en la unidad 19.

### Practica 2

Tras la última línea añadimos `await tester.pumpWidget(misma);` dos veces seguidas. ¿Cuánto vale `construcciones` tras cada una?

<details>
<summary>Ver respuesta</summary>

`5` y después `5`. En el árbol estaba el objeto creado en la última línea, que no es `misma`, así que la primera entrega provoca un `build`. En la segunda, el objeto que llega es el que ya está y no hay trabajo.

</details>

## 3. El widget se sustituye; el elemento permanece

Si los widgets se crean y se tiran continuamente, ¿qué es lo que permanece en la pantalla entre un frame y otro? Flutter mantiene un segundo árbol, formado por objetos llamados **elementos** (`Element`). Cada elemento representa un sitio de la interfaz y recuerda qué widget lo describe en este momento.

Una analogía: el widget es la **ficha de instrucciones** de un puesto de trabajo y el elemento es **el puesto**. Se puede cambiar la ficha sin desmontar el puesto. La analogía se queda corta en que un elemento hace más que guardar la ficha: coordina la construcción de sus hijos.

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Etiqueta extends StatelessWidget {
  const Etiqueta(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Text(texto),
  );
}

class OtraEtiqueta extends StatelessWidget {
  const OtraEtiqueta(this.texto, {super.key});

  final String texto;

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.ltr,
    child: Text(texto),
  );
}

void main() {
  testWidgets('widgets nuevos y un mismo elemento', (tester) async {
    await tester.pumpWidget(const Etiqueta('claro'));
    final elementoA = tester.element(find.byType(Etiqueta));
    final widgetA = tester.widget(find.byType(Etiqueta));

    await tester.pumpWidget(const Etiqueta('oscuro'));
    final elementoB = tester.element(find.byType(Etiqueta));
    final widgetB = tester.widget(find.byType(Etiqueta));

    expect(identical(widgetA, widgetB), isFalse);
    expect(identical(elementoA, elementoB), isTrue);

    await tester.pumpWidget(const OtraEtiqueta('oscuro'));
    final elementoC = tester.element(find.byType(OtraEtiqueta));

    expect(identical(elementoB, elementoC), isFalse);
    expect(elementoB.mounted, isFalse);
  });
}
```

`tester.element` y `tester.widget` devuelven los objetos que hay en ese sitio. Con `identical` (unidad 8) comprobamos:

1. Entre `claro` y `oscuro` hay **dos widgets y un solo elemento**. El elemento recibió la nueva descripción y siguió ahí.
2. Al pasar a `OtraEtiqueta` cambia también el elemento: el anterior se retira (`mounted` es `false`) y se crea uno nuevo.

¿Cómo decide Flutter? Compara la descripción antigua con la nueva mediante [`Widget.canUpdate`](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html):

```dart
// Fragmento del código de Flutter.
static bool canUpdate(Widget oldWidget, Widget newWidget) {
  return oldWidget.runtimeType == newWidget.runtimeType && oldWidget.key == newWidget.key;
}
```

Si el tipo real y la `key` coinciden, el elemento se reutiliza con la descripción nueva. Si no, se descarta y se crea otro. El contenido del texto no interviene en esa decisión.

No necesitarás escribir elementos propios. Basta con saber que existen, porque son los que **sobreviven** entre construcciones y, como veremos, los que conservan el estado y reciben las solicitudes de reconstrucción.

### Practica 3

¿Se reutiliza el elemento en cada uno de estos cambios? (a) `Etiqueta('a')` por `Etiqueta('b')`; (b) `Etiqueta('a')` por `Etiqueta('a', key: ValueKey(1))`; (c) `Etiqueta('a')` por `OtraEtiqueta('a')`.

<details>
<summary>Ver respuesta</summary>

(a) Sí: mismo tipo y misma `key` (ninguna en ambos). (b) No: el tipo coincide, pero la `key` ha cambiado de `null` a `ValueKey(1)`. (c) No: aunque el texto sea igual, el tipo es otro. Lo que decide es el tipo y la `key`, no el contenido.

</details>

## 4. `StatefulWidget` y `State`

Un widget no puede guardar un dato que cambie: sus campos son `final` y además el objeto se sustituye en cualquier momento. Si queremos contar pulsaciones, ese dato necesita un sitio que **permanezca**. Ese sitio es un objeto `State`, que el elemento conserva mientras está montado.

Un `StatefulWidget` se reparte en dos clases:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Contador extends StatefulWidget {
  const Contador({super.key, required this.titulo});

  final String titulo;

  @override
  State<Contador> createState() => ContadorState();
}

class ContadorState extends State<Contador> {
  int veces = 0;

  void sumar() {
    setState(() {
      veces++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: sumar,
      child: Text('${widget.titulo}: $veces'),
    );
  }
}

void main() {
  testWidgets('un State conserva el contador', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Contador(titulo: 'Veces'),
      ),
    );
    expect(find.text('Veces: 0'), findsOneWidget);

    await tester.tap(find.text('Veces: 0'));
    await tester.pump();
    expect(find.text('Veces: 1'), findsOneWidget);
  });
}
```

Las líneas nuevas:

- `Contador` es el widget: inmutable y con la configuración que llega de fuera (`titulo`). Su único trabajo adicional es `createState`, que crea el objeto de estado.
- `ContadorState extends State<Contador>` conserva el dato mutable (`veces`) y contiene `build`. Aquí, `build` pertenece al `State`, no al widget.
- `widget` es un getter de `State` que devuelve la descripción actual. Por eso se escribe `widget.titulo`.
- `GestureDetector` ejecuta `onTap` cuando se pulsa; `tester.tap` simula esa pulsación en la prueba.

En código real, la clase de estado suele ser privada (`_ContadorState`). Aquí la dejamos pública para poder usarla desde las pruebas de los apartados siguientes.

Quién hace cada cosa en esta prueba:

| Objeto                  | Qué hace                                                     | Cuánto vive                       |
|-------------------------|--------------------------------------------------------------|-----------------------------------|
| `Contador`              | Describe la configuración y sabe crear el estado             | Hasta que llega otra descripción  |
| El elemento             | Ocupa el sitio y conserva la referencia al `State`           | Mientras esté montado             |
| `ContadorState`         | Conserva `veces`, cambia el dato y produce la descripción    | Lo mismo que su elemento          |
| `Text('Veces: 1')`      | Describe el texto de este momento                            | Hasta la siguiente construcción   |

Observa también que la pulsación no reconstruye nada por sí misma: `onTap` ejecuta `sumar`, y es `setState` quien solicita la reconstrucción. Es lo que veremos a continuación.

### Practica 4

¿Dónde debe declararse cada dato: en `Contador` o en `ContadorState`? (a) el título que recibe del padre; (b) el número de pulsaciones; (c) si el ratón está encima en este momento.

<details>
<summary>Ver respuesta</summary>

(a) En `Contador`, como campo `final`: es configuración que llega de fuera. (b) y (c) en `ContadorState`: son datos que cambian durante la vida de ese sitio de la interfaz y no deben perderse cuando llega una descripción nueva.

</details>

## 5. `setState`: cambiar el dato y solicitar son dos cosas

La unidad 1 adelantó que `setState` conecta el cambio de un dato con una actualización. Ahora podemos separar sus piezas. Esta prueba expone cuatro métodos para observarlas por separado.

**Antes de mirar los `expect`**, predice el valor de `construcciones` y el texto tras cada bloque:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Contador extends StatefulWidget {
  const Contador({super.key});

  @override
  State<Contador> createState() => ContadorState();
}

class ContadorState extends State<Contador> {
  int veces = 0;
  int construcciones = 0;

  void sumarSinSolicitar() => veces++;

  void solicitarSinCambiar() => setState(() {});

  void sumar() => setState(() => veces++);

  @override
  Widget build(BuildContext context) {
    construcciones++;
    return Text('Veces: $veces');
  }
}

void main() {
  testWidgets('dato cambiado y reconstrucción solicitada', (tester) async {
    await tester.pumpWidget(
      const Directionality(textDirection: TextDirection.ltr, child: Contador()),
    );
    final estado = tester.state<ContadorState>(find.byType(Contador));
    expect(estado.construcciones, 1);

    // 1. Cambia el dato; nadie solicita nada.
    estado.sumarSinSolicitar();
    await tester.pump();
    expect(estado.veces, 1);
    expect(estado.construcciones, 1);
    expect(find.text('Veces: 0'), findsOneWidget);

    // 2. Se solicita; el dato no cambia en esta llamada.
    estado.solicitarSinCambiar();
    await tester.pump();
    expect(estado.construcciones, 2);
    expect(find.text('Veces: 1'), findsOneWidget);

    // 3. Dos solicitudes antes del mismo frame.
    estado.sumar();
    estado.sumar();
    expect(estado.veces, 3);
    expect(estado.construcciones, 2);
    await tester.pump();
    expect(estado.construcciones, 3);
    expect(find.text('Veces: 3'), findsOneWidget);
  });
}
```

Paso a paso:

1. **Dato sin solicitud.** `veces` vale `1`, pero nadie ha pedido una descripción nueva. El árbol sigue diciendo `Veces: 0`. Es el mismo error que modificar la variable en el apartado 1.
2. **Solicitud sin cambio.** `setState(() {})` no cambia nada, pero sí provoca un `build`. Al ejecutarse, lee el valor actual y aparece `Veces: 1`. Flutter no comprueba si el dato cambió: solo atiende la solicitud.
3. **Dos solicitudes.** Justo después de `sumar()` dos veces, `veces` ya es `3`: la función que recibe `setState` se ejecuta **inmediatamente**. Pero `construcciones` sigue en `2`: `build` no se ejecuta en ese momento, sino cuando se procesa el frame. Las dos solicitudes producen una sola construcción, que lee el valor final.

`setState` hace por tanto dos cosas, en este orden: ejecuta tu función y marca el elemento como pendiente de reconstruir (mediante un método del elemento llamado `markNeedsBuild`, que ya apareció en la unidad 10). Es un elemento marcado lo que Flutter procesa en el siguiente frame. En las pruebas, ese frame lo provoca `pump`; en una aplicación, el motor lo programa cuando hace falta.

Tampoco es la única forma de solicitar una reconstrucción: es la disponible dentro de un `State`. La suscripción de `SignalBuilder` usa `markNeedsBuild` directamente, y en la unidad 22 veremos cómo lo hace el scope.

### Practica 5

Si en el bloque 3 llamáramos a `sumarSinSolicitar()` y después a `sumar()`, ¿cuántas construcciones se añaden y qué texto aparece? ¿Importaría invertir el orden de esas dos llamadas?

<details>
<summary>Ver respuesta</summary>

Se añade una sola construcción, y el texto refleja las dos sumas, porque `build` lee `veces` al procesar el frame. El orden no importa en este caso: cuando se ejecute `build`, ambas sumas ya habrán ocurrido. Aun así, no conviene apoyarse en esto: en otro código, la solicitud podría no llegar y el dato quedaría sin mostrar.

</details>

## 6. Qué sobrevive a una reconstrucción

Ahora podemos responder a la pregunta del plan: ¿qué conserva `State` y qué papel tiene `build`? El `State` conserva los datos entre construcciones; `build` produce la descripción de ahora con esos datos. Comprobémoslo cuando es el **padre** quien entrega una descripción nueva.

**Antes de mirar los `expect`**, predice qué ocurre con `veces` en cada `pumpWidget`:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Contador extends StatefulWidget {
  const Contador({super.key, required this.titulo});

  final String titulo;

  @override
  State<Contador> createState() => ContadorState();
}

class ContadorState extends State<Contador> {
  int veces = 0;

  void sumar() => setState(() => veces++);

  @override
  Widget build(BuildContext context) => Text('${widget.titulo}: $veces');
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('el State sobrevive a la descripción', (tester) async {
    await tester.pumpWidget(pantalla(const Contador(titulo: 'Puntos')));
    final estado = tester.state<ContadorState>(find.byType(Contador));
    estado.sumar();
    await tester.pump();
    expect(find.text('Puntos: 1'), findsOneWidget);

    await tester.pumpWidget(pantalla(const Contador(titulo: 'Goles')));
    expect(find.text('Goles: 1'), findsOneWidget);
    expect(identical(tester.state(find.byType(Contador)), estado), isTrue);

    await tester.pumpWidget(
      pantalla(const Contador(key: ValueKey('otro'), titulo: 'Goles')),
    );
    expect(find.text('Goles: 0'), findsOneWidget);
    expect(estado.mounted, isFalse);
  });
}
```

Paso a paso:

1. La segunda descripción tiene otro `titulo`, pero el mismo tipo y la misma `key`: `canUpdate` es verdadero. El elemento se queda, conserva el **mismo** `State`, y el getter `widget` pasa a devolver la descripción nueva. Se muestra `Goles: 1`: dato conservado y configuración nueva.
2. La tercera tiene otra `key`. `canUpdate` es falso: el elemento antiguo se retira con su `State`, y se crea otro que empieza en `0`. `mounted` indica si el `State` sigue en el árbol.

Por lo tanto, el `State` no se pierde por reconstruir, sino por **perder su sitio en el árbol**. Cambiar el tipo de un widget de esa posición tiene el mismo efecto que cambiar su `key`. Esto es importante en DaisyUI: un controlador guardado en un `State` sobrevive a las reconstrucciones, y la unidad 19 parte de esa idea.

Una `key` es un valor que identifica un widget entre sus hermanos. No hace falta saber más para esta unidad.

### Practica 6

Una lista de la compra está en un `State` y queremos conservarla. ¿Se pierde en estos casos? (a) El padre la entrega otra vez con otro título. (b) El padre la envuelve en un nuevo `Padding`, de modo que en esa posición pasa a haber otro tipo de widget. (c) Se llama a `setState`.

<details>
<summary>Ver respuesta</summary>

(a) No: mismo tipo y misma `key`. (b) Sí: en esa posición ahora hay un `Padding`, así que el elemento anterior se descarta con su `State`, y dentro del `Padding` se crea otro. (c) No: `setState` vuelve a ejecutar `build` del mismo `State`.

</details>

## 7. Reconstruir no es volver a pintar

Un `build` no dibuja nada: produce objetos que describen la interfaz. Después, Flutter sigue con más trabajo, en este orden aproximado:

1. **Construcción (*build*)**: ejecutar `build` de lo que esté marcado y actualizar los elementos.
2. **Diseño (*layout*)**: calcular tamaños y posiciones.
3. **Pintura (*paint*)**: producir las instrucciones de dibujo.

Cada fase solo trabaja donde hace falta, de modo que pueden ocurrir por separado. Para verlo usamos `CustomPaint`, un widget que pide a un objeto `CustomPainter` que dibuje. El método `paint` no pertenece a ningún `build`, así que podemos contar ambos por separado.

**Antes de mirar los `expect`**, predice los dos contadores después de cada paso:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var pinturas = 0;

class Pintor extends CustomPainter {
  Pintor({super.repaint});

  @override
  void paint(Canvas canvas, Size size) => pinturas++;

  @override
  bool shouldRepaint(Pintor oldDelegate) => false;
}

void main() {
  testWidgets('construir y pintar por separado', (tester) async {
    final marca = ValueNotifier<int>(0);
    addTearDown(marca.dispose);
    var construcciones = 0;

    Widget pantalla() => Builder(
      builder: (_) {
        construcciones++;
        return CustomPaint(
          size: const Size(10, 10),
          painter: Pintor(repaint: marca),
        );
      },
    );

    await tester.pumpWidget(pantalla());
    expect(construcciones, 1);
    expect(pinturas, 1);

    await tester.pumpWidget(pantalla());
    expect(construcciones, 2);
    expect(pinturas, 1);

    marca.value = 1;
    await tester.pump();
    expect(construcciones, 2);
    expect(pinturas, 2);
  });
}
```

Paso a paso:

1. Montar el árbol ejecuta `build` y `paint` por primera vez.
2. **Construir sin pintar.** El segundo `pumpWidget` ejecuta el `build` y crea otro `Pintor`. Flutter pregunta a `shouldRepaint` si hace falta pintar de nuevo. Devuelve `false` y `paint` no se ejecuta.
3. **Pintar sin construir.** `repaint` recibe un `Listenable` (unidad 4). El sistema de pintura lo escucha y, al recibir el aviso, marca esa zona para volver a pintarla. No interviene ningún `build`.

No hay que usar `CustomPaint` para esto: lo usamos porque deja ver la diferencia. La conclusión práctica es que un `build` adicional no significa necesariamente un dibujo adicional. Tampoco ocurre al revés: una animación puede repintar sin pasar por `build`. Cuando en esta y las próximas unidades contemos construcciones, estaremos midiendo **cuántas descripciones se producen**, no cuánto se dibuja.

### Practica 7

¿Qué cambiaría en el segundo paso si `shouldRepaint` devolviera `true`? ¿Y en el tercero si no pasáramos `repaint`?

<details>
<summary>Ver respuesta</summary>

Con `true`, el segundo paso daría `construcciones` 2 y `pinturas` 2: la nueva descripción sí pide volver a pintar. Sin `repaint`, nadie escucharía a `marca`: en el tercer paso seguiríamos con `pinturas` igual, aunque el notifier hubiera cambiado. Un aviso solo tiene efecto si hay alguien registrado para recibirlo.

</details>

## 8. `setState` y `ValueListenableBuilder`

Hay dos maneras de actualizar el mismo texto. En la primera, el `State` de un panel conserva el dato y llama a `setState`. En la segunda, el dato vive en un `ValueNotifier` (unidad 7) y un `ValueListenableBuilder` lo observa.

**Antes de mirar los `expect`**, predice cuántas veces se ejecuta el `build` del panel y el callback en cada caso:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class PanelConState extends StatefulWidget {
  const PanelConState({super.key});

  @override
  State<PanelConState> createState() => PanelConStateState();
}

class PanelConStateState extends State<PanelConState> {
  int valor = 0;
  int construcciones = 0;

  void sumar() => setState(() => valor++);

  @override
  Widget build(BuildContext context) {
    construcciones++;
    return Text('Valor: $valor');
  }
}

class PanelConNotifier extends StatelessWidget {
  const PanelConNotifier({
    super.key,
    required this.fuente,
    required this.alConstruirPanel,
    required this.alConstruirTexto,
  });

  final ValueNotifier<int> fuente;
  final VoidCallback alConstruirPanel;
  final VoidCallback alConstruirTexto;

  @override
  Widget build(BuildContext context) {
    alConstruirPanel();
    return ValueListenableBuilder<int>(
      valueListenable: fuente,
      builder: (_, valor, _) {
        alConstruirTexto();
        return Text('Valor: $valor');
      },
    );
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('con setState se repite el panel', (tester) async {
    await tester.pumpWidget(pantalla(const PanelConState()));
    final estado = tester.state<PanelConStateState>(
      find.byType(PanelConState),
    );

    estado.sumar();
    await tester.pump();
    expect(find.text('Valor: 1'), findsOneWidget);
    expect(estado.construcciones, 2);
  });

  testWidgets('con el notifier solo se repite el callback', (tester) async {
    final fuente = ValueNotifier<int>(0);
    addTearDown(fuente.dispose);
    var panel = 0;
    var texto = 0;

    await tester.pumpWidget(
      pantalla(
        PanelConNotifier(
          fuente: fuente,
          alConstruirPanel: () => panel++,
          alConstruirTexto: () => texto++,
        ),
      ),
    );
    expect((panel, texto), (1, 1));

    fuente.value = 1;
    await tester.pump();
    expect(find.text('Valor: 1'), findsOneWidget);
    expect((panel, texto), (1, 2));

    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
  });
}
```

`(panel, texto)` es un *record*, un pequeño valor con dos campos. Lo usamos para comparar los dos contadores a la vez.

En el primer caso, `setState` marca el `State` del panel y se repite todo su `build`. En el segundo, el panel no se vuelve a construir: solo el callback del `ValueListenableBuilder`. Parece que este último hace algo especial, pero no es así. Este es **su código en Flutter**, sin los comentarios:

```dart
// Fragmento del código de Flutter.
class _ValueListenableBuilderState<T> extends State<ValueListenableBuilder<T>> {
  late T value;

  @override
  void initState() {
    super.initState();
    value = widget.valueListenable.value;
    widget.valueListenable.addListener(_valueChanged);
  }

  // También cambia de fuente en didUpdateWidget y retira el listener en dispose.

  void _valueChanged() {
    setState(() {
      value = widget.valueListenable.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, value, widget.child);
  }
}
```

`ValueListenableBuilder` **es un `StatefulWidget`**, con un listener que llama a `setState`. Ya tienes todas las piezas:

1. **Quién conserva el dato:** el notifier.
2. **Quién registra la escucha:** el `State` del `ValueListenableBuilder`, con `addListener`.
3. **Quién avisa:** el notifier, al asignar un valor distinto (unidad 7).
4. **Quién solicita la reconstrucción:** el listener `_valueChanged`, mediante `setState`.
5. **Quién reconstruye:** Flutter, en el siguiente frame, y solo el elemento marcado.

La diferencia con el panel de `setState` no es de mecanismo, sino de **qué `State` se marca**: uno pequeño situado junto al texto, en lugar de el del panel entero. `initState` y `dispose` se estudian en la unidad 19. Ya viste en la unidad 10 que `SignalBuilder` sigue un esquema parecido: una observación que acaba marcando su elemento.

### Practica 8

En el panel con notifier, hacemos `fuente.value = 1` y a continuación `fuente.value = 1` otra vez, y después `pump`. ¿Cuántas veces se llama a `_valueChanged`? ¿Cómo quedan `panel` y `texto`?

<details>
<summary>Ver respuesta</summary>

`_valueChanged` se llama una vez: la segunda asignación es igual a la primera y `ValueNotifier` no avisa. Quedan `panel` 1 y `texto` 2. Con dos valores distintos habría dos avisos y dos `setState`, pero seguiría habiendo una sola construcción, como en el apartado 5.

</details>

## 9. Lo mismo en el código de DaisyUI

El [ejemplo de la aplicación](../../../example/lib/main.dart) tiene sobre todo `StatelessWidget`: `MyApp`, `_Header` o `_Sidebar` solo describen lo que reciben. El [botón](../../../lib/themes/presentation/action/button.dart) es un `StatefulWidget`. Este **fragmento** muestra su reparto:

```dart
class DaisyButton extends StatefulWidget {
  const DaisyButton({ /* ... */ });

  final bool enabled;
  final Widget? child;
  final VoidCallback? onPressed;
  // ...

  @override
  State<DaisyButton> createState() => _DaisyButtonState();
}

class _DaisyButtonState extends State<DaisyButton> {
  bool _isHovering = false;
  bool _isPressed = false;

  // Dentro de build:
  // onHover: (value) { setState(() => _isHovering = value); ... }

  void _setPressed(bool value) {
    if (_isPressed != value) {
      setState(() => _isPressed = value);
    }
  }
}
```

El widget tiene la configuración: `enabled`, `child`, `onPressed`. El `State` tiene lo que cambia durante la interacción: si el ratón está encima y si está pulsado. Fíjate en `_setPressed`: comprueba antes si el valor cambia. No es necesario para que funcione, pero evita solicitar una construcción cuando no hay nada nuevo, ya que `setState` no lo comprueba por ti (apartado 5).

**Antes de mirar los `expect`**, predice la elevación después de que el padre entregue otra descripción:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:daisy_ui/themes/presentation/action/button.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('el botón conserva su estado entre descripciones', (tester) async {
    Widget pantalla(String texto) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        child: Center(
          child: DaisyButton(onPressed: () {}, child: Text(texto)),
        ),
      ),
    );
    Material material() => tester.widget<Material>(
      find
          .descendant(
            of: find.byType(DaisyButton),
            matching: find.byType(Material),
          )
          .first,
    );

    await tester.pumpWidget(pantalla('Uno'));
    expect(material().elevation, 0);

    final raton = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await raton.addPointer(location: Offset.zero);
    await raton.moveTo(tester.getCenter(find.byType(DaisyButton)));
    await tester.pumpAndSettle();
    expect(material().elevation, 4);

    await tester.pumpWidget(pantalla('Dos'));
    await tester.pumpAndSettle();
    expect(find.text('Dos'), findsOneWidget);
    expect(material().elevation, 4);

    await raton.removePointer();
  });
}
```

`createGesture` simula un ratón, y `pumpAndSettle` procesa frames hasta que no quedan pendientes, porque el botón anima su elevación. `DaisyButton` no se exporta en `daisy_ui.dart`, por eso se importa con su ruta, igual que en el ejemplo.

La segunda descripción cambia el texto y crea un `DaisyButton` nuevo, pero en el mismo sitio y con el mismo tipo. El elemento y su `_DaisyButtonState` permanecen, así que `_isHovering` sigue en `true` y la elevación se mantiene en `4`. La prueba comprueba el valor de `elevation` en el `Material`; cómo se anima se estudia en el [plan de animaciones](../../learn_animations/plan-de-estudio-animaciones-flutter.md), no aquí.

Desde el último cambio del ejemplo, ningún botón cambia el tema: `DaisyThemeService.setTheme` ya no se llama desde `main.dart`. Las unidades anteriores describen una versión con `_ThemeExample` y `_ThemePreview`, que puedes consultar con `git show 41fe41f~1:example/lib/main.dart`. Cuando la necesitemos, en las unidades 19 y 25, la reproduciremos en la propia prueba para que sea independiente.

### Practica 9

`_DaisyButtonState` guarda `_isHovering`. Si fuera un campo de `DaisyButton`, ¿qué dos problemas habría?

<details>
<summary>Ver respuesta</summary>

Primero, tendría que ser `final` para que el widget siguiera siendo inmutable, de modo que no se podría cambiar. Segundo, aunque se pudiera, cada descripción nueva crea otro `DaisyButton`, así que el dato se perdería en cuanto el padre entregara otra. El `State` lo conserva precisamente porque permanece mientras cambian las descripciones.

</details>

## Ejercicio final: un panel con tres partes

Escribe una prueba que reúna las ideas de la unidad:

1. Declara un `StatefulWidget` llamado `Panel`, con un parámetro `titulo` y otro `fuente`, de tipo `ValueNotifier<int>`.
2. Su `State` tiene `int local = 0` y un método que lo incrementa con `setState`. Su `build` cuenta sus construcciones y devuelve una `Column` con tres hijos: `Text('$titulo: $local')`, un `ValueListenableBuilder` que muestra `Fuente: $valor` y cuenta sus construcciones, y un `const Fijo()`, un `StatelessWidget` que también las cuenta.
3. Monta el panel y comprueba los tres contadores.
4. Cambia la fuente a `1` y procesa un frame. Asígnale otra vez `1` y procesa otro.
5. Cambia `local` directamente, sin `setState`, y procesa un frame.
6. Llama al método con `setState` y procesa un frame.
7. Entrega desde fuera otro `Panel`, con otro título y la misma fuente.
8. Desmonta el árbol y libera lo que hayas creado.

Predice los tres contadores y los textos tras cada paso antes de abrir la solución. Como variaciones, ¿qué cambia si quitas el `const` de `Fijo()`? ¿Y si en el paso 7 añades una `key` distinta al nuevo `Panel`?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var buildsPanel = 0;
var buildsFuente = 0;
var buildsFijo = 0;

class Fijo extends StatelessWidget {
  const Fijo({super.key});

  @override
  Widget build(BuildContext context) {
    buildsFijo++;
    return const Text('Fijo');
  }
}

class Panel extends StatefulWidget {
  const Panel({super.key, required this.titulo, required this.fuente});

  final String titulo;
  final ValueNotifier<int> fuente;

  @override
  State<Panel> createState() => PanelState();
}

class PanelState extends State<Panel> {
  int local = 0;

  void sumar() => setState(() => local++);

  @override
  Widget build(BuildContext context) {
    buildsPanel++;
    return Column(
      children: [
        Text('${widget.titulo}: $local'),
        ValueListenableBuilder<int>(
          valueListenable: widget.fuente,
          builder: (_, valor, _) {
            buildsFuente++;
            return Text('Fuente: $valor');
          },
        ),
        const Fijo(),
      ],
    );
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('un panel con tres partes', (tester) async {
    final fuente = ValueNotifier<int>(0);
    addTearDown(fuente.dispose);

    await tester.pumpWidget(pantalla(Panel(titulo: 'A', fuente: fuente)));
    final estado = tester.state<PanelState>(find.byType(Panel));
    expect((buildsPanel, buildsFuente, buildsFijo), (1, 1, 1));

    fuente.value = 1;
    await tester.pump();
    expect(find.text('Fuente: 1'), findsOneWidget);
    expect((buildsPanel, buildsFuente, buildsFijo), (1, 2, 1));

    fuente.value = 1;
    await tester.pump();
    expect((buildsPanel, buildsFuente, buildsFijo), (1, 2, 1));

    estado.local++;
    await tester.pump();
    expect(find.text('A: 0'), findsOneWidget);
    expect((buildsPanel, buildsFuente, buildsFijo), (1, 2, 1));

    estado.sumar();
    await tester.pump();
    expect(find.text('A: 2'), findsOneWidget);
    expect((buildsPanel, buildsFuente, buildsFijo), (2, 3, 1));

    await tester.pumpWidget(pantalla(Panel(titulo: 'B', fuente: fuente)));
    expect(find.text('B: 2'), findsOneWidget);
    expect((buildsPanel, buildsFuente, buildsFijo), (3, 4, 1));

    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
  });
}
```

Al montar, los tres se construyen. Cambiar la fuente marca solo el `State` interno del `ValueListenableBuilder`. La segunda asignación es igual y no avisa, de modo que no hay nada que construir.

Cambiar `local` sin `setState` deja el dato en `1` y el texto en `A: 0`. Al llamar a `sumar`, `local` llega a `2` y el `build` del panel se ejecuta: el texto muestra `A: 2`. Ese `build` también crea un `ValueListenableBuilder` nuevo, cuyo callback es otra función, y por eso se ejecuta su `builder` aunque la fuente no haya cambiado. `const Fijo()`, en cambio, es el mismo objeto de antes y Flutter no trabaja en él.

Al entregar otro `Panel`, mismo tipo y sin `key`, el `State` permanece: se conserva `2` y se usa el nuevo título.

Sin `const`, `Fijo()` sería un objeto nuevo en cada `build` del panel: al final del ejercicio `buildsFijo` valdría `3` en lugar de `1`. Y con una `key` distinta en el paso 7, el `State` se descartaría: el texto sería `B: 0` y `estado.mounted` pasaría a `false`, aunque la `fuente` conservaría su valor, porque vive fuera del panel.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué significa que la interfaz de Flutter sea declarativa? **Apartado 1.**
2. ¿Por qué un `StatelessWidget` puede ejecutar `build` varias veces? ¿Cuándo no lo hace aunque se entregue de nuevo? **Apartado 2.**
3. ¿Qué diferencia hay entre un widget y un elemento? ¿Qué decide si un elemento se reutiliza? **Apartado 3.**
4. ¿Qué se guarda en un `StatefulWidget` y qué en su `State`? **Apartado 4.**
5. ¿Qué ocurre en orden al llamar a `setState`, y cuándo se ejecuta `build`? **Apartado 5.**
6. ¿Por qué cambiar un campo del `State` sin `setState` no actualiza el árbol? **Apartado 5.**
7. ¿Por qué dos `setState` seguidos pueden producir una sola construcción? **Apartado 5.**
8. ¿Qué conserva el `State` y qué papel tiene `build`? ¿Qué hace que se pierda un `State`? **Apartado 6.**
9. ¿Cómo puede haber un `build` sin pintura, o una pintura sin `build`? **Apartado 7.**
10. ¿Qué hay dentro de `ValueListenableBuilder`, y qué se marca al recibir un aviso? **Apartado 8.**
11. ¿Por qué `_isHovering` pertenece a `_DaisyButtonState` y `enabled` a `DaisyButton`? **Apartado 9.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y expliques qué conserva `State` y qué papel tiene `build`. La unidad 19 estudia el ciclo de vida: en qué momento conviene crear, actualizar y liberar lo que posee un widget.

## Para consultar si necesitas reforzar

- [`StatefulWidget`](https://api.flutter.dev/flutter/widgets/StatefulWidget-class.html) y [`StatelessWidget`](https://api.flutter.dev/flutter/widgets/StatelessWidget-class.html): el reparto entre widget y estado, y consejos sobre cuánto cuesta construir.
- [`State.setState`](https://api.flutter.dev/flutter/widgets/State/setState.html): qué ocurre con la función y la solicitud.
- [`Widget.canUpdate`](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html): la regla de tipo y `key`.
- [Arquitectura de Flutter](https://docs.flutter.dev/resources/architectural-overview): los árboles de widgets, elementos y objetos de renderizado, y las fases de un frame.
- [`ValueListenableBuilder`](https://api.flutter.dev/flutter/widgets/ValueListenableBuilder-class.html): el constructor que acabamos de abrir.
- [Botón](../../../lib/themes/presentation/action/button.dart) y [ejemplo](../../../example/lib/main.dart): comportamiento actual de DaisyUI.

# 20. `BuildContext` y el árbol de widgets

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) · [Repasar la unidad 19](19-ciclo-de-vida-y-lugar-correcto-para-crear-recursos.md) · **Estado:** pendiente

## Qué vas a aprender

Todo `build` recibe un parámetro `context` y, hasta ahora, lo hemos usado sin explicar: `context.daisyTheme` funciona dentro de un `Builder`, pero este otro código falla, aunque el scope esté escrito justo al lado:

```dart
// Fragmento: dentro del build de un widget.
return DaisyThemeScope(child: Text(context.daisyTheme.name));
```

¿Por qué? ¿Por qué añadir un `Builder` lo arregla, si parece que no aporta nada?

Al terminar podrás situar cada widget como ancestro o descendiente de otros, y explicar qué es un contexto. Podrás señalar qué scope encuentra cada contexto **sin ejecutar el programa**, y corregir una lectura mal ubicada de tres maneras. También entenderás por qué el ejemplo coloca `DaisyThemeScope` por encima de `MaterialApp`.

Los ejemplos completos son pruebas de widgets independientes. Copia **una cada vez** a `test/estudio_contexto_test.dart` y ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_contexto_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar con 7–9 y el ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0; consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Esta unidad trata de **qué se encuentra** al buscar. Cómo esa búsqueda registra una dependencia y provoca actualizaciones se estudia en las unidades 21 y 22.

## 1. El árbol: ancestros y descendientes

Cuando un widget recibe a otro como `child`, se forma una relación de padre e hijo. Al anidarlos, obtenemos un **árbol**:

```text
Marca('raíz')
└── Column
    ├── Marca('a')
    │   └── Marca('a1')
    └── Marca('b')
```

Los **ancestros** de un nodo son los que encuentras subiendo desde él hasta la raíz: los de `a1` son `a`, `Column` y `raíz`. Sus **descendientes** son los que hay por debajo: los de `a` son solo `a1`. Dos nodos con el mismo padre, como `a` y `b`, son **hermanos**: ninguno es ancestro del otro.

Comprobémoslo en un árbol real. `Marca` es un widget propio que apunta su contexto en un mapa, para que la prueba pueda consultarlo después. `visitAncestorElements` recorre los elementos de los ancestros, desde el más cercano, y se detiene cuando la función devuelve `false`. `elemento.widget` es el widget actual de cada uno, y `is` comprueba su tipo (unidad 16).

**Antes de mirar los `expect`**, predice las marcas que encontrará cada contexto:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final contextos = <String, BuildContext>{};

class Marca extends StatelessWidget {
  const Marca(this.nombre, {super.key, this.child = const SizedBox.shrink()});

  final String nombre;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    contextos[nombre] = context;
    return child;
  }
}

List<String> marcasAncestras(BuildContext context) {
  final nombres = <String>[];
  context.visitAncestorElements((elemento) {
    final widget = elemento.widget;
    if (widget is Marca) {
      nombres.add(widget.nombre);
    }
    return true;
  });
  return nombres;
}

void main() {
  testWidgets('los ancestros de cada contexto', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Marca(
          'raíz',
          child: Column(
            children: [
              Marca('a', child: Marca('a1')),
              Marca('b'),
            ],
          ),
        ),
      ),
    );

    expect(marcasAncestras(contextos['a1']!), ['a', 'raíz']);
    expect(marcasAncestras(contextos['a']!), ['raíz']);
    expect(marcasAncestras(contextos['b']!), ['raíz']);
    expect(marcasAncestras(contextos['raíz']!), isEmpty);
  });
}
```

El `!` indica que estamos seguros de que la clave existe; lo estudiaremos en la unidad 23. Fíjate en estos resultados:

1. `a1` encuentra a `a` y a `raíz`, por este orden: de cerca a lejos.
2. `b` **no** encuentra a `a`: los hermanos no son ancestros.
3. Ningún contexto se encuentra a sí mismo. La búsqueda empieza **por su padre**. Este detalle será la clave del apartado 4.

En el código, «estar dentro» significa aparecer como `child` o `children`, pero lo que determina el árbol es **qué devuelve cada `build` cuando se ejecuta**. Por eso hablamos de árbol y no de código anidado. Lo veremos en el apartado 5.

### Practica 1

En el árbol del ejemplo añadimos `Marca('a2')` como hermano de `a1`, dentro de `a`. ¿Qué devuelve `marcasAncestras` para `a2`? ¿Es `a1` ancestro de `a2`? ¿Y `a` descendiente de `raíz`?

<details>
<summary>Ver respuesta</summary>

`['a', 'raíz']`, igual que `a1`. `a1` no es ancestro de `a2`, porque son hermanos. `a` sí es descendiente de `raíz`, y por tanto `raíz` es ancestro de `a`.

</details>

## 2. Un contexto es el elemento visto por un contrato

Decíamos en la unidad 18 que los elementos ocupan los sitios del árbol. **`BuildContext` es la forma en que un widget accede a su propio sitio**. No es una copia ni una caja de datos: el contexto que recibe `build` es el propio elemento, con un tipo declarado que solo expone parte de sus operaciones. Es la idea de contrato de la unidad 3: `Element implements BuildContext`.

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Contador extends StatefulWidget {
  const Contador({super.key});

  @override
  State<Contador> createState() => ContadorState();
}

class ContadorState extends State<Contador> {
  BuildContext? recibido;

  @override
  Widget build(BuildContext context) {
    recibido = context;
    return const SizedBox.shrink();
  }
}

void main() {
  testWidgets('el contexto es el elemento', (tester) async {
    late BuildContext interior;
    late BuildContext exterior;

    await tester.pumpWidget(
      Builder(
        builder: (context) {
          exterior = context;
          return Builder(
            builder: (context) {
              interior = context;
              return const Contador();
            },
          );
        },
      ),
    );

    expect(identical(exterior, interior), isFalse);
    expect(interior.widget, isA<Builder>());

    final elemento = tester.element(find.byType(Contador));
    final estado = tester.state<ContadorState>(find.byType(Contador));
    expect(identical(estado.recibido, elemento), isTrue);
    expect(identical(estado.context, elemento), isTrue);
  });
}
```

`late` promete que asignaremos las variables antes de leerlas (unidad 19). Las comprobaciones muestran:

1. Cada `Builder` recibe **un contexto distinto**, porque cada uno tiene su propio sitio. No existe un único «contexto de la aplicación».
2. El contexto que recibe `build` del `State` es su elemento. El getter `context` de `State` devuelve ese mismo objeto, y por eso los métodos del ciclo de vida también pueden usarlo sin recibirlo como parámetro.

Una analogía: el contexto es **la dirección de tu casa**. Te permite averiguar en qué calle y barrio estás, pero no contiene el barrio. Si dos personas viven en casas distintas, sus direcciones también lo son, aunque compartan el barrio. La analogía se queda corta porque el contexto es además el propio sitio, no solo una descripción de cómo llegar a él.

### Practica 2

¿Tiene sentido guardar un `BuildContext` en una variable global y usarlo desde cualquier widget para leer el tema? ¿Qué scope encontraría?

<details>
<summary>Ver respuesta</summary>

No. Un contexto representa un sitio concreto del árbol, y encuentra los ancestros de ese sitio, no los de quien lo está usando. Encontraría el scope más cercano por encima del widget al que pertenecía ese contexto. Y, además, podría haberse retirado (apartado 8). Cada widget debería usar el suyo.

</details>

## 3. Buscar hacia arriba

Con un contexto se puede preguntar por los ancestros. `findAncestorWidgetOfExactType<T>()` sube desde el padre y devuelve el primero del tipo indicado, o `null` si no lo hay. Es la operación más sencilla de este tipo y nos servirá para razonar antes de estudiar las que registran dependencias.

**Antes de mirar los `expect`**, predice qué devuelve `cercana` en cada contexto:

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final contextos = <String, BuildContext>{};

class Marca extends StatelessWidget {
  const Marca(this.nombre, {super.key, this.child = const SizedBox.shrink()});

  final String nombre;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    contextos[nombre] = context;
    return child;
  }
}

String cercana(String nombre) {
  final marca = contextos[nombre]!.findAncestorWidgetOfExactType<Marca>();
  if (marca == null) {
    return 'ninguna';
  }
  return marca.nombre;
}

void main() {
  testWidgets('buscar el ancestro más cercano', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: Marca(
          'raíz',
          child: Column(
            children: [
              Marca('a', child: Marca('a1')),
              Marca('b'),
            ],
          ),
        ),
      ),
    );

    expect(cercana('a1'), 'a');
    expect(cercana('a'), 'raíz');
    expect(cercana('b'), 'raíz');
    expect(cercana('raíz'), 'ninguna');
  });
}
```

La regla tiene tres partes, y todas las búsquedas de esta unidad la cumplen:

1. **Solo hacia arriba.** `a` no encuentra a `a1`, aunque lo tenga debajo. `b` no encuentra a `a`, porque está en otra rama.
2. **El más cercano.** Desde `a1` hay dos marcas por encima, y el resultado es `a`. La más cercana oculta a las de más arriba.
3. **Por tipo.** Se busca un tipo, no un objeto ni un nombre. No se puede pedir «la marca que se llama `raíz`».

Sustituye mentalmente `Marca` por `DaisyThemeScope` y ya tienes la lógica de `context.daisyTheme`. Por eso un consumidor «encuentra» su tema sin recibirlo por parámetro: busca en sus ancestros.

### Practica 3

Con este árbol, ¿qué devuelve `cercana` para `x`, `y` y `z`?

```text
Marca('p')
└── Column
    ├── Marca('x')
    └── Marca('q')
        └── Marca('y')
            └── Marca('z')
```

<details>
<summary>Ver respuesta</summary>

`x` devuelve `p`: `q` es su hermano, no su ancestro. `y` devuelve `q`, y `z` devuelve `y`: en ambos casos, el más cercano. Saber la respuesta sin ejecutarlo es justo lo que se te pedirá con los scopes.

</details>

## 4. El contexto de quien crea el scope está por encima

Ya podemos resolver el error del principio. En este árbol, `PantallaMal` construye un scope y pretende leerlo:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class PantallaMal extends StatelessWidget {
  const PantallaMal({super.key});

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(child: Text(context.daisyTheme.name));
  }
}

void main() {
  testWidgets('el contexto está por encima del scope', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: PantallaMal(),
      ),
    );

    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect(error.toString(), contains('Coloca DaisyThemeScope'));
  });
}
```

Dibujemos el árbol que se pretendía construir, señalando de quién es `context`:

```text
Directionality
└── PantallaMal          ← context pertenece a este elemento
    └── DaisyThemeScope  ← el scope que queremos encontrar
        └── Text
```

La variable `context` es el **elemento de `PantallaMal`**. El scope es hijo de `PantallaMal`, así que queda por debajo de ese contexto. Por la regla del apartado 3, la búsqueda sube desde `PantallaMal` y no ve lo que tiene debajo. No hay scope entre sus ancestros y salta el error de `DaisyThemeScope.of`.

Hay, además, una cuestión de **tiempo**. Dart evalúa los argumentos antes de llamar a una función. Primero se ejecuta `context.daisyTheme.name`, luego `Text(...)` y solo después `DaisyThemeScope(...)`. En el momento de leer, el scope ni siquiera se ha creado como objeto. La sangría del código sugiere otra cosa, como vimos con las lecturas en la unidad 10:

> Estar **escrito** dentro de un widget no significa estar **situado** debajo de él en el árbol.

### Practica 4

Si `PantallaMal` estuviera dentro de otro `DaisyThemeScope` más arriba, ¿seguiría saltando el error? ¿Qué tema se mostraría?

<details>
<summary>Ver respuesta</summary>

No saltaría el error, porque la búsqueda encontraría el scope exterior. Se mostraría el tema de ese scope exterior, no el del scope que `PantallaMal` acaba de crear. Es un fallo más difícil de detectar: el programa funciona, pero con otro tema. Lo comprobaremos en el apartado 6.

</details>

## 5. Tres formas de leer desde abajo

Para leer un scope hace falta un contexto **situado por debajo de él**. Solo hay que crear un widget más en esa posición y usar su contexto. Veamos tres formas de hacerlo:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// 1. Un widget propio: su build recibe su contexto.
class NombreDelTema extends StatelessWidget {
  const NombreDelTema({super.key});

  @override
  Widget build(BuildContext context) => Text(context.daisyTheme.name);
}

class ConWidgetPropio extends StatelessWidget {
  const ConWidgetPropio({super.key});

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(child: const NombreDelTema());
  }
}

// 2. Un Builder: lo mismo, sin escribir una clase.
class ConBuilder extends StatelessWidget {
  const ConBuilder({super.key});

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      child: Builder(builder: (context) => Text(context.daisyTheme.name)),
    );
  }
}

// 3. Colocar el scope más arriba, fuera de este widget.
class SinScopePropio extends StatelessWidget {
  const SinScopePropio({super.key});

  @override
  Widget build(BuildContext context) => Text(context.daisyTheme.name);
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('tres formas de leer desde abajo', (tester) async {
    await tester.pumpWidget(pantalla(const ConWidgetPropio()));
    expect(find.text('Light'), findsOneWidget);

    await tester.pumpWidget(pantalla(const ConBuilder()));
    expect(find.text('Light'), findsOneWidget);

    await tester.pumpWidget(
      pantalla(DaisyThemeScope(child: const SinScopePropio())),
    );
    expect(find.text('Light'), findsOneWidget);
  });
}
```

`Builder` puede parecer especial, pero este es **todo su código en Flutter**, sin los comentarios:

```dart
// Fragmento del código de Flutter.
class Builder extends StatelessWidget {
  const Builder({super.key, required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) => builder(context);
}
```

Es un `StatelessWidget` que le pasa su propio contexto a la función. Aporta dos cosas: **un elemento nuevo en esa posición** y **un momento posterior**. Su callback se ejecuta cuando Flutter construye el `Builder`, es decir, una vez que el scope ya está en el árbol. Como ves, la función no se ejecuta donde se escribe; se ejecuta cuando llega su turno, igual que en la unidad 2.

Así queda el árbol de la versión 2:

```text
ConBuilder               ← context exterior
└── DaisyThemeScope
    └── Builder          ← context del callback: su ancestro incluye el scope
        └── Text
```

¿Cuándo usar cada forma? `Builder` va bien para lecturas pequeñas y puntuales. Un widget propio es preferible si esa parte tiene entidad, ya que además le da nombre y permite usar `const`. Colocar el scope más arriba es adecuado si varias pantallas lo necesitan.

### Practica 5

Con la forma 1, `NombreDelTema` pasa a recibir el nombre por parámetro, y `ConWidgetPropio.build` lo lee y se lo entrega. ¿Sigue funcionando? ¿Por qué?

<details>
<summary>Ver respuesta</summary>

No: la lectura vuelve al contexto de `ConWidgetPropio`, que está por encima del scope, y salta el mismo error. Además, ya no podría ser `const`, porque el valor no se conoce al compilar. Lo decisivo es de quién es el contexto con el que se lee, no el nombre del widget que muestra el resultado.

</details>

## 6. El error que no lanza ningún error

Hay un error todavía más sutil. Si llamas `_` al parámetro del callback, porque crees que no lo necesitas, `context` sigue refiriéndose al contexto exterior. En el apartado 5, escribir `builder: (context)` **oculta** la variable exterior con otra del mismo nombre, y ese detalle es lo que hace que funcione.

**Antes de mirar los `expect`**, predice qué nombre muestra cada línea. El árbol tiene un scope exterior y otro interior:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Interior extends StatelessWidget {
  const Interior({super.key, required this.controller});

  final DaisyThemeController controller;

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      controller: controller,
      child: Column(
        children: [
          Builder(builder: (_) => Text('Con _: ${context.daisyTheme.name}')),
          Builder(
            builder: (context) => Text('Con context: ${context.daisyTheme.name}'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('el contexto equivocado encuentra otro scope', (tester) async {
    final exterior = DaisyThemeController();
    final interior = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(exterior.dispose);
    addTearDown(interior.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: exterior,
          child: Interior(controller: interior),
        ),
      ),
    );

    expect(find.text('Con _: Light'), findsOneWidget);
    expect(find.text('Con context: Cupcake'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Las dos líneas están escritas **dentro** del mismo scope, y las dos compilan y se ejecutan sin errores. Pero:

1. `(_) => ...context...` usa el `context` capturado de `Interior.build` (una closure, unidad 2). Ese contexto está por encima del scope interior, así que encuentra al exterior: `Light`.
2. `(context) => ...context...` usa el parámetro del callback, el contexto del propio `Builder`. Encuentra el scope interior: `Cupcake`.

Es el mismo problema que en el apartado 4, pero ahora hay otro scope por encima que responde. Fíjate también en que este error afecta a la reactividad: el primer `Builder` no se actualizaría si cambia el tema interior.

Cuando leas código, sigue este procedimiento: **localiza qué variable es `context` en esa línea**, y a quién pertenece. Después, sube desde ahí por el árbol. El ejemplo actual lo hace con `LayoutBuilder(builder: (context, constraints) { ... })`, cuyo parámetro también oculta al exterior.

### Practica 6

En este **fragmento**, ¿a qué elemento pertenece el `context` del `Text` y qué scope encuentra?

```dart
Widget build(BuildContext context) {
  return DaisyThemeScope(
    controller: previa,
    child: Builder(
      builder: (contextoInterno) => Text(context.daisyTheme.name),
    ),
  );
}
```

<details>
<summary>Ver respuesta</summary>

`context` pertenece al widget cuyo `build` estamos viendo, porque el parámetro del callback se llama `contextoInterno` y no se usa. Encuentra el scope que haya **por encima** de ese widget, o lanza el error si no lo hay. `previa` queda por debajo. Para corregirlo, hay que escribir `contextoInterno.daisyTheme.name`.

</details>

## 7. Por qué el scope va por encima de `MaterialApp`

Las pantallas nuevas de una aplicación también dependen del árbol. `Navigator.of(context).push(...)` abre una **ruta**, y esta no se coloca debajo de quien la abrió, sino como hija del `Navigator`, que crea `MaterialApp`:

```text
MaterialApp
└── Navigator
    ├── ruta 1: home
    └── ruta 2: la pantalla que acabamos de abrir
```

Las rutas son **hermanas**. Con esto ya deberías poder predecir qué ocurre según la posición del scope. **Antes de mirar los `expect`**, predice qué ocurre al abrir la segunda ruta en cada prueba:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class BotonAbrir extends StatelessWidget {
  const BotonAbrir({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => Text('Ruta: ${context.daisyTheme.name}'),
        ),
      ),
      child: Text('Abrir: ${context.daisyTheme.name}'),
    );
  }
}

void main() {
  testWidgets('scope por encima de MaterialApp', (tester) async {
    await tester.pumpWidget(
      DaisyThemeScope(child: const MaterialApp(home: BotonAbrir())),
    );

    await tester.tap(find.text('Abrir: Light'));
    await tester.pumpAndSettle();
    expect(find.text('Ruta: Light'), findsOneWidget);
  });

  testWidgets('scope dentro de home', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: DaisyThemeScope(child: const BotonAbrir())),
    );
    expect(find.text('Abrir: Light'), findsOneWidget);

    await tester.tap(find.text('Abrir: Light'));
    await tester.pump();
    expect(tester.takeException(), isA<FlutterError>());
  });
}
```

Paso a paso:

1. En la primera prueba, el scope es ancestro de `MaterialApp` y, por tanto, de su `Navigator` y de todas las rutas. Cualquier ruta lo encuentra.
2. En la segunda, el scope solo es ancestro de la primera ruta. La ruta nueva es su **hermana**: al subir desde ella, pasa por el `Navigator` y por `MaterialApp`, sin llegar a ningún scope. Salta el error.

La segunda ruta se abre correctamente desde el botón, y el fallo aparece al construirla: `Navigator.of(context)` es otra búsqueda por el árbol, con el mismo patrón que estudiaremos en la unidad 23. Ese botón funciona porque su contexto está por debajo de `MaterialApp`. Desde el `build` del widget que **crea** `MaterialApp`, `Navigator.of(context)` fallaría, por el mismo motivo que en el apartado 4.

### Practica 7

Una aplicación tiene `MaterialApp` con `home: PantallaPrincipal()`, y esta contiene un scope con un controlador propio. Al abrir una pantalla de detalle desde ahí, queremos que use ese mismo tema. ¿Bastaría con mover el scope a `MaterialApp`? ¿Hay otra opción si solo la pantalla de detalle debe compartirlo?

<details>
<summary>Ver respuesta</summary>

Moverlo por encima de `MaterialApp` funcionaría, pero entonces todas las rutas compartirían ese tema. Si solo queremos ese detalle, el constructor de la ruta puede envolver su contenido en otro `DaisyThemeScope` con **el mismo controlador**, que se pasa como referencia: `builder: (_) => DaisyThemeScope(controller: controller, child: const Detalle())`. Los scopes distintos comparten el estado si comparten la instancia. Lo veremos en la unidad 25.

</details>

## 8. Un contexto puede dejar de ser válido

Como el contexto es un sitio del árbol, tiene la misma vida que su elemento. Veamos qué le ocurre al que guardamos en una variable:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('un contexto guardado', (tester) async {
    final controller = DaisyThemeController();
    addTearDown(controller.dispose);
    late BuildContext guardado;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: controller,
          child: Builder(
            builder: (context) {
              guardado = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(guardado.mounted, isTrue);
    expect(guardado.daisyTheme.name, 'Light');

    controller.setTheme(DaisyThemes.dark);
    expect(guardado.daisyTheme.name, 'Dark');

    await tester.pumpWidget(const SizedBox.shrink());
    expect(guardado.mounted, isFalse);
    expect(() => guardado.daisyTheme, throwsFlutterError);
  });
}
```

Observa dos cosas:

1. La misma variable da `Light` y después `Dark`. El contexto no guarda el tema: cada lectura **consulta** el valor actual. Esta idea es central en la unidad 24.
2. Después de desmontar, `mounted` es `false` y buscar desde ese contexto lanza un error, porque ya no tiene ancestros que recorrer. Esto es como el `mounted` de `State` que vimos en la unidad 19: conviene comprobarlo con `if (!context.mounted) return;` si un `await` separa el momento de obtenerlo del de usarlo.

### Practica 8

Una función guarda `final tema = context.daisyTheme;`, hace un `await` y luego usa `tema`. Otra guarda `context` y, después del `await`, lee `context.daisyTheme`. ¿Cuál puede usar un valor obsoleto? ¿Cuál puede lanzar un error?

<details>
<summary>Ver respuesta</summary>

La primera puede usar un valor obsoleto: `tema` es una lectura puntual y el tema puede cambiar durante la espera. La segunda obtiene el valor actual, pero puede lanzar un error si el widget se desmontó mientras tanto. Por eso debe comprobar `context.mounted` antes de leer.

</details>

## 9. El árbol real del ejemplo

Este es el árbol del [ejemplo actual](../../../example/lib/main.dart), reducido a lo que nos interesa. Indicamos de quién es cada contexto y qué widget lee el tema:

```text
MyApp                       ← context de MyApp: sin scope por encima
└── DaisyThemeScope         ← sin controller: usa el servicio
    └── MaterialApp
        └── Navigator
            └── _ButtonExample
                └── Scaffold
                    └── Column
                        ├── _Header
                        └── LayoutBuilder
                            └── Row
                                ├── _Sidebar (si cabe)
                                └── _ButtonContent           ← lee context.daisyTheme
                                    └── ... DaisyButton      ← su State también lo lee
```

Dos lecturas reales. La primera está en `_ButtonContent`, dentro de `build`, para el radio del `Ink`. Este es el **fragmento**:

```dart
borderRadius: BorderRadius.circular(
  context.daisyTheme.radius.fields.toDouble(),
),
```

La segunda, en `_DaisyButtonState.build`, que usa su propio contexto para calcular la forma:

```dart
final th = context.daisyTheme;
```

Ambas suben por el árbol y encuentran el mismo scope, porque ninguna tiene otro más cercano. También se ve el motivo de la posición de `DaisyThemeScope`: está por encima de `MaterialApp`, por lo que todas las rutas lo encuentran. `MyApp` no podría leer `context.daisyTheme` en su propio `build`, porque el scope es su hijo.

### Practica 9

Sin ejecutar nada: si envolvemos solo `_ButtonContent` en un `DaisyThemeScope` con un controlador propio, ¿qué scope encuentra `_ButtonContent`? ¿Y el `State` del botón? ¿Y `_Header`?

<details>
<summary>Ver respuesta</summary>

`_ButtonContent` y el `State` del botón encuentran el nuevo scope, porque está en sus ancestros y es el más cercano. `_Header` está en otra rama y sigue encontrando el del servicio.

</details>

## Ejercicio final: el tablero con dos scopes

Partimos de este widget, con los errores incluidos:

```dart
// Fragmento: dentro del build de Tablero.
return Column(
  children: [
    Text('Fuera: ${context.daisyTheme.name}'),
    DaisyThemeScope(
      controller: interior,
      child: Text('Dentro: ${context.daisyTheme.name}'),
    ),
  ],
);
```

Queremos que `Dentro` muestre el tema de `interior`. Escribe una prueba que:

1. Monte `Tablero` debajo de `DaisyThemeScope(controller: exterior, ...)`. Antes de ejecutarla, dibuja el árbol, marca de quién es `context` y predice los dos textos.
2. Corrija el widget para que `Dentro` use el scope interior, y compruebe de nuevo los textos.
3. Cambie `interior` a `dark` y procese un frame. Prediga los dos textos.
4. Cambie `exterior` a `cupcake` y procese un frame. Prediga los dos textos.
5. Monte `Tablero` **sin** scope exterior y compruebe qué ocurre.

Como variaciones: ¿qué pasaría si el callback del `Builder` se escribiera con `(_)`? Si `Tablero` tuviera otro `Text` *debajo* del scope interior pero en otro `Builder`, ¿qué tema vería?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TableroMal extends StatelessWidget {
  const TableroMal({super.key, required this.interior});

  final DaisyThemeController interior;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Fuera: ${context.daisyTheme.name}'),
        DaisyThemeScope(
          controller: interior,
          child: Text('Dentro: ${context.daisyTheme.name}'),
        ),
      ],
    );
  }
}

class Tablero extends StatelessWidget {
  const Tablero({super.key, required this.interior});

  final DaisyThemeController interior;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Fuera: ${context.daisyTheme.name}'),
        DaisyThemeScope(
          controller: interior,
          child: Builder(
            builder: (context) => Text('Dentro: ${context.daisyTheme.name}'),
          ),
        ),
      ],
    );
  }
}

void main() {
  testWidgets('el tablero con dos scopes', (tester) async {
    final exterior = DaisyThemeController();
    final interior = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(exterior.dispose);
    addTearDown(interior.dispose);

    Widget conExterior(Widget hijo) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(controller: exterior, child: hijo),
    );

    await tester.pumpWidget(conExterior(TableroMal(interior: interior)));
    expect(find.text('Fuera: Light'), findsOneWidget);
    expect(find.text('Dentro: Light'), findsOneWidget);

    await tester.pumpWidget(conExterior(Tablero(interior: interior)));
    expect(find.text('Fuera: Light'), findsOneWidget);
    expect(find.text('Dentro: Cupcake'), findsOneWidget);

    interior.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Fuera: Light'), findsOneWidget);
    expect(find.text('Dentro: Dark'), findsOneWidget);

    exterior.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(find.text('Fuera: Cupcake'), findsOneWidget);
    expect(find.text('Dentro: Dark'), findsOneWidget);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Tablero(interior: interior),
      ),
    );
    expect(tester.takeException(), isA<FlutterError>());

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El árbol de partida es:

```text
DaisyThemeScope (exterior)
└── Tablero                     ← context
    └── Column
        ├── Text('Fuera...')
        └── DaisyThemeScope (interior)
            └── Text('Dentro...')
```

Las dos lecturas usan el `context` de `Tablero`, de modo que ambas encuentran `exterior`. No hay ningún error, pero `Dentro` muestra `Light`: es el error silencioso del apartado 6. Al corregirlo con `Builder`, la lectura se hace desde un contexto bajo el scope interior y muestra `Cupcake`.

Cambiar `interior` solo afecta a `Dentro`, y cambiar `exterior` solo a `Fuera`: cada lectura está conectada con el scope que encontró. Sin scope exterior, `Fuera` lanza el error: el contexto de `Tablero` no tiene ninguno encima. `Dentro` funcionaría, pero no se llega a construir, porque el `build` de `Tablero` falla antes.

Con `(_)`, el callback usaría el `context` de `Tablero`, y volvería al resultado de `TableroMal`, con la diferencia de que la lectura ocurre más tarde. Cualquier otro `Builder` bajo el scope interior, con su propio parámetro, vería `interior`.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué son los ancestros, los descendientes y los hermanos? ¿Un contexto se encuentra a sí mismo? **Apartado 1.**
2. ¿Qué es exactamente un `BuildContext`? ¿Cuántos hay en una pantalla? **Apartado 2.**
3. ¿Qué tres reglas sigue una búsqueda hacia arriba? **Apartado 3.**
4. ¿Por qué `DaisyThemeScope(child: Text(context.daisyTheme.name))` falla o lee otro scope? **Apartados 4 y 6.**
5. ¿Qué aporta exactamente un `Builder`? ¿Qué otras dos formas hay de resolver el error? **Apartado 5.**
6. ¿Qué cambia entre `Builder(builder: (_) => ...)` y `Builder(builder: (context) => ...)`? **Apartado 6.**
7. ¿Por qué el ejemplo coloca el scope por encima de `MaterialApp`? **Apartado 7.**
8. ¿Qué ocurre con un contexto guardado cuando se desmonta su widget? **Apartado 8.**
9. En el árbol del ejemplo, ¿qué scope encuentran `_ButtonContent` y `_DaisyButtonState`? **Apartado 9.**

Puedes dar la unidad por comprendida cuando, ante un árbol nuevo, señales sin ejecutarlo qué scope encuentra cada contexto. La unidad 21 estudia `InheritedWidget`: qué diferencia hay entre encontrar un dato y registrar que dependes de él.

## Para consultar si necesitas reforzar

- [`BuildContext`](https://api.flutter.dev/flutter/widgets/BuildContext-class.html): operaciones disponibles y cuándo es seguro usarlas.
- [`Builder`](https://api.flutter.dev/flutter/widgets/Builder-class.html): cuándo hace falta y un ejemplo con `Scaffold.of`.
- [`findAncestorWidgetOfExactType`](https://api.flutter.dev/flutter/widgets/BuildContext/findAncestorWidgetOfExactType.html): búsqueda de ancestros sin dependencia.
- [`Navigator`](https://api.flutter.dev/flutter/widgets/Navigator-class.html): cómo se organizan las rutas.
- [Scope](../../../lib/themes/application/daisy_theme_scope.dart), [ejemplo](../../../example/lib/main.dart) y [botón](../../../lib/themes/presentation/action/button.dart): comportamiento actual de DaisyUI.

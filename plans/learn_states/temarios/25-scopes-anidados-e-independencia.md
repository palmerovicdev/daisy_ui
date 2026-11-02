# 25. Scopes anidados e independencia

[Volver al plan de estudio](../plan-de-estudio-reactividad-daisy-ui.md) ·
[Repasar la unidad 24](24-extensiones-y-context-daisy-theme.md) · **Estado:** pendiente

## Qué vas a aprender

Una aplicación tiene un tema general y una vista previa que prueba otro tema. Las dos se muestran a la vez. ¿Qué se
actualiza cuando cambias cada una? ¿Y si las dos comparten controlador? ¿Y si se cambia de controlador sobre la marcha,
o se cierra la vista previa? ¿Quién libera qué?

Esta unidad no presenta mecanismos nuevos, sino que junta todo lo del Bloque 5 en un mismo escenario. Al terminar podrás
predecir qué consumidores se actualizan en cada caso y quién conserva la responsabilidad de liberar cada controlador.
También sabrás por qué el aislamiento entre scopes depende de dónde coloques `const`, y qué se pierde al añadir un scope
a un árbol que ya está montado.

Los ejemplos completos son pruebas de widgets independientes. Copia **una cada vez** a `test/estudio_scopes_test.dart` y
ejecuta desde la raíz del proyecto:

```shell
flutter test --no-pub test/estudio_scopes_test.dart
```

Necesitas las dependencias ya resueltas. Predice cada resultado antes de mirarlo. Los fragmentos identificados como
tales no son archivos completos. Puedes estudiar los apartados 1–3 en una sesión, 4–6 en otra y terminar con 7–8 y el
ejercicio final.

Los ejemplos se contrastaron con Flutter 3.47.8, `signals_flutter` 7.1.0, `signals_core` 7.0.0 y `preact_signals` 7.0.0;
consulta [pubspec.lock](../../../pubspec.lock) para las versiones resueltas. Las pruebas que usan el servicio global lo
restablecen con `setUp` y `tearDown`, como explicó la unidad 17.

## 1. Alcance y scope más cercano

El **alcance** de un scope es su subárbol: todo lo que hay debajo de él y nada más. Cuando dos alcances se solapan, cada
consumidor se queda con el más cercano (unidades 20 y 23).

```text
DaisyThemeScope (global: exterior)
└── Column
    ├── Lector('fuera')
    └── DaisyThemeScope (preview: interior)
        └── Column
            ├── Lector('dentro 1')
            └── Lector('dentro 2')
```

**Antes de mirar los `expect`**, predice qué muestra cada lector:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Lector extends StatelessWidget {
  const Lector(this.etiqueta, {super.key});

  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    return Text('$etiqueta: ${context.daisyTheme.name}');
  }
}

void main() {
  testWidgets('cada lector encuentra el scope más cercano', (tester) async {
    final global = DaisyThemeController();
    final preview = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(global.dispose);
    addTearDown(preview.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          controller: global,
          child: Column(
            children: [
              const Lector('fuera'),
              DaisyThemeScope(
                controller: preview,
                child: const Column(
                  children: [Lector('dentro 1'), Lector('dentro 2')],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('fuera: Light'), findsOneWidget);
    expect(find.text('dentro 1: Cupcake'), findsOneWidget);
    expect(find.text('dentro 2: Cupcake'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El scope interior **oculta** al exterior para los lectores de su subárbol. Ninguno de ellos puede llegar a `global` con
`context.daisyTheme`: no hay forma de decir «el scope de más arriba». Si un widget de la vista previa necesita el tema
general, debe recibirlo de otro modo, por ejemplo con una lectura situada por encima del scope interior que se pase por
parámetro.

### Practica 1

Mueve `Lector('dentro 2')` para que quede a continuación del scope interior, como hermano suyo. ¿Qué muestra? ¿Y si se
añade un tercer scope, con `cupcake`, solo alrededor de `dentro 1`?

<details>
<summary>Ver respuesta</summary>

`dentro 2` pasa a mostrar `Light`: el scope interior ya no está entre sus ancestros. Con el tercer scope, `dentro 1` lo
encuentra primero: muestra `Cupcake`, pero de otro controlador, aunque el nombre sea el mismo. Igual valor no significa
misma fuente (unidad 17).

</details>

## 2. Controladores independientes: se actualiza cada uno

Dos controladores distintos significan dos señales, dos adaptadores y dos elementos de scope, cada uno con su lista de
dependientes. Cada cadena de la unidad 22 funciona por separado.

**Antes de mirar los `expect`**, predice las construcciones después de cada cambio:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final builds = <String, int>{};

class Lector extends StatelessWidget {
  const Lector(this.etiqueta, {super.key});

  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    builds[etiqueta] = (builds[etiqueta] ?? 0) + 1;
    return Text('$etiqueta: ${context.daisyTheme.name}');
  }
}

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('cambiar por separado', (tester) async {
    final preview = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    addTearDown(preview.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(
          child: Column(
            children: [
              const Lector('global'),
              DaisyThemeScope(
                controller: preview,
                child: const Lector('preview'),
              ),
            ],
          ),
        ),
      ),
    );
    expect(builds, {'global': 1, 'preview': 1});

    DaisyThemeService.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('global: Dark'), findsOneWidget);
    expect(find.text('preview: Cupcake'), findsOneWidget);
    expect(builds, {'global': 2, 'preview': 1});

    preview.setTheme(DaisyThemes.light);
    await tester.pump();
    expect(find.text('global: Dark'), findsOneWidget);
    expect(find.text('preview: Light'), findsOneWidget);
    expect(builds, {'global': 2, 'preview': 2});

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Fíjate en dos cosas. El scope interior es **descendiente** del exterior, y aun así el cambio global no le afecta: el
elemento del scope interior no leyó el exterior, de modo que no es un dependiente. Y como el `child` del exterior es el
mismo objeto, el aviso no baja por el árbol (unidad 22).

Esta es la prueba `Nested scopes update only their own theme consumers` de
[las pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart), reducida. La del proyecto tiene tres niveles
y `builds` también comprueba cada cambio. Merece la pena que la leas: ya conoces todas sus piezas.

### Practica 2

Sin ejecutarla, lee en esa prueba del proyecto la cadena `global → preview → nested`. Tras
`nested.setTheme(DaisyThemes.dark)`, ¿por qué `builds` no cambia para `global` y `preview`, si `nested` está dentro de
ambos?

<details>
<summary>Ver respuesta</summary>

Porque el aviso sale de la señal de `nested`, llega al elemento de su scope, y este marca solo a sus dependientes: el
consumidor `nested`. El árbol no transmite avisos hacia arriba ni hacia los lados. `global` y `preview` están
registrados en elementos diferentes.

</details>

## 3. El aislamiento depende del árbol: `const` importa

En las pruebas anteriores nadie reconstruía el árbol. Pero en una aplicación normal, un consumidor del tema global suele
**contener** la vista previa. En ese caso, ¿sigue estando aislada?

**Antes de mirar los `expect`**, predice cuántas veces se construye el lector de la vista previa en cada versión. La
única diferencia es un `const`:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var buildsPreview = 0;

class VistaPrevia extends StatefulWidget {
  const VistaPrevia({super.key});

  @override
  State<VistaPrevia> createState() => _VistaPreviaState();
}

class _VistaPreviaState extends State<VistaPrevia> {
  late final DaisyThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      controller: _controller,
      child: Builder(
        builder: (context) {
          buildsPreview++;
          return Text('Preview: ${context.daisyTheme.name}');
        },
      ),
    );
  }
}

class PantallaConConst extends StatelessWidget {
  const PantallaConConst({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('App: ${context.daisyTheme.name}'),
        const VistaPrevia(),
      ],
    );
  }
}

class PantallaSinConst extends StatelessWidget {
  const PantallaSinConst({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('App: ${context.daisyTheme.name}'),
        // ignore: prefer_const_constructors
        VistaPrevia(),
      ],
    );
  }
}

void main() {
  setUp(() {
    DaisyThemeService.setTheme(DaisyThemes.light);
    buildsPreview = 0;
  });
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  Widget app(Widget pantalla) => Directionality(
    textDirection: TextDirection.ltr,
    child: DaisyThemeScope(child: pantalla),
  );

  testWidgets('con const, la vista previa no se toca', (tester) async {
    await tester.pumpWidget(app(const PantallaConConst()));
    expect(buildsPreview, 1);

    DaisyThemeService.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('App: Dark'), findsOneWidget);
    expect(find.text('Preview: Cupcake'), findsOneWidget);
    expect(buildsPreview, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sin const, se reconstruye sin motivo', (tester) async {
    await tester.pumpWidget(app(const PantallaSinConst()));
    expect(buildsPreview, 1);

    DaisyThemeService.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('App: Dark'), findsOneWidget);
    expect(find.text('Preview: Cupcake'), findsOneWidget);
    expect(buildsPreview, 2);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

El texto es correcto en las dos versiones, pero el trabajo no es el mismo. Sigamos la segunda:

1. `PantallaSinConst` depende del tema global, así que se reconstruye.
2. Su `build` crea un `VistaPrevia` **nuevo** (unidad 18). El `State` se conserva, pero Flutter ejecuta su `build`.
3. Ese `build` crea un `DaisyThemeScope` nuevo y un `Builder` nuevo, con otro callback. El scope recibe el mismo
   notifier, y no se notifica nada (unidad 22).
4. Pero el `Builder` es un objeto nuevo: se reconstruye porque el padre lo ha entregado, no porque el tema de la vista
   previa haya cambiado.

Con `const VistaPrevia()`, el paso 2 se detiene: es el mismo objeto de antes. Es lo que hacía el ejemplo anterior con
`const _ThemePreview()`.

**El aislamiento de los datos está garantizado por los controladores. El aislamiento de las reconstrucciones depende
además de cómo se escribe el árbol.** Aquí una construcción de más no es un error; el resultado es correcto, solo hay
trabajo extra. Pero conviene distinguirlas cuando estudies por qué se reconstruye algo.

### Practica 3

Si `VistaPrevia` recibiera un parámetro no constante, como `VistaPrevia(titulo: tema.name)`, no se podría usar `const`.
¿Qué harías para evitar reconstruir su contenido?

<details>
<summary>Ver respuesta</summary>

Se reconstruirá su `build` cuando cambie ese parámetro, y es lógico: ha cambiado. Para no reconstruir el contenido que
no depende de él, se puede separar en un widget propio que sí sea `const`, o mantenerlo en un campo. Es la misma técnica
del `child` por parámetro de la unidad 21. Lo importante es saber qué causa cada reconstrucción, no eliminarlas todas.

</details>

## 4. Compartir una instancia

¿Qué cambia si dos scopes reciben **el mismo** controlador? **Antes de mirar los `expect`**, predice los textos y las
construcciones de los tres lectores:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

final builds = <String, int>{};

class Lector extends StatelessWidget {
  const Lector(this.etiqueta, {super.key});

  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    builds[etiqueta] = (builds[etiqueta] ?? 0) + 1;
    return Text('$etiqueta: ${context.daisyTheme.name}');
  }
}

void main() {
  testWidgets('dos scopes con la misma instancia', (tester) async {
    final compartido = DaisyThemeController();
    final otro = DaisyThemeController();
    addTearDown(compartido.dispose);
    addTearDown(otro.dispose);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Column(
          children: [
            DaisyThemeScope(controller: compartido, child: const Lector('a')),
            DaisyThemeScope(controller: compartido, child: const Lector('b')),
            DaisyThemeScope(controller: otro, child: const Lector('c')),
          ],
        ),
      ),
    );
    expect(builds, {'a': 1, 'b': 1, 'c': 1});

    compartido.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('a: Dark'), findsOneWidget);
    expect(find.text('b: Dark'), findsOneWidget);
    expect(find.text('c: Light'), findsOneWidget);
    expect(builds, {'a': 2, 'b': 2, 'c': 1});

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Cuéntalo por objetos:

| Objeto                            | Cuántos hay | Comentario                                                  |
|-----------------------------------|-------------|-------------------------------------------------------------|
| Controladores `compartido`        | 1           | Una señal y un adaptador                                    |
| Widgets y elementos de scope      | 2           | Uno por cada `DaisyThemeScope` escrito                      |
| Listeners en la señal             | 2           | Cada elemento registra su propio `_handleUpdate`            |
| Listas de dependientes            | 2           | Cada una tiene un lector                                    |

Un solo `setTheme` provoca dos avisos que llegan a dos elementos, y cada uno marca a su lector. Así es como dos zonas
alejadas pueden compartir un tema sin que este sea global: el `c` queda fuera. Es la opción (c) de la práctica 8 de la
unidad 17.

¿Quién libera `compartido`? **Su propietario, una sola vez**. Ninguno de los dos scopes lo hace.

### Practica 4

Los dos scopes con `compartido` se anidan:
`DaisyThemeScope(controller: compartido, child: DaisyThemeScope(controller: compartido, child: Lector('x')))`. ¿En
cuántos elementos se registra el lector? ¿Cuántas construcciones provoca un `setTheme`?

<details>
<summary>Ver respuesta</summary>

Se registra en uno, el más cercano. El exterior también escucha la señal y procesa su aviso, pero no tiene dependientes.
Por eso solo hay una construcción. Este anidamiento no es útil, pero no es incorrecto.

</details>

## 5. Sustituir un controlador

Ahora el mismo sitio del árbol recibe otro controlador. Este caso ya lo vimos para `InheritedNotifier` en la unidad 22,
y aquí lo aplicamos al scope real. La propiedad de ambos es de la prueba.

**Antes de mirar los `expect`**, predice si el lector se reconstruye en cada paso:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

var builds = 0;

class Lector extends StatelessWidget {
  const Lector({super.key});

  @override
  Widget build(BuildContext context) {
    builds++;
    return Text(context.daisyTheme.name);
  }
}

void main() {
  testWidgets('sustituir y liberar el anterior', (tester) async {
    final primero = DaisyThemeController();
    final segundo = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(segundo.dispose);
    const hijo = Lector();

    Widget arbol(DaisyThemeController controller) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(controller: controller, child: hijo),
    );

    await tester.pumpWidget(arbol(primero));
    expect(find.text('Light'), findsOneWidget);
    expect(builds, 1);

    await tester.pumpWidget(arbol(primero));
    expect(builds, 1);

    await tester.pumpWidget(arbol(segundo));
    expect(find.text('Dark'), findsOneWidget);
    expect(builds, 2);

    primero.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(builds, 2);

    primero.dispose();

    segundo.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(find.text('Cupcake'), findsOneWidget);
    expect(builds, 3);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

Paso a paso:

1. **El mismo controlador otra vez.** `primero.theme` devuelve el mismo adaptador (unidad 16), de modo que el scope no
   cambia su listener ni avisa.
2. **Otro controlador.** El elemento del scope permanece, y traslada `_handleUpdate` al adaptador de `segundo`. El
   lector sigue en la lista de dependientes y recibe el aviso: **la dependencia es con el sitio del scope, no con el
   controlador.**
3. **El anterior queda libre.** El scope ya no lo usa, así que su propietario puede liberarlo. Es lo que hace
   `primero.dispose()`. Después, todo sigue funcionando con `segundo`.

La prueba `Replacing a controller detaches the previous notifier` del proyecto comprueba lo mismo. En ambos casos, el
scope nunca libera.

### Y si se libera antes de tiempo

¿Qué pasa si el propietario libera un controlador que un scope sigue usando? **No hay un error inmediato**, y eso es lo
peligroso:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class Lector extends StatefulWidget {
  const Lector({super.key});

  @override
  State<Lector> createState() => LectorState();
}

class LectorState extends State<Lector> {
  void refrescar() => setState(() {});

  @override
  Widget build(BuildContext context) => Text(context.daisyTheme.name);
}

void main() {
  testWidgets('liberar con el scope todavía montado', (tester) async {
    final controller = DaisyThemeController();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(controller: controller, child: const Lector()),
      ),
    );

    controller.dispose();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Light'), findsOneWidget);

    tester.state<LectorState>(find.byType(Lector)).refrescar();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('Light'), findsOneWidget);

    expect(
      () => controller.setTheme(DaisyThemes.dark),
      throwsA(isA<SignalsWriteAfterDisposeError>()),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

La lectura sigue devolviendo el último valor y `signals` escribe en la consola un aviso: `has been read after disposed`.
La pantalla parece correcta, pero **el tema ya no puede cambiar**, y la siguiente escritura lanza un error. Si en una
aplicación ves ese aviso, busca un propietario que libera demasiado pronto.

El orden correcto se obtiene de la unidad 19: si el propietario está por encima del scope, cuando recibe `dispose`, el
scope ya se ha retirado.

### Practica 5

Un `State` tiene `_controller` y, en un método, hace
`_controller.dispose(); _controller = DaisyThemeController(); setState(() {});`. El campo no es `final`. ¿Hay algún
problema de orden? ¿Cómo lo reescribirías?

<details>
<summary>Ver respuesta</summary>

Entre el `dispose` y el siguiente frame, el scope sigue montado con el adaptador del controlador liberado. Si en ese
intervalo se produce una lectura, verás el aviso; y una escritura en el controlador antiguo lanzaría un error. Lo seguro
es crear el nuevo, entregarlo con `setState`, y liberar el anterior **después** de que el frame lo haya sustituido, por
ejemplo con `WidgetsBinding.instance.addPostFrameCallback`. A menudo basta con reutilizar el mismo controlador llamando
a `setTheme`, lo que evita el problema.

</details>

## 6. Desmontar un scope sin liberar lo prestado

Cerrar una vista previa puede significar dos cosas muy distintas, y el código debe reflejar cuál quieres. Aquí, `Taller`
es el propietario y un `bool` decide si se muestra la vista previa.

**Antes de mirar los `expect`**, predice qué tema se muestra al volver a abrirla:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

class Taller extends StatefulWidget {
  const Taller({super.key});

  @override
  State<Taller> createState() => TallerState();
}

class TallerState extends State<Taller> {
  late final DaisyThemeController controller;
  bool abierta = true;

  @override
  void initState() {
    super.initState();
    controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void alternar() => setState(() => abierta = !abierta);

  @override
  Widget build(BuildContext context) {
    if (!abierta) {
      return const Text('Cerrada');
    }
    return DaisyThemeScope(
      controller: controller,
      child: Builder(builder: (context) => Text(context.daisyTheme.name)),
    );
  }
}

Widget pantalla(Widget hijo) =>
    Directionality(textDirection: TextDirection.ltr, child: hijo);

void main() {
  testWidgets('quién conserva el tema al cerrar', (tester) async {
    await tester.pumpWidget(pantalla(const Taller()));
    final taller = tester.state<TallerState>(find.byType(Taller));
    final controller = taller.controller;

    controller.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);

    taller.alternar();
    await tester.pump();
    expect(find.text('Cerrada'), findsOneWidget);

    controller.setTheme(DaisyThemes.light);
    expect(controller.theme.value.name, 'Light');

    taller.alternar();
    await tester.pump();
    expect(find.text('Light'), findsOneWidget);

    await tester.pumpWidget(pantalla(const SizedBox.shrink()));
    expect(
      () => controller.setTheme(DaisyThemes.dark),
      throwsA(isA<SignalsWriteAfterDisposeError>()),
    );
  });
}
```

Paso a paso:

1. **Cerrar la vista previa** retira el scope: su elemento quita el listener (unidad 22). El controlador no se libera,
   porque es de `Taller`, y su señal conserva el tema.
2. **Cambiar con el scope cerrado** funciona. Es solo una señal, sin observadores. La unidad 13 ya lo comprobó en
   `Unmounting a scope does not dispose its borrowed controller`.
3. **Abrir de nuevo** crea un scope nuevo, que lee el valor actual. El tema `Light` no estaba en el scope, sino en el
   controlador.
4. **Retirar `Taller`** sí termina con el recurso: su `State` recibe `dispose`, y el controlador deja de aceptar
   escrituras.

La duración del tema coincide con la de su propietario, no con la del scope. Si se quiere que el tema se reinicie al
cerrar, el controlador debería pertenecer a la vista previa; si se quiere que perdure, debe estar más arriba. Es la
misma pregunta de la unidad 19: ¿cuánto debe durar?

### Practica 6

¿Qué responsabilidad tiene cada uno, en este apartado? (a) El elemento de `DaisyThemeScope` al desmontarse. (b)
`TallerState.dispose`. (c) El `Builder` consumidor al desmontarse.

<details>
<summary>Ver respuesta</summary>

(a) Retirar su listener del adaptador. (b) Liberar el controlador que creó. (c) Darse de baja como dependiente, algo que
hace Flutter al retirar su elemento (unidad 21). Ninguno de ellos libera algo que no le pertenece.

</details>

## 7. Añadir un scope cambia el árbol

Hay una consecuencia que conviene conocer. Si una condición **añade o quita un scope** alrededor de un widget, cambia el
tipo de widget en esa posición. Por la regla de la unidad 18, esto retira el elemento y su `State`, también los de todo
lo que tenga debajo.

Compara dos formas de cambiar a un tema propio. **Antes de mirar los `expect`**, predice qué le ocurre al contador del
`State` de `Formulario` en cada una:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class Formulario extends StatefulWidget {
  const Formulario({super.key});

  @override
  State<Formulario> createState() => FormularioState();
}

class FormularioState extends State<Formulario> {
  int borradores = 0;

  void sumar() => setState(() => borradores++);

  @override
  Widget build(BuildContext context) {
    return Text('${context.daisyTheme.name}: $borradores');
  }
}

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('envolver con otro scope retira el State', (tester) async {
    final propio = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(propio.dispose);

    Widget arbol({required bool usarPropio}) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        child: usarPropio
            ? DaisyThemeScope(controller: propio, child: const Formulario())
            : const Formulario(),
      ),
    );

    await tester.pumpWidget(arbol(usarPropio: false));
    tester.state<FormularioState>(find.byType(Formulario)).sumar();
    await tester.pump();
    expect(find.text('Light: 1'), findsOneWidget);

    await tester.pumpWidget(arbol(usarPropio: true));
    expect(find.text('Dark: 0'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('cambiar la fuente del mismo scope lo conserva', (tester) async {
    final propio = DaisyThemeController(initialTheme: DaisyThemes.dark);
    addTearDown(propio.dispose);

    Widget arbol({required bool usarPropio}) => Directionality(
      textDirection: TextDirection.ltr,
      child: DaisyThemeScope(
        controller: usarPropio ? propio : null,
        child: const Formulario(),
      ),
    );

    await tester.pumpWidget(arbol(usarPropio: false));
    tester.state<FormularioState>(find.byType(Formulario)).sumar();
    await tester.pump();
    expect(find.text('Light: 1'), findsOneWidget);

    await tester.pumpWidget(arbol(usarPropio: true));
    expect(find.text('Dark: 1'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}
```

En la primera versión, el hijo del scope exterior pasa de ser un `Formulario` a un `DaisyThemeScope`. Es otro tipo: se
retira el elemento y el `State` de `Formulario`, y se pierde su contador (`Dark: 0`). El tema es correcto, pero se ha
perdido un dato sin que lo pidiéramos.

En la segunda, el scope siempre está ahí. La expresión `controller: usarPropio ? propio : null` aprovecha las dos ramas
de su constructor (unidad 23): con `null` usa el servicio, y con `propio` usa ese controlador. Es el caso de sustitución
del apartado 5: el elemento permanece, y `Formulario` conserva su `State` (`Dark: 1`). Eso es lo que explica que
`controller` sea un parámetro opcional y no dos clases distintas.

### Practica 7

Tenemos `if (mostrarPreview) DaisyThemeScope(controller: c, child: const Lector()) else const Lector()`. El `Lector` es
un `StatelessWidget`. ¿Importa aquí esta pérdida? ¿Qué pasaría con un `TextField` en lugar de `Lector`?

<details>
<summary>Ver respuesta</summary>

Con un `StatelessWidget`, no se pierde nada: se vuelve a construir y lee el tema actual. Solo cuesta trabajo. Con un
`TextField`, su `State` se perdería, y con él el texto escrito, si no se guarda en un controlador externo, y el foco.
Para esos casos, conviene mantener el scope y cambiar su `controller`.

</details>

## 8. El ejemplo anterior completo

Volvamos a la versión del ejemplo que estudiamos en las unidades 13, 14 y 17. Esta prueba la reproduce a partir de
`git show 41fe41f~1:example/lib/main.dart`, con la única diferencia de los imports, ya que `material_ui` no es una
dependencia del paquete raíz. Tiene un tema global con su botón y una vista previa con el suyo. Ya sabes explicar cada
línea.

**Antes de mirar los `expect`**, predice los dos nombres después de cada pulsación:

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(child: const MaterialApp(home: _ThemeExample()));
  }
}

class _ThemeExample extends StatelessWidget {
  const _ThemeExample();

  @override
  Widget build(BuildContext context) {
    final theme = context.daisyTheme;

    return Scaffold(
      backgroundColor: theme.colors.base.base,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              theme.name,
              style: TextStyle(fontSize: 24, color: theme.colors.base.content),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => DaisyThemeService.setTheme(
                theme.id == DaisyThemes.light.id
                    ? DaisyThemes.dark
                    : DaisyThemes.light,
              ),
              child: const Text('Switch theme'),
            ),
            const SizedBox(height: 32),
            const _ThemePreview(),
          ],
        ),
      ),
    );
  }
}

class _ThemePreview extends StatefulWidget {
  const _ThemePreview();

  @override
  State<_ThemePreview> createState() => _ThemePreviewState();
}

class _ThemePreviewState extends State<_ThemePreview> {
  late final DaisyThemeController _controller;

  @override
  void initState() {
    super.initState();
    _controller = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DaisyThemeScope(
      controller: _controller,
      child: Builder(
        builder: (context) {
          final theme = context.daisyTheme;

          return Container(
            padding: const EdgeInsets.all(24),
            color: theme.colors.base.base,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Preview: ${theme.name}',
                  style: TextStyle(color: theme.colors.base.content),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.setTheme(
                    theme.id == DaisyThemes.dark.id
                        ? DaisyThemes.cupcake
                        : DaisyThemes.dark,
                  ),
                  child: const Text('Switch preview theme'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('los dos temas por separado', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Preview: Cupcake'), findsOneWidget);

    await tester.tap(find.text('Switch theme'));
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Preview: Cupcake'), findsOneWidget);

    await tester.tap(find.text('Switch preview theme'));
    await tester.pump();
    expect(find.text('Dark'), findsOneWidget);
    expect(find.text('Preview: Dark'), findsOneWidget);

    await tester.tap(find.text('Switch theme'));
    await tester.pump();
    expect(find.text('Light'), findsOneWidget);
    expect(find.text('Preview: Dark'), findsOneWidget);
  });
}
```

Comprueba que puedes rellenar esta tabla sin mirarla. Es el resumen de todo el Bloque 5:

| Escenario                            | Consumidores que se actualizan        | Quién libera                  |
|--------------------------------------|---------------------------------------|-------------------------------|
| `DaisyThemeService.setTheme`         | Dependientes del scope global         | Nadie: dura todo el programa  |
| `_controller.setTheme`               | Dependientes del scope de la vista    | `_ThemePreviewState`          |
| Mismo controlador en dos scopes      | Dependientes de los dos scopes        | Su único propietario          |
| Se sustituye el controlador          | Dependientes de ese scope             | El propietario de cada uno    |
| Se desmonta un scope                 | Ninguno: solo se retiran las escuchas | Nadie por ello                |
| Se desmonta el propietario           | Ninguno                               | El propietario, en `dispose`  |

Si comparas con el [ejemplo actual](../../../example/lib/main.dart), verás que ya no hay vista previa ni botones de
tema. Solo tiene el scope global, leído en `_ButtonContent` y en `_DaisyButtonState`. El mecanismo es el mismo, y en
cuanto vuelvas a añadir un scope anidado tendrás este comportamiento.

### Practica 8

En esta prueba, ¿por qué el `Container` de la vista previa no cambia de color al pulsar `Switch theme`? ¿Qué cambiaría
en la aplicación si `_ThemePreview` recibiera el controlador global desde `DaisyThemeService`, si eso fuera posible?

<details>
<summary>Ver respuesta</summary>

Porque su `Builder` lee el scope más cercano, que tiene otro controlador. Su color depende de ese tema, que no ha
cambiado. Además, `const _ThemePreview()` evita que el `build` de la pantalla la reconstruya. Si compartiera el
controlador global, los dos temas serían siempre el mismo, los dos botones cambiarían ambos textos y la vista previa no
tendría sentido. Por eso, el servicio no expone su controlador (unidad 17).

</details>

## Ejercicio final: un taller con tres vistas

Escribe una prueba que reúna todo el Bloque 5. `Taller` es un `StatefulWidget` que **posee** dos controladores,
`compartido` y `solo`, y se muestra debajo de un scope global, que usa el servicio. Tiene:

- Un `Lector('app')`, fuera de cualquier scope propio.
- Dos `DaisyThemeScope` con `compartido`, cada uno con su lector: `Lector('a')` y `Lector('b')`.
- Un `DaisyThemeScope` con `solo` y su `Lector('c')`.
- Un método para quitar el lector `b` y su scope, y otro para sustituir el `solo` de `c` por un tercer controlador
  `reserva`, que el propio `Taller` también crea.

Los lectores son `const` y cuentan sus construcciones. Predice los cuatro textos y los contadores tras cada paso:

1. Montar.
2. Cambiar el servicio.
3. Cambiar `compartido`.
4. Cambiar `solo`.
5. Sustituir `solo` por `reserva` y luego cambiar `solo`. Después, cambiar `reserva`.
6. Quitar `b` y cambiar `compartido`.
7. Retirar `Taller`. Comprueba que escribir en cualquiera de sus tres controladores lanza un error, y que el servicio
   sigue funcionando.

Responde además: ¿por qué se reconstruye `c` en el paso 5 si el tema que muestra podría ser el mismo? ¿Qué falla si
`Taller` no libera `reserva`? ¿Qué pasaría con `a` si `compartido` se liberara en el paso 6?

<details>
<summary>Ver una posible solución</summary>

```dart
import 'package:daisy_ui/daisy_ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';

final builds = <String, int>{};

class Lector extends StatelessWidget {
  const Lector(this.etiqueta, {super.key});

  final String etiqueta;

  @override
  Widget build(BuildContext context) {
    builds[etiqueta] = (builds[etiqueta] ?? 0) + 1;
    return Text('$etiqueta: ${context.daisyTheme.name}');
  }
}

class Taller extends StatefulWidget {
  const Taller({super.key});

  @override
  State<Taller> createState() => TallerState();
}

class TallerState extends State<Taller> {
  late final DaisyThemeController compartido;
  late final DaisyThemeController solo;
  late final DaisyThemeController reserva;
  bool mostrarB = true;
  bool usarReserva = false;

  @override
  void initState() {
    super.initState();
    compartido = DaisyThemeController(initialTheme: DaisyThemes.cupcake);
    solo = DaisyThemeController(initialTheme: DaisyThemes.dark);
    reserva = DaisyThemeController();
  }

  @override
  void dispose() {
    compartido.dispose();
    solo.dispose();
    reserva.dispose();
    super.dispose();
  }

  void quitarB() => setState(() => mostrarB = false);

  void pasarAReserva() => setState(() => usarReserva = true);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Lector('app'),
        DaisyThemeScope(controller: compartido, child: const Lector('a')),
        if (mostrarB)
          DaisyThemeScope(controller: compartido, child: const Lector('b')),
        DaisyThemeScope(
          controller: usarReserva ? reserva : solo,
          child: const Lector('c'),
        ),
      ],
    );
  }
}

void main() {
  setUp(() => DaisyThemeService.setTheme(DaisyThemes.light));
  tearDown(() => DaisyThemeService.setTheme(DaisyThemes.light));

  testWidgets('un taller con tres vistas', (tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: DaisyThemeScope(child: const Taller()),
      ),
    );
    final taller = tester.state<TallerState>(find.byType(Taller));
    final compartido = taller.compartido;
    final solo = taller.solo;
    final reserva = taller.reserva;
    expect(find.text('app: Light'), findsOneWidget);
    expect(find.text('a: Cupcake'), findsOneWidget);
    expect(find.text('b: Cupcake'), findsOneWidget);
    expect(find.text('c: Dark'), findsOneWidget);
    expect(builds, {'app': 1, 'a': 1, 'b': 1, 'c': 1});

    DaisyThemeService.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('app: Dark'), findsOneWidget);
    expect(builds, {'app': 2, 'a': 1, 'b': 1, 'c': 1});

    compartido.setTheme(DaisyThemes.light);
    await tester.pump();
    expect(find.text('a: Light'), findsOneWidget);
    expect(find.text('b: Light'), findsOneWidget);
    expect(builds, {'app': 2, 'a': 2, 'b': 2, 'c': 1});

    solo.setTheme(DaisyThemes.cupcake);
    await tester.pump();
    expect(find.text('c: Cupcake'), findsOneWidget);
    expect(builds, {'app': 2, 'a': 2, 'b': 2, 'c': 2});

    taller.pasarAReserva();
    await tester.pump();
    expect(find.text('c: Light'), findsOneWidget);
    expect(builds, {'app': 2, 'a': 2, 'b': 2, 'c': 3});

    solo.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(builds['c'], 3);

    reserva.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('c: Dark'), findsOneWidget);
    expect(builds['c'], 4);

    taller.quitarB();
    await tester.pump();
    compartido.setTheme(DaisyThemes.dark);
    await tester.pump();
    expect(find.text('a: Dark'), findsOneWidget);
    expect(find.textContaining('b:'), findsNothing);
    expect(builds['a'], 3);
    expect(builds['b'], 2);

    await tester.pumpWidget(const SizedBox.shrink());
    for (final controller in [compartido, solo, reserva]) {
      expect(
        () => controller.setTheme(DaisyThemes.light),
        throwsA(isA<SignalsWriteAfterDisposeError>()),
      );
    }

    DaisyThemeService.setTheme(DaisyThemes.cupcake);
    expect(DaisyThemeService.theme.value.name, 'Cupcake');
  });
}
```

Cada controlador tiene una cadena independiente: servicio → `app`; `compartido` → `a` y `b`; `solo` → `c`. Como los
lectores son `const` y `Taller` no se reconstruye con esos avisos, solo se construyen los dependientes.

En el paso 5, `c` se reconstruye porque ha cambiado su fuente: `updateShouldNotify` compara notifiers, no temas (unidad
22). Cambiar `solo` ya no tiene efecto; cambiar `reserva` sí. `setState` reconstruye `Taller`, pero los lectores `const`
no se tocan. El de `c` solo se debe a la nueva dependencia del scope.

En el paso 6, `if (mostrarB)` es una **colección condicional**: sin `b`, la lista de hijos cambia. El elemento del
`DaisyThemeScope` que queda en esa posición es el de `c`. Flutter lo reconcilia por tipo y posición: aquí hay tres
scopes con hijos distintos, pero como `a` queda igual y el tercer scope del árbol anterior pasa a ser el segundo, sus
elementos se reutilizan con cuidado. En este árbol no se pierde ningún dato, porque los lectores no tienen estado. Si lo
tuvieran, conviene añadir una `key` a cada scope. El tema de `a` cambia a `Dark`, y `b` no lo recibe porque se ha
retirado.

Retirar `Taller` llama a su `dispose`, y sus tres controladores dejan de aceptar escrituras. Si no liberara `reserva`,
su señal quedaría sin liberar: la prueba no lo detectaría, y por eso importa razonarlo. El servicio sigue funcionando,
ya que nadie puede liberarlo.

Si `compartido` se liberara en el paso 6, `a` seguiría mostrando el último valor, con un aviso de lectura, y la
siguiente escritura lanzaría un error, como mostró el apartado 5. Por eso se libera solo cuando desaparecen todos los
que lo tienen prestado.

</details>

## Comprueba si puedes avanzar

Intenta responder sin mirar; vuelve al apartado indicado si necesitas repasar.

1. ¿Qué es el alcance de un scope? ¿Qué ocurre si dos se solapan? **Apartado 1.**
2. ¿Por qué un cambio en el scope exterior no afecta a los consumidores del interior? **Apartado 2.**
3. ¿Qué garantizan los controladores, y qué depende de `const`? **Apartado 3.**
4. Si dos scopes reciben la misma instancia, ¿cuántos listeners, elementos y señales hay? **Apartado 4.**
5. ¿Qué le ocurre al lector al sustituir el controlador? ¿Con qué objeto es su dependencia? **Apartado 5.**
6. ¿Qué pasa si se libera un controlador con el scope aún montado? **Apartado 5.**
7. ¿Qué conserva un controlador prestado al desmontar su scope? ¿Quién lo libera? **Apartado 6.**
8. ¿Por qué añadir un scope alrededor de un widget puede perder su `State`? ¿Cómo se evita? **Apartado 7.**
9. Rellena la tabla de escenarios y responsables. **Apartado 8.**

Puedes dar la unidad por comprendida cuando resuelvas el ejercicio final y predigas qué consumidores se actualizan en
cada escenario y quién conserva la responsabilidad de liberar los controladores. Con esto termina el Bloque 5: ya puedes
seguir un cambio de tema desde la pulsación hasta el `build`. El Bloque 6 empieza en la unidad 26, que estudia los datos
que se observan: tokens, colores y tamaños.

## Para consultar si necesitas reforzar

- [`InheritedNotifier`](https://api.flutter.dev/flutter/widgets/InheritedNotifier-class.html): sustitución y escucha del
  notifier.
- [`Widget.canUpdate`](https://api.flutter.dev/flutter/widgets/Widget/canUpdate.html): por qué se reutiliza o se retira
  un elemento.
- [Claves en Flutter](https://api.flutter.dev/flutter/foundation/Key-class.html): cómo identificar hijos cuando cambia
  la lista.
- [Scope](../../../lib/themes/application/daisy_theme_scope.dart),
  [controlador](../../../lib/themes/application/daisy_theme_controller.dart),
  [servicio](../../../lib/themes/application/daisy_theme_service.dart) y
  [pruebas del scope](../../../test/themes/daisy_theme_scope_test.dart): comportamiento actual de DaisyUI.
